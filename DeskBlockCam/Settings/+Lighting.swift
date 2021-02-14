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
            #if false
            LightingSample.showsStatistics = true
            #endif
            LightingSample.allowsCameraControl = true
        }
        LightingSample.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if ["LightNode", "DisplayNode", "MainDisplayNode"].contains(Node.name)
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
        if Settings.GetBoolean(ForKey: .EnableMetalness)
        {
            Shape1.firstMaterial?.roughness.contents = Settings.GetDouble(ForKey: .Roughness)
            Shape1.firstMaterial?.metalness.contents = Settings.GetDouble(ForKey: .Metalness)
        }
        else
        {
            Shape1.firstMaterial?.roughness.contents = nil
            Shape1.firstMaterial?.metalness.contents = nil
        }
        let Node1 = SCNNode(geometry: Shape1)
        Node1.name = "DisplayNode"
        
        let Shape2 = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.05)
        Shape2.firstMaterial?.lightingModel = Model
        Shape2.firstMaterial?.diffuse.contents = NSColor.systemYellow
        Shape2.firstMaterial?.specular.contents = NSColor.white
        if Settings.GetBoolean(ForKey: .EnableMetalness)
        {
            Shape2.firstMaterial?.roughness.contents = Settings.GetDouble(ForKey: .Roughness)
            Shape2.firstMaterial?.metalness.contents = Settings.GetDouble(ForKey: .Metalness)
        }
        else
        {
            Shape2.firstMaterial?.roughness.contents = nil
            Shape2.firstMaterial?.metalness.contents = nil
        }
        let Node2 = SCNNode(geometry: Shape2)
        let RotateBy = 45.0 * CGFloat.pi / 180.0
        Node2.eulerAngles = SCNVector3(0.0, RotateBy, 0.0)
        Node2.name = "DisplayNode"
        let Node2Rotate = SCNAction.rotateBy(x: 0.0, y: RotateBy, z: 0.0, duration: 30.0)
        let Node2Forever = SCNAction.repeatForever(Node2Rotate)
        Node2.runAction(Node2Forever)
        
        let Shape3 = SCNBox(width: 2.5, height: 2.5, length: 2.5, chamferRadius: 0.05)
        Shape3.firstMaterial?.lightingModel = Model
        Shape3.firstMaterial?.diffuse.contents = NSColor.systemGreen
        Shape3.firstMaterial?.specular.contents = NSColor.white
        if Settings.GetBoolean(ForKey: .EnableMetalness)
        {
            Shape3.firstMaterial?.roughness.contents = Settings.GetDouble(ForKey: .Roughness)
            Shape3.firstMaterial?.metalness.contents = Settings.GetDouble(ForKey: .Metalness)
        }
        else
        {
            Shape3.firstMaterial?.roughness.contents = nil
            Shape3.firstMaterial?.metalness.contents = nil
        }
        let Node3 = SCNNode(geometry: Shape3)
        Node3.name = "DisplayNode"
        
        Node1.position = SCNVector3(0.0, 0.0, 0.0)
        Node2.position = SCNVector3(0.0, 2.5, 0.0)
        Node3.position = SCNVector3(0.0, -2.5, 0.0)
        let AllNodes = SCNNode()
        AllNodes.name = "MainDisplayNode"
        AllNodes.addChildNode(Node1)
        AllNodes.addChildNode(Node2)
        AllNodes.addChildNode(Node3)
        AllNodes.position = SCNVector3(0.0, 0.0, 0.0)
        AllNodes.scale = SCNVector3(1.5, 1.5, 1.5)
        LightingSample.scene?.rootNode.addChildNode(AllNodes)
        
        //let ZAngle = 45.0 * -CGFloat.pi / 180.0
        //let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: ZAngle, duration: 1.0)
        //let Forever = SCNAction.repeatForever(Rotate)
        //AllNodes.runAction(Forever)
    }
}
