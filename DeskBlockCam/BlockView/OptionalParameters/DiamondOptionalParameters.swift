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
    
    init(WithOrientation: Orientations, Size: Distances)
    {
        super.init(WithShape: .Diamonds)
        _Orientation = WithOrientation
        _Size = Size
    }
    
    private var _Orientation: Orientations = .Horizontal
    public var Orientation: Orientations
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
    
    private var _Size: Distances = .Medium
    public var Size: Distances
    {
        get
        {
            return _Size
        }
        set
        {
            _Size = newValue
        }
    }
}

