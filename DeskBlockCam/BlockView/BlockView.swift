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
    /// Initial camera location.
    public static var InitialCameraLocation = SCNVector3(0.0, 0.0, 15.0)
    /// Initial camera orientation.
    public static var InitialCameraOrientation = SCNVector4(0.0, 0.0, 0.0, 1.0)
    /// Initial camera rotation.
    public static var InitialCameraRotation = SCNVector4(0.0, 0.0, 0.0, 0.0)
    
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
    
    /// Deinitializer. Remove KVO on cameras.
    deinit
    {
         PositionObservation = nil
         OrientationObservation = nil
         RotationObservation = nil
    }
    
    /// Clear the scene of any nodes.
    func ClearScene()
    {
        #if true
        if MasterNode != nil
        {
            print("Removing master node from scene.")
            MasterNode?.removeFromParentNode()
            MasterNode = nil
        }
        if LiveViewMasterNode != nil
        {
            print("Removing live view master node from scene.")
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
    
    func ColorProminence(_ Color: NSColor) -> CGFloat
    {
        var Ex: CGFloat = 1.0
        switch Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                Default: VerticalExaggerations.Small)
        {
            case .None:
                Ex = 1.0
            
            case .Small:
                Ex = 1.5
            
            case .Medium:
                Ex = 2.2
            
            case .Large:
                Ex = 3.5
        }
        var Height: CGFloat = 0.0
        switch Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                Default: HeightDeterminations.Brightness)
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
        if Settings.GetBoolean(ForKey: .InvertHeight)
        {
            Height = 1.0 - Height
        }
        return Height * Ex
    }
    
    /// Sets the antialiasing mode for the view using stored user defaults.
    func SetAntialiasing()
    {
        let AAMode = Settings.GetEnum(ForKey: .Antialiasing, EnumType: AntialiasingModes.self,
                                      Default: AntialiasingModes.x4)
        switch AAMode
        {
            case .None:
                self.antialiasingMode = .none
            
            case .x2:
                self.antialiasingMode = .multisampling2X
            
            case .x4:
                self.antialiasingMode = .multisampling4X
            
            case .x8:
                self.antialiasingMode = .multisampling8X
            
            case .x16:
                self.antialiasingMode = .multisampling16X
        }
    }
    
    func XProcessImage(_ Image: NSImage, Options: ProcessingAttributes)
    {
        DispatchQueue.global(qos: .background).async
            {
                //self.DoProcessImage(Image, Options: Options)
        }
    }
    
    /// Process the passed image then display the result.
    /// - Parameter Image: The image to process.
    /// - Parameter Options: Determines how the image is processd.
    func ProcessImage(_ Image: NSImage, Options: ProcessingAttributes)
    {
        StatusDelegate?.UpdateStatus(With: .ResetStatus)
        let Start = CACurrentMediaTime()
        Initialize()
         SetAntialiasing()
        StatusDelegate?.UpdateDuration(NewDuration: 0.0)
        StatusDelegate?.UpdateStatus(With: .PreparingImage)
//        ClearScene()
        let AfterClear = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterClear)
        if MasterNode == nil
        {
            MasterNode = SCNNode()
            MasterNode?.name = "Master Node"
        }
        let Resized = Shrinker.ResizeImage(Image: Image, Longest: 1024)
        let ResizedData = Resized.tiffRepresentation
        let ResizedCI = CIImage(data: ResizedData!)
        let AfterResize = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterResize)
        let Pixellated = Pixellator.Pixellate(ResizedCI!)
        let AfterPixellate = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterPixellate)
        StatusDelegate?.UpdateStatus(With: .PreparationDone)
        var HBlocks: Int = 0
        var VBlocks: Int = 0
        let Colors = ParseImage(Pixellated!, BlockSize: 16, HBlocks: &HBlocks, VBlocks: &VBlocks,
                                IsLiveView: false)
        let AfterParsing = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterParsing)
        Options.Colors = Colors
        Options.HorizontalBlocks = HBlocks
        Options.VerticalBlocks = VBlocks
        
        StatusDelegate?.UpdateStatus(With: .CreatingShapes)
        let Total = Double(VBlocks * HBlocks)
        var Count: Double = 0.0
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
                        let ShapeNode = Generator.MakeShape(With: Options, AtX: X, AtY: Y)
                        ShapeNode.SetProminence(Double(Prominence))
                        ShapeNode.position = SCNVector3(XLocation * Float(Options.Side),
                                                        YLocation * Float(Options.Side),
                                                        Float(ZLocation))
                        MasterNode?.addChildNode(ShapeNode)
                        Count = Count + 1.0
                        let Percent = 100.0 * (Count / Total)
                        StatusDelegate?.UpdateStatus(With: .CreatingPercentUpdate, PercentComplete: Percent)
                }
            }
        }
        StatusDelegate?.UpdateStatus(With: .CreatingDone)
        let AfterShapes = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterShapes)
        
        scene?.rootNode.addChildNode(MasterNode!)
        #if false
        self.StatusDelegate?.UpdateStatus(With: .AddingShapes)
        prepare([MasterNode!])
        {
            Completed in
            if Completed
            {
                //DispatchQueue.main.async
                //    {
                self.scene?.rootNode.addChildNode(self.MasterNode!)
                print("Added master node to scene.")
                self.StatusDelegate?.UpdateStatus(With: .AddingDone)
                let AfterAdded = CACurrentMediaTime() - Start
                self.StatusDelegate?.FinalizeDuration(WithDuration: AfterAdded)
                //}
            }
        }
        #endif
        #if false
        if !AddedObserversCamera
        {
            if let CameraNode = self.pointOfView
            {
                DefaultCameraNode = CameraNode
                PositionObservation = DefaultCameraNode?.observe(\.position, options: [.initial, .new])
                {
                    (camera, change) in
                    print("camera position: \(camera.position)")
                }
                OrientationObservation = DefaultCameraNode?.observe(\.position, options: [.initial, .new])
                {
                    (camera, change) in
                    print("camera orientation: \(camera.orientation)")
                }
                RotationObservation = DefaultCameraNode?.observe(\.position, options: [.initial, .new])
                {
                    (camera, change) in
                    print("camera rotation: \(camera.rotation)")
                }
                AddedObserversCamera = true
            }
        }
        #endif
    }
    
    var AddedObserversCamera = false
    
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
        self.allowsCameraControl = true
        self.scene = SCNScene()
        #if true
        AddCamera()
