//
//  +Lighting.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

extension ShapeOptionsCode
{
    func InitializeLighting()
    {
        LightingSampleInitialized = false
        DoUpdateLightSample()
    }
    
    func DrawLightingSample(Model: SCNMaterial.LightingModel, Type: SCNLight.LightType, Color: NSColor, Intensity: CGFloat)
    {
        if !LightingSampleInitialized
        {
            LightingSample.scene = SCNScene()
            LightingSampleInitialized = true
        }
        LightingSample.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if ["LightNode", "DisplayNode"].contains(Node.name)
                {
                    Node.removeAllActions()
                    Node.removeFromParentNode()
                }
        }
        LightingSample.scene = SCNScene()
        LightingSample.scene?.background.contents = NSColor.black
        
        let Light = SCNLight()
        Light.type = Type
        Light.color = Color
        Light.intensity = Intensity
        let LightNode = SCNNode()
        LightNode.name = "LightNode"
        LightNode.light = Light
        LightNode.position = SCNVector3(-4.0, 3.0, 10.0)
        LightingSample.scene?.rootNode.addChildNode(LightNode)
        
        let Camera = SCNCamera()
        Camera.fieldOfView = 95.0
        let CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 10.0)
        LightingSample.scene?.rootNode.addChildNode(CameraNode)
        
        let Shape1 = SCNCylinder(radius: 1.0, height: 5.0)
        Shape1.firstMaterial?.lightingModel = Model
        Shape1.firstMaterial?.diffuse.contents = NSColor.systemOrange
        Shape1.firstMaterial?.specular.contents = NSColor.white
        let Node1 = SCNNode(geometry: Shape1)
        Node1.name = "DisplayNode"
        let Shape2 = SCNSphere(radius: 1.5)
        Shape2.firstMaterial?.lightingModel = Model
        Shape2.firstMaterial?.diffuse.contents = NSColor.systemYellow
        Shape2.firstMaterial?.specular.contents = NSColor.white
        let Node2 = SCNNode(geometry: Shape2)
        Node2.name = "DisplayNode"
        let Shape3 = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.05)
        Shape3.firstMaterial?.lightingModel = Model
        Shape3.firstMaterial?.diffuse.contents = NSColor.systemGreen
        Shape3.firstMaterial?.specular.contents = NSColor.white
        let Node3 = SCNNode(geometry: Shape3)
        Node3.name = "DisplayNode"
        Node1.position = SCNVector3(0.0, 0.0, 0.0)
        Node2.position = SCNVector3(0.0, 2.5, 0.0)
        Node3.position = SCNVector3(0.0, -2.5, 0.0)
        let AllNodes = SCNNode()
        AllNodes.name = "DisplayNode"
        AllNodes.addChildNode(Node1)
        AllNodes.addChildNode(Node2)
        AllNodes.addChildNode(Node3)
        AllNodes.position = SCNVector3(0.0, 0.0, 0.0)
        AllNodes.scale = SCNVector3(1.5, 1.5, 1.5)
        LightingSample.scene?.rootNode.addChildNode(AllNodes)
        let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: -CGFloat.pi / 180.0, duration: 0.04)
        let Forever = SCNAction.repeatForever(Rotate)
        AllNodes.runAction(Forever)
    }
}
