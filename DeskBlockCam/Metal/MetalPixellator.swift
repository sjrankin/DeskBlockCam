//
//  MetalPixellator.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 11/20/26.
//  Copyright © 2026 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import Metal
import ImageIO

/// Reduces a still image to one color per block using a Metal compute kernel (`BlockAverage` in
/// `BlockAverage.metal`).
///
/// The old route resized the image with `lockFocus`, encoded and decoded a TIFF, ran `CIPixellate` and then sampled the
/// middle of every block with `NSBitmapImageRep.colorAt`, all on the CPU. Here the image is drawn once into a bitmap,
/// handed to the GPU as a texture, and each block's color is the average of the source pixels it covers.
final class MetalPixellator
{
    /// The shared instance, or nil if this Mac has no usable Metal device.
    static let Shared: MetalPixellator? = MetalPixellator()
    
    /// The result of reducing an image.
    struct Reduction
    {
        /// Number of blocks across.
        let HBlocks: Int
        /// Number of blocks down.
        let VBlocks: Int
        /// Block colors (red, green, blue, alpha; sRGB), row by row from the *top* of the image.
        let Values: [SIMD4<Float>]
    }
    
    /// Mirrors `BlockAverageParameters` in the Metal source.
    private struct Parameters
    {
        var HBlocks: UInt32
        var VBlocks: UInt32
        var CellWidth: Float
        var CellHeight: Float
    }
    
    private let Device: MTLDevice
    private let Queue: MTLCommandQueue
    private let Pipeline: MTLComputePipelineState
    /// Serializes use of the queue and pipeline.
    private let Lock = NSLock()
    
    private init?()
    {
        guard let Device = MTLCreateSystemDefaultDevice(),
              let Queue = Device.makeCommandQueue(),
              let Library = Device.makeDefaultLibrary(),
              let Function = Library.makeFunction(name: "BlockAverage"),
              let Pipeline = try? Device.makeComputePipelineState(function: Function) else
        {
            return nil
        }
        self.Device = Device
        self.Queue = Queue
        self.Pipeline = Pipeline
    }
    
