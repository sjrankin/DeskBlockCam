//
//  SampleGenerator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/24/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension Generator
{
    /// Returns a single shape intended to be used for sample displays.
    /// - Note: The `X` and `Y` properties in the returned shape will be set to 0.
    /// - Parameter Shape: The shape that will be returned.
    /// - Parameter Color: The color of the shape.
    /// - Parameter Side: The side length for the shape.
    /// - Returns: The shape as a `PSCNNode` ready to be inserted in to a scene. Nil on error.
    public static func SingleShape(_ Shape: Shapes, Color: NSColor, Side: CGFloat) -> PSCNNode?
    {
        var ZLocation: CGFloat = 0.0
        var Sample: PSCNNode? = nil
        let Height = HeightFor(Color: Color)
        
        switch Shape
        {
            case .Blocks:
                let Geo = MakeSimpleShape(Shape: .Blocks, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
            
            case .BlockBases:
                Sample = MakeBlockWithOtherShape(Shape: .BlockBases, Side: Side, AtX: 0, AtY: 0,
                                                 Height: Height, Color: Color, Model: GetLightModel())
            
            case .Characters:
                var FinalScale: Double = 0.0
                let Geo = GenerateCharacterFromSet(Prominence: Height, FinalScale: &FinalScale)
                Geo.firstMaterial?.diffuse.contents = Color
                Geo.firstMaterial?.specular.contents = NSColor.white
                Geo.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo, X: 0, Y: 0)
                Sample?.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                NeedsOrientationChange(Sample!, .Characters, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Capsules:
                let Geo = MakeSimpleShape(Shape: .Capsules, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Cylinders, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Circles:
                Sample = Make2DShape(Shape: .Circles, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .CappedLines:
                Sample = MakeCombinedShape(Shape: .CappedLines, Side: Side, AtX: 0, AtY: 0,
                                           Height: Height, Color: Color, Model: GetLightModel())
            
            case .ComponentVariable:
                break
            
            case .Cones:
                let Geo = MakeSimpleShape(Shape: .Cones, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Cylinders, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Cylinders:
                let Geo = MakeSimpleShape(Shape: .Cylinders, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Cylinders, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Diamond2D:
                Sample = Make2DShape(Shape: .Diamond2D, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .Diamonds:
                let Geo = MakeNonStandardShape(Shape: .Diamonds, Side: Side, AtX: 0, AtY: 0,
                                               Height: Height)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Diamonds, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .HueTriangles:
                Sample = MakeComplexShape(Shape: .HueTriangles, Side: CGFloat(Side), AtX: 0, AtY: 0,
                                          Height: Height, Color: Color,
                                          Model: GetLightModel())
            
            case .Lines:
                let Geo = MakeNonStandardShape(Shape: .Lines, Side: Side, AtX: 0, AtY: 0,
                                               Height: Height)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Lines, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Oval2D:
                Sample = Make2DShape(Shape: .Oval2D, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .Ovals:
                let Geo = MakeNonStandardShape(Shape: .Ovals, Side: Side, AtX: 0, AtY: 0,
                                               Height: Height)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Ovals, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .PerpendicularCircles:
                Sample = MakeCombinedShape(Shape: .PerpendicularCircles, Side: Side, AtX: 0, AtY: 0,
                                           Height: Height, Color: Color, Model: GetLightModel())
            
            case .PerpendicularSquares:
                Sample = MakeCombinedShape(Shape: .PerpendicularSquares, Side: Side, AtX: 0, AtY: 0,
                                           Height: Height, Color: Color, Model: GetLightModel())
            
            case .Polygons:
                let Geo = MakeNonStandardShape(Shape: .Polygons, Side: Side, AtX: 0, AtY: 0,
                                               Height: Height)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Polygons, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Polygons2D:
                Sample = Make2DShape(Shape: .Polygons2D, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .Pyramids:
                let Geo = MakeSimpleShape(Shape: .Pyramids, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Pyramids, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .RadiatingLines:
                Sample = MakeCombinedShape(Shape: .RadiatingLines, Side: Side, AtX: 0, AtY: 0,
                                           Height: Height, Color: Color, Model: GetLightModel())
            
            case .Rectangles:
                Sample = Make2DShape(Shape: .Rectangles, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .Rings:
                let Geo = MakeSimpleShape(Shape: .Rings, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Rings, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Spheres:
                let Geo = MakeSimpleShape(Shape: .Spheres, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
            
            case .Squares:
                Sample = Make2DShape(Shape: .Squares, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .StackedShapes:
                Sample = MakeCombinedShape(Shape: .StackedShapes, Side: Side, AtX: 0, AtY: 0,
                                           Height: Height, Color: Color, Model: GetLightModel())
                break
            
            case .Stars:
                let Geo = MakeNonStandardShape(Shape: .Stars, Side: Side, AtX: 0, AtY: 0,
                                               Height: Height)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Stars, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Stars2D:
                Sample = Make2DShape(Shape: .Stars2D, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .Triangles:
                let Geo = MakeNonStandardShape(Shape: .Triangles, Side: Side, AtX: 0, AtY: 0,
                                               Height: Height)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Triangles, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            case .Triangles2D:
                Sample = Make2DShape(Shape: .Triangles2D, Side: Side, AtX: 0, AtY: 0, Height: Height,
                                     Color: Color, ZLocation: &ZLocation)
            
            case .Tubes:
                let Geo = MakeSimpleShape(Shape: .Tubes, Side: Side, AtX: 0, AtY: 0,
                                          Height: Height, Color: Color)
                Geo?.firstMaterial?.diffuse.contents = Color
                Geo?.firstMaterial?.specular.contents = NSColor.white
                Geo?.firstMaterial?.lightingModel = GetLightModel()
                Sample = PSCNNode(geometry: Geo!, X: 0, Y: 0)
                NeedsOrientationChange(Sample!, .Tubes, Color)
                {
                    NeedsToRotate, EulerAngles in
                    if NeedsToRotate
                    {
                        if let Euler = EulerAngles
                        {
                            Sample?.eulerAngles = Euler
                        }
                    }
            }
            
            default:
                print("Encountered unexpected shape: \(Shape.rawValue)")
        }
        return Sample
    }
    
    public static func MakeQuickShape(Shape: Shapes, Side: CGFloat, Color: NSColor) -> SCNNode
    {
        var Node: SCNNode? = nil
        switch Shape
        {
            case .Blocks:
                Node = SCNNode(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: Side * 0.05))
            
            case .Spheres:
                Node = SCNNode(geometry: SCNSphere(radius: Side))
            
            case .Capsules:
                let Geo = SCNCapsule(capRadius: Side * 0.25, height: Side)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Cylinders:
                let Geo = SCNCylinder(radius: Side, height: Side * 2)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Cones:
                let (Top, Bottom) = GetConeDimensions(From: Color, Side: Side)
                let Geo = SCNCone(topRadius: Top, bottomRadius: Bottom, height: Side * 2)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Lines:
                let Geo = SCNCapsule(capRadius: 0.1, height: Side)
                Node = SCNNode(geometry: Geo)
            
            case .Triangles:
                let Geo = SCNTriangle.Geometry(A: Float(Side), B: Float(Side), C: Float(Side), Scale: 1.0)
                Node = SCNNode(geometry: Geo)
            
            case .Ovals:
                let (Major, Minor) = GetOvalParameters(ShapeKey: .OvalLength)
                let Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: Side)
                Node = SCNNode(geometry: Geo)
                Node?.scale = SCNEllipse.ReciprocalScale()
            
            case .Stars:
                var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
                if Settings.GetBoolean(ForKey: .ApexesIncrease)
                {
                    ApexCount = ApexCount + Int(Side * 1.3)
                    if ApexCount > 10
                    {
                        ApexCount = 10
                    }
                }
                let Geo = SCNStar.Geometry(VertexCount: ApexCount, Height: Double(Side), Base: Double(Side / 2.0),
                                           ZHeight: Double(Side))
                Node = SCNNode(geometry: Geo)
            
            case .Squares:
                let Geo = SCNBox(width: Side * 1.5, height: Side * 1.5, length: 0.05, chamferRadius: 0.0)
                Node = SCNNode(geometry: Geo)
            
            case .Circles:
                let Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                Node = SCNNode(geometry: Geo)
                Node?.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Oval2D:
                let (Major, Minor) = GetOvalParameters(ShapeKey: .OvalLength)
                let Geo = SCNEllipse.Geometry(MajorAxis: Side * Major, MinorAxis: Side * Minor, Height: 0.05)
                Node = SCNNode(geometry: Geo)
                Node?.scale = SCNEllipse.ReciprocalScale()
            
            case .Triangles2D:
                let Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
                Node = SCNNode(geometry: Geo)
            
            default:
                Node = SCNNode(geometry: SCNBox(width: Side, height: Side, length: Side, chamferRadius: Side * 0.05))
        }
        Node?.geometry?.firstMaterial?.diffuse.contents = Color
        Node?.geometry?.firstMaterial?.specular.contents = NSColor.white
        Node?.geometry?.firstMaterial?.lightingModel = GetLightModel()
        return Node!
    }
}
