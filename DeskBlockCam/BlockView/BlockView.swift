//
//  BlockView.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Provides a block view in an `SCNView` control.
class BlockView: SCNView
{
    /// Delegate for reporting processing status.
    public weak var StatusDelegate: StatusProtocol? = nil
    
    /// Initializer.
    /// - Parameter frame: The frame of the view.
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Clear the scene of any nodes.
    func ClearScene()
    {
        #if true
        if MasterNode != nil
        {
            MasterNode?.removeFromParentNode()
            MasterNode = nil
        }
        if LiveViewMasterNode != nil
        {
            LiveViewMasterNode?.removeFromParentNode()
            LiveViewMasterNode = nil
        }
        #else
        DispatchQueue.main.async
            {
                if self.MasterNode != nil
                {
                    self.MasterNode?.removeFromParentNode()
                    self.MasterNode = nil
                }
                if self.LiveViewMasterNode != nil
                {
                    self.LiveViewMasterNode?.removeFromParentNode()
                    self.LiveViewMasterNode = nil
                }
        }
        #endif
    }
    
    /// Process the passed image then display the result.
    /// - Parameter Image: The image to process.
    /// - Parameter Options: Determines how the image is processd.
    func ProcessImage(_ Image: NSImage, Options: ProcessingAttributes)
    {
        StatusDelegate?.UpdateStatus(With: .ResetStatus)
        StatusDelegate?.UpdateStatus(With: .PreparingImage)
        ClearScene()
        if MasterNode == nil
        {
            MasterNode = SCNNode()
            MasterNode?.name = "Master Node"
        }
        let Resized = Shrinker.ResizeImage(Image: Image, Longest: 1024)
        let ResizedData = Resized.tiffRepresentation
        let ResizedCI = CIImage(data: ResizedData!)
        let Pixellated = Pixellator.Pixellate(ResizedCI!)
        StatusDelegate?.UpdateStatus(With: .PreparationDone)
        var HBlocks: Int = 0
        var VBlocks: Int = 0
        let Colors = ParseImage(Pixellated!, BlockSize: 16, HBlocks: &HBlocks, VBlocks: &VBlocks)
        Options.Colors = Colors
        Options.HorizontalBlocks = HBlocks
        Options.VerticalBlocks = VBlocks
        let Nodes = Generator.Process(Attributes: Options, UIUpdate: StatusDelegate)
        
        for Y in 0 ... VBlocks - 1
        {
            for X in 0 ... HBlocks - 1
            {
                autoreleasepool
                    {
                        let Color = Colors[Y][X]
                        let Prominence = ColorProminence(Color) * 0.5
                        let XLocation: Float = Float(X - (HBlocks / 2))
                        let YLocation: Float = Float(Y - (VBlocks / 2))
                        var ZLocation = (Prominence * PMul) * PMul
                        //let Node = CreateNode(Side: Options.Side, Color: Color, Prominence: Prominence,
                        //                      AtX: X, AtY: Y, Z: &ZLocation)
                        if let Node = GetNodeAt(X: X, Y: Y, From: MasterNode!)
                        {
                        Node.SetProminence(Double(Prominence))
                        Node.position = SCNVector3(XLocation * Float(Options.Side),
                                                   YLocation * Float(Options.Side),
                                                   Float(ZLocation))
                        MasterNode?.addChildNode(Node)
                        }
                        else
                        {
                            print("Node not found at \(X),\(Y)")
                        }
                }
            }
        }
        
        self.StatusDelegate?.UpdateStatus(With: .AddingShapes)
        prepare([MasterNode!])
        {
            Completed in
            if Completed
            {
                self.scene?.rootNode.addChildNode(self.MasterNode!)
                self.StatusDelegate?.UpdateStatus(With: .AddingDone)
            }
        }
    }
    
    func GetNodeAt(X: Int, Y: Int, From: SCNNode) -> PSCNNode?
    {
        for Node in From.childNodes
        {
            if let PNode = Node as? PSCNNode
            {
                if PNode.X == X && PNode.Y == Y
                {
                    return PNode
                }
            }
        }
        return nil
    }
    
    /// Process the passed image then display the result. Current attributes from user settings are used.
    /// - Parameter Image: The image to process.
    func ProcessImage(_ Image: NSImage)
    {
        let Options = ProcessingAttributes.Create()
        ProcessImage(Image, Options: Options)
    }
    
