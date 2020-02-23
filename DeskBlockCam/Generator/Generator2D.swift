//
//  Generator2D.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension Generator
{
    public static func Make2DShape(Side: CGFloat, AtX: Int, AtY: Int, Height: CGFloat, Color: NSColor,
                                   ZLocation: inout CGFloat) -> PSCNNode?
    {
        let Shape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        var Node = PSCNNode()
        switch Shape
        {
            case .Squares:
                let Geo = SCNBox(width: Side * 1.5, height: Side * 1.5, length: 0.05, chamferRadius: 0.0)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Rectangles:
                let Geo = SCNBox(width: Side * 1.5, height: Side * 0.75, length: 0.05, chamferRadius: 0.0)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Circles:
                let Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Stars2D:
                let Dim = Double(Side * 1.5)
                var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
                if Settings.GetBoolean(ForKey: .ApexesIncrease)
                {
                    ApexCount = ApexCount + Int(Height * 1.3)
                    if ApexCount > 12
                    {
                        ApexCount = 12
                    }
                }
                let Geo = SCNStar.Geometry(VertexCount: ApexCount, Height: Dim, Base: Dim * 0.5, ZHeight: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Polygons2D:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                let NGon = SCNPolygon.Geometry(VertexCount: SideCount, Radius: Side / 2.0, Depth: 0.05)
                Node = PSCNNode(geometry: NGon, X: AtX, Y: AtY)
            
            case .Oval2D:
                let (Major, Minor) = GetOvalParameters(ShapeKey: .OvalLength)
                let Geo = SCNEllipse.Geometry(MajorAxis: Major, MinorAxis: Minor, Height: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
                Node.scale = SCNEllipse.ReciprocalScale()
            
            case .Diamond2D:
                let (Major, Minor) = GetOvalParameters(ShapeKey: .DiamondLength)
                let Geo = SCNDiamond.Geometry(MajorAxis: Major, MinorAxis: Minor, Height: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            default:
                return nil
        }
        
        ZLocation = Height * 2.0
        Node.geometry?.firstMaterial?.diffuse.contents = Color
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        Node.geometry?.firstMaterial?.lightingModel = GetLightModel()
        return Node
    }
}

