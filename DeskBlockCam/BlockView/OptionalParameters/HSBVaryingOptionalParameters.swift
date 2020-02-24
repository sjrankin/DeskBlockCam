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
    /*
    init(WithChannel: HSBChannels)
    {
         ActualShape = Shapes.HueVarying
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
        self.Read()
    }
    
    init(WithChannel: HSBChannels, ShapeList: [Shapes])
    {
         ActualShape = Shapes.HueVarying
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
    
    public var ActualShape: Shapes = .HueVarying
    
    private let InvalidShapes: [Shapes] = [.HueVarying, .SaturationVarying, .BrightnessVarying, .StackedShapes]
    
    private var _ShapeList: [Shapes] = [.Blocks, .Spheres, .Cylinders, .Polygons, .Stars]
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
    
    override public func Read()
    {
        var KeyName = SettingKeys.HueShapes
        switch ActualShape
        {
            case .HueVarying:
                KeyName = SettingKeys.HueShapes
            
            case .SaturationVarying:
                KeyName = SettingKeys.SaturationShapes
            
            case .BrightnessVarying:
                KeyName = SettingKeys.BrightnessShapes
            
            default:
            return
        }
        let RawString = Settings.GetString(ForKey: KeyName, Shapes.Blocks.rawValue)
        _ShapeList = ProcessingAttributes.MakeShapeList(From: RawString)
    }
    
    override public func Write()
    {
        var KeyName = SettingKeys.HueShapes
        switch ActualShape
        {
            case .HueVarying:
                KeyName = SettingKeys.HueShapes
            
            case .SaturationVarying:
                KeyName = SettingKeys.SaturationShapes
            
            case .BrightnessVarying:
                KeyName = SettingKeys.BrightnessShapes
            
            default:
                return
        }
        let AsString = ProcessingAttributes.MakeShapeString(From: ShapeList)
        Settings.SetString(AsString, ForKey: KeyName)
    }
 */
}

