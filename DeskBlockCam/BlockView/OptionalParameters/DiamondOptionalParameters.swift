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
        self.Read()
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
    
    override public func Read()
    {
        _Orientation = Settings.GetEnum(ForKey: .DiamondOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
        _Size = Settings.GetEnum(ForKey: .DiamondLength, EnumType: Distances.self, Default: Distances.Medium)
    }
    
    override public func Write()
    {
        Settings.SetEnum(Orientation, EnumType: Orientations.self, ForKey: .DiamondOrientation)
        Settings.SetEnum(Size, EnumType: Distances.self, ForKey: .DiamondLength)
    }
}

