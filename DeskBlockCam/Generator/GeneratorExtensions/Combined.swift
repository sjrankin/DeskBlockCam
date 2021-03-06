//
//  Combined.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Extensions to `Generator` for the creation of combined shapes.
extension Generator
{
    /// Returns a color for the line for the capped line shape. The color is determined by user settings.
    /// - Parameter BasedOn: The base color of the shape.
    /// - Returns: Color to use for the line.
    public static func GetCappedLineColor(BasedOn: NSColor) -> NSColor
    {
        let LineColor = Settings.GetEnum(ForKey: .CappedLineLineColor, EnumType: CappedLineLineColors.self,
                                         Default: CappedLineLineColors.Same)
        switch LineColor
        {
            case .Same:
                return BasedOn
            
            case .Black:
                return NSColor.black
            
            case .White:
                return NSColor.white
            
            case .Darker:
                return BasedOn.Darken(By: 0.7)
            
            case .Lighter:
                return BasedOn.Brighten(By: 0.4)
        }
    }
    
    /// Returns the shape the user selected as the cap of a capped line shape.
    /// - Parameter Side: The radius of a sphere. Multiplied by various constants for other shapes.
    /// - Parameter Diffuse: The diffuse material color.
    /// - Reurns: Geometry for the specified (in user defaults) shape.
    public static func GetCappedLineShape(Side: CGFloat, Diffuse: NSColor) -> SCNGeometry
    {
        let CapShape = Settings.GetEnum(ForKey: .CapShape, EnumType: Shapes.self, Default: Shapes.Spheres)
        var Shape: SCNGeometry!
        switch CapShape
        {
            case .Spheres:
                Shape = SCNSphere(radius: Side)
            
            case .Circles:
                Shape = SCNCylinder(radius: Side * 0.85, height: 0.05)
            
            case .Cones:
                Shape = SCNCone(topRadius: 0.0, bottomRadius: Side, height: Side * 2.5)
            
            case .Blocks:
                Shape = SCNBox(width: Side * 1.5, height: Side * 1.5, length: Side * 1.5, chamferRadius: 0.0)
            
            case .Squares:
                Shape = SCNBox(width: Side * 1.5, height: 0.05, length: Side * 1.5, chamferRadius: 0.0)
            
            default:
                Shape = SCNSphere(radius: Side)
        }
        
        Shape.firstMaterial?.diffuse.contents = Diffuse
        Shape.firstMaterial?.specular.contents = NSColor.white
        Shape.firstMaterial?.lightingModel = GetLightModel()
        
        return Shape
    }
    
    public static func MakeCappedLines(Side: CGFloat, Color: NSColor, Height: CGFloat, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let CapLocation = Settings.GetEnum(ForKey: .CapLocation, EnumType: CapLocations.self,
                                           Default: CapLocations.Top)
        let Node = PSCNNode()
        let Shape1 = SCNCylinder(radius: 0.1, height: Height * 2.0)
        let LineColor = GetCappedLineColor(BasedOn: Color)
        Shape1.firstMaterial?.diffuse.contents = LineColor
        Shape1.firstMaterial?.specular.contents = NSColor.white
        Shape1.firstMaterial?.lightingModel = Model
        let Node1 = SCNNode(geometry: Shape1)
        Node1.position = SCNVector3(0.0, 0.0, 0.0)
        let Shape2 = GetCappedLineShape(Side: 0.25, Diffuse: Color)
        let Node2 = SCNNode(geometry: Shape2)
        var ShapeCoordinate: CGFloat = 0.0
        switch CapLocation
        {
            case .Top:
                ShapeCoordinate = (Height * 2.0) / 2.0
            
            case .Middle:
                ShapeCoordinate = 0.0
            
            case .Bottom:
                ShapeCoordinate = -((Height * 2.0) / 2.0)
        }
        Node2.position = SCNVector3(0.0, ShapeCoordinate, 0.0)
        Node.addChildNode(Node1)
        Node.addChildNode(Node2)
        return Node
    }
    
