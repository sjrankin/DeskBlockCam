//
//  ImageDelta.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//
#if false
import Foundation
import AppKit
import MetalKit
import CoreMedia

class ImageDelta
{
    init()
    {
        RenderInitialization()
    }
    
        private let MetalDevice = MTLCreateSystemDefaultDevice()
    var ImageDevice: MTLDevice? = nil
    var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.MetalDevice?.makeCommandQueue()
    }()
    
    func RenderInitialization()
    {
        ImageDevice = MTLCreateSystemDefaultDevice()
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "ImageDelta")
        do
        {
            ImageComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state for ImageDelta")
        }
    }
    
    func Render(Image1: NSImage, Image2: NSImage) -> NSImage?
    {
        let CgImage1 = Image1.cgImage(forProposedRect: nil, context: nil, hints: nil)
        let ImageWidth = Image1.size.width
        let ImageHeight = Image1.size.height
        var RawData1 = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight * 4))
        let RGBColorSpace = CGColorSpaceCreateDeviceRGB()
        let BitmapInfo1 = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let Context1 = CGContext(data: &RawData1,
                                width: Int(ImageWidth),
                                height: Int(ImageHeight),
                                bitsPerComponent: (CgImage1?.bitsPerComponent)!,
                                bytesPerRow: (CgImage1?.bytesPerRow)!,
                                space: RGBColorSpace,
                                bitmapInfo: BitmapInfo1.rawValue)
        Context1!.draw(CgImage1!, in: CGRect(x: 0, y: 0, width: ImageWidth, height: ImageHeight))
        let TextureDescriptor1 = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bc7_rgbaUnorm,
                                                                          width: Int(ImageWidth),
                                                                          height: Int(ImageHeight),
                                                                          mipmapped: true)
        guard let Texture1 = ImageDevice?.makeTexture(descriptor: TextureDescriptor1) else
        {
            print("Error creating texture for Image1.")
            return nil
        }
        let Region1 = MTLRegionMake2D(0, 0, Int(ImageWidth), Int(ImageHeight))
        Texture1.replace(region: Region1, mipmapLevel: 0, withBytes: &RawData1, bytesPerRow: Int((CgImage1?.bytesPerRow)!))
        
        let CgImage2 = Image2.cgImage(forProposedRect: nil, context: nil, hints: nil)
        var RawData2 = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight * 4))
        let BitmapInfo2 = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let Context = CGContext(data: &RawData2,
                                width: Int(ImageWidth),
                                height: Int(ImageHeight),
                                bitsPerComponent: (CgImage1?.bitsPerComponent)!,
                                bytesPerRow: (CgImage1?.bytesPerRow)!,
                                space: RGBColorSpace,
                                bitmapInfo: BitmapInfo2.rawValue)
        Context!.draw(CgImage2!, in: CGRect(x: 0, y: 0, width: ImageWidth, height: ImageHeight))
        let TextureDescriptor2 = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bc7_rgbaUnorm,
                                                                          width: Int(ImageWidth),
                                                                          height: Int(ImageHeight),
                                                                          mipmapped: true)
        guard let Texture2 = ImageDevice?.makeTexture(descriptor: TextureDescriptor2) else
        {
            print("Error creating texture for Image2.")
            return nil
        }
        let Region2 = MTLRegionMake2D(0, 0, Int(ImageWidth), Int(ImageHeight))
        Texture2.replace(region: Region2, mipmapLevel: 0, withBytes: &RawData2, bytesPerRow: Int((CgImage2?.bytesPerRow)!))
        
        let OutputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Texture1.pixelFormat,
                                                                               width: Texture1.width,
                                                                               height: Texture1.height,
                                                                               mipmapped: true)
        OutputTextureDescriptor.usage = MTLTextureUsage.shaderWrite
        let OutputTexture = ImageDevice?.makeTexture(descriptor: OutputTextureDescriptor)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(Texture1, index: 0)
        CommandEncoder?.setTexture(Texture2, index: 1)
        CommandEncoder?.setTexture(OutputTexture, index: 2)
        
        let ThreadGroupCount = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(Texture1.width / ThreadGroupCount.width,
                                       Texture1.height / ThreadGroupCount.height,
                                       1)
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        
        CommandEncoder!.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder!.endEncoding()
        CommandBuffer!.commit()
        CommandBuffer!.waitUntilCompleted()
        
        let ImageSize = CGSize(width: Texture1.width, height: Texture1.height)
        let ImageByteCount = Int(ImageSize.width * ImageSize.height * 4)
        let BytesPerRow = CgImage1?.bytesPerRow
        var ImageBytes = [UInt8](repeating: 0,count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, Int(ImageSize.width), Int(ImageSize.height))
        OutputTexture?.getBytes(&ImageBytes, bytesPerRow: BytesPerRow!, from: ORegion, mipmapLevel: 0)
        let SizeOfUInt8 = UInt8.SizeOf()
        let Provider = CGDataProvider(data: NSData(bytes: &ImageBytes, length: ImageBytes.count * SizeOfUInt8))
        let OBitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let RenderingIntent = CGColorRenderingIntent.defaultIntent
        let Result = CGImage(width: Int(ImageSize.width),
                             height: Int(ImageSize.height),
                             bitsPerComponent: (CgImage1?.bitsPerComponent)!,
                             bitsPerPixel: (CgImage1?.bitsPerPixel)!,
                             bytesPerRow: BytesPerRow!,
                             space: RGBColorSpace,
                             bitmapInfo: OBitmapInfo,
                             provider: Provider!,
                             decode: nil,
                             shouldInterpolate: false,
                             intent: RenderingIntent)
        let Final: NSImage = NSImage(cgImage: Result!, size: NSSize(width: ImageSize.width, height: ImageSize.height))
        return Final
    }
}

extension UInt8
{
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: UInt(0))
    }
}
#endif
