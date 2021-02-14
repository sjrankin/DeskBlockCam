//
//  PixelCounter.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreMedia
import CoreVideo
import MetalKit

class PixelCounter
{
    init()
    {
        RenderInitialization()
    }
    
    func RenderInitialization()
    {
        ImageDevice = MTLCreateSystemDefaultDevice()
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "PixelCounter")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            fatalError("Error creating pipeline for PixelCounter")
        }
    }
    
    private var ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
        {
            return self.ImageDevice?.makeCommandQueue()
        }()
    
    func ExtractPixels(In Image: CIImage, BlockWidth: Int, BlockHeight: Int) -> [NSColor]
    {
        let Rep = NSCIImageRep(ciImage: Image)
        let ConvertMe = NSImage(size: Rep.size)
        ConvertMe.addRepresentation(Rep)
        return ExtractPixels(In: ConvertMe, BlockWidth: BlockWidth, BlockHeight: BlockHeight)
    }
    
    func ExtractPixels(In Image: NSImage, BlockWidth: Int, BlockHeight: Int) -> [NSColor]
    {
        let CgImage = Image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let ImageWidth = Image.size.width
        let ImageHeight = Image.size.height

        var RawData = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight))
        let RGBColorSpace = CGColorSpaceCreateDeviceRGB()
        let BitmapInfo1 = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let Context1 = CGContext(data: &RawData,
                                 width: Int(ImageWidth),
                                 height: Int(ImageHeight),
                                 bitsPerComponent: (CgImage?.bitsPerComponent)!,
                                 bytesPerRow: (CgImage?.bytesPerRow)!,
                                 space: RGBColorSpace,
                                 bitmapInfo: BitmapInfo1.rawValue)
        Context1!.draw(CgImage!, in: CGRect(x: 0, y: 0, width: ImageWidth, height: ImageHeight))
        let TextureDescriptor1 = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bc7_rgbaUnorm,
                                                                          width: Int(ImageWidth),
                                                                          height: Int(ImageHeight),
                                                                          mipmapped: true)
        guard let Texture1 = ImageDevice?.makeTexture(descriptor: TextureDescriptor1) else
        {
            fatalError("Error creating texture for Image in \(#function)")
        }
        
        let HorizontalBlocks = Int(Int(Image.size.width) / BlockWidth)
        let BlockInfo = BlockInfoParameters(Width: simd.uint(BlockWidth),
                                            BlockWidth: simd.uint(HorizontalBlocks),
                                            Height: simd.uint(BlockHeight))
        let Buffers = [BlockInfo]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<BlockInfoParameters>.stride,
                                                  options: [])
        memcpy(ParameterBuffer?.contents(), Buffers, MemoryLayout<BlockInfoParameters>.stride)
        let ResultCount = (BlockWidth * BlockHeight)
        let BlockPixels = ImageDevice?.makeBuffer(length: MemoryLayout<simd_float4>.stride * ResultCount,
                                                  options: [])
        let Results = UnsafeBufferPointer<simd.float4>(start: UnsafePointer(BlockPixels!.contents().assumingMemoryBound(to: simd.float4.self)),
                                                       count: ResultCount)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(Texture1, index: 0)
        CommandEncoder?.label = "Pixel Counter"
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        CommandEncoder?.setBuffer(BlockPixels, offset: 0, index: 1)
        let ThreadGroupCount = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(Texture1.width / ThreadGroupCount.width,
                                       Texture1.height / ThreadGroupCount.height,
                                       1)
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        var BlockColors = [NSColor]()
        for RawColor in Results
        {
            BlockColors.append(NSColor.FromFloat4(RawColor))
        }
        return BlockColors
    }
}

extension NSColor
{
    public static func FromFloat4(_ Raw: simd_float4) -> NSColor
    {
        let NewColor = NSColor(calibratedRed: CGFloat(Raw.w),
                               green: CGFloat(Raw.x),
                               blue: CGFloat(Raw.y),
                               alpha: CGFloat(Raw.z))
        return NewColor
    }
}
