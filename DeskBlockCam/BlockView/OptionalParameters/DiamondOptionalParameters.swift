//
//  DiamondOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DiamondOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Diamonds)
    }
    
    init(WithOrientation: DiamondOrientations)
    {
        super.init(WithShape: .Diamonds)
        _Orientation = WithOrientation
    }
    
    private var _Orientation: DiamondOrientations = .HorizontalMedium
    public var Orientation: DiamondOrientations
    {
        get
        {
            return _Orientation
        }
        set
        {
            _Orientation = newValue
        }
    }
}

enum DiamondOrientations: String, CaseIterable
{
    case HorizontalShort = "Horizontal Short"
    case HorizontalMedium = "Horizontal Medium"
    case HorizontalLong = "Horizontal Long"
    case VerticalShort = "Vertical Short"
    case VerticalMedium = "Vertical Medium"
    case VerticalLong = "Vertical Long"
}
