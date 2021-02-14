//
//  PixelCounter.metal
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct BlockInfoParameters
{
    uint Width;
    uint BlockWidth;
    uint Height;
};

kernel void PixelCounter(texture2d<float, access::read> InTexture [[texture(0)]],
                            constant BlockInfoParameters &BlockInfo [[buffer(0)]],
                            device float4 *Output [[buffer(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = BlockInfo.Width;
    uint Height = BlockInfo.Height;
    
    uint PixelX = (gid.x / Width) * Width;
    uint PixelY = (gid.y / Height) * Height;
    const uint2 PixelattedGrid = uint2(PixelX, PixelY);
    float4 ColorAtPixel = InTexture.read(PixelattedGrid);
    int Index = (PixelY + BlockInfo.BlockWidth) + PixelX;
    Output[Index] = ColorAtPixel;
}
