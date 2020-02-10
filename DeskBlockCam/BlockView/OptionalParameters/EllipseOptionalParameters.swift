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
        self.Read()
    }
    
    init(WithOrientation: Orientations, Size: Distances)
    {
        super.init(WithShape: .Ovals)
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
        _Orientation = Settings.GetEnum(ForKey: .OvalOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
        _Size = Settings.GetEnum(ForKey: .OvalLength, EnumType: Distances.self, Default: Distances.Medium)
    }
    
    override public func Write()
    {
        Settings.SetEnum(Orientation, EnumType: Orientations.self, ForKey: .OvalOrientation)
        Settings.SetEnum(Size, EnumType: Distances.self, ForKey: .OvalLength)
    }
}