    /// Common initialization.
    func Initialize()
    {
        self.scene = SCNScene()
        AddCamera()
        AddLight()
        self.scene?.background.contents = NSColor.black
        self.allowsCameraControl = true
        self.showsStatistics = true
    }
    
    /// Add a camera to the scene.
    func AddCamera()
    {
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        CameraNode = SCNNode()
        CameraNode!.name = "Camera Node"
        CameraNode!.camera = Camera
        CameraNode!.position = SCNVector3(0.0, 0.0, 15.0)
        self.scene?.rootNode.addChildNode(CameraNode!)
    }
    
    /// Add a light to the scene.
    func AddLight()
    {
        let Light = SCNLight()
        Light.type = .omni
        Light.color = NSColor.white
        LightNode = SCNNode()
        LightNode!.light = Light
        LightNode!.position = SCNVector3(-10.0, 10.0, 15.0)
        self.scene?.rootNode.addChildNode(LightNode!)
    }
    
    /// The camera's node in the scene.
    var CameraNode: SCNNode? = nil
    /// The light's node in the scene.
    var LightNode: SCNNode? = nil
    
    func Snapshot() -> NSImage
    {
        return self.snapshot()
    }
    
    /// Master node for still image processing.
    var MasterNode: SCNNode? = nil
    
    /// Determines if all child nodes (including the node itself) are in the frustrum of the passed scene.
    /// - Note: See [How to know if a node is visible in scene or not in SceneKit?](https://stackoverflow.com/questions/47828491/how-to-know-if-node-is-visible-in-screen-or-not-in-scenekit)
    /// - Parameter View: The SCNView used to determine visibility.
    /// - Parameter Node: The node to check for visibility. All child nodes (and all descendent nodes) also checked.
    /// - Parameter PointOfView: The point of view node for the scene.
    /// - Returns: True if all nodes are visible, false if not.
    private func AllInView(View: SCNView, Node: SCNNode, PointOfView: SCNNode) -> Bool
    {
        if !View.isNode(Node, insideFrustumOf: PointOfView)
        {
            return false
        }
        for ChildNode in Node.childNodes
        {
            if !AllInView(View: View, Node: ChildNode, PointOfView: PointOfView)
            {
                return false
            }
        }
        return true
    }
    
    /// Calculate the camera position for a small "bezel" (eg, border around the processed image) to
    /// maximize the image in the view.
    /// - Note: This function moves the camera to determine the best view. The camera is returned to its
    ///         original location when done.
    /// - Parameter IsLiveView: If true, the live view is being processed. Otherwise, a still image is
    ///                         being processed.
    /// - Returns: Recommended Z location of the camera to minimize wasted, empty space.
    func MinimizeBezel(IsLiveView: Bool = true) -> Double
    {
        var OriginalZ: CGFloat = 15.0
        let POV = self.pointOfView
        if let RootNode = GetNode(WithName: "Master Node", InScene: self.scene!)
        {
            if let CameraNode = GetNode(WithName: "Camera Node", InScene: self.scene!)
            {
                OriginalZ = CameraNode.position.z
                for CameraHeight in stride(from: 1.0, to: 100.0, by: 0.1)
                {
                    CameraNode.position = SCNVector3(CameraNode.position.x,
                                                     CameraNode.position.y,
                                                     CGFloat(CameraHeight))
                    if IsLiveView
                    {
                        if AllInView(View: self, Node: LiveViewMasterNode!, PointOfView: POV!)
                        {
                            CameraNode.position = SCNVector3(CameraNode.position.x,
                                                             CameraNode.position.y,
                                                             OriginalZ)
                            return CameraHeight + 1.4
                        }
                    }
                    else
                    {
                        if AllInView(View: self, Node: MasterNode!, PointOfView: POV!)
                        {
                            CameraNode.position = SCNVector3(CameraNode.position.x,
                                                             CameraNode.position.y,
                                                             OriginalZ)
                            return CameraHeight + 1.4
                        }
                    }
                }
                CameraNode.position = SCNVector3(CameraNode.position.x,
                                                 CameraNode.position.y,
                                                 OriginalZ)
            }
        }
        
        return Double(OriginalZ)
    }
    