//        DefaultCameraNode = self.pointOfView
//        DefaultCameraNode!.addObserver(self, forKeyPath: "DefaultCameraNode.position",
//                                       options: NSKeyValueObservingOptions.new,
//                                       context: nil)
        #else
        AddCamera()
        #endif
        AddLight()
        self.scene?.background.contents = NSColor.black
        #if DEBUG
        self.showsStatistics = true
        #endif
    }
    
    var PositionObservation: NSKeyValueObservation? = nil
    var OrientationObservation: NSKeyValueObservation? = nil
    var RotationObservation: NSKeyValueObservation? = nil
    
    var DefaultCameraNode: SCNNode? = nil
    
    func GetDefaultCamera() -> SCNCameraController
    {
        let DefaultCamera = defaultCameraController
        return DefaultCamera
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
    
    /// The camera's node in the scene.
    public var CameraNode: SCNNode? = nil
    
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

    /// The light's node in the scene.
    public var LightNode: SCNNode? = nil
    
    func Snapshot() -> NSImage
    {
        return self.snapshot()
    }
    
    /// Master node for still image processing.
    var MasterNode: SCNNode? = nil
    
    /// Resets the camera view to initial location, orientation, and rotation.
    public func ResetCamera()
    {
        CameraNode?.position = BlockView.InitialCameraLocation
        CameraNode?.orientation = BlockView.InitialCameraOrientation
        CameraNode?.rotation = BlockView.InitialCameraRotation
        self.pointOfView?.position = BlockView.InitialCameraLocation
        self.pointOfView?.orientation = BlockView.InitialCameraOrientation
        self.pointOfView?.rotation = BlockView.InitialCameraRotation
    }
    
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
        #if true
        return 15.0
        #else
        var OriginalZ: CGFloat = 15.0
        let POV = self.pointOfView
        if POV == nil
        {
            return Double((CameraNode?.position.z)!)
        }
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
        #endif
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
    
    public func XProcessLiveView(_ Source: CIImage, _ FrameIndex: Int)
    {
        DispatchQueue.global(qos: .background).async
            {
                //self.DoProcessLiveView(Source, FrameIndex)
        }
    }
    
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
                                      NodeShape: Settings.GetEnum(ForKey: .LiveViewShape, EnumType: Shapes.self,
                                                                  Default: Shapes.Blocks))
                    #if false
                    if !self.AddedObserversCamera
                    {
                        if let CameraNode = self.pointOfView
                        {
                            self.DefaultCameraNode = CameraNode
                            self.PositionObservation = self.DefaultCameraNode?.observe(\.position, options: [.initial, .new])
                            {
                                (camera, change) in
                                print("camera position: \(camera.position)")
                            }
                            self.OrientationObservation = self.DefaultCameraNode?.observe(\.position, options: [.initial, .new])
                            {
                                (camera, change) in
                                print("camera orientation: \(camera.orientation)")
                            }
                            self.RotationObservation = self.DefaultCameraNode?.observe(\.position, options: [.initial, .new])
                            {
                                (camera, change) in
                                print("camera rotation: \(camera.rotation)")
                            }
                            self.AddedObserversCamera = true
                        }
                    }
                    #endif
            }
        }
    }
    
    /// Return a prominence value used to determine size and/or Z location of individual shapes.
    /// - Parameter Color: The color whose prominence will be returned.
    /// - Returns: A value to use for setting size and/or Z location of shapes.
    func LiveViewColorProminence(_ Color: NSColor) -> CGFloat
    {
        #if true
        return ColorProminence(Color)
        #else
        var Ex: CGFloat = 1.0
        switch Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
        Default: VerticalExaggerations.Small)
        {
            case .None:
                Ex = 1.0
            
            case .Small:
                Ex = 1.3
            
            case .Medium:
                Ex = 1.9
            
            case .Large:
                Ex = 2.5
        }
        switch Settings.GetEnum(ForKey: .LiveViewHeight, EnumType: HeightDeterminations.self,
                                Default: HeightDeterminations.Brightness)
        {
            case .Hue:
                return Color.hueComponent * Ex
            
            case .Saturation:
                return Color.saturationComponent * Ex
            
            case .Brightness:
                return Color.brightnessComponent * Ex
            
            default:
                return Color.brightnessComponent * Ex
        }
        #endif
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
                    let Prominence = LiveViewColorProminence(Color)
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

