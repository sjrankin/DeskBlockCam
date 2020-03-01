//
//  SimpleShapesGenerator.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/1/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension Generator
{
    /// Make simple shapes here. Simple is defined as built-in to SceneKit.
    /// - Parameter Shape: The shape to create.
    /// - Parameter Side: The side of the pixel side.
    /// - Parameter AtX: The horizontal location of the shape.
    /// - Parameter AtY: The vertical location of the shape.
    /// - Parameter Height: The height/prominence of the color.
    /// - Parameter Color: The color of the shape.
    /// - Returns: Geometry of the shape.
    public static func MakeSimpleShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int,
                                       Height: CGFloat, Color: NSColor) -> SCNGeometry?
    {
        let CurrentShape = Shape
        switch CurrentShape
        {
            case .Blocks:
                let ChamferSetting = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self,
                                                      Default: BlockChamferSizes.None)
                let Chamfer = BlockOptionalParameters.ChamferSize(From: ChamferSetting)
                let BlockGeo = SCNBox(width: Side, height: Side, length: Height, chamferRadius: Chamfer)
                return BlockGeo
            
            case .Spheres:
                let Behavior = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self, Default: .Size)
                var Geo = SCNGeometry()
                if Behavior == .Size
                {
                    Geo = SCNSphere(radius: Side / 2.0 * (Height + 1.0))
                }
                else
                {
                    Geo = SCNSphere(radius: Side / 2.0)
                }
                return Geo
            
            case .Capsules:
                let CapGeo = SCNCapsule(capRadius: Side / 2.0, height: Height)
                return CapGeo
            
            case .Tubes:
                let TubeGeo = SCNTube(innerRadius: Side * Height * 0.2, outerRadius: Side * Height * 0.4, height: Height)
                return TubeGeo
            
            case .Pyramids:
                let PyGeo = SCNPyramid(width: Side * Height * 0.1, height: Height / 3.0, length: Side * Height * 0.1)
                return PyGeo
            
            case .Cylinders:
                let CyGeo = SCNCylinder(radius: Side * Height * 0.1, height: Height)
                return CyGeo
            
            case .Rings:
                let DonutSize = Settings.GetEnum(ForKey: .DonutHoleSize, EnumType: DonutHoleSizes.self,
                                                 Default: DonutHoleSizes.Medium)
                var HoleSize: CGFloat = 0.7
                switch DonutSize
                {
                    case .Small:
                        HoleSize = 0.35
                    
                    case .Medium:
                        HoleSize = 0.7
                    
                    case .Large:
                        HoleSize = 0.9
                }
                let RingGeo = SCNTorus(ringRadius: Height, pipeRadius: Height * HoleSize)
                return RingGeo
            
            case .Cones:
                let (Top, Bottom) = GetConeDimensions(From: Color, Side: Side)
                let ConeGeo = SCNCone(topRadius: Top, bottomRadius: Bottom, height: Height * 2.0)
                return ConeGeo
            
            default:
                return nil
        }
    }
}
