//
//  ProcessedViewController.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/3/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class ProcessedViewController: NSViewController, SCNSceneRendererDelegate
{
    public weak var Delegate: ProcessedProtocol? = nil
    
    /// Standard prominence multiplier.
    let PMul: CGFloat = 1.0
    
    /// Initialize the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShapeSelector.selectedSegment = 0
        ProcessedImage.delegate = self
        ProcessedImage.preferredFramesPerSecond = 10
        ProcessedImage.wantsLayer = true
        ProcessedImage.layer?.backgroundColor = NSColor.black.cgColor
        BottomBar.wantsLayer = true
        BottomBar.layer?.backgroundColor = NSColor.systemTeal.cgColor
        
        InitializeScene()
    }
    
    /// The processed view's scene.
    var Scene: SCNScene? = nil
    
    /// Initialize the SCNView.
    func InitializeScene()
    {
        let Scene = SCNScene()
        ProcessedImage.scene = Scene
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 95.0
        CameraNode = SCNNode()
        CameraNode?.name = "Camera Node"
        CameraNode?.camera = Camera
        CameraNode?.position = SCNVector3(0.0, 0.0, 15.0)
        Scene.rootNode.addChildNode(CameraNode!)
        
        let Light = SCNLight()
        Light.type = .omni
        Light.color = NSColor.white
        if ProcessedImage.renderingAPI != .metal
        {
            Light.intensity = 2000
        }
        let LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(-30.0, 15.0, 20.0)
        Scene.rootNode.addChildNode(LightNode)
        
        Scene.background.contents = NSColor.black
        
        ProcessedImage.allowsCameraControl = true
        ProcessedImage.showsStatistics = true
    }
    
    /// The camera node. It is available to the rest of the class because other code may change
    /// its z position to better fit the result in the available space.
    var CameraNode: SCNNode? = nil
    
    /// Semaphore for parsing the image to prevent things from getting confused.
    var ParseLock: NSObject = NSObject()
    
    /// Parses the pixellated image and returns a list of colors, one for each pixellated block.
    /// - Parameter Image: The pixellated image to parse.
    /// - Parameter BlockSize: The size of each pixellated region.
    /// - Parameter HBlocks: On output, will contain the number of horizontal pixellated regions.
    /// - Parameter VBlocks: On output, will contain the number of vertical pixellated regions.
    /// - Returns: List of colors in YX order.
    func ParseImage(_ Image: NSImage, BlockSize: CGFloat, HBlocks: inout Int, VBlocks: inout Int) -> [[NSColor]]
    {
        Delegate?.ImageForDebug(Image, ImageType: .Pixellated)
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
                }
            }
        }
        return Colors
    }
    
    /// Return a prominence value used to determine size and/or Z location of individual shapes.
    /// - Parameter Color: The color whose prominence will be returned.
    /// - Returns: A value to use for setting size and/or Z location of shapes.
    func ColorProminence(_ Color: NSColor) -> CGFloat
    {
        return Color.brightnessComponent
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
        switch CurrentNodeShape
        {
            case 0:
                //Box
                Node = PSCNNode(geometry: SCNBox(width: Side,
                                                 height: Side,
                                                 length: Prominence * PMul,
                                                 chamferRadius: Chamfer),
                                X: AtX, Y: AtY)
            
            case 1:
                //Sphere
                Node = PSCNNode(geometry: SCNSphere(radius: Prominence * PMul), X: AtX, Y: AtY)
            
            case 2:
                //ring
                Node = PSCNNode(geometry: SCNTorus(ringRadius: Prominence * PMul, pipeRadius: Prominence * PMul * 0.3),
                                X: AtX, Y: AtY)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case 3:
                //cone
                Node = PSCNNode(geometry: SCNCone(topRadius: 0.0, bottomRadius: Prominence, height: Prominence),
                                X: AtX, Y: AtY)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case 4:
                //floating square
                Node = PSCNNode(geometry: SCNPlane(width: Side + (Prominence * 0.2), height: (Prominence * 0.2)),
                                X: AtX, Y: AtY)
            
            case 5:
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
    
    /// Holds the master node of the scene. All shapes are added to this node rather than to the
    /// scene's root node.
    var MasterNode: SCNNode? = nil
    
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
        for SomeNode in MasterNode!.childNodes
        {
            autoreleasepool
                {
                    let Node = SomeNode as! PSCNNode
                    let Color = Colors[Node.Y][Node.X]
                    let Prominence = ColorProminence(Color)
                    Node.SetProminence(Double(Prominence))
                    switch CurrentNodeShape
                    {
                        case 0:
                            //box
                            if let Geo = Node.geometry as? SCNBox
                            {
                                Geo.length = Prominence * PMul
                        }
                        
                        case 1:
                            //sphere
                            if let Geo = Node.geometry as? SCNSphere
                            {
                                Geo.radius = Prominence * PMul
                        }
                        
                        case 2:
                            //ring
                            if let Geo = Node.geometry as? SCNTorus
                            {
                                Geo.ringRadius = Prominence * PMul
                                Geo.pipeRadius = Prominence * PMul * 0.3
                        }
                        
                        case 3:
                            //cone
                            if let Geo = Node.geometry as? SCNCone
                            {
                                Geo.bottomRadius = Prominence * PMul
                                Geo.height = Prominence * PMul
                        }
                        
                        case 4:
                            //Floating squares
                            if let Geo = Node.geometry as? SCNPlane
                            {
                                Geo.width = Side + (Prominence * 0.2)
                                Geo.height = Side + (Prominence * 0.2)
                                let OldPos = Node.position
                                Node.position = SCNVector3(OldPos.x, OldPos.y, Prominence * 2.0 * PMul)
                        }
                        
                        case 5:
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
    }
    
    /// Draw the nodes using the supplied colors from a pixellated image. If the shape type has changed,
    /// the existing scene has all shapes removed and new ones created, which takes a while. Otherwise,
    /// the existing shape nodes are reused and edited in-place.
    /// - Parameter With: Set of colors from the pixellated source image in YX order.
    /// - Parameter HShapeCount: Number of horizontal shapes.
    /// - Parameter VShapeCount: Number of vertical shapes.
    /// - Parameter NodeShape: Indicates the shape to draw.
    func DrawNodes(With Colors: [[NSColor]], HShapeCount: Int, VShapeCount: Int, _ NodeShape: Int)
    {
        let Side: CGFloat = 0.5
        if CurrentNodeShape != NodeShape
        {
            CurrentNodeShape = NodeShape
            MasterNode?.removeFromParentNode()
            MasterNode = nil
        }
        if MasterNode != nil
        {
            UpdateNodes(With: Colors, HShapeCount: HShapeCount, VShapeCount: VShapeCount, Side: Side)
            return
        }
        MasterNode = SCNNode()
        MasterNode?.name = "Master Node"
        MasterNode?.position = SCNVector3(0.0, 0.0, 0.0)
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
                        MasterNode?.addChildNode(Node)
                }
            }
        }
        ProcessedImage.scene?.rootNode.addChildNode(MasterNode!)
        let NewHeight = MinimizeBezel()
        CameraNode?.position = SCNVector3(CameraNode!.position.x,
                                          CameraNode!.position.y,
                                          CGFloat(NewHeight))
    }
    
    /// Calculate the camera position for a small "bezel" (eg, border around the processed image) to
    /// maximize the image in the view.
    /// - Note: This function moves the camera to determine the best view. The camera is returned to its
    ///         original location when done.
    /// - Returns: Recommended Z location of the camera to minimize wasted, empty space.
    func MinimizeBezel() -> Double
    {
        var OriginalZ: CGFloat = 15.0
        let POV = ProcessedImage.pointOfView
        if let RootNode = GetNode(WithName: "Master Node", InScene: ProcessedImage.scene!)
        {
            if let CameraNode = GetNode(WithName: "Camera Node", InScene: ProcessedImage.scene!)
            {
                OriginalZ = CameraNode.position.z
                for CameraHeight in stride(from: 1.0, to: 100.0, by: 0.1)
                {
                    CameraNode.position = SCNVector3(CameraNode.position.x,
                                                     CameraNode.position.y,
                                                     CGFloat(CameraHeight))
                    if AllInView(View: ProcessedImage, Node: MasterNode!, PointOfView: POV!)
                    {
                        CameraNode.position = SCNVector3(CameraNode.position.x,
                                                         CameraNode.position.y,
                                                         OriginalZ)
                        return CameraHeight + 1.4
                    }
                }
                CameraNode.position = SCNVector3(CameraNode.position.x,
                                                 CameraNode.position.y,
                                                 OriginalZ)
            }
        }
        
        return Double(OriginalZ)
    }
    
    /// Returns a node with the specified name in the specified scene.
    /// - Parameter WithName: The name of the node to return. **Names must match exactly**. If multiple nodes have the same name,
    ///                       the first node encountered will be returned.
    /// - Parameter InScene: The scene to search for the named node.
    /// - Returns: The node with the specified name on success, nil if not found.
    public  func GetNode(WithName: String, InScene: SCNScene) -> SCNNode?
    {
        return DoGetNode(FromNode: InScene.rootNode, WithName: WithName)
    }
    
    /// Returns a node with the specified name in the passed node. Recursively (so large trees will use up a lot of stack space)
    /// searches child node.
    /// - Parameter FromNode: The parent node to search.
    /// - Parameter WithName: The name of the node to return. **Names must match exactly**.
    /// - Returns: The first node whose name matches `WithName`. Nil if not found. If multiple nodes have the same name, only the
    ///            first is returned.
    private  func DoGetNode(FromNode: SCNNode, WithName: String) -> SCNNode?
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
    
    /// Determines if all child nodes (including the node itself) are in the frustrum of the passed scene.
    /// - Note: See [How to know if a node is visible in scene or not in SceneKit?](https://stackoverflow.com/questions/47828491/how-to-know-if-node-is-visible-in-screen-or-not-in-scenekit)
    /// - Parameter View: The SCNView used to determine visibility.
    /// - Parameter Node: The node to check for visibility. All child nodes (and all descendent nodes) also checked.
    /// - Parameter PointOfView: The point of view node for the scene.
    /// - Returns: True if all nodes are visible, false if not.
    private  func AllInView(View: SCNView, Node: SCNNode, PointOfView: SCNNode) -> Bool
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
    
    /// Process a new image from the caller.
    /// - Parameter Source: The source image to process/display.
    /// - Parameter FrameIndex: The frame number of the image.
    public func NewImage(_ Source: CIImage, _ FrameIndex: Int)
    {
        objc_sync_enter(CloseLock)
        defer{ objc_sync_exit(CloseLock) }
        if let Reduced = Pixellator.Pixellate(Source)
        {
            let NSRep = NSCIImageRep(ciImage: Source)
            let Original = NSImage(size: NSRep.size)
            Original.addRepresentation(NSRep)
            var HBlocks: Int = 0
            var VBlocks: Int = 0
            let Colors = self.ParseImage(Reduced, BlockSize: 16, HBlocks: &HBlocks, VBlocks: &VBlocks)
            DispatchQueue.main.sync
                {
                    let ShapeIndex = self.ShapeSelector.selectedSegment
                    self.Busy = true
                    Delegate?.ImageForDebug(Original, ImageType: .Original)
                    self.DrawNodes(With: Colors, HShapeCount: HBlocks, VShapeCount: VBlocks, ShapeIndex)
                    self.Busy = false
            }
        }
    }
    
    /// Nuber of dropped frames.
    public var DroppedFrameCount = 0
    
    /// Busy flag.
    var Busy = false
    
    /// Save frames flag.
    var SaveFrames = false
    
    /// Holds the current shape to use.
    var CurrentNodeShape = -1
    
    /// Lock to synchronize closing the window.
    var CloseLock = NSObject()
    
    /// Close the window.
    func CloseWindow()
    {
        objc_sync_enter(CloseLock)
        defer{ objc_sync_exit(CloseLock) }
        self.dismiss(self)
    }
    
    /// Save the passed image in the frames directory. Intended to be used later to create a video.
    /// - Parameter Frame: The image to save.
    func SaveFrame(_ Frame: NSImage)
    {
        FileIO.SaveFrame(Frame, FrameID: FrameCount)
        FrameCount = FrameCount + 1
    }
    
    /// Frame count for number of processed frames.
    var FrameCount = 0
    
    @IBAction func HandleChangedShape(_ sender: Any)
    {
    }
    
    /// Handle the record button pressed. Update the UI. Save frames or combine saved frames into
    /// a video, depending on the state of recording.
    /// - Parameter sender: Not used.
    @IBAction func HandleRecordButtonPressed(_ sender: Any)
    {
        if Recording
        {
            Recording = false
        }
        else
        {
            Recording = true
        }
        if Recording
        {
            RecordButton.image = NSImage(named: "BigRedCircle")
            SaveFrames = true
        }
        else
        {
            RecordButton.image = NSImage(named: "BigCircle")
            SaveFrames = false
        }
    }
    
    var Recording: Bool = false
    
    @IBOutlet weak var RecordButton: NSButton!
    @IBOutlet weak var ShapeSelector: NSSegmentedControl!
    @IBOutlet weak var BottomBar: NSView!
    @IBOutlet weak var ProcessedImage: SCNView!
}
