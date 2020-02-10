//
//  CappedLineOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class CappedLineOptionalParameters: OptionalParameters
{
    init()
    {
        super.init(WithShape: .CappedLines)
    }
    
    init(WithCapShape: Shapes, AtLocation: CapLocations)
    {
        super.init(WithShape: .CappedLines)
        _CapLocation = AtLocation
        if WithCapShape == .CappedLines
        {
            _CapShape = .Spheres
        }
        else
        {
            _CapShape = WithCapShape
        }
    }
    
    private var _CapLocation: CapLocations = .Top
    public var CapLocation: CapLocations
    {
        get
        {
            return _CapLocation
        }
        set
        {
            _CapLocation = newValue
        }
    }
    
    private var _CapShape: Shapes = .Spheres
    public var CapShape: Shapes
    {
        get
        {
            return _CapShape
        }
        set
        {
            if newValue == .CappedLines
            {
                _CapShape = .Spheres
            }
            else
            {
                _CapShape = newValue
            }
        }
    }
}
