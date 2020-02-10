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
        var Attr = ProcessingAttributes()
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
        let Chamfer = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self, Default: BlockChamferSizes.None)
        let BlockOp = BlockOptionalParameters(WithChamfer: Chamfer)
        Attr.ShapeOptions!.append(BlockOp)
        let CLineShape = Settings.GetEnum(ForKey: .CapShape, EnumType: Shapes.self, Default: Shapes.Spheres)
        let CLoc = Settings.GetEnum(ForKey: .CapLocation, EnumType: CapLocations.self, Default: CapLocations.Top)
        let CLineOp = CappedLineOptionalParameters(WithCapShape: CLineShape, AtLocation: CLoc)
        Attr.ShapeOptions!.append(CLineOp)
        let CSet = Settings.GetEnum(ForKey: .CharacterSet, EnumType: CharacterSets.self, Default: CharacterSets.Latin)
        let CSetOp = CharactersOptionalParameters(WithSet: CSet)
        Attr.ShapeOptions!.append(CSetOp)
        let StarApex = Settings.GetInteger(ForKey: .StarApexCount)
        let ApexesIncrease = Settings.GetBoolean(ForKey: .ApexesIncrease)
        let StarOp = StarOptionalParameters(ApexCount: StarApex, UseIntensity: ApexesIncrease)
        Attr.ShapeOptions!.append(StarOp)
        let OvalOr = Settings.GetEnum(ForKey: .OvalOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
        let OvalDi = Settings.GetEnum(ForKey: .OvalLength, EnumType: Distances.self, Default: Distances.Medium)
        let OvalOp = EllipseOptionalParameters(WithOrientation: OvalOr, Size: OvalDi)
        Attr.ShapeOptions!.append(OvalOp)
        let DiaOr = Settings.GetEnum(ForKey: .DiamondOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
        let DiaDi = Settings.GetEnum(ForKey: .DiamondLength, EnumType: Distances.self, Default: Distances.Medium)
        let DiaOp = DiamondOptionalParameters(WithOrientation: DiaOr, Size: DiaDi)
        Attr.ShapeOptions!.append(DiaOp)
        let ConeTop = Settings.GetEnum(ForKey: .ConeTopSize, EnumType: ConeTopSizes.self, Default: ConeTopSizes.Zero)
        let ConeBottom = Settings.GetEnum(ForKey: .ConeBottomSize, EnumType: ConeBottomSizes.self, Default: ConeBottomSizes.Side)
        let SwapTopBottom = Settings.GetBoolean(ForKey: .ConeSwapTopBottom)
        let ConeOp = ConeOptionalParameters(WithTopSize: ConeTop, BottomSize: ConeBottom, Swap: SwapTopBottom)
        Attr.ShapeOptions!.append(ConeOp)
        let HueList = Settings.GetString(ForKey: .HueShapes, Shapes.Blocks.rawValue)
        let HueOp = HSBVaryingOptionalParameters(WithChannel: .HSB_Hue, ShapeList: MakeShapeList(From: HueList))
        Attr.ShapeOptions!.append(HueOp)
        let SatList = Settings.GetString(ForKey: .SaturationShapes, Shapes.Blocks.rawValue)
        let SatOp = HSBVaryingOptionalParameters(WithChannel: .HSB_Saturation, ShapeList: MakeShapeList(From: SatList))
        Attr.ShapeOptions!.append(SatOp)
        let BriList = Settings.GetString(ForKey: .BrightnessShapes, Shapes.Blocks.rawValue)
        let BriOp = HSBVaryingOptionalParameters(WithChannel: .HSB_Brightness, ShapeList: MakeShapeList(From: BriList))
        Attr.ShapeOptions!.append(BriOp)
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
    
    /// Write the passed set of attributes to user settings.
    /// - Parameter Attributes: The attributes to write.
    public static func Write(_ Attributes: ProcessingAttributes)
    {
        
    }
}

/// NSColor extension to create a color from an integer.
extension NSColor
{
    /// Create an NSColor from the passed integer.
    /// - Parameter With: The integer value of the color.
    /// - Parameter ForceAlpha1: If true, alpha is forced to 1.0 in the final color. Otherwise, the
    ///                          value in `With` is used.
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