    /// Reduce an image to one color per `BlockSize` x `BlockSize` block of the image after it is scaled. An image whose
    /// longest side is no more than `Longest` is not scaled; a larger one is scaled so its longest side is
    /// `Longest * ResizedScale`. The old resize-then-pixellate route drew the scaled image with `lockFocus`, which renders
    /// at the screen's backing scale (2 on a Retina display), so passing that scale as `ResizedScale` gives the same
    /// block grid as before.
    /// - Parameter Image: The image to reduce.
    /// - Parameter Longest: The longest side, in points, above which an image is scaled down.
    /// - Parameter ResizedScale: Pixels per point of the scaled image.
    /// - Parameter BlockSize: The side of a block in pixels of the scaled image.
    /// - Returns: The block colors, or nil if the image could not be read or the GPU work failed.
    func Reduce(_ Image: NSImage, Longest: CGFloat, ResizedScale: CGFloat, BlockSize: Int) -> Reduction?
    {
        Lock.lock()
        defer { Lock.unlock() }
        // The scaled size the old code worked with (it only ever scaled down).
        let LogicalWidth = Image.size.width
        let LogicalHeight = Image.size.height
        let LongestSide = max(LogicalWidth, LogicalHeight)
        guard LongestSide > 0 else
        {
            return nil
        }
        let Ratio = LongestSide > Longest ? Longest * ResizedScale / LongestSide : 1.0
        let ScaledWidth = LogicalWidth * Ratio
        let ScaledHeight = LogicalHeight * Ratio
        let HBlocks = Int(ScaledWidth / CGFloat(BlockSize))
        let VBlocks = Int(ScaledHeight / CGFloat(BlockSize))
        guard HBlocks >= 1, VBlocks >= 1 else
        {
            return nil
        }
        // Draw the image at its full pixel size, converting to sRGB. Drawing through NSImage keeps any orientation.
        var PixelWidth = Int(LogicalWidth.rounded())
        var PixelHeight = Int(LogicalHeight.rounded())
        if let Rep = Image.representations.max(by: {$0.pixelsWide < $1.pixelsWide}),
           Rep.pixelsWide > 0, Rep.pixelsHigh > 0,
           abs(CGFloat(Rep.pixelsWide) / CGFloat(Rep.pixelsHigh) - LogicalWidth / LogicalHeight) < 0.01
        {
            PixelWidth = Rep.pixelsWide
            PixelHeight = Rep.pixelsHigh
        }
        guard let Space = CGColorSpace(name: CGColorSpace.sRGB),
              let Context = CGContext(data: nil, width: PixelWidth, height: PixelHeight, bitsPerComponent: 8,
                                      bytesPerRow: 0, space: Space,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
              let Pixels = Context.data else
        {
            return nil
        }
        let Graphics = NSGraphicsContext(cgContext: Context, flipped: false)
        Graphics.imageInterpolation = .none
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = Graphics
        Image.draw(in: NSRect(x: 0, y: 0, width: PixelWidth, height: PixelHeight),
                   from: NSRect(x: 0, y: 0, width: LogicalWidth, height: LogicalHeight),
                   operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        return RunKernel(Pixels: Pixels, PixelWidth: PixelWidth, PixelHeight: PixelHeight,
                         BytesPerRow: Context.bytesPerRow, HBlocks: HBlocks, VBlocks: VBlocks,
                         CellWidth: Float(CGFloat(PixelWidth) / ScaledWidth * CGFloat(BlockSize)),
                         CellHeight: Float(CGFloat(PixelHeight) / ScaledHeight * CGFloat(BlockSize)))
    }
    
    /// Reduce an image file the same way as `Reduce(_:Longest:ResizedScale:BlockSize:)`, but decode it with ImageIO
    /// instead of `NSImage`.
    ///
    /// Drawing an `NSImage` at full size is slow for some files. Phone photos in the Ultra HDR format (an ordinary JPEG
    /// plus an HDR "gain map") take seconds to draw because the HDR is processed on the CPU. ImageIO can decode just the
    /// standard image, already scaled down, in a few hundredths of a second, which is all the block averages need.
    /// - Parameter URL: The image file.
    /// - Parameter Longest: The longest side, in pixels, above which an image is scaled down.
    /// - Parameter ResizedScale: Multiplier applied to `Longest` for the scaled size (see the other `Reduce`).
    /// - Parameter BlockSize: The side of a block in pixels of the scaled image.
    /// - Returns: The block colors, or nil if the file could not be decoded or the GPU work failed.
    func Reduce(URL: URL, Longest: CGFloat, ResizedScale: CGFloat, BlockSize: Int) -> Reduction?
    {
        Lock.lock()
        defer { Lock.unlock() }
        guard let Source = CGImageSourceCreateWithURL(URL as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              let Properties = CGImageSourceCopyPropertiesAtIndex(Source, 0, nil) as? [CFString: Any],
              let FileWidth = Properties[kCGImagePropertyPixelWidth] as? Int,
              let FileHeight = Properties[kCGImagePropertyPixelHeight] as? Int else
        {
            return nil
        }
        // The side to scale to: images that are not larger than `Longest` keep their size.
        let LongestSide = CGFloat(max(FileWidth, FileHeight))
        let Target = LongestSide > Longest ? Longest * ResizedScale : LongestSide
        var Options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                        kCGImageSourceThumbnailMaxPixelSize: Int(Target.rounded()),
                                        kCGImageSourceCreateThumbnailWithTransform: true,
                                        kCGImageSourceShouldCacheImmediately: true]
        if #available(macOS 14.0, *)
        {
            // Decode only the standard (SDR) image; skip any HDR gain map.
            Options[kCGImageSourceDecodeRequest] = kCGImageSourceDecodeToSDR
        }
        guard let Scaled = CGImageSourceCreateThumbnailAtIndex(Source, 0, Options as CFDictionary) else
        {
            return nil
        }
        let PixelWidth = Scaled.width
        let PixelHeight = Scaled.height
        let HBlocks = PixelWidth / BlockSize
        let VBlocks = PixelHeight / BlockSize
        guard HBlocks >= 1, VBlocks >= 1,
              let Space = CGColorSpace(name: CGColorSpace.sRGB),
              let Context = CGContext(data: nil, width: PixelWidth, height: PixelHeight, bitsPerComponent: 8,
                                      bytesPerRow: 0, space: Space,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
              let Pixels = Context.data else
        {
            return nil
        }
        Context.interpolationQuality = .none
        Context.draw(Scaled, in: CGRect(x: 0, y: 0, width: PixelWidth, height: PixelHeight))
        return RunKernel(Pixels: Pixels, PixelWidth: PixelWidth, PixelHeight: PixelHeight,
                         BytesPerRow: Context.bytesPerRow, HBlocks: HBlocks, VBlocks: VBlocks,
                         CellWidth: Float(BlockSize), CellHeight: Float(BlockSize))
    }
    
    /// Uploads a BGRX bitmap as a texture and runs the `BlockAverage` kernel over it.
    /// - Note: The caller must hold `Lock`.
    private func RunKernel(Pixels: UnsafeMutableRawPointer, PixelWidth: Int, PixelHeight: Int, BytesPerRow: Int,
                           HBlocks: Int, VBlocks: Int, CellWidth: Float, CellHeight: Float) -> Reduction?
    {
        let Descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: PixelWidth,
                                                                  height: PixelHeight, mipmapped: false)
        Descriptor.usage = .shaderRead
        Descriptor.storageMode = .shared
        guard let Texture = Device.makeTexture(descriptor: Descriptor),
              let Output = Device.makeBuffer(length: HBlocks * VBlocks * MemoryLayout<SIMD4<Float>>.stride,
                                             options: .storageModeShared),
              let Commands = Queue.makeCommandBuffer(),
              let Encoder = Commands.makeComputeCommandEncoder() else
        {
            return nil
        }
        Texture.replace(region: MTLRegionMake2D(0, 0, PixelWidth, PixelHeight), mipmapLevel: 0, withBytes: Pixels,
                        bytesPerRow: BytesPerRow)
        var Settings = Parameters(HBlocks: UInt32(HBlocks), VBlocks: UInt32(VBlocks),
                                  CellWidth: CellWidth, CellHeight: CellHeight)
        Encoder.setComputePipelineState(Pipeline)
        Encoder.setTexture(Texture, index: 0)
        Encoder.setBuffer(Output, offset: 0, index: 0)
        Encoder.setBytes(&Settings, length: MemoryLayout<Parameters>.stride, index: 1)
        let Width = Pipeline.threadExecutionWidth
        let Height = max(1, Pipeline.maxTotalThreadsPerThreadgroup / Width)
        Encoder.dispatchThreads(MTLSize(width: HBlocks, height: VBlocks, depth: 1),
                                threadsPerThreadgroup: MTLSize(width: Width, height: Height, depth: 1))
        Encoder.endEncoding()
        Commands.commit()
        Commands.waitUntilCompleted()
        if Commands.status != .completed
        {
            return nil
        }
        let Raw = Output.contents().bindMemory(to: SIMD4<Float>.self, capacity: HBlocks * VBlocks)
        return Reduction(HBlocks: HBlocks, VBlocks: VBlocks,
                         Values: Array(UnsafeBufferPointer(start: Raw, count: HBlocks * VBlocks)))
    }
    
    /// Convert a reduction to colors in the order `BlockView.ParseImage` returns: rows from the *bottom* of the image,
    /// each row left to right.
    /// - Parameter Result: The reduction.
    /// - Returns: Colors in YX order.
    static func Colors(From Result: Reduction) -> [[NSColor]]
    {
        var Rows: [[NSColor]] = []
        Rows.reserveCapacity(Result.VBlocks)
        var Y = Result.VBlocks - 1
        while Y >= 0
        {
            var Row: [NSColor] = []
            Row.reserveCapacity(Result.HBlocks)
            var X = 0
            while X < Result.HBlocks
            {
                let V = Result.Values[Y * Result.HBlocks + X]
                Row.append(NSColor(srgbRed: CGFloat(V.x), green: CGFloat(V.y), blue: CGFloat(V.z), alpha: 1.0))
                X += 1
            }
            Rows.append(Row)
            Y -= 1
        }
        return Rows
    }
}
