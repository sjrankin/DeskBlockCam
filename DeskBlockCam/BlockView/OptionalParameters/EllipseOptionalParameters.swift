//
//  EllipseOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class EllipseOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Ovals)
    }
    
    init(WithOrientation: EllipseOrientations)
    {
        super.init(WithShape: .Ovals)
        _Orientation = WithOrientation
    }
    
    private var _Orientation: EllipseOrientations = .HorizontalMedium
    public var Orientation: EllipseOrientations
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

enum EllipseOrientations: String, CaseIterable
{
    case HorizontalShort = "Horizontal Short"
    case HorizontalMedium = "Horizontal Medium"
    case HorizontalLong = "Horizontal Long"
    case VerticalShort = "Vertical Short"
    case VerticalMedium = "Vertical Medium"
    case VerticalLong = "Vertical Long"
}
