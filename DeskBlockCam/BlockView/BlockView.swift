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
import CoreImage

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
    
    /// Mode of the view.
    private var _InLiveViewMode: Bool = true
    /// Get or set the view's mode.
    public var InLiveViewMode: Bool
    {
        get
        {
            return _InLiveViewMode
        }
        set
        {
            _InLiveViewMode = newValue
        }
    }
    
    /// Clear the scene of any nodes.
    func ClearScene()
    {
        #if true
        if PrimaryNode != nil
        {
            print("Removing primary node from scene.")
            PrimaryNode?.removeFromParentNode()
            PrimaryNode = nil
        }
        if LiveViewPrimaryNode != nil
        {
            print("Removing live view primary node from scene.")
            LiveViewPrimaryNode?.removeFromParentNode()
            LiveViewPrimaryNode = nil
        }
        #else
        DispatchQueue.main.async
            {
                if self.PrimaryNode != nil
                {
                    self.PrimaryNode?.removeFromParentNode()
                    self.PrimaryNode = nil
                }
                if self.LiveViewPrimaryNode != nil
                {
                    self.LiveViewPrimaryNode?.removeFromParentNode()
                    self.LiveViewPrimaryNode = nil
                }
        }
        #endif
    }
    
    /// Return a prominence value (used to determine either extrusion or size depending on the shape)
    /// for the passed color.
    /// - Note: The vertical exaggeration setting is also used to define the final prominence value.
    /// - Parameter Color: The base color used to determine prominence.
    /// - Returns: Prominence value for the passed color.
    /// - Parameter Exaggeration: Vertical exaggeration. If nil, read from settings. Pass a value when calling in a loop.
    /// - Parameter Determination: Height determination. If nil, read from settings. Pass a value when calling in a loop.
    /// - Parameter Invert: Invert height flag. If nil, read from settings. Pass a value when calling in a loop.
    func ColorProminence(_ Color: NSColor, Exaggeration: VerticalExaggerations? = nil,
                         Determination: HeightDeterminations? = nil, Invert: Bool? = nil) -> CGFloat
    {
        var Ex: CGFloat = 1.0
        switch Exaggeration ?? Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
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
        switch Determination ?? Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
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
        if Invert ?? Settings.GetBoolean(ForKey: .InvertHeight)
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
    
    func ReprocessImage()
    {
        if PreviouslyProcessedImage == nil
        {
            return
        }
        let Shape = Settings.GetEnum(ForKey: .Shape, EnumType: Shapes.self, Default: Shapes.Blocks)
        print("Reprocessing image with \(Shape.rawValue)")
        ProcessImage(PreviouslyProcessedImage!)
    }
    
    private var PreviouslyProcessedImage: NSImage? = nil
    
    func ProcessImage(_ Image: NSImage)
    {
        DispatchQueue.global(qos: .background).async
            {
                self.DoProcessImage(Image)
        }
    }
    
    /// Process the passed image then display the result.
    /// - Parameter Image: The image to process.
    /// - Parameter Options: Determines how the image is processd.
    func DoProcessImage(_ Image: NSImage)
    {
        if InLiveViewMode
        {
            return
        }
        PreviouslyProcessedImage = Image
        StatusDelegate?.UpdateStatus(With: .ResetStatus)
        let Start = CACurrentMediaTime()
        if PrimaryNode != nil
        {
            PrimaryNode?.removeAllActions()
            PrimaryNode?.removeFromParentNode()
            PrimaryNode = nil
        }
        Initialize()
        SetAntialiasing()
        StatusDelegate?.UpdateDuration(NewDuration: 0.0)
        StatusDelegate?.UpdateStatus(With: .PreparingImage)
        //        ClearScene()
        let AfterClear = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterClear)
        if PrimaryNode == nil
        {
            PrimaryNode = SCNNode()
            PrimaryNode?.name = "Primary Node"
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
        //Options.Colors = Colors
        //Options.HorizontalBlocks = HBlocks
        //Options.VerticalBlocks = VBlocks
        
        StatusDelegate?.UpdateStatus(With: .CreatingShapes)
        let Total = Double(VBlocks * HBlocks)
        var Count: Double = 0.0
        let Side = Settings.GetDouble(ForKey: .Side)
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
                        let ZLocation = (Prominence * PMul) * PMul
                        let ShapeNode = Generator.MakeShape(With: Colors, AtX: X, AtY: Y)
                        ShapeNode.castsShadow = true
                        ShapeNode.SetProminence(Double(Prominence))
                        ShapeNode.position = SCNVector3(XLocation * Float(Side),
                                                        YLocation * Float(Side),
                                                        Float(ZLocation))
                        /*
                         ShapeNode.position = SCNVector3(XLocation * Float(Options.Side),
                         YLocation * Float(Options.Side),
                         Float(ZLocation))
                         */
                        PrimaryNode?.addChildNode(ShapeNode)
                        Count = Count + 1.0
                        let Percent = 100.0 * (Count / Total)
                        StatusDelegate?.UpdateStatus(With: .CreatingPercentUpdate, PercentComplete: Percent)
                }
            }
        }
        StatusDelegate?.UpdateStatus(With: .CreatingDone)
        let AfterShapes = CACurrentMediaTime() - Start
        StatusDelegate?.UpdateDuration(NewDuration: AfterShapes)
        
        self.StatusDelegate?.UpdateStatus(With: .AddingShapes)

        #if true
        prepare([PrimaryNode!])
        {
            Completed in
            if Completed
            {
                OperationQueue.main.addOperation
                    {
                self.scene?.rootNode.addChildNode(self.PrimaryNode!)
                }
                self.isPlaying = true
                print("Added primary node to scene.")
            }
        }
        #else
        var NCount = 0
        PrimaryNode?.enumerateChildNodes
            {
                (Node, _) in
                autoreleasepool
                    {
                self.scene?.rootNode.addChildNode(Node)
                NCount = NCount + 1
                }
        }
        print("\(NCount) nodes added to scene.")
        #endif
        self.StatusDelegate?.UpdateStatus(With: .AddingDone)
        let AfterAdded = CACurrentMediaTime() - Start
        self.StatusDelegate?.FinalizeDuration(WithDuration: AfterAdded)
        
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
    
    /// Return the node at the specified coordinate.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Parameter From: The parent node.
    /// - Returns: The node at the specified coordinate if found, nil if not found.
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
        Camera.zNear = 0.0
        //Camera.zFar = 10000.0
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
        
        Light.castsShadow = true
        Light.shadowMode = .forward
        Light.shadowColor = NSColor.black.withAlphaComponent(0.8)
        Light.shadowRadius = 10.0
        
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
    
    /// Primary node for still image processing.
    var PrimaryNode: SCNNode? = nil
    
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
    /// - Parameter FinalOffset: Value to add to the final Z location for adjustment purposes. Defaults
    ///                          to `1.4`.
    /// - Returns: Recommended Z location of the camera to minimize wasted, empty space.
    func MinimizeBezel(IsLiveView: Bool = true, FinalOffset: Double = 1.4) -> Double
    {
        var OriginalZ: CGFloat = 15.0
        let POV = self.pointOfView
        if POV == nil
        {
            return Double((CameraNode?.position.z)!)
        }
        if let RootNode = GetNode(WithName: "Primary Node", InScene: self.scene!)
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
                        if AllInView(View: self, Node: LiveViewPrimaryNode!, PointOfView: POV!)
                        {
                            CameraNode.position = SCNVector3(CameraNode.position.x,
                                                             CameraNode.position.y,
                                                             OriginalZ)
                            return CameraHeight + FinalOffset
                        }
                    }
                    else
                    {
                        if AllInView(View: self, Node: PrimaryNode!, PointOfView: POV!)
                        {
                            CameraNode.position = SCNVector3(CameraNode.position.x,
                                                             CameraNode.position.y,
                                                             OriginalZ)
                            return CameraHeight + FinalOffset
                        }
                    }
                }
                //Restore the camera.
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
    
    /// Process the passed image. This function assumes the image is from a live view stream and restricts
    /// the image processing to help increase performance.
    /// - Note: Processing occurs on a background thread.
    /// - Parameter Source: The image to process.
    public func ProcessLiveView(_ Source: CIImage)
    {
        DispatchQueue.global(qos: .userInitiated).async
            {
                self.DoProcessLiveView(Source)
        }
    }
    
    var LiveViewBusy = false
    var DropCount = 0
    
    /// Process the passed image. This function works on the assumption the image is from a camera
    /// stream.
    /// - Note: Due to performance constrains when processing live views, only a small subset of
    ///         shapes are supported.
    /// - Parameter Source: The image to processed.
    public func DoProcessLiveView(_ Source: CIImage)
    {
        if !InLiveViewMode
        {
            return
        }
        if LiveViewBusy
        {
            DropCount = DropCount + 1
            return
        }
        LiveViewBusy = true
        objc_sync_enter(CloseLock)
        defer{ objc_sync_exit(CloseLock) }
 
        let ResizeTo = Settings.GetEnum(ForKey: .LiveViewImageSize, EnumType: LiveViewImageSizes.self, Default: LiveViewImageSizes.Medium)
        let BlockSizeSetting = Settings.GetInteger(ForKey: .ShapeSize)
        if let Buffer = Source.pixelBuffer,
           CVPixelBufferGetPixelFormatType(Buffer) == kCVPixelFormatType_32BGRA
        {
            var TargetSize: CGFloat = 1024.0
            switch ResizeTo
            {
                case .Small:
                    TargetSize = 512.0
                
                case .Medium:
                    TargetSize = 1024.0
                
                case .Large:
                    TargetSize = 2048.0
                
                default:
                    TargetSize = 0.0
            }
            var DirectH: Int = 0
            var DirectV: Int = 0
            if let Colors = SampledColors(Buffer, TargetSize: TargetSize, PixelSize: BlockSizeSetting, BlockSize: 16,
                                          HBlocks: &DirectH, VBlocks: &DirectV)
            {
                DispatchQueue.main.async
                    {
                        self.DrawLiveViewNodes(Colors: Colors, HShapeCount: DirectH, VShapeCount: DirectV,
                                               NodeShape: Settings.GetEnum(ForKey: .LiveViewShape, EnumType: Shapes.self,
                                                                           Default: Shapes.Blocks))
                        self.LiveViewBusy = false
                }
                return
            }
        }
        var NextImage: CIImage = Source
        if ResizeTo != .Native
        {
            var NewSize: CGFloat = 0.0
            switch ResizeTo
            {
                case .Small:
                    NewSize = 512.0
                
                case .Medium:
                    NewSize = 1024.0
                
                case .Large:
                    NewSize = 2048.0
                
                default:
                    NewSize = 1024.0
            }
            let Longest = max(Source.extent.width, Source.extent.height)
            if NewSize < Longest
            {
                let Scale = NewSize / Longest
                NextImage = Source.transformed(by: CGAffineTransform(scaleX: Scale, y: Scale))
            }
        }
        let BlockSize = Settings.GetInteger(ForKey: .ShapeSize)
        var HBlocks: Int = 0
        var VBlocks: Int = 0
        if let Colors = PixellatedColors(NextImage, PixelSize: BlockSize, BlockSize: 16,
                                         HBlocks: &HBlocks, VBlocks: &VBlocks)
        {
            DispatchQueue.main.async
                {
                    self.DrawLiveViewNodes(Colors: Colors, HShapeCount: HBlocks, VShapeCount: VBlocks,
                                           NodeShape: Settings.GetEnum(ForKey: .LiveViewShape, EnumType: Shapes.self,
                                                                       Default: Shapes.Blocks))
                    self.LiveViewBusy = false
            }
        }
        else
        {
            LiveViewBusy = false
        }
    }
    
    /// Sample block colors straight from a BGRA camera buffer, with no Core Image rendering. The grid
    /// matches what the Core Image path produces for an image scaled so its longest side is `TargetSize`.
    /// - Parameter Buffer: BGRA pixel buffer from the camera.
    /// - Parameter TargetSize: Longest side of the virtual scaled image. 0 or larger than the source means native size.
    /// - Parameter PixelSize: Size of the averaged region, in scaled-image pixels.
    /// - Parameter BlockSize: Spacing of the sample grid, in scaled-image pixels.
    /// - Parameter HBlocks: On output, the number of horizontal samples.
    /// - Parameter VBlocks: On output, the number of vertical samples.
    /// - Returns: Colors in the same order `ParseImage` returns, nil on error.
    func SampledColors(_ Buffer: CVPixelBuffer, TargetSize: CGFloat, PixelSize: Int, BlockSize: Int,
                       HBlocks: inout Int, VBlocks: inout Int) -> [[NSColor]]?
    {
        CVPixelBufferLockBaseAddress(Buffer, .readOnly)
        defer{ CVPixelBufferUnlockBaseAddress(Buffer, .readOnly) }
        guard let Base = CVPixelBufferGetBaseAddress(Buffer) else
        {
            return nil
        }
        let SrcW = CVPixelBufferGetWidth(Buffer)
        let SrcH = CVPixelBufferGetHeight(Buffer)
        let Stride = CVPixelBufferGetBytesPerRow(Buffer)
        let Longest = CGFloat(max(SrcW, SrcH))
        let Scale: CGFloat = (TargetSize > 0.0 && TargetSize < Longest) ? TargetSize / Longest : 1.0
        HBlocks = Int(CGFloat(SrcW) * Scale) / BlockSize
        VBlocks = Int(CGFloat(SrcH) * Scale) / BlockSize
        if HBlocks < 1 || VBlocks < 1
        {
            return nil
        }
        let Pixels = Base.assumingMemoryBound(to: UInt8.self)
        let Half = max(1.0, CGFloat(PixelSize) / 2.0) / Scale
        var Colors = Array(repeating: Array(repeating: NSColor.black, count: HBlocks), count: VBlocks)
        for Y in 0 ..< VBlocks
        {
            let CenterY = (CGFloat(Y * BlockSize + BlockSize / 2)) / Scale
            for X in 0 ..< HBlocks
            {
                let CenterX = (CGFloat(X * BlockSize + BlockSize / 2)) / Scale
                var R = 0, G = 0, B = 0
                for DY in -1 ... 1
                {
                    let PY = min(max(Int(CenterY + CGFloat(DY) * Half * 0.5), 0), SrcH - 1)
                    for DX in -1 ... 1
                    {
                        let PX = min(max(Int(CenterX + CGFloat(DX) * Half * 0.5), 0), SrcW - 1)
                        let Offset = PY * Stride + PX * 4
                        B += Int(Pixels[Offset])
                        G += Int(Pixels[Offset + 1])
                        R += Int(Pixels[Offset + 2])
                    }
                }
                Colors[VBlocks - 1 - Y][X] = NSColor(srgbRed: CGFloat(R) / (9.0 * 255.0),
                                                      green: CGFloat(G) / (9.0 * 255.0),
                                                      blue: CGFloat(B) / (9.0 * 255.0),
                                                      alpha: 1.0)
            }
        }
        return Colors
    }
    
    /// Pixellate the image on the GPU, render it once into a byte buffer, and sample the center of each
    /// block directly from the buffer. Replaces the TIFF round trip and `NSBitmapImageRep.colorAt` path
    /// used for still images.
    /// - Parameter Image: The image to pixellate.
    /// - Parameter PixelSize: Size of the pixellation regions.
    /// - Parameter BlockSize: Spacing of the sample grid.
    /// - Parameter HBlocks: On output, the number of horizontal samples.
    /// - Parameter VBlocks: On output, the number of vertical samples.
    /// - Returns: Colors in the same order `ParseImage` returns, nil on error.
    func PixellatedColors(_ Image: CIImage, PixelSize: Int, BlockSize: Int,
                          HBlocks: inout Int, VBlocks: inout Int) -> [[NSColor]]?
    {
        guard let Filter = CIFilter(name: "CIPixellate") else
        {
            return nil
        }
        Filter.setDefaults()
        Filter.setValue(Image, forKey: kCIInputImageKey)
        Filter.setValue(PixelSize, forKey: kCIInputScaleKey)
        guard let Reduced = Filter.outputImage else
        {
            return nil
        }
        let Bounds = Image.extent.integral
        let Width = Int(Bounds.width)
        let Height = Int(Bounds.height)
        HBlocks = Width / BlockSize
        VBlocks = Height / BlockSize
        if HBlocks < 1 || VBlocks < 1
        {
            return nil
        }
        let RowBytes = Width * 4
        var Pixels = [UInt8](repeating: 0, count: RowBytes * Height)
        CIImage.SharedContext.render(Reduced, toBitmap: &Pixels, rowBytes: RowBytes, bounds: Bounds,
                                     format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        var Colors = Array(repeating: Array(repeating: NSColor.black, count: HBlocks), count: VBlocks)
        for Y in 0 ..< VBlocks
        {
            let RowStart = (Y * BlockSize + BlockSize / 2) * RowBytes
            for X in 0 ..< HBlocks
            {
                let Offset = RowStart + (X * BlockSize + BlockSize / 2) * 4
                Colors[VBlocks - 1 - Y][X] = NSColor(srgbRed: CGFloat(Pixels[Offset]) / 255.0,
                                                      green: CGFloat(Pixels[Offset + 1]) / 255.0,
                                                      blue: CGFloat(Pixels[Offset + 2]) / 255.0,
                                                      alpha: 1.0)
            }
        }
        return Colors
    }
    
    /// Call to reset the live view mode. This happens when the user changes the maximum size of other
    /// attribute of the live view such that existing nodes can no longer be used.
    public func ResetLiveView()
    {
        LiveViewPrimaryNode?.removeAllActions()
        LiveViewPrimaryNode?.removeFromParentNode()
        LiveViewPrimaryNode = nil
    }
    
    /// Udpate existing nodes with new colors.
    /// - Note: This function uses nodes already in the scene rather than recreate nodes, which is
    ///         very expensive in terms of performance. Any time a base shape changes, `CreateNode`
    ///         must be called, not `UpdateNodes`.
    /// - Note: All nodes are updated in this function.
    /// - Parameter With: Array of pixellated colors from the pixellated source image in YZ order.
    /// - Parameter HShapeCount: Number of horizontal shapes.
    /// - Parameter VShapeCount: Number of vertical shapes.
    /// - Parameter Side: Base shape side length.
    func UpdateNodes(With Colors: [[NSColor]], HShapeCount: Int, VShapeCount: Int, Side: CGFloat)
    {
        let Exaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                            Default: VerticalExaggerations.Small)
        let Determination = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                             Default: HeightDeterminations.Brightness)
        let Invert = Settings.GetBoolean(ForKey: .InvertHeight)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        SCNTransaction.disableActions = true
        defer{ SCNTransaction.commit() }
        for SomeNode in LiveViewPrimaryNode!.childNodes
        {
            let Node = SomeNode as! PSCNNode
            let Color = Colors[Node.Y][Node.X]
            let Prominence = ColorProminence(Color, Exaggeration: Exaggeration, Determination: Determination,
                                             Invert: Invert)
            Node.SetProminence(Double(Prominence))
            //Shapes with unit-sized geometry are resized with the node's scale. Changing geometry
            //parameters forces SceneKit to rebuild the geometry, which is far too slow per frame.
            let Scale = max(Prominence * PMul, 0.001)
            switch CurrentLiveViewNodeShape
            {
                case .Blocks:
                    Node.scale = SCNVector3(1.0, 1.0, Scale)
                
                case .Spheres, .Rings, .Cones:
                    Node.scale = SCNVector3(Scale, Scale, Scale)
                
                case .Squares:
                    if let Geo = Node.geometry as? SCNPlane
                    {
                        Geo.width = Side + (Prominence * 0.2)
                        Geo.height = Side + (Prominence * 0.2)
                        let OldPos = Node.position
                        Node.position = SCNVector3(OldPos.x, OldPos.y, Prominence * 2.0 * PMul)
                    }
                
                case .Pyramids:
                    if let Geo = Node.geometry as? SCNPyramid
                    {
                        Geo.width = Side + (Prominence * 0.2)
                        Geo.height = Side + (Prominence * 0.2)
                        let OldPos = Node.position
                        Node.position = SCNVector3(OldPos.x, OldPos.y, Prominence * 2.0 * PMul)
                    }
                
                case .Tubes:
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
        #if false
        let PImage = ProcessedImage.snapshot()
        Delegate?.ImageForDebug(PImage, ImageType: .VideoView)
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
                                                 length: 1.0,
                                                 chamferRadius: Chamfer),
                                X: AtX, Y: AtY)
                Node.scale = SCNVector3(1.0, 1.0, max(Prominence * PMul, 0.001))
            
            case .Spheres:
                //Sphere
                Node = PSCNNode(geometry: SCNSphere(radius: 1.0), X: AtX, Y: AtY)
                let SphereScale = max(Prominence * PMul, 0.001)
                Node.scale = SCNVector3(SphereScale, SphereScale, SphereScale)
            
            case .Rings:
                //ring
                Node = PSCNNode(geometry: SCNTorus(ringRadius: 1.0, pipeRadius: 0.3),
                                X: AtX, Y: AtY)
                let RingScale = max(Prominence * PMul, 0.001)
                Node.scale = SCNVector3(RingScale, RingScale, RingScale)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Cones:
                //cone
                Node = PSCNNode(geometry: SCNCone(topRadius: 0.0, bottomRadius: 1.0, height: 1.0),
                                X: AtX, Y: AtY)
                let ConeScale = max(Prominence, 0.001)
                Node.scale = SCNVector3(ConeScale, ConeScale, ConeScale)
                Node.rotation = SCNVector4(1.0, 0.0, 0.0, 90.0 * CGFloat.pi / 180.0)
            
            case .Pyramids:
                //pyramid
                Node = PSCNNode(geometry: SCNPyramid(width: Side, height: Side, length: Prominence), X: AtX, Y: AtY)
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
            
            case .Particles:
                let particles = SCNParticleSystem()
                particles.birthRate = 100
                particles.particleSize = 1.45
                particles.particleLifeSpan = 2
                particles.particleColor = Color
                Node = PSCNNode()
                Node.addParticleSystem(particles)
                
            default:
                break
        }
        Node.geometry?.firstMaterial?.diffuse.contents = Color
        Node.geometry?.firstMaterial?.specular.contents = NSColor.white
        let LightModel = Settings.GetEnum(ForKey: .LightModel, EnumType: LightModels.self, Default: .Lambert)
        switch LightModel
        {
            case .Blinn:
                Node.geometry?.firstMaterial?.lightingModel = .blinn
                
            case .Constant:
                Node.geometry?.firstMaterial?.lightingModel = .constant
                
            case .Lambert:
                Node.geometry?.firstMaterial?.lightingModel = .lambert
                
            case .Phong:
                Node.geometry?.firstMaterial?.lightingModel = .phong
                
            case .Physical:
                Node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        }
        if Settings.GetBoolean(ForKey: .EnableMetalness)
        {
            Node.geometry?.firstMaterial?.roughness.contents = Settings.GetDouble(ForKey: .Roughness)
            Node.geometry?.firstMaterial?.metalness.contents = Settings.GetDouble(ForKey: .Metalness)
        }
        else
        {
            Node.geometry?.firstMaterial?.roughness.contents = nil
            Node.geometry?.firstMaterial?.metalness.contents = nil
        }
        
        return Node
    }
    
    /// Create a 3D shape for each passed color. Add it to the `LiveViewPrimaryNode`.
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
            LiveViewPrimaryNode?.removeFromParentNode()
            LiveViewPrimaryNode = nil
            LiveMesh = nil
        }
        if NodeShape == .Blocks
        {
            DrawLiveViewMesh(Colors: Colors, HShapeCount: HShapeCount, VShapeCount: VShapeCount, Side: Side)
            return
        }
        if LiveViewPrimaryNode != nil
        {
            UpdateNodes(With: Colors, HShapeCount: HShapeCount, VShapeCount: VShapeCount, Side: Side)
            return
        }
        LiveViewPrimaryNode = SCNNode()
        LiveViewPrimaryNode?.name = "Primary Node"
        LiveViewPrimaryNode?.position = SCNVector3(0.0, 0.0, 0.0)
        let Exaggeration = Settings.GetEnum(ForKey: .VerticalExaggeration, EnumType: VerticalExaggerations.self,
                                            Default: VerticalExaggerations.Small)
        let Determination = Settings.GetEnum(ForKey: .HeightDetermination, EnumType: HeightDeterminations.self,
                                             Default: HeightDeterminations.Brightness)
        let Invert = Settings.GetBoolean(ForKey: .InvertHeight)
        for Y in 0 ... VShapeCount - 1
        {
            for X in 0 ... HShapeCount - 1
            {
                autoreleasepool
                    {
                        let Color = Colors[Y][X]
                        let Prominence = ColorProminence(Color, Exaggeration: Exaggeration, Determination: Determination,
                                                         Invert: Invert) * 0.5
                        let XLocation: Float = Float(X - (HShapeCount / 2))
                        let YLocation: Float = Float(Y - (VShapeCount / 2))
                        var ZLocation = (Prominence * PMul) * PMul
                        let Node = CreateNode(Side: Side, Color: Color, Prominence: Prominence,
                                              AtX: X, AtY: Y, Z: &ZLocation)
                        Node.SetProminence(Double(Prominence))
                        Node.position = SCNVector3(XLocation * Float(Side),
                                                   YLocation * Float(Side),
                                                   Float(ZLocation))
                        LiveViewPrimaryNode?.addChildNode(Node)
                }
            }
        }
        self.scene?.rootNode.addChildNode(LiveViewPrimaryNode!)
        let NewHeight = MinimizeBezel()
        CameraNode?.position = SCNVector3(CameraNode!.position.x,
                                          CameraNode!.position.y,
                                          CGFloat(NewHeight))
    }
    
    /// The current shape to use in live view mode.
    var CurrentLiveViewNodeShape = Shapes.NoShape
    
    /// The primary node for live view mode.
    var LiveViewPrimaryNode: SCNNode? = nil
    
    /// Mesh used to draw the live view when the shape is `.Blocks`.
    var LiveMesh: LiveViewMesh? = nil
}
