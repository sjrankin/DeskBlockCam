//
//  Generator.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class Generator
{
    /// Return the height/size for the shape given the color and attributes.
    /// - Parameter Color: The color used to determine the base height.
    /// - Parameter With: Attributes used to determine which part of the color to use and any extra
    ///                   modifications to the height.
    /// - Returns: Height for the shape.
    public static func HeightFor(Color: NSColor, With Attributes: ProcessingAttributes) -> CGFloat
    {
        let Exaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                            Default: VerticalExaggerations.Medium)
        var Exaggerate: CGFloat = 0.0
        switch Exaggeration
        {
            case .None:
                Exaggerate = 1.0
            
            case .Small:
                Exaggerate = 1.2
            
            case .Medium:
                Exaggerate = 1.5
            
            case .Large:
                Exaggerate = 2.0
        }
        var Height: CGFloat = 0.0
        let Determinate = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                           Default: HeightDeterminations.Brightness)
        switch Determinate
        {
            case .Hue:
                Height = Color.hueComponent
            
            case .Saturation:
                Height = Color.saturationComponent
            
            case .Brightness:
                Height = Color.brightnessComponent
            
            case .Red:
                Height = Color.redComponent
            
            case .Green:
                Height = Color.greenComponent
            
            case .Blue:
                Height = Color.blueComponent
            
            case .Cyan:
                Height = Color.cyanComponent
            
            case .Magenta:
                Height = Color.magentaComponent
            
            case .Yellow:
                Height = Color.yellowComponent
            
            case .Black:
                Height = Color.blackComponent
            
            case .YUV_Y:
                Height = 1.0
            
            case .YUV_U:
                Height = 1.0
            
            case .YUV_V:
                Height = 1.0
            
            case .Greatest:
                Height = max(Color.redComponent, Color.greenComponent, Color.blueComponent)
            
            case .Least:
                Height = min(Color.redComponent, Color.greenComponent, Color.blueComponent)
        }
        return Height * Exaggerate
    }
    
    public static func MakeSimpleShape(With Attributes: ProcessingAttributes, AtX: Int, AtY: Int, Height: CGFloat) -> SCNGeometry?
    {
        let Side = Attributes.Side
        let CurrentShape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        switch CurrentShape
        {
            case .Blocks:
                let BlockOptions = Attributes.GetOptionsFor(.Blocks) as? BlockOptionalParameters
                let ChamferSetting = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self,
                                                      Default: BlockChamferSizes.None)
                let Chamfer = BlockOptionalParameters.ChamferSize(From: ChamferSetting)
                let BlockGeo = SCNBox(width: Side, height: Side, length: Height, chamferRadius: Chamfer)
                return BlockGeo
            
            case .Spheres:
                let SphereGeo = SCNSphere(radius: Side / 2.0 * Height)
                return SphereGeo
            
            case .Tubes:
                let TubeGeo = SCNTube(innerRadius: Side * Height * 0.05, outerRadius: Side * Height * 0.1, height: Height)
                return TubeGeo
            
            case .Pyramids:
                let PyGeo = SCNPyramid(width: Side * Height * 0.1, height: Side * Height * 0.1, length: Height)
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
            default:
                return nil
        }
    }
    
    /// Create a shape at the specified location with the passed attributes.
    /// - Parameter With: Set of attributes to use to create a shape.
    /// - Parameter AtX: Horizontal shape location.
    /// - Parameter AtY: Vertical shape location.
    /// - Returns: New shape node.
    public static func MakeShape(With Attributes: ProcessingAttributes, AtX: Int, AtY: Int) -> PSCNNode
    {
        autoreleasepool
            {
                var FinalShape: Shapes = .Blocks
                if Attributes.Shape == .NoShape
                {
                    FinalShape = .Blocks
                }
                else
                {
                    FinalShape = Attributes.Shape
                }
                let Node = PSCNNode()
                Node.name = "PixelNode"
                Node.X = AtX
                Node.Y = AtY
                let Height = HeightFor(Color: Attributes.Colors[AtY][AtX], With: Attributes)
                Node.Prominence = Height
                var Model = SCNMaterial.LightingModel.lambert
                let LightModel = Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self, Default: LightModels.Lambert)
                switch LightModel
                {
                    case .Blinn:
                        Model = .blinn
                    
                    case .Constant:
                        Model = .constant
                    
                    case .Lambert:
                        Model = .lambert
                    
                    case .Phong:
                        Model = .phong
                    
                    case .Physical:
                        Model = .physicallyBased
                }
                
                switch FinalShape
                {
                    case .Blocks, .Spheres, .Tubes, .Pyramids, .Cylinders, .Rings:
                        let Geo = MakeSimpleShape(With: Attributes, AtX: AtX, AtY: AtY, Height: Height)
                        Geo?.firstMaterial?.diffuse.contents = Attributes.Colors[AtY][AtX]
                        Geo?.firstMaterial?.specular.contents = NSColor.white
                        Geo?.firstMaterial?.lightingModel = Model
                        Node.geometry = Geo
                        NeedsOrientationChange(Node, Attributes.Colors[AtY][AtX], Attributes)
                        {
                            NeedsToRotate, EulerAngles in
                            if NeedsToRotate
                            {
                                if let Euler = EulerAngles
                                {
                                    Node.eulerAngles = Euler
                                }
                            }
                        }
                    
                    default:
                        break
                }
                
                return Node
        }
    }
    
    /// Determines if the passed node needs to be rotated in any (or any combination of) dimension.
    /// - Parameter Node: The node that may need to be rotated.
    /// - Parameter Color: The color of the node.
    /// - Parameter Options: Processing attributes for the image.
    /// - Parameter DoesNeed: Trailing closure. First parameter (`Bool`) is true if the node should be rotated and
    ///                       false if not. The second parameter (`SCNVector3`) contains the Euler angles to use
    ///                       to rotate the node **if** the first parameter is `true`. If the first parameter is
    ///                       `false`, the second parameter will also be `false`.
    public static func NeedsOrientationChange(_ Node: PSCNNode, _ Color: NSColor, _ Options: ProcessingAttributes,
                                              DoesNeed: ((Bool, SCNVector3?) -> ())?)
    {
        var NeedsToRotate = false
        var EulerAngles: SCNVector3? = nil
        switch Options.Shape
        {
            case .Rings:
                let RingOrientation = Settings.GetEnum(ForKey: .RingOrientation, EnumType: RingOrientations.self,
                                                       Default: RingOrientations.Flat)
                    if RingOrientation == .Flat
                    {
                        NeedsToRotate = true
                        EulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
                    }
            
            default:
                break
        }
        DoesNeed?(NeedsToRotate, EulerAngles)
    }
    
    /// Create a set of nodes to display in an SCNView.
    /// - Parameter Attributes: Data that tells how to construct each node as well as containing
    ///                         color data.
    /// - Parameter UIUpdate: Status update protocol to call for updating the UI.
    /// - Returns: Array of shape nodes.
    public static func MakeNodesFor(Attributes: ProcessingAttributes, UIUpdate: StatusProtocol? = nil) -> [PSCNNode]
    {
        var Results = [PSCNNode]()
        if Attributes.Colors.count < 1
        {
            return Results
        }
        
        var Count = 0
        let Total = Double(Attributes.Colors.count * Attributes.Colors[0].count)
        for Y in 0 ..< Attributes.Colors.count
        {
            for X in 0 ..< Attributes.Colors[Y].count
            {
                autoreleasepool
                    {
                        Results.append(MakeShape(With: Attributes, AtX: X, AtY: Y))
                        Count = Count + 1
                        let Percent = 100.0 * Double(Count) / Total
                        UIUpdate?.UpdateStatus(With: .CreatingPercentUpdate, PercentComplete: Percent)
                }
            }
        }
        
        return Results
    }
    
    /// Process the image as defined in the passed attribute. Results placed in the passed scene.
    /// - Parameter Attributes: Defines how to create the image.
    /// - Parameter UIUpdate: Status update protocol for updating the UI.
    public static func Process(Attributes: ProcessingAttributes,
                               UIUpdate: StatusProtocol? = nil) -> [PSCNNode]
    {
        UIUpdate?.UpdateStatus(With: .CreatingShapes)
        let NodeList = MakeNodesFor(Attributes: Attributes, UIUpdate: UIUpdate)
        UIUpdate?.UpdateStatus(With: .CreatingDone)
        return NodeList
    }
}