    /// Parses the pixellated image and returns a list of colors, one for each pixellated block.
    /// - Parameter Image: The pixellated image to parse.
    /// - Parameter BlockSize: The size of each pixellated region.
    /// - Parameter HBlocks: On output, will contain the number of horizontal pixellated regions.
    /// - Parameter VBlocks: On output, will contain the number of vertical pixellated regions.
    /// - Parameter IsLiveView: If true, the image being parsed will be used in a live view. Otherwise,
    ///                         the image will be used for a still view.
    /// - Returns: List of colors in YX order.
    func ParseImage(_ Image: NSImage, BlockSize: CGFloat, HBlocks: inout Int, VBlocks: inout Int,
                    IsLiveView: Bool = true) -> [[NSColor]]
    {
        if !IsLiveView
        {
            StatusDelegate?.UpdateStatus(With: .ParsingImage)
        }
        HBlocks = Int(Image.size.width / BlockSize)
        VBlocks = Int(Image.size.height / BlockSize)
        var Colors = Array(repeating: Array(repeating: NSColor.black, count: Int(HBlocks)), count: Int(VBlocks))
        var ImageRep: NSBitmapImageRep? = nil
        if let Tiff = Image.tiffRepresentation
        {
            ImageRep = NSBitmapImageRep(data: Tiff)
        }
        else
        {
            return [[NSColor]]()
        }
        let Total = VBlocks * HBlocks
        var Count = 0
        for Y in 0 ..< VBlocks
        {
            for X in 0 ..< HBlocks
            {
                autoreleasepool
                    {
                        let PixelX = X * Int(BlockSize) + Int(BlockSize / 2.0)
                        let PixelY = Y * Int(BlockSize) + Int(BlockSize / 2.0)
                        //Online commentators say this is very slow. However, for our purposes and
                        //for how we use it, it is sufficient.
                        let Color = ImageRep?.colorAt(x: PixelX, y: PixelY)
                        Colors[VBlocks - 1 - Y][X] = Color!
                        if !IsLiveView
                        {
                            Count = Count + 1
                            let Percent = 100.0 * Double(Count) / Double(Total)
                            StatusDelegate?.UpdateStatus(With: .ParsingPercentUpdate, PercentComplete: Percent)
                        }
                }
            }
        }
        if !IsLiveView
        {
            StatusDelegate?.UpdateStatus(With: .ParsingDone)
        }
        return Colors
    }
    
    /// Returns a node with the specified name in the specified scene.
    /// - Parameter WithName: The name of the node to return. **Names must match exactly**. If multiple nodes have the same name,
    ///                       the first node encountered will be returned.
    /// - Parameter InScene: The scene to search for the named node.
    /// - Returns: The node with the specified name on success, nil if not found.
    public func GetNode(WithName: String, InScene: SCNScene) -> SCNNode?
    {
        return DoGetNode(FromNode: InScene.rootNode, WithName: WithName)
    }
    
    /// Returns a node with the specified name in the passed node. Recursively (so large trees will use up a lot of stack space)
    /// searches child node.
    /// - Parameter FromNode: The parent node to search.
    /// - Parameter WithName: The name of the node to return. **Names must match exactly**.
    /// - Returns: The first node whose name matches `WithName`. Nil if not found. If multiple nodes have the same name, only the
    ///            first is returned.
    private func DoGetNode(FromNode: SCNNode, WithName: String) -> SCNNode?
    {
        if let NodesName = FromNode.name
        {
            if NodesName == WithName
            {
                return FromNode
            }
        }
        for ChildNode in FromNode.childNodes
        {
            if let NamedNode = DoGetNode(FromNode: ChildNode, WithName: WithName)
            {
                return NamedNode
            }
        }
        return nil
    }
    
    // MARK: - Live view processing.
    
    /// Multiplier for the prominence for live view processing.
    let PMul: CGFloat = 1.0
    
    /// Lock for processing the live view.
    var CloseLock = NSObject()
    
    /// Process the passed image. This function works on the assumption the image is from a camera
    /// stream.
    /// - Note: Due to performance constrains when processing live views, only a small subset of
    ///         shapes are supported.
    /// - Parameter Source: The image to processed.
    /// - Parameter FrameIndex: Not currently used.
    public func ProcessLiveView(_ Source: CIImage, _ FrameIndex: Int)
    {
        objc_sync_enter(CloseLock)
        defer{ objc_sync_exit(CloseLock) }
        if let Reduced = Pixellator.Pixellate(Source)
        {
            var HBlocks: Int = 0
            var VBlocks: Int = 0
            let Colors = ParseImage(Reduced, BlockSize: 16, HBlocks: &HBlocks, VBlocks: &VBlocks)
            DispatchQueue.main.sync
                {
                    DrawLiveViewNodes(Colors: Colors, HShapeCount: HBlocks, VShapeCount: VBlocks,
                                      NodeShape: Settings.GetEnum(ForKey: .LiveViewShape, EnumType: Shapes.self, Default: Shapes.Blocks))
            }
        }
    }
    
