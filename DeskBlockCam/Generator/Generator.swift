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
    /// Get the dimensions of a cone given the pixel's color and side.
    /// - Parameter From: The pixel color.
    /// - Parameter Side: The calculated side value.
    /// - Returns: Tuple of the top and bottom sizes of the cone.
    public static func GetConeDimensions(From: NSColor, Side: CGFloat) -> (Top: CGFloat, Base: CGFloat)
    {
        let DoInvert = Settings.GetBoolean(ForKey: .ConeSwapTopBottom)
        let TopSize = Settings.GetEnum(ForKey: .ConeTopSize, EnumType: ConeTopSizes.self, Default: ConeTopSizes.Zero)
        let BaseSize = Settings.GetEnum(ForKey: .ConeBottomSize, EnumType: ConeBottomSizes.self, Default: ConeBottomSizes.Side)
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        From.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        var TopRadius: CGFloat = 0.0
        var TopSet = true
        switch TopSize
        {
            case .Zero:
                TopRadius = 0.0
            
            case .Hue:
                TopRadius = Side * Hue
            
            case .Saturation:
                TopRadius = Side * Saturation
            
            case .Side:
                TopRadius = Side
            
            case .Side10:
                TopRadius = Side * 0.1
            
            case .Side50:
                TopRadius = Side * 0.5
            
            default:
                TopSet = false
        }
        
        var BottomRadius: CGFloat = 0.0
        var BaseSet = true
        switch BaseSize
        {
            case .Zero: 
                BottomRadius = 0.0
            
            case .Hue:
                BottomRadius = Side * Hue
            
            case .Saturation:
                BottomRadius = Side * Saturation
            
            case .Side:
                BottomRadius = Side
            
            case .Side10:
                BottomRadius = Side * 0.1
            
            case .Side50:
                BottomRadius = Side * 0.25
            
            default:
                BaseSet = false
        }
        
        switch (TopSet, BaseSet)
        {
            case (false, false):
                BottomRadius = Side
                TopRadius = 0.0
            
            case (true, false):
                switch BaseSize
                {
                    case .Side10:
                        BottomRadius = TopRadius * 0.1
                    
                    case .Side50:
                        BottomRadius = TopRadius * 0.5
                    
                    default:
                        break
            }
            
            case (false, true):
                switch TopSize
                {
                    case .TenPercent:
                        TopRadius = BottomRadius * 0.1
                    
                    case .FiftyPercent:
                        TopRadius = BottomRadius * 0.5
                    
                    default:
                        break
            }
            
            case (true, true):
                if BottomRadius == 0.0 && TopRadius == 0.0
                {
                    BottomRadius = Side
                    TopRadius = 0.0
            }
        }
        
        if DoInvert
        {
            return (BottomRadius, TopRadius)
        }
        else
        {
            return (TopRadius, BottomRadius)
        }
    }
    
    /// Return the height/size for the shape given the color and attributes.
    /// - Parameter Color: The color used to determine the base height.
    /// - Parameter With: Attributes used to determine which part of the color to use and any extra
    ///                   modifications to the height.
    /// - Returns: Height for the shape.
    public static func HeightFor(Color: NSColor) -> CGFloat
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
                Height = Color.CMYK.C
            
            case .Magenta:
                Height = Color.CMYK.M
            
            case .Yellow:
                Height = Color.CMYK.Y
            
            case .Black:
                Height = Color.CMYK.K
            
            case .YUV_Y:
                Height = Color.YUV.Y
            
            case .YUV_U:
                Height = Color.YUV.U
            
            case .YUV_V:
                Height = Color.YUV.V
            
            case .GreatestRGB:
                Height = max(Color.redComponent, Color.greenComponent, Color.blueComponent)
            
            case .LeastRGB:
                Height = min(Color.redComponent, Color.greenComponent, Color.blueComponent)
            
            case .GreatestCMYK:
                Height = max(Color.CMYK.C, Color.CMYK.M, Color.CMYK.Y, Color.CMYK.K)
            
            case .LeastCMYK:
                Height = min(Color.CMYK.C, Color.CMYK.M, Color.CMYK.Y, Color.CMYK.K)
        }
        return Height * Exaggerate
    }
    
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
                let SphereGeo = SCNSphere(radius: Side / 2.0 * Height)
                return SphereGeo
            
            case .Capsules:
                let CapGeo = SCNCapsule(capRadius: Side / 5.0, height: Height)
                return CapGeo
            
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
            
            case .Cones:
          let (Top, Bottom) = GetConeDimensions(From: Color, Side: Side)
          let ConeGeo = SCNCone(topRadius: Top, bottomRadius: Bottom, height: Height * 2.0)
            return ConeGeo
            
            default:
                return nil
        }
    }
    
    /// Get the parameters needed to create an oval or oval-like shape.
    public static func GetOvalParameters(ShapeKey: SettingKeys) -> (Major: CGFloat, Minor: CGFloat)
    {
        let Length = Settings.GetEnum(ForKey: ShapeKey, EnumType: Distances.self, Default: Distances.Medium)
        switch Length
        {
            case .Long:
                return (3.0, 1.0)
            
            case .Medium:
                return (2.0, 1.0)
            
            case .Short:
                return (1.5, 1.0)
        }
    }
    
    public static func MakeNonStandardShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int, Height: CGFloat) -> SCNGeometry?
    {
        let CurrentShape = Shape
        switch CurrentShape
        {
            case .Circles:
                let Circle = SCNCircle.Geometry(Radius: Side / 2.0, Extrusion: 0.1)
                return Circle
            
            case .Squares:
                let Square = SCNBox(width: Side, height: Side, length: 0.1, chamferRadius: 0.0)
                return Square
            
            case .Triangles:
                let Triangle = SCNTriangle.Geometry(A: Float(Height * 1.5), B: Float(Height * 1.5), C: Float(Height * 1.5),
                                                    Scale: Float(Side * 2.0))
                return Triangle
            
            case .Triangles2D:
                let Triangle = SCNTriangle.Geometry(A: Float(Height * 0.1), B: Float(Height * 0.1), C: Float(Height * 0.1),
                                                    Scale: Float(Side * 2.0))
                return Triangle
            
            case .Ovals:
                let (Major, Minor) = GetOvalParameters(ShapeKey: .OvalLength)
                let Oval = SCNEllipse.Geometry(MajorAxis: Major, MinorAxis: Minor, Height: Height * 1.5)
                return Oval
            
            case .Diamonds:
                let (Major, Minor) = GetOvalParameters(ShapeKey: .DiamondLength)
                let Diamond = SCNDiamond.Geometry(MajorAxis: Major, MinorAxis: Minor, Height: Height * 1.5)
                return Diamond
            
            case .Stars:
                var ApexCount = Settings.GetInteger(ForKey: .StarApexCount)
                if Settings.GetBoolean(ForKey: .ApexesIncrease)
                {
                    ApexCount = ApexCount + Int(Height * 1.3)
                    if ApexCount > 12
                    {
                        ApexCount = 12
                    }
                }
                let StarShape = SCNStar.Geometry(VertexCount: ApexCount, Height: Double(Side),
                                                 Base: Double(Side / 2.0), ZHeight: Double(Height) * 2.0)
                return StarShape
            
            case .Polygons:
                let SideCount = Settings.GetInteger(ForKey: .PolygonSideCount)
                let NGon = SCNPolygon.Geometry(VertexCount: SideCount, Radius: Side / 2.0, Depth: Height * 2.0)
                return NGon
            
            case .Lines:
                var Width: CGFloat = 0.1
                switch Settings.GetEnum(ForKey: .LineThickness, EnumType: LineThicknesses.self, Default: LineThicknesses.Thin)
                {
                    case .Thick:
                        Width = 0.15
                    
                    case .Medium:
                        Width = 0.05
                    
                    case .Thin:
                        Width = 0.01
                }
                let Geo = SCNBox(width: Width, height: Width, length: Side, chamferRadius: 0.0)
                return Geo
            
            default:
                return nil
        }
    }
    
    public static func MakeComplexShape(Shape: Shapes, Side: CGFloat, AtX: Int, AtY: Int, Height: CGFloat,
                                        Color: NSColor, Model: SCNMaterial.LightingModel) -> PSCNNode?
    {
        let CurrentShape = Shape
        switch CurrentShape
        {
            case .HueTriangles:
                let Node = PSCNNode()
                Node.X = AtX
                Node.Y = AtY
                let HueT = SCNArrowHead.Geometry(Height: Side * 2.5, Base: Side * 1.0,
                                                 Inset: Side * 0.35, Extrusion: Height * 2.0)
                Node.geometry = HueT
                Node.geometry?.firstMaterial?.diffuse.contents = Color
                Node.geometry?.firstMaterial?.specular.contents = NSColor.white
                Node.geometry?.firstMaterial?.lightingModel = Model
                var Hue: CGFloat = 0.0
                var Saturation: CGFloat = 0.0
                var Brightness: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                Color.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
                let HueAngle = fmod((360.0 * Hue) + 180.0, 360.0)
                Node.rotation = SCNVector4(0.0, 0.0, 1.0, -HueAngle * CGFloat.pi / 180.0)
                return Node
            
            default:
                return nil
        }
    }
    
    /// Returns the current (as saved in user defaults) material lighting model.
    /// - Returns: Lighting model to use for material surfaces.
    public static func GetLightModel() -> SCNMaterial.LightingModel
    {
        switch Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self, Default: LightModels.Lambert)
        {
            case .Blinn:
                return .blinn
            
            case .Constant:
                return .constant
            
            case .Lambert:
                return .lambert
            
            case .Phong:
                return .phong
            
            case .Physical:
                return .physicallyBased
        }
    }
    
    /// Create a shape at the specified location with the passed attributes.
    /// - Parameter With: Pixellated colors.
    /// - Parameter AtX: Horizontal shape location.
    /// - Parameter AtY: Vertical shape location.
    /// - Returns: New shape node.
    public static func MakeShape(With Colors: [[NSColor]], AtX: Int, AtY: Int) -> PSCNNode
    {
        autoreleasepool
            {
                let FinalShape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
                let Node = PSCNNode()
                Node.name = "PixelNode"
                Node.X = AtX
                Node.Y = AtY
                let Height = HeightFor(Color: Colors[AtY][AtX])
                Node.Prominence = Height
                let Model = GetLightModel()
                
                let Side = Settings.GetDouble(ForKey: .Side)
                switch FinalShape
                {
                    //Variable shapes.
                    case .ComponentVariable:
                        break
                    
                    //2D shapes
                    case .Squares, .Circles, .Rectangles, .Stars2D, .Triangles2D,
                         .Polygons2D, .Oval2D, .Diamond2D:
                        var ZLocation: CGFloat = 0.0
                        let Node = Make2DShape(Shape: FinalShape, Side: CGFloat(Side), AtX: AtX, AtY: AtY, Height: Height,
                                               Color: Colors[AtY][AtX], ZLocation: &ZLocation)
                        return Node!
                    
                    //Combined shapes.
                    case .CappedLines, .StackedShapes, .RadiatingLines, .PerpendicularCircles,
                         .PerpendicularSquares, .BlockBases:
                        let Node = MakeCombinedShape(Shape: FinalShape, Side: CGFloat(Side), AtX: AtX, AtY: AtY,
                                                     Height: Height, Color: Colors[AtY][AtX],
                                                     Model: Model)
                        NeedsOrientationChange(Node!, FinalShape, Colors[AtY][AtX])
                        {
                            NeedsToRotate, EulerAngles in
                            if NeedsToRotate
                            {
                                if let Euler = EulerAngles
                                {
                                    Node?.eulerAngles = Euler
                                }
                            }
                        }
                        return Node!
                    
                    //Complex shapes.
                    case .HueTriangles:
                        let Node = MakeComplexShape(Shape: FinalShape, Side: CGFloat(Side), AtX: AtX, AtY: AtY,
                                                    Height: Height, Color: Colors[AtY][AtX],
                                                    Model: Model)
                        return Node!
                    
                    //Character sets.
                    case .Characters:
                        var FinalScale: Double = 0.0
                        let Geo = GenerateCharacterFromSet(Prominence: Height, FinalScale: &FinalScale)
                        Geo.firstMaterial?.diffuse.contents = Colors[AtY][AtX]
                        Geo.firstMaterial?.specular.contents = NSColor.white
                        Geo.firstMaterial?.lightingModel = Model
                        Node.geometry = Geo
                        Node.scale = SCNVector3(FinalScale, FinalScale, FinalScale)
                        NeedsOrientationChange(Node, FinalShape, Colors[AtY][AtX])
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
                        return Node
                    
                    //Non-standard shapes.
                    case .Triangles, .Ovals, .Diamonds, .Stars, .Polygons, .Lines:
                        let Geo = MakeNonStandardShape(Shape: FinalShape, Side: CGFloat(Side),
                                                       AtX: AtX, AtY: AtY, Height: Height)
                        Geo?.firstMaterial?.diffuse.contents = Colors[AtY][AtX]
                        Geo?.firstMaterial?.specular.contents = NSColor.white
                        Geo?.firstMaterial?.lightingModel = Model
                        Node.geometry = Geo
                        NeedsOrientationChange(Node, FinalShape, Colors[AtY][AtX])
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
                        return Node
                    
                    //Standard shapes.
                    case .Blocks, .Spheres, .Tubes, .Pyramids, .Cylinders, .Rings, .Capsules, .Cones:
                        let Geo = MakeSimpleShape(Shape: FinalShape, Side: CGFloat(Side), AtX: AtX,
                                                  AtY: AtY, Height: Height, Color: Colors[AtY][AtX])
                        Geo?.firstMaterial?.diffuse.contents = Colors[AtY][AtX]
                        Geo?.firstMaterial?.specular.contents = NSColor.white
                        Geo?.firstMaterial?.lightingModel = Model
                        Node.geometry = Geo
                        NeedsOrientationChange(Node, FinalShape, Colors[AtY][AtX])
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
                        return Node
                    
                    default:
                        break
                }
                
                return Node
        }
    }
    
    /// Determines if the passed node needs to be rotated in any (or any combination of) dimension.
    /// - Parameter Node: The node that may need to be rotated.
    /// - Parameter Shape: The shape.
    /// - Parameter Color: The color of the node.
    /// - Parameter DoesNeed: Trailing closure. First parameter (`Bool`) is true if the node should be rotated and
    ///                       false if not. The second parameter (`SCNVector3`) contains the Euler angles to use
    ///                       to rotate the node **if** the first parameter is `true`. If the first parameter is
    ///                       `false`, the second parameter will also be `false`.
    public static func NeedsOrientationChange(_ Node: PSCNNode, _ Shape: Shapes, _ Color: NSColor,
                                              DoesNeed: ((Bool, SCNVector3?) -> ())?)
    {
        var NeedsToRotate = false
        var EulerAngles: SCNVector3? = nil
        switch Shape
        {
            case .Rings:
                let RingOrientation = Settings.GetEnum(ForKey: .RingOrientation, EnumType: RingOrientations.self,
                                                       Default: RingOrientations.Flat)
                if RingOrientation == .Flat
                {
                    NeedsToRotate = true
                    EulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            }
            
            case .Tubes, .Cones, .Capsules, .CappedLines:
                NeedsToRotate = true
                EulerAngles = SCNVector3(90.0 * CGFloat.pi / 180.0, 0.0, 0.0)
            
            default:
                break
        }
        DoesNeed?(NeedsToRotate, EulerAngles)
    }
    
    /// Create a set of nodes to display in an SCNView.
    /// - Parameter Colors: Pixellated colors.
    /// - Parameter UIUpdate: Status update protocol to call for updating the UI.
    /// - Returns: Array of shape nodes.
    public static func MakeNodesFor(Colors: [[NSColor]], UIUpdate: StatusProtocol? = nil) -> [PSCNNode]
    {
        var Results = [PSCNNode]()
        
        var Count = 0
        let Total = Double(Colors.count * Colors[0].count)
        for Y in 0 ..< Colors.count
        {
            for X in 0 ..< Colors[Y].count
            {
                autoreleasepool
                    {
                        Results.append(MakeShape(With: Colors, AtX: X, AtY: Y))
                        Count = Count + 1
                        let Percent = 100.0 * Double(Count) / Total
                        UIUpdate?.UpdateStatus(With: .CreatingPercentUpdate, PercentComplete: Percent)
                }
            }
        }
        
        return Results
    }
    
    /// Process the image as defined in the passed attribute. Results placed in the passed scene.
    /// - Parameter Colors: Array of pixellated colors.
    /// - Parameter UIUpdate: Status update protocol for updating the UI.
    public static func Process(Colors: [[NSColor]],
                               UIUpdate: StatusProtocol? = nil) -> [PSCNNode]
    {
        UIUpdate?.UpdateStatus(With: .CreatingShapes)
        let NodeList = MakeNodesFor(Colors: Colors, UIUpdate: UIUpdate)
        UIUpdate?.UpdateStatus(With: .CreatingDone)
        return NodeList
    }
}
