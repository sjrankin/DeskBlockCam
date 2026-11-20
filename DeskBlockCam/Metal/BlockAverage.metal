//
//  BlockAverage.metal
//  DeskBlockCam
//
//  Created by Stuart Rankin on 11/20/26.
//  Copyright © 2026 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/// Layout must match `MetalPixellator.Parameters` in Swift.
struct BlockAverageParameters
{
    /// Number of blocks across.
    uint HBlocks;
    /// Number of blocks down.
    uint VBlocks;
    /// Width of one block in source pixels (not necessarily a whole number).
    float CellWidth;
    /// Height of one block in source pixels.
    float CellHeight;
};

/// Averages the source pixels that fall inside each block. One thread handles one block, so this replaces resizing
/// the image, pixellating it and then sampling the middle of every block with a single pass over the source.
///
/// The output has one float4 (red, green, blue, alpha) per block, row by row from the top of the image.
kernel void BlockAverage(texture2d<float, access::read> Source [[texture(0)]],
                         device float4 *Output [[buffer(0)]],
                         constant BlockAverageParameters &Parameters [[buffer(1)]],
                         uint2 Block [[thread_position_in_grid]])
{
    if (Block.x >= Parameters.HBlocks || Block.y >= Parameters.VBlocks)
    {
        return;
    }
    uint Width = Source.get_width();
    uint Height = Source.get_height();
    uint X0 = min(uint(floor(float(Block.x) * Parameters.CellWidth)), Width - 1);
    uint Y0 = min(uint(floor(float(Block.y) * Parameters.CellHeight)), Height - 1);
    uint X1 = min(max(uint(floor(float(Block.x + 1) * Parameters.CellWidth)), X0 + 1), Width);
    uint Y1 = min(max(uint(floor(float(Block.y + 1) * Parameters.CellHeight)), Y0 + 1), Height);
    // Very large blocks are sampled on a grid of at most about 32 x 32 pixels, which is plenty for an average.
    uint StepX = max(1u, (X1 - X0) / 32u);
    uint StepY = max(1u, (Y1 - Y0) / 32u);
    float4 Sum = float4(0.0);
    float Count = 0.0;
    for (uint Y = Y0; Y < Y1; Y += StepY)
    {
        for (uint X = X0; X < X1; X += StepX)
        {
            Sum += Source.read(uint2(X, Y));
            Count += 1.0;
        }
    }
    Output[Block.y * Parameters.HBlocks + Block.x] = Sum / max(Count, 1.0);
}