    /// Return a prominence value used to determine size and/or Z location of individual shapes.
    /// - Parameter Color: The color whose prominence will be returned.
    /// - Returns: A value to use for setting size and/or Z location of shapes.
    func ColorProminence(_ Color: NSColor) -> CGFloat
    {
        return Color.brightnessComponent
    }
    
    /// Udpate existing nodes with new colors.
    /// - Note: This function uses nodes already in the scene rather than recreate nodes, which is
    ///         very expensive in terms of performance. Any time a base shape changes, `CreateNode`
    ///         must be called, not `UpdateNodes`.
    /// - Note: All nodes are updated in this function.
    /// - Parameter: With: Array of pixellated colors from the pixellated source image in YZ order.
    /// - Parameter HShapeCount: Number of horizontal shapes.
    /// - Parameter VShapeCount: Number of vertical shapes.
    /// - Parameter Side: Base shape side length.
    func UpdateNodes(With Colors: [[NSColor]], HShapeCount: Int, VShapeCount: Int, Side: CGFloat)
    {
        for SomeNode in LiveViewMasterNode!.childNodes
        {
            autoreleasepool
                {
                    let Node = SomeNode as! PSCNNode
                    let Color = Colors[Node.Y][Node.X]
                    let Prominence = ColorProminence(Color)
                    Node.SetProminence(Double(Prominence))
                    switch CurrentLiveViewNodeShape
                    {
                        case .Blocks:
                            //box
                            if let Geo = Node.geometry as? SCNBox
                            {
                                Geo.length = Prominence * PMul
                        }
                        
                        case .Spheres:
                            //sphere
                            if let Geo = Node.geometry as? SCNSphere
                            {
                                Geo.radius = Prominence * PMul
                        }
                        
                        case .Rings:
                            //ring
                            if let Geo = Node.geometry as? SCNTorus
                            {
                                Geo.ringRadius = Prominence * PMul
                                Geo.pipeRadius = Prominence * PMul * 0.3
                        }
                        
                        case .Cones:
                            //cone
                            if let Geo = Node.geometry as? SCNCone
                            {
                                Geo.bottomRadius = Prominence * PMul
                                Geo.height = Prominence * PMul
                        }
                        
                        case .Squares:
                            //Floating squares
                            if let Geo = Node.geometry as? SCNPlane
                            {
                                Geo.width = Side + (Prominence * 0.2)
                                Geo.height = Side + (Prominence * 0.2)
                                let OldPos = Node.position
                                Node.position = SCNVector3(OldPos.x, OldPos.y, Prominence * 2.0 * PMul)
                        }
                        
                        case .Tubes:
                            //tube
                            if let Geo = Node.geometry as? SCNTube
                            {
                                Geo.outerRadius = Side + Prominence * 0.2
                                Geo.innerRadius = Side * 0.5 + Prominence * 0.2
                                Geo.height = Prominence * PMul * 2.0
                        }
                        
                        default:
                            break
                    }
                    Node.geometry?.firstMaterial?.diffuse.contents = Color
            }
        }
        #if false
        let PImage = ProcessedImage.snapshot()
        Delegate?.ImageForDebug(PImage, ImageType: .Snapshot)
        let DHistogram = HistogramDisplay(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        DHistogram.DisplayHistogram(For: PImage, RemoveFirst: 5)
        let HImage = NSImage(data: DHistogram.dataWithPDF(inside: DHistogram.bounds))
        Delegate?.ImageForDebug(HImage!, ImageType: .Histogram)
        if SaveFrames
        {
            SaveFrame(PImage)
        }
        #endif
    }
    
    /// Create a new shape for each pixellated location in the image.
    /// - Parameter Side: The general side length of each shape. Forms a square for the base region of the shape.
    /// - Parameter Color: The color for the pixellated region. Used as material value values for the
    ///                    surfaces as well as prominence calculation.
    /// - Parameter AtX: The horizontal coordinate of the shape.
    /// - Parameter AtY: The vertical coordinate of the shape.
    /// - Parameter Z: The Z value of the shape. Changed only for some shapes.
    /// - Returns: New instance of a `PSCNNode` to use to populate the final scene.
    func CreateNode(Side: CGFloat, Color: NSColor, Prominence: CGFloat, AtX: Int, AtY: Int,
                    Z: inout CGFloat) -> PSCNNode
    {
        let Chamfer: CGFloat = 0.0
        var Node: PSCNNode!
        switch CurrentLiveViewNodeShape
        {
            case .Blocks:
                //Box
                Node = PSCNNode(geometry: SCNBox(width: Side,
                                                 height: Side,
                                                 length: Prominence * PMul,
                                                 chamferRadius: Chamfer),
                                X: AtX, Y: AtY)
            
            case .Spheres:
                //Sphere
                Node = PSCNNode(geometry: SCNSphere(radius: Prominence * PMul), X: AtX, Y: AtY)
            
            case .Rings:
                //ring
                Node = PSCNNode(geometry: SCNTorus(ringRadius: Prominence * PMul, pipeRadius: Prominence * PMul * 0.3),
                                X: AtX, Y: AtY)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Cones:
                //cone
                Node = PSCNNode(geometry: SCNCone(topRadius: 0.0, bottomRadius: Prominence, height: Prominence),
                                X: AtX, Y: AtY)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Squares:
                //floating square
                Node = PSCNNode(geometry: SCNPlane(width: Side + (Prominence * 0.2), height: (Prominence * 0.2)),
                                X: AtX, Y: AtY)
            
            case .Tubes:
                //tube
                Node = PSCNNode(geometry: SCNTube(innerRadius: Side * 0.5 + Prominence * 0.2,
                                                  outerRadius: Side + Prominence * 0.2,
                                                  height: Prominence * PMul * 2.0),
                                X: AtX, Y: AtY)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            default:
                break
        }
        Node.geometry?.firstMaterial?.diffuse.contents = Color
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        Node.geometry?.firstMaterial?.lightingModel = .lambert
        return Node
    }
    
    /// Create a 3D shape for each passed color. Add it to the `LiveViewMasterNode`.
    /// - Parameter Colors: Array of colors from the original image. One shape will be created for each color.
    /// - Parameter HShapeCount: Number of horizontal colors.
    /// - Parameter VShapeCount: Number of vertical colors.
    /// - Parameter NodeShape: The shape to create.
    func DrawLiveViewNodes(Colors: [[NSColor]], HShapeCount: Int, VShapeCount: Int, NodeShape: Shapes)
    {
        let Side: CGFloat = 0.5
        if CurrentLiveViewNodeShape != NodeShape
        {
            CurrentLiveViewNodeShape = NodeShape
            LiveViewMasterNode?.removeFromParentNode()
            LiveViewMasterNode = nil
        }
        if LiveViewMasterNode != nil
        {
            UpdateNodes(With: Colors, HShapeCount: HShapeCount, VShapeCount: VShapeCount, Side: Side)
            return
        }
        LiveViewMasterNode = SCNNode()
        LiveViewMasterNode?.name = "Master Node"
        LiveViewMasterNode?.position = SCNVector3(0.0, 0.0, 0.0)
        for Y in 0 ... VShapeCount - 1
        {
            for X in 0 ... HShapeCount - 1
            {
                autoreleasepool
                    {
                        let Color = Colors[Y][X]
                        let Prominence = ColorProminence(Color) * 0.5
                        let XLocation: Float = Float(X - (HShapeCount / 2))
                        let YLocation: Float = Float(Y - (VShapeCount / 2))
                        var ZLocation = (Prominence * PMul) * PMul
                        let Node = CreateNode(Side: Side, Color: Color, Prominence: Prominence,
                                              AtX: X, AtY: Y, Z: &ZLocation)
                        Node.SetProminence(Double(Prominence))
                        Node.position = SCNVector3(XLocation * Float(Side),
                                                   YLocation * Float(Side),
                                                   Float(ZLocation))
                        LiveViewMasterNode?.addChildNode(Node)
                }
            }
        }
        self.scene?.rootNode.addChildNode(LiveViewMasterNode!)
        let NewHeight = MinimizeBezel()
        CameraNode?.position = SCNVector3(CameraNode!.position.x,
                                          CameraNode!.position.y,
                                          CGFloat(NewHeight))
    }
    
    /// The current shape to use in live view mode.
    var CurrentLiveViewNodeShape = Shapes.NoShape
    /// The master node for live view mode.
    var LiveViewMasterNode: SCNNode? = nil
}
