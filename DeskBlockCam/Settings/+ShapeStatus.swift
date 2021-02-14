//
//  +ShapeStatus.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/13/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ShapeOptionsCode
{
    /// Initialize the current settings side bar.
    func InitializeSideBar()
    {
        CurrentSettings.reloadData()
        CurrentSettings.expandItem(Current[1])
        CurrentSettings.expandItem(Current[2])
        let CurrentShape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        UpdateShapeSettings(With: CurrentShape)
        UpdateHeightSettings()
        UpdateLiveViewSettings()
        UpdateLightSettings()
        UpdateColorSettings()
        UpdateProcessingSettings()
        UpdateBackgroundSettings()
    }
    
    func UpdateHeightSettings()
    {
        Current[2].ValueItems.removeAll()
        let HDeterm = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                       Default: HeightDeterminations.Brightness)
        Current[2].ValueItems.append(ValueItem(Description: "Height", Value: HDeterm.rawValue))
        let Exg = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                   Default: VerticalExaggerations.Medium)
        Current[2].ValueItems.append(ValueItem(Description: "Exaggeration", Value: Exg.rawValue))
        let Invert = Settings.GetBoolean(ForKey: .InvertHeight)
        Current[2].ValueItems.append(ValueItem(Description: "Invert", Value: "\(Invert)"))
        CurrentSettings.reloadData()
    }
    
    func UpdateLightSettings()
    {
        Current[3].ValueItems.removeAll()
        let LType = Settings.GetEnum(ForKey: .LightType, EnumType: LightingTypes.self, Default: .Omni)
        Current[3].ValueItems.append(ValueItem(Description: "Type", Value: LType.rawValue))
        let RawLColor = Settings.GetInteger(ForKey: .LightColor)
        let LColor = NSColor.MakeColor(With: RawLColor)
        let LColorName = NSColor.NameFor(Color: LColor)
        Current[3].ValueItems.append(ValueItem(Description: "Color", Value: LColorName))
        let LInt = Settings.GetEnum(ForKey: .LightIntensity, EnumType: LightIntensities.self,
                                    Default: .Normal)
        Current[3].ValueItems.append(ValueItem(Description: "Intensity", Value: LInt.rawValue))
        let LModel = Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self,
                                      Default: .Lambert)
        Current[3].ValueItems.append(ValueItem(Description: "Model", Value: LModel.rawValue))
        Current[3].ValueItems.append(ValueItem(Description: "Metal Surface", Value: "\(Settings.GetBoolean(ForKey: .EnableMetalness))"))
        Current[3].ValueItems.append(ValueItem(Description: "Metalness", Value: "\(Settings.GetDouble(ForKey: .Metalness))"))
        Current[3].ValueItems.append(ValueItem(Description: "Roughness", Value: "\(Settings.GetDouble(ForKey: .Roughness))"))
        CurrentSettings.reloadData()
    }
    
    func UpdateColorSettings()
    {
        CurrentSettings.reloadData()
    }
    
    func UpdateProcessingSettings()
    {
        Current[5].ValueItems.removeAll()
        let NodeSize = Settings.GetInteger(ForKey: .ShapeSize)
        Current[5].ValueItems.append(ValueItem(Description: "Shape size", Value: "\(NodeSize)"))
        let ISize = Settings.GetInteger(ForKey: .MaximumLength)
        Current[5].ValueItems.append(ValueItem(Description: "Image size", Value: "\(ISize)"))
        let AA = Settings.GetEnum(ForKey: .Antialiasing, EnumType: AntialiasingModes.self, Default: AntialiasingModes.x4)
        Current[5].ValueItems.append(ValueItem(Description: "Antialiasing", Value: AA.rawValue))
        CurrentSettings.reloadData()
    }
    
    func UpdateBackgroundSettings()
    {
        Current[6].ValueItems.removeAll()
        let BType = Settings.GetEnum(ForKey: .BackgroundType, EnumType: Backgrounds.self,
                                     Default: .Color)
        Current[6].ValueItems.append(ValueItem(Description: "Type", Value: BType.rawValue))
        switch BType
        {
            case .Color:
                let BColor = Settings.GetInteger(ForKey: .BackgroundColor)
                let Name = NSColor.NameFor(Color: NSColor.MakeColor(With: BColor))
                Current[6].ValueItems.append(ValueItem(Description: "Color", Value: Name))
                
            case .Gradient:
                let GColors = Settings.GetString(ForKey: .BackgroundGradientColors)
                let Parts = GColors?.split(separator: ",", omittingEmptySubsequences: true)
                var GColorList = [String]()
                for Part in Parts!
                {
                    var SPart = String(Part)
                    SPart.removeFirst(2)
                    let SInt = Int(SPart) ?? 0
                    let SColor = NSColor.MakeColor(With: SInt)
                    let Name = NSColor.NameFor(Color: SColor)
                    GColorList.append(Name)
                }
                var Final = ""
                for Clr in GColorList
                {
                    Final.append(Clr)
                    Final.append(",")
                }
                Final.removeLast(1)
                Current[6].ValueItems.append(ValueItem(Description: "Gradient", Value: Final))
            default:
                break
        }
        CurrentSettings.reloadData()
    }
    
    /// Update live view settings.
    func UpdateLiveViewSettings()
    {
        Current[8].ValueItems.removeAll()
        let Shape = Settings.GetEnum(ForKey: .LiveViewShape, EnumType: Shapes.self, Default: Shapes.Blocks)
        Current[8].ValueItems.append(ValueItem(Description: "Shape", Value: Shape.rawValue))
        let LiveViewSize = Settings.GetEnum(ForKey: .LiveViewImageSize, EnumType: LiveViewImageSizes.self,
                                            Default: LiveViewImageSizes.Medium)
        Current[8].ValueItems.append(ValueItem(Description: "Stream size", Value: LiveViewSize.rawValue))
        CurrentSettings.reloadData()
    }
    
    /// Update the current side bar shape settings.
    /// - Parameter With: The new shape.
    func UpdateShapeSettings(With NewShape: Shapes)
    {
        let ShapeName = NewShape.rawValue
        
        Current[1].ValueItems.removeAll()
        Current[1].ValueItems.append(ValueItem(Description: "Shape", Value: ShapeName, Color: NSColor.systemBlue))
        switch NewShape
        {
            case .Blocks:
                let Chamfer = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self, Default: BlockChamferSizes.None)
                Current[1].ValueItems.append(ValueItem(Description: "Chamfer", Value: Chamfer.rawValue))
                
            case .Polygons:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                Current[1].ValueItems.append(ValueItem(Description: "Sides", Value: "\(SideCount)"))
                
            case .Polygons2D:
                let SideCount = Settings.GetInteger(ForKey: .Polygon2DSideCount)
                Current[1].ValueItems.append(ValueItem(Description: "Sides", Value: "\(SideCount)"))
                
            case .ComponentVariable:
                let Component = Settings.GetEnum(ForKey: .VaryingComponent, EnumType: VaryingComponents.self,
                                                 Default: VaryingComponents.Hue)
                Current[1].ValueItems.append(ValueItem(Description: "Component", Value: Component.rawValue))
                var SList = ""
                switch Component
                {
                    case .Hue:
                        SList = Settings.GetString(ForKey: .HueShapes, Shapes.Blocks.rawValue)
                        
                    case .Saturation:
                        SList = Settings.GetString(ForKey: .SaturationShapes, Shapes.Blocks.rawValue)
                        
                    case .Brightness:
                        SList = Settings.GetString(ForKey: .BrightnessShapes, Shapes.Blocks.rawValue)
                        
                    case .Red:
                        SList = Settings.GetString(ForKey: .RedShapes, Shapes.Blocks.rawValue)
                        
                    case .Green:
                        SList = Settings.GetString(ForKey: .GreenShapes, Shapes.Blocks.rawValue)
                        
                    case .Blue:
                        SList = Settings.GetString(ForKey: .BlueShapes, Shapes.Blocks.rawValue)
                        
                    case .Cyan:
                        SList = Settings.GetString(ForKey: .CyanShapes, Shapes.Blocks.rawValue)
                        
                    case .Magenta:
                        SList = Settings.GetString(ForKey: .MagentaShapes, Shapes.Blocks.rawValue)
                        
                    case .Yellow:
                        SList = Settings.GetString(ForKey: .YellowShapes, Shapes.Blocks.rawValue)
                        
                    case .Black:
                        SList = Settings.GetString(ForKey: .BlackShapes, Shapes.Blocks.rawValue)
                }
                Current[1].ValueItems.append(ValueItem(Description: "Shapes", Value: SList))
                
            case .CappedLines:
                let Location = Settings.GetEnum(ForKey: .CapLocation, EnumType: CapLocations.self, Default: CapLocations.Top)
                let CapShape = Settings.GetEnum(ForKey: .CapShape, EnumType: Shapes.self, Default: Shapes.Spheres)
                let LineColor = Settings.GetEnum(ForKey: .CappedLineLineColor, EnumType: CappedLineLineColors.self, Default: CappedLineLineColors.Same)
                Current[1].ValueItems.append(ValueItem(Description: "Location", Value: Location.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Shape", Value: CapShape.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Line color", Value: LineColor.rawValue))
                
            case .Characters:
                let CharSet = Settings.GetEnum(ForKey: .CharacterSet, EnumType: CharacterSets.self, Default: CharacterSets.Latin)
                Current[1].ValueItems.append(ValueItem(Description: "Characters", Value: CharSet.rawValue))
                
            case .Cones:
                let Top = Settings.GetEnum(ForKey: .ConeTopSize, EnumType: ConeTopSizes.self, Default: ConeTopSizes.Zero)
                let Bottom = Settings.GetEnum(ForKey: .ConeBottomSize, EnumType: ConeBottomSizes.self, Default: ConeBottomSizes.Side)
                let Invert = Settings.GetBoolean(ForKey: .ConeSwapTopBottom)
                Current[1].ValueItems.append(ValueItem(Description: "Top size", Value: Top.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Bottom size", Value: Bottom.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Swap top/bottom", Value: "\(Invert)"))
                
            case .Diamonds:
                let Orientation = Settings.GetEnum(ForKey: .DiamondOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
                let Distance = Settings.GetEnum(ForKey: .DiamondLength, EnumType: Distances.self, Default: Distances.Medium)
                Current[1].ValueItems.append(ValueItem(Description: "Orientation", Value: Orientation.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Length", Value: Distance.rawValue))
                
            case .Ovals:
                let Orientation = Settings.GetEnum(ForKey: .OvalOrientation, EnumType: Orientations.self, Default: Orientations.Horizontal)
                let Distance = Settings.GetEnum(ForKey: .OvalLength, EnumType: Distances.self, Default: Distances.Medium)
                Current[1].ValueItems.append(ValueItem(Description: "Orientation", Value: Orientation.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Length", Value: Distance.rawValue))
                
            case .RadiatingLines:
                let LineCount = Settings.GetInteger(ForKey: .LineCount)
                let Thickness = Settings.GetEnum(ForKey: .RadialLineThickness, EnumType: LineThicknesses.self, Default: LineThicknesses.Thin)
                Current[1].ValueItems.append(ValueItem(Description: "Line count", Value: "\(LineCount)"))
                Current[1].ValueItems.append(ValueItem(Description: "Thickness", Value: Thickness.rawValue))
                
            case .Rings:
                let Orientation = Settings.GetEnum(ForKey: .RingOrientation, EnumType: RingOrientations.self, Default: RingOrientations.Flat)
                let DonutHole = Settings.GetEnum(ForKey: .DonutHoleSize, EnumType: DonutHoleSizes.self, Default: DonutHoleSizes.Medium)
                Current[1].ValueItems.append(ValueItem(Description: "Orientation", Value: Orientation.rawValue))
                Current[1].ValueItems.append(ValueItem(Description: "Hole size", Value: DonutHole.rawValue))
                
            case .Spheres:
                let SphereB = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self, Default: SphereBehaviors.Size)
                Current[1].ValueItems.append(ValueItem(Description: "Prominence", Value: SphereB.rawValue))
                
            case .Stars:
                let Apexes = Settings.GetInteger(ForKey: .StarApexCount)
                let Intensity = Settings.GetBoolean(ForKey: .ApexesIncrease)
                Current[1].ValueItems.append(ValueItem(Description: "Apex count", Value: "\(Apexes)"))
                Current[1].ValueItems.append(ValueItem(Description: "Variable apexes", Value: "\(Intensity)"))
                
            case .BlockBases:
                let ExShape = Settings.GetEnum(ForKey: .BlockWithShape, EnumType: Shapes.self, Default: Shapes.Cones)
                Current[1].ValueItems.append(ValueItem(Description: "Extruded shape", Value: ExShape.rawValue))
                
            case .SphereBases:
                let ExShape = Settings.GetEnum(ForKey: .SphereWithShape, EnumType: Shapes.self, Default: Shapes.Cones)
                Current[1].ValueItems.append(ValueItem(Description: "Extruded shape", Value: ExShape.rawValue))
                
            default:
                break
        }
        CurrentSettings.reloadData()
    }
}