    public static func MakeRadiatingLines(Side: CGFloat, Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Node = PSCNNode()
        var RLineThickness: CGFloat = 0.05
        switch Settings.GetEnum(ForKey: .RadialLineThickness, EnumType: LineThicknesses.self,
                                Default: LineThicknesses.Thin)
        {
            case LineThicknesses.Thin:
                RLineThickness = 0.02
            
            case LineThicknesses.Medium:
                RLineThickness = 0.05
            
            case LineThicknesses.Thick:
                RLineThickness = 0.08
        }
        
        let UpLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
        UpLineGeo.firstMaterial?.diffuse.contents = Color
        UpLineGeo.firstMaterial?.specular.contents = NSColor.white
        UpLineGeo.firstMaterial?.lightingModel = GetLightModel()
        let UpLine = SCNNode(geometry: UpLineGeo)
        UpLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 0.0)
        Node.addChildNode(UpLine)
        
        let DownLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
        DownLineGeo.firstMaterial?.diffuse.contents = Color
        DownLineGeo.firstMaterial?.specular.contents = NSColor.white
        DownLineGeo.firstMaterial?.lightingModel = GetLightModel()
        let DownLine = SCNNode(geometry: DownLineGeo)
        DownLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 0.0, 0.0)
        Node.addChildNode(DownLine)
        
        let LeftLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
        LeftLineGeo.firstMaterial?.diffuse.contents = Color
        LeftLineGeo.firstMaterial?.specular.contents = NSColor.white
        LeftLineGeo.firstMaterial?.lightingModel = GetLightModel()
        let LeftLine = SCNNode(geometry: LeftLineGeo)
        LeftLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 90.0 * Double.pi / 180.0)
        Node.addChildNode(LeftLine)
        
        let RightLineGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
        RightLineGeo.firstMaterial?.diffuse.contents = Color
        RightLineGeo.firstMaterial?.specular.contents = NSColor.white
        RightLineGeo.firstMaterial?.lightingModel = GetLightModel()
        let RightLine = SCNNode(geometry: RightLineGeo)
        RightLine.eulerAngles = SCNVector3(-90.0 * Double.pi / 180.0, 0.0, -90.0 * Double.pi / 180.0)
        Node.addChildNode(RightLine)
        
        if Settings.GetInteger(ForKey: .LineCount) > 4
        {
            let ULGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
            ULGeo.firstMaterial?.diffuse.contents = Color
            ULGeo.firstMaterial?.specular.contents = NSColor.white
            ULGeo.firstMaterial?.lightingModel = GetLightModel()
            let ULLine = SCNNode(geometry: ULGeo)
            ULLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 45.0 * Double.pi / 180.0)
            Node.addChildNode(ULLine)
            
            let LLGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
            LLGeo.firstMaterial?.diffuse.contents = Color
            LLGeo.firstMaterial?.specular.contents = NSColor.white
            LLGeo.firstMaterial?.lightingModel = GetLightModel()
            let LLLine = SCNNode(geometry: LLGeo)
            LLLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, 135.0 * Double.pi / 180.0)
            Node.addChildNode(LLLine)
            
            let URGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
            URGeo.firstMaterial?.diffuse.contents = Color
            URGeo.firstMaterial?.specular.contents = NSColor.white
            URGeo.firstMaterial?.lightingModel = GetLightModel()
            let URLine = SCNNode(geometry: URGeo)
            URLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, -45.0 * Double.pi / 180.0)
            Node.addChildNode(URLine)
            
            let LRGeo = SCNBox(width: RLineThickness, height: RLineThickness, length: 1.0, chamferRadius: 0.0)
            LRGeo.firstMaterial?.diffuse.contents = Color
            LRGeo.firstMaterial?.specular.contents = NSColor.white
            LRGeo.firstMaterial?.lightingModel = GetLightModel()
            let LRLine = SCNNode(geometry: LRGeo)
            LRLine.eulerAngles = SCNVector3(90.0 * Double.pi / 180.0, 0.0, -135.0 * Double.pi / 180.0)
            Node.addChildNode(LRLine)
        }
        
        return Node
    }
    
    public static func MakeTouchingTriangles(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                             Height: CGFloat, Color: NSColor,
                                             Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Node = PSCNNode()
        Node.X = AtX
        Node.Y = AtY
        let SidesTouch = Settings.GetBoolean(ForKey: .SidesTouch)
        
        let T1Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
        T1Geo.firstMaterial?.diffuse.contents = Color
        T1Geo.firstMaterial?.specular.contents = NSColor.white
        T1Geo.firstMaterial?.lightingModel = Model
        let T1 = SCNNode(geometry: T1Geo)
        T1.position = SCNVector3(0.0, 0.0, 0.0)
        if SidesTouch
        {
            T1.eulerAngles = SCNVector3(0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
        }
        else
        {
            T1.eulerAngles = SCNVector3(0.0 * CGFloat.pi / 180.0, 0.0, 90.0 * CGFloat.pi / 180.0)
        }
        
        let T2Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
        T2Geo.firstMaterial?.diffuse.contents = Color
        T2Geo.firstMaterial?.specular.contents = NSColor.white
        T2Geo.firstMaterial?.lightingModel = Model
        let T2 = SCNNode(geometry: T2Geo)
        T2.position = SCNVector3(0.0, 0.0, 0.0)
        if SidesTouch
        {
            T2.eulerAngles = SCNVector3(120.0 * CGFloat.pi / 180.0, 0.0, 90 * CGFloat.pi / 180.0)
        }
        else
        {
            T2.eulerAngles = SCNVector3(0.0 * CGFloat.pi / 180.0, 120.0 * CGFloat.pi / 180.0, 90.0 * CGFloat.pi / 180.0)
        }
        
        let T3Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
        T3Geo.firstMaterial?.diffuse.contents = Color
        T3Geo.firstMaterial?.specular.contents = NSColor.white
        T3Geo.firstMaterial?.lightingModel = Model
        let T3 = SCNNode(geometry: T3Geo)
        T3.position = SCNVector3(0.0, 0.0, 0.0)
        if SidesTouch
        {
            T3.eulerAngles = SCNVector3(240.0 * CGFloat.pi / 180.0, 0.0, 90 * CGFloat.pi / 180.0)
        }
        else
        {
            T3.eulerAngles = SCNVector3(0.0 * CGFloat.pi / 180.0, 240.0 * CGFloat.pi / 180.0, 90.0 * CGFloat.pi / 180.0)
        }
        
        Node.addChildNode(T1)
        Node.addChildNode(T2)
        Node.addChildNode(T3)
        Node.eulerAngles = SCNVector3(0.0, 0.0, -90.0 * CGFloat.pi / 180.0)
        Node.eulerAngles = SCNVector3(0.0, -90.0 * CGFloat.pi / 180.0, 0.0)
        return Node
    }
    
    public static func MakePerpendicularShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                              Height: CGFloat, Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Node = PSCNNode()
        Node.X = AtX
        Node.Y = AtY
        var Shape1: SCNGeometry? = nil
        var Shape2: SCNGeometry? = nil
        var RotateSecondShape = false
        switch Shape
        {
            case .PerpendicularCircles:
                Shape1 = SCNCylinder(radius: 0.25, height: 0.05)
                Shape2 = SCNCylinder(radius: 0.25, height: 0.05)
                RotateSecondShape = true
            
            case .PerpendicularSquares:
                Shape1 = SCNBox(width: 0.25 * 2.0, height: 0.05, length: 0.25 * 2.0, chamferRadius: 0.0)
                Shape2 = SCNBox(width: 0.25 * 2.0, height: 0.25 * 2.0, length: 0.05, chamferRadius: 0.0)
            
            default:
                return nil
        }
        
        Shape1?.firstMaterial?.diffuse.contents = Color
        Shape1?.firstMaterial?.specular.contents = NSColor.white
        Shape1?.firstMaterial?.lightingModel = GetLightModel()
        let Node1 = SCNNode(geometry: Shape1)
        Node1.position = SCNVector3(0.0, 0.0, 0.0)
        Shape2?.firstMaterial?.diffuse.contents = Color
        Shape2?.firstMaterial?.specular.contents = NSColor.white
        Shape2?.firstMaterial?.lightingModel = GetLightModel()
        let Node2 = SCNNode(geometry: Shape2)
        Node2.position = SCNVector3(0.0, 0.0, 0.0)
        if RotateSecondShape
        {
            Node2.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        }
        Node.addChildNode(Node1)
        Node.addChildNode(Node2)
        Node.rotation = SCNVector4(0.0, 1.0, 0.0, 90.0 * CGFloat.pi / 180.0)
        return Node
    }
    
    private static func MakeShapeList(From Raw: String) -> [Shapes]
    {
        if Raw.isEmpty
        {
            return []
        }
        var Results = [Shapes]()
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let RawPart = String(Part)
            if let SomeShape = Shapes(rawValue: RawPart)
            {
                Results.append(SomeShape)
            }
        }
        return Results
    }
    
    public static func MakeStackedShape(Side: CGFloat, Height: CGFloat, Color: NSColor,
                                        Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Node = PSCNNode()
        var ShapeList = [Shapes]()
        var ListKey = SettingKeys.BrightnessShapes
        switch Settings.GetEnum(ForKey: .VaryingComponent, EnumType: VaryingComponents.self, Default: VaryingComponents.Brightness)
        {
            case .Hue:
                ListKey = .HueShapes
            
            case .Saturation:
                ListKey = .SaturationShapes
            
            case .Brightness:
                ListKey = .BrightnessShapes

            case .Red:
                ListKey = .RedShapes

            case .Green:
                ListKey = .GreenShapes

            case .Blue:
                ListKey = .BlueShapes

            case .Cyan:
                ListKey = .CyanShapes

            case .Magenta:
                ListKey = .MagentaShapes

            case .Yellow:
                ListKey = .YellowShapes

            case .Black:
                ListKey = .BlueShapes
        }
        let RawShapeList = Settings.GetString(ForKey: ListKey, Shapes.Blocks.rawValue)
        ShapeList = MakeShapeList(From: RawShapeList)
        var Index = 0
        let Count = Int((Height * 2.0 / Side)) + 1
        for SomeNode in 0 ..< Count
        {
            if Index > ShapeList.count - 1
            {
                Index = 0
            }
            let SubNodeShape = ShapeList[Index]
            Index = Index + 1
            let SubNode = MakeQuickShape(Shape: SubNodeShape, Side: Side, Color: Color)
            SubNode.position = SCNVector3(0.0, 0.0, Side * CGFloat(SomeNode))
            Node.addChildNode(SubNode)
        }
        return Node
    }
    
    public static func MakeBlockWithOtherShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                               Height: CGFloat, Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Other = Settings.GetEnum(ForKey: .BlockWithShape, EnumType: Shapes.self, Default: Shapes.Cones)
        let ChamferSetting = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self,
                                              Default: BlockChamferSizes.None)
        let Chamfer = BlockOptionalParameters.ChamferSize(From: ChamferSetting)
        let BlockGeo = SCNBox(width: Side, height: Side, length: Height, chamferRadius: Chamfer)
        BlockGeo.firstMaterial?.diffuse.contents = Color
        BlockGeo.firstMaterial?.specular.contents = NSColor.white
        BlockGeo.firstMaterial?.lightingModel = Model
        let Node = PSCNNode()
        Node.X = AtX
        Node.Y = AtY
        Node.addChildNode(SCNNode(geometry: BlockGeo))
        var Geo: SCNGeometry? = nil
        var NeedsRotation = true
        var OtherPosition = SCNVector3(0.0, 0.0, 0.0)
        let HeightMultiplier: CGFloat = 1.5
        switch Other
        {
            case .Cones:
                Geo = SCNCone(topRadius: 0.0, bottomRadius: Side * 0.8, height: Height * HeightMultiplier)
            
            case .Pyramids:
                Geo = SCNPyramid(width: Side * 0.8, height: Height * HeightMultiplier, length: Side * 0.8)
            
            case .Lines:
                Geo = SCNBox(width: 0.08, height: 0.08, length: Height * HeightMultiplier, chamferRadius: 0.0)
                NeedsRotation = false
            
            case .Spheres:
                let SphereRadiusMultiplier: CGFloat = 0.4
                Geo = SCNSphere(radius: Side * SphereRadiusMultiplier)
                NeedsRotation = false
                OtherPosition = SCNVector3(0.0, 0.0, Height - Side * 1.5)
            
            case .Capsules:
                Geo = SCNCapsule(capRadius: Side * 0.1, height: Height * HeightMultiplier)
            
            default:
                fatalError("Unexpected shape found in MakeBlockWithOtherShape.")
        }
        Geo?.firstMaterial?.specular.contents = NSColor.white
        Geo?.firstMaterial?.diffuse.contents = Color
        Geo?.firstMaterial?.lightingModel = Model
        let OtherNode = SCNNode(geometry: Geo)
        if NeedsRotation
        {
            OtherNode.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        }
        OtherNode.position = OtherPosition
        Node.addChildNode(OtherNode)
        
        return Node
    }
    
    public static func MakeSphereWithOtherShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                                Height: CGFloat, Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let SGeo = SCNSphere(radius: Side / 2.0)
        SGeo.firstMaterial?.diffuse.contents = Color
        SGeo.firstMaterial?.specular.contents = NSColor.white
        SGeo.firstMaterial?.lightingModel = Model
        let Node = PSCNNode()
        Node.X = AtX
        Node.Y = AtY
        Node.addChildNode(SCNNode(geometry: SGeo))
        let BaseZ: CGFloat = 0.0
        Node.position = SCNVector3(0.0, 0.0, BaseZ)
        var Geo: SCNGeometry? = nil
        var NeedsRotation = true
        var Position = SCNVector3(0.0, 0.0, 0.0)
        let Other = Settings.GetEnum(ForKey: .SphereWithShape, EnumType: Shapes.self, Default: Shapes.Cones)
        switch Other
        {
            case .Blocks:
                Geo = SCNBox(width: Side / 2.5, height: Side / 2.5, length: Side / 2.5, chamferRadius: 0.0)
                NeedsRotation = false
                Position = SCNVector3(0.0, 0.0, Side * 0.55 + BaseZ)
            
            case .Cones:
                Geo = SCNCone(topRadius: 0.0, bottomRadius: Side * 0.4, height: Side * 2.0)
                Position = SCNVector3(0.0, 0.0, Side + BaseZ)
            
            case .Pyramids:
                Geo = SCNPyramid(width: Side * 0.4, height: Side * 2.0, length: Side * 0.4)
                Position = SCNVector3(0.0, 0.0, Side + BaseZ)
            
            case .Lines:
                Geo = SCNBox(width: 0.08, height: 0.08, length: Side * 2.0, chamferRadius: 0.0)
                NeedsRotation = false
                Position = SCNVector3(0.0, 0.0, Side + BaseZ)
            
            case .Capsules:
                Geo = SCNCapsule(capRadius: Side * 0.35, height: Side * 2.0)
                Position = SCNVector3(0.0, 0.0, Side + BaseZ)
            
            default:
                fatalError("Unexpected shape found in MakeSphereWithOtherShape.")
        }
        Geo?.firstMaterial?.specular.contents = NSColor.white
        Geo?.firstMaterial?.diffuse.contents = Color
        Geo?.firstMaterial?.lightingModel = Model
        let OtherNode = SCNNode(geometry: Geo)
        OtherNode.position = Position
        if NeedsRotation
        {
            OtherNode.eulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
        }
        Node.addChildNode(OtherNode)
        
        return Node
    }
    
    public static func MakeCombinedShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                         Height: CGFloat, Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Parent = PSCNNode()
        Parent.X = AtX
        Parent.Y = AtY
        
        switch Shape
        {
            case .CappedLines:
                Parent.addChildNode(MakeCappedLines(Side: Side, Color: Color, Height: Height, Model: Model)!)
            
            case .ComponentVariable:
                Parent.addChildNode(MakeStackedShape(Side: Side, Height: Height, Color: Color, Model: Model)!)
            
            case .RadiatingLines:
                Parent.addChildNode(MakeRadiatingLines(Side: Side, Color: Color, Model: Model)!)
            
            case .PerpendicularCircles:
                Parent.addChildNode(MakePerpendicularShape(Shape: .PerpendicularCircles, Side: Side,
                                                           AtX: AtX, AtY: AtY,
                                                           Height: Height, Color: Color, Model: Model)!)
            
            case .PerpendicularSquares:
                Parent.addChildNode(MakePerpendicularShape(Shape: .PerpendicularSquares, Side: Side,
                                                           AtX: AtX, AtY: AtY,
                                                           Height: Height, Color: Color, Model: Model)!)
            
            case .ThreeTriangles:
                Parent.addChildNode(MakeTouchingTriangles(Shape: .ThreeTriangles, Side: Side,
                                                          AtX: AtX, AtY: AtY, Height: Height,
                                                          Color: Color, Model: Model)!)
            
            case .BlockBases:
                Parent.addChildNode(MakeBlockWithOtherShape(Shape: .BlockBases, Side: Side,
                                                            AtX: AtX, AtY: AtY, Height: Height,
                                                            Color: Color, Model: Model)!)
            
            case .SphereBases:
                Parent.addChildNode(MakeSphereWithOtherShape(Shape: .BlockBases, Side: Side,
                                                             AtX: AtX, AtY: AtY, Height: Height,
                                                             Color: Color, Model: Model)!)
            
            default:
                return nil
        }
        
        return Parent
    }
}

