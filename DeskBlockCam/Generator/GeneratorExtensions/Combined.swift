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
        var CapLocation = Settings.GetEnum(ForKey: .CapLocation, EnumType: CapLocations.self,
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
    
    public static func MakePerpendicularShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                              Height: CGFloat, Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let Node = PSCNNode()
        Node.X = AtX
        Node.Y = AtY
        var Shape1: SCNGeometry? = nil
        var Shape2: SCNGeometry? = nil
        switch Shape
        {
            case .PerpendicularCircles:
                Shape1 = SCNCylinder(radius: 0.25, height: 0.05)
                Shape2 = SCNCylinder(radius: 0.25, height: 0.05)
            
            case .PerpendicularSquares:
                Shape1 = SCNBox(width: 0.25 * 2.0, height: 0.05, length: 0.25 * 2.0, chamferRadius: 0.0)
                Shape2 = SCNBox(width: 0.25 * 2.0, height: 0.05, length: 0.25 * 2.0, chamferRadius: 0.0)
            
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
    
    public static func MakeStackedShape(Side: CGFloat, Height: CGFloat, Color: NSColor) -> PSCNNode?
    {
        let Node = PSCNNode()
        var ShapeList = [Shapes]()
        let RawShapeList = Settings.GetString(ForKey: .StackedShapeList, Shapes.Blocks.rawValue)
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
            
            case .StackedShapes:
                Parent.addChildNode(MakeStackedShape(Side: Side, Height: Height, Color: Color)!)
            
            case .RadiatingLines:
                Parent.addChildNode(MakeRadiatingLines(Side: Side, Color: Color, Model: Model)!)
            
            case .PerpendicularCircles:
                Parent.addChildNode(MakePerpendicularShape(Shape: .PerpendicularCircles, Side: Side, AtX: AtX, AtY: AtY,
                                                           Height: Height, Color: Color, Model: Model)!)
            
            case .PerpendicularSquares:
                Parent.addChildNode(MakePerpendicularShape(Shape: .PerpendicularSquares, Side: Side, AtX: AtX, AtY: AtY,
                                                           Height: Height, Color: Color, Model: Model)!)
            
            default:
                return nil
        }
        
        return Parent
    }
}

