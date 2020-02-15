//
//  RingOptionalParameters.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/15/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RingOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .Rings)
        self.Read()
    }
    
    init(WithOrientation: RingOrientations, DonutHole: DonutHoleSizes)
    {
        super.init(WithShape: .Rings)
        _Orientation = WithOrientation
        _DonutHoleSize = DonutHole
    }
    
    private var _Orientation: RingOrientations = .Flat
    public var Orientation: RingOrientations
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
    
    private var _DonutHoleSize: DonutHoleSizes = .Medium
    public var DonutHoleSize: DonutHoleSizes
    {
        get
        {
            return _DonutHoleSize
        }
        set
        {
            _DonutHoleSize = newValue
        }
    }
    
    override public func Read()
    {
        _Orientation = Settings.GetEnum(ForKey: .RingOrientation, EnumType: RingOrientations.self, Default: RingOrientations.Flat)
        _DonutHoleSize = Settings.GetEnum(ForKey: .DonutHoleSize, EnumType: DonutHoleSizes.self, Default: DonutHoleSizes.Medium)
    }
    
    override public func Write()
    {
        Settings.SetEnum(Orientation, EnumType: RingOrientations.self, ForKey: .RingOrientation)
        Settings.SetEnum(DonutHoleSize, EnumType: DonutHoleSizes.self, ForKey: .DonutHoleSize)
    }
}

