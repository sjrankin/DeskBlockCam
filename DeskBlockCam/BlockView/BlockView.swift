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
    
    func ProcessImage(_ Image: NSImage, Options: ProcessingAttributes)
    {
        DispatchQueue.main.async
            {
                if self.MasterNode != nil
                {
                    self.MasterNode?.removeFromParentNode()
                    self.MasterNode = nil
                }
                if let Final = self.ImageProcessor?.Process(Image: Image, With: Options)
                {
                    self.MasterNode = Final
                    self.scene?.rootNode.addChildNode(self.MasterNode!)
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
}
