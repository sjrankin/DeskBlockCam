//
//  RadiatingLinesOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class RadiatingLinesOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .RadiatingLines)
        self.Read()
    }
    
    init(LineCount: Int, Thickness: LineThicknesses)
    {
        super.init(WithShape: .RadiatingLines)
        _LineCount = LineCount
        _Thickness = Thickness
    }
    
    private var _LineCount: Int = 4
    public var LineCount: Int
    {
        get
        {
            return _LineCount
        }
        set
        {
            _LineCount = newValue
        }
    }
    
    private var _Thickness: LineThicknesses = .Thin
    public var Thickness: LineThicknesses
    {
        get
        {
            return _Thickness
        }
        set
        {
            _Thickness = newValue
        }
    }
    
    override public func Read()
    {
        _LineCount = Settings.GetInteger(ForKey: .LineCount)
        _Thickness = Settings.GetEnum(ForKey: .RadialLineThickness, EnumType: LineThicknesses.self, Default: LineThicknesses.Thin)
    }
    
    override public func Write()
    {
        Settings.SetInteger(LineCount, ForKey: .LineCount)
        Settings.SetEnum(Thickness, EnumType: LineThicknesses.self, ForKey: .RadialLineThickness)
    }
}
