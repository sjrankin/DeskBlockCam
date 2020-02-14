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

class BlockView: SCNView
{
    public weak var StatusDelegate: StatusProtocol? = nil
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        Initialize()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    var ImageProcessor: Processor? = nil
    
    func Initialize()
    {
        ImageProcessor = Processor()
        self.scene = SCNScene()
        AddCamera()
        AddLight()
        self.scene?.background.contents = NSColor.black
        self.allowsCameraControl = true
        self.showsStatistics = true
    }
    
    func AddCamera()
    {
        let Camera = SCNCamera()
        Camera.fieldOfView = 90.0
        CameraNode = SCNNode()
        CameraNode!.name = "Camera Node"
        CameraNode!.camera = Camera
        CameraNode!.position = SCNVector3(0.0, 0.0, -15.0)
        self.scene?.rootNode.addChildNode(CameraNode!)
    }
    
    func AddLight()
    {
        let Light = SCNLight()
        Light.type = .omni
        Light.color = NSColor.white
        LightNode = SCNNode()
        LightNode!.light = Light
        LightNode!.position = SCNVector3(-10.0, -10.0, -15.0)
        self.scene?.rootNode.addChildNode(LightNode!)
    }
    
    var CameraNode: SCNNode? = nil
    var LightNode: SCNNode? = nil
    
    func Snapshot() -> NSImage
    {
        return self.snapshot()
    }
    
    /// Process the passed image then display the result.
    /// - Parameter Image: The image to process.
    /// - Parameter Options: Determines how the image is processd.
    func ProcessImage(_ Image: NSImage, Options: ProcessingAttributes)
    {
        StatusDelegate?.UpdateStatus(With: .ResetStatus)
        StatusDelegate?.UpdateStatus(With: .PreparingImage)
        DispatchQueue.main.sync
            {
                if self.MasterNode != nil
                {
                    self.MasterNode?.removeFromParentNode()
                    self.MasterNode = nil
                }
        }
        let Resized = Shrinker.ResizeImage(Image: Image, Longest: 1024)
        let ResizedData = Resized.tiffRepresentation
        let ResizedCI = CIImage(data: ResizedData!)
        let Pixellated = Pixellator.Pixellate(ResizedCI!)
        StatusDelegate?.UpdateStatus(With: .PreparationDone)
        var HBlocks: Int = 0
        var VBlocks: Int = 0
        let Colors = ParseImage(Pixellated!, BlockSize: 16, HBlocks: &HBlocks, VBlocks: &VBlocks)
        let Attributes = ProcessingAttributes.Create()
        Attributes.Colors = Colors
        Attributes.HorizontalBlocks = HBlocks
        Attributes.VerticalBlocks = VBlocks
        let Nodes = Generator.Process(InScene: self.scene!, Attributes: Attributes, UIUpdate: StatusDelegate)
        for Node in Nodes
        {
            MasterNode!.addChildNode(Node)
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
    
    var MasterNode: SCNNode? = nil
    
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
    
    /// Calculate the camera position for a small "bezel" (eg, border around the processed image) to
    /// maximize the image in the view.
    /// - Note: This function moves the camera to determine the best view. The camera is returned to its
    ///         original location when done.
    /// - Returns: Recommended Z location of the camera to minimize wasted, empty space.
    func MinimizeBezel() -> Double
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
                    if AllInView(View: self, Node: MasterNode!, PointOfView: POV!)
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
    
    /// Parses the pixellated image and returns a list of colors, one for each pixellated block.
    /// - Parameter Image: The pixellated image to parse.
    /// - Parameter BlockSize: The size of each pixellated region.
    /// - Parameter HBlocks: On output, will contain the number of horizontal pixellated regions.
    /// - Parameter VBlocks: On output, will contain the number of vertical pixellated regions.
    /// - Returns: List of colors in YX order.
    func ParseImage(_ Image: NSImage, BlockSize: CGFloat, HBlocks: inout Int, VBlocks: inout Int) -> [[NSColor]]
    {
        StatusDelegate?.UpdateStatus(With: .ParsingImage)
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
                        Count = Count + 1
                        let Percent = 100.0 * Double(Count) / Double(Total)
                        StatusDelegate?.UpdateStatus(With: .ParsingPercentUpdate, PercentComplete: Percent)
                }
            }
        }
        StatusDelegate?.UpdateStatus(With: .ParsingDone)
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
}
