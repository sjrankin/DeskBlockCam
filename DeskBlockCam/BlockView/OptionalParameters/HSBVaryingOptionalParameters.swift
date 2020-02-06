//
//  HSBVaryingOptionalParameters.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class HSBVaryingOptionalParameters: OptionalParameters
{
    init(WithChannel: HSBChannels)
    {
        var ActualShape = Shapes.HueVarying
        switch WithChannel
        {
            case .HSB_Hue:
                ActualShape = .HueVarying
            
            case .HSB_Saturation:
                ActualShape = .SaturationVarying
            
            case .HSB_Brightness:
                ActualShape = .BrightnessVarying
        }
        super.init(WithShape: ActualShape)
    }
    
    init(WithChannel: HSBChannels, ShapeList: [Shapes])
    {
        var ActualShape = Shapes.HueVarying
        switch WithChannel
        {
            case .HSB_Hue:
                ActualShape = .HueVarying
            
            case .HSB_Saturation:
                ActualShape = .SaturationVarying
            
            case .HSB_Brightness:
                ActualShape = .BrightnessVarying
        }
        super.init(WithShape: ActualShape)
        _ShapeList = ShapeList
    }
    
    private let InvalidShapes: [Shapes] = [.HueVarying, .SaturationVarying, .BrightnessVarying, .StackedShapes]
    
    private var _ShapeList: [Shapes] = [.Blocks, .Spheres, .Cylinders, .Hexagons, .Stars]
    {
        didSet
        {
            _ShapeList = _ShapeList.filter({!self.InvalidShapes.contains($0)})
        }
    }
    public var ShapeList: [Shapes]
    {
        get
        {
            return _ShapeList
        }
        set
        {
            _ShapeList = newValue
        }
    }
}

enum HSBChannels: String, CaseIterable
{
    case HSB_Hue = "Hue"
    case HSB_Saturation = "Saturation"
    case HSB_Brightness = "Brightness"
}
