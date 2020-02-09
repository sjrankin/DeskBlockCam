//
//  Enums.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

enum VerticalExaggerations: String, CaseIterable
{
    case None = "None"
    case Small = "Small"
    case Medium = "Medium"
    case Large = "Large"
}

enum HeightDeterminations: String, CaseIterable
{
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Black = "Black"
    case YUV_Y = "YUV Y"
    case YUV_U = "YUV U"
    case YUV_V = "YUV V"
    case Greatest = "Greatest Channel"
    case Least = "Least Channel"
}