extension NSColor
{
    /// Returns the YUV equivalent of the instance color, in Y, U, V order.
    /// - See
    ///   - [YUV](https://en.wikipedia.org/wiki/YUV)
    ///   - [FourCC YUV to RGB Conversion](http://www.fourcc.org/fccyvrgb.php)
    var YUV: (Y: CGFloat, U: CGFloat, V: CGFloat)
    {
        get
        {
            let Wr: CGFloat = 0.299
            let Wg: CGFloat = 0.587
            let Wb: CGFloat = 0.114
            let Umax: CGFloat = 0.436
            let Vmax: CGFloat = 0.615
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Y = (Wr * Red) + (Wg * Green) + (Wb * Blue)
            let U = Umax * ((Blue - Y) / (1.0 - Wb))
            let V = Vmax * ((Red - Y) / (1.0 - Wr))
            return (Y, U, V)
        }
    }
    
    /// Returns the CMYK equivalent of the instance color, in C, M, Y, K order.
    var CMYK: (C: CGFloat, Y: CGFloat, M: CGFloat, K: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let K: CGFloat = 1.0 - max(Red, max(Green, Blue))
            var C: CGFloat = 0.0
            var M: CGFloat = 0.0
            var Y: CGFloat = 0.0
            if K == 1.0
            {
                C = 1.0
            }
            else
            {
                C = abs((1.0 - Red - K) / (1.0 - K))
            }
            if K == 1.0
            {
                M = 1.0
            }
            else
            {
                M = abs((1.0 - Green - K) / (1.0 - K))
            }
            if K == 1.0
            {
                Y = 1.0
            }
            else
            {
                Y = abs((1.0 - Blue - K) / (1.0 - K))
            }
            return (C, M, Y, K)
        }
    }
    
    /// Returns the CIE LAB equivalent of the instance color, in L, A, B order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var LAB: (L: CGFloat, A: CGFloat, B: CGFloat)
    {
        get
        {
            let (X, Y, Z) = self.XYZ
            var Xr = X / 111.144                //X referent is X10 incandescent/tungsten
            var Yr = Y / 100.0                  //Y referent is X10 incandescent/tungsten
            var Zr = Z / 35.2                   //Z referent is X10 incandescent/tungsten
            if Xr > 0.008856
            {
                Xr = pow(Xr, (1.0 / 3.0))
            }
            else
            {
                Xr = (7.787 * Xr) + (16.0 / 116.0)
            }
            if Yr > 0.008856
            {
                Yr = pow(Yr, (1.0 / 3.0))
            }
            else
            {
                Yr = (7.787 * Yr) + (16.0 / 116.0)
            }
            if Zr > 0.008856
            {
                Zr = pow(Zr, (1.0 / 3.0))
            }
            else
            {
                Zr = (7.787 * Zr) + (16.0 / 116.0)
            }
            let L = (Xr * 116.0) - 16.0
            let A = 500.0 * (Xr - Yr)
            let B = 200.0 * (Yr - Zr)
            return (L, A, B)
        }
    }
    
    /// Returns the XYZ equivalent of the instance color, in X, Y, Z order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var XYZ: (X: CGFloat, Y: CGFloat, Z: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            if Red > 0.04045
            {
                Red = pow(((Red + 0.055) / 1.055), 2.4)
            }
            else
            {
                Red = Red / 12.92
            }
            if Green > 0.04045
            {
                Green = pow(((Green + 0.055) / 1.055), 2.4)
            }
            else
            {
                Green = Green / 12.92
            }
            if Blue > 0.04045
            {
                Blue = pow(((Blue + 0.055) / 1.055), 2.4)
            }
            else
            {
                Blue = Blue / 12.92
            }
            Red = Red * 100.0
            Green = Green * 100.0
            Blue = Blue * 100.0
            let X = (Red * 0.4124) + (Green * 0.3576) * (Blue * 0.1805)
            let Y = (Red * 0.2126) + (Green * 0.7152) * (Blue * 0.0722)
            let Z = (Red * 0.0193) + (Green * 0.1192) * (Blue * 0.9505)
            return (X, Y, Z)
        }
    }
    
    /// Returns the HSL equivalent of the instance color, in H, S, L order.
    /// - Note: See (Color math and programming code examples)[http://www.easyrgb.com/en/math.php]
    var HSL: (H: CGFloat, S: CGFloat, L: CGFloat)
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            let Min = min(Red, Green, Blue)
            let Max = max(Red, Green, Blue)
            let Delta = Max - Min
            let L: CGFloat = (Max + Min) / 2.0
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            if Delta != 0.0
            {
                if L < 0.5
                {
                    S = Max / (Max + Min)
                }
                else
                {
                    S = Max / (2.0 - Max - Min)
                }
                let DeltaR = (((Max - Red) / 6.0) + (Max / 2.0)) / Max
                let DeltaG = (((Max - Green) / 6.0) + (Max / 2.0)) / Max
                let DeltaB = (((Max - Blue) / 6.0) + (Max / 2.0)) / Max
                if Red == Max
                {
                    H = DeltaB - DeltaG
                }
                else
                    if Green == Max
                    {
                        H = (1.0 / 3.0) + (DeltaR - DeltaB)
                    }
                    else
                        if Blue == Max
                        {
                            H = (2.0 / 3.0) + (DeltaG - DeltaR)
                }
                if H < 0.0
                {
                    H = H + 1.0
                }
                if H > 1.0
                {
                    H = H - 1.0
                }
            }
            return (H, S, L)
        }
    }
}
