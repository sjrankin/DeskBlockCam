//
//  ImageDelta.metal
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void ImageDelta(texture2d<float, access::read> Image1 [[texture(0)]],
                       texture2d<float, access::read> Image2 [[texture(1)]],
                       texture2d<float, access::write> Result [[texture(2)]],
                       uint2 gid [[thread_position_in_grid]])
{
    float4 Pixel1 = Image1.read(gid);
    float4 Pixel2 = Image2.read(gid);
    float Red = abs(Pixel1.r - Pixel2.r);
    float Green = abs(Pixel1.g - Pixel2.g);
    float Blue = abs(Pixel1.b - Pixel2.b);
    float Alpha = 1.0;
    float4 DeltaColor = float4(Red, Green, Blue, Alpha);
    Result.write(DeltaColor, gid);
}

