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
        //Read and add optional data.
        Attr.ShapeOptions = [OptionalParameters]()
        Attr.ShapeOptions!.append(BlockOptionalParameters())
        Attr.ShapeOptions!.append(CappedLineOptionalParameters())
        Attr.ShapeOptions!.append(CharactersOptionalParameters())
        Attr.ShapeOptions!.append(StarOptionalParameters())
        Attr.ShapeOptions!.append(EllipseOptionalParameters())
        Attr.ShapeOptions!.append(DiamondOptionalParameters())
        Attr.ShapeOptions!.append(ConeOptionalParameters())
        /*
        Attr.ShapeOptions!.append(HSBVaryingOptionalParameters(WithChannel: .HSB_Hue))
        Attr.ShapeOptions!.append(HSBVaryingOptionalParameters(WithChannel: .HSB_Saturation))
        Attr.ShapeOptions!.append(HSBVaryingOptionalParameters(WithChannel: .HSB_Brightness))
 */
        Attr.ShapeOptions!.append(SphereOptionalParameters())
        Attr.ShapeOptions!.append(RingOptionalParameters())
        return Attr
    }
    
    /// Returns an array of shapes based on the contents of the passed string.
    /// - Note: The string must be formatted such that:
    ///    - Each shape's name is from the enum case value for the given shape.
    ///    - Shape names are separated by commas.
    /// - Parameter From: The string with the list of strings.
    /// - Returns: List of shapes in the passed string. May be empty if the passed string is empty
    ///            or no valid shapes found.
    public static func MakeShapeList(From Raw: String) -> [Shapes]
    {
        var ShapeList = [Shapes]()
        if Raw.isEmpty
        {
            return ShapeList
        }
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let RawShape = String(Part)
            if let Shape = Shapes(rawValue: RawShape)
            {
                ShapeList.append(Shape)
            }
        }
        return ShapeList
    }
    
    /// Converts a list of shapes into a comma-separated string of shape names.
    /// - Parameter From: The array of shapes to convert to a string.
    /// - Returns: Comma-separated string of shape names. May be empty if `From` has no entries.
    public static func MakeShapeString(From List: [Shapes]) -> String
    {
        var Result = ""
        if List.count < 1
        {
            return Result
        }
        for Shape in List
        {
            Result.append(Shape.rawValue)
            Result.append(",")
        }
        return Result
    }
    
    /// Write the passed set of attributes to user settings.
    /// - Parameter Attributes: The attributes to write.
    public static func Write(_ Attributes: ProcessingAttributes)
    {
        Settings.SetEnum(Attributes.Shape, EnumType: Shapes.self, ForKey: .Shape)
        Settings.SetEnum(Attributes.VerticalExaggeration, EnumType: VerticalExaggerations.self, ForKey: .VerticalExaggeration)
        Settings.SetBoolean(Attributes.InvertHeight, ForKey: .InvertHeight)
        Settings.SetEnum(Attributes.HeightDeterminate, EnumType: HeightDeterminations.self, ForKey: .HeightDetermination)
        Settings.SetEnum(Attributes.ConditionalColor, EnumType: ConditionalColorTypes.self, ForKey: .ConditionalColor)
        Settings.SetEnum(Attributes.ConditionalColorAction, EnumType: ConditionalColorActions.self, ForKey: .ConditionalColorAction)
        Settings.SetEnum(Attributes.ConditionalColorThreshold, EnumType: ConditionalColorThresholds.self, ForKey: .ConditionalColorThreshold)
        Settings.SetBoolean(Attributes.InvertConditionalColorThreshold, ForKey: .InvertConditionalColor)
        Settings.SetEnum(Attributes.Background, EnumType: Backgrounds.self, ForKey: .BackgroundType)
        Settings.SetInteger(NSColor.AsInt(Attributes.BackgroundColor), ForKey: .BackgroundColor)
        var GrList = ""
        for GColor in Attributes.BackgroundGradientColors
        {
            let GInt = NSColor.AsInt(GColor)
            let GS = "0x\(GInt)"
            GrList.append(GS)
            GrList.append(",")
        }
        Settings.SetString(GrList, ForKey: .BackgroundGradientColors)
        Settings.SetInteger(NSColor.AsInt(Attributes.LightColor), ForKey: .LightColor)
        Settings.SetEnum(Attributes.LightType, EnumType: LightingTypes.self, ForKey: .LightType)
        Settings.SetEnum(Attributes.LightIntensity, EnumType: LightIntensities.self, ForKey: .LightIntensity)
        Settings.SetEnum(Attributes.LightModel, EnumType: LightModels.self, ForKey: .LightModel)
        for Optional in Attributes.ShapeOptions!
        {
            Optional.Write()
        }
    }
}


