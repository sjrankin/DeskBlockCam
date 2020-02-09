//
//  AttributeFactory.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ProcessingAttributes
{
    /// Load the current set of attributes from user settings and return a new instance.
    /// - Note: Some fields are left untouched on the assumption the caller will fill them in with
    ///         non-stored data (eg, color data from images).
    /// - Returns: New `ProcessingAttributes` instance with current settings.
    public static func Create() -> ProcessingAttributes
    {
        let Attr = ProcessingAttributes()
        Attr.Shape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        Attr.VerticalExaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                                     Default: VerticalExaggerations.None)
        Attr.InvertHeight = Settings.GetBoolean(ForKey: .InvertHeight)
        Attr.Side = CGFloat(Settings.GetDouble(ForKey: .Side))
        Attr.HeightDeterminate = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                                 Default: HeightDeterminations.Brightness)
        Attr.ConditionalColor = Settings.GetEnum(ForKey: .ConditionalColor, EnumType: ConditionalColorTypes.self,
                                                 Default: ConditionalColorTypes.None)
        Attr.ConditionalColorAction = Settings.GetEnum(ForKey: .ConditionalColorAction, EnumType: ConditionalColorActions.self,
                                                       Default: ConditionalColorActions.Grayscale)
        Attr.ConditionalColorThreshold = Settings.GetEnum(ForKey: .ConditionalColorThreshold,
                                                          EnumType: ConditionalColorThresholds.self,
                                                          Default: ConditionalColorThresholds.Less50)
        Attr.InvertConditionalColorThreshold = Settings.GetBoolean(ForKey: .InvertConditionalColor)
        Attr.Background = Settings.GetEnum(ForKey: .BackgroundType, EnumType: Backgrounds.self,
                                           Default: Backgrounds.Color)
        Attr.BackgroundColor = NSColor.MakeColor(With: Settings.GetInteger(ForKey: .BackgroundColor))
        let Gradients = Settings.GetString(ForKey: .BackgroundGradientColors)
        let Parts = Gradients!.split(separator: ",", omittingEmptySubsequences: true)
        var BGGradientColors = [NSColor]()
        for Part in Parts
        {
            let ColorScanner = Scanner(string: String(Part))
            var Scanned: UInt64 = 0
            if ColorScanner.scanHexInt64(&Scanned)
            {
                let SomeColor = NSColor.MakeColor(With: Int(Scanned))
                BGGradientColors.append(SomeColor)
            }
        }
        Attr.BackgroundGradientColors = BGGradientColors
        Attr.LightColor = NSColor.MakeColor(With: Settings.GetInteger(ForKey: .LightColor))
        Attr.LightType = Settings.GetEnum(ForKey: .LightType, EnumType: LightingTypes.self,
                                          Default: LightingTypes.Omni)
        Attr.LightIntensity = Settings.GetEnum(ForKey: .LightIntensity, EnumType: LightIntensities.self,
                                               Default: LightIntensities.Normal)
        Attr.LightModel = Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self,
                                          Default: LightModels.Lambert)
        return Attr
    }
    
    /// Write the passed set of attributes to user settings.
    /// - Parameter Attributes: The attributes to write.
    public static func Write(_ Attributes: ProcessingAttributes)
    {
        
    }
}

extension NSColor
{
    static func MakeColor(With Value: Int, ForceAlpha1: Bool = true) -> NSColor
    {
        let Alpha = (Value & 0xff000000) >> 24
        let Red = (Value & 0x00ff0000) >> 16
        let Green = (Value & 0x0000ff00) >> 8
        let Blue = (Value * 0x000000ff)
        let Color = NSColor(red: CGFloat(Red) / 255.0, green: CGFloat(Green) / 255.0, blue: CGFloat(Blue) / 255.0,
                            alpha: ForceAlpha1 ? 1.0 : CGFloat(Alpha) / 255.0)
        return Color
    }
}
