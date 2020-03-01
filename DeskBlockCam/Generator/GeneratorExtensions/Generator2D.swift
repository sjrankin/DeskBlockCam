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
    public static func Make2DShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int, Height: CGFloat, Color: NSColor,
                                   ZLocation: inout CGFloat) -> PSCNNode?
    {
        var Node = PSCNNode()
        var ColorUse = ColorControls.Height
        if let (_, ColorControl) = Settings.Get2DAxisAndColorInfo(Shape)
        {
            ColorUse = ColorControl
        }
        let FinalHeight = ColorUse == .Size ? Height + 1.0 : Height
        var Geo = SCNGeometry()
        switch Shape
        {
            case .Squares:
                if ColorUse == .Height
                {
                    Geo = SCNBox(width: Side * 1.5, height: Side * 1.5, length: 0.05, chamferRadius: 0.0)
                }
                else
                {
                    Geo = SCNBox(width: Side * FinalHeight, height: Side * FinalHeight, length: 0.05, chamferRadius: 0.0)
                }
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Rectangles:
                if ColorUse == .Height
                {
                    Geo = SCNBox(width: Side * 1.5, height: Side * 0.75, length: 0.05, chamferRadius: 0.0)
                }
                else
                {
                    Geo = SCNBox(width: Side * FinalHeight, height: Side * FinalHeight * 0.75, length: 0.05, chamferRadius: 0.0)
                }
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Circles:
                if ColorUse == .Height
                {
                    Geo = SCNCylinder(radius: Side * 0.85, height: 0.05)
                }
                else
                {
                    Geo = SCNCylinder(radius: Side * FinalHeight, height: 0.05)
                }
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Triangles2D:
                if ColorUse == .Height
                {
                    Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: 1.0)
                }
                else
                {
                    Geo = SCNTriangle.Geometry(A: 0.05, B: 0.05, C: 0.05, Scale: Float(FinalHeight * 1.5))
                }
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Stars2D:
                var Dim = Double(Side * 1.5)
                if ColorUse == .Size
                {
                    Dim = Double(FinalHeight * 1.5)
                }
                var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
                if Settings.GetBoolean(ForKey: .ApexesIncrease)
                {
                    ApexCount = ApexCount + Int(Height * 1.3)
                    if ApexCount > 12
                    {
                        ApexCount = 12
                    }
                }
                Geo = SCNStar.Geometry(VertexCount: ApexCount, Height: Dim, Base: Dim * 0.5, ZHeight: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Polygons2D:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                if ColorUse == .Height
                {
                    Geo = SCNPolygon.Geometry(VertexCount: SideCount, Radius: Side / 2.0, Depth: 0.05)
                }
                else
                {
                    Geo = SCNPolygon.Geometry(VertexCount: SideCount, Radius: FinalHeight / 2.0, Depth: 0.05)
                }
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            case .Oval2D:
                var (Major, Minor) = GetOvalParameters(ShapeKey: .OvalLength)
                if ColorUse == .Size
                {
                    Major = Major * FinalHeight
                    Minor = Minor * FinalHeight
                }
                Geo = SCNEllipse.Geometry(MajorAxis: Major, MinorAxis: Minor, Height: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
                Node.scale = SCNEllipse.ReciprocalScale()
            
            case .Diamond2D:
                var (Major, Minor) = GetOvalParameters(ShapeKey: .DiamondLength)
                if ColorUse == .Size
                {
                    Major = Major * FinalHeight
                    Minor = Minor * FinalHeight
                }
                Geo = SCNDiamond.Geometry(MajorAxis: Major, MinorAxis: Minor, Height: 0.05)
                Node = PSCNNode(geometry: Geo, X: AtX, Y: AtY)
            
            default:
                return nil
        }
        
        if ColorUse == .Height
        {
            ZLocation = Height * 2.0
        }
        else
        {
            ZLocation = Height * 0.1
        }
        Node.geometry?.firstMaterial?.diffuse.contents = Color
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        Node.geometry?.firstMaterial?.lightingModel = GetLightModel()
        return Node
    }
}

