//
//  Assembler.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class Assembler
{
    public static func ClearScene(_ Scene: SCNScene)
    {
        Scene.rootNode.enumerateChildNodes
            {
                (Node, _) in
                if Node.name == "PixelNode"
                {
                Node.removeFromParentNode()
                }
        }
    }
    
    public static func ProcessedView(InScene: SCNScene, With Attributes: ProcessingAttributes)
    {
        ClearScene(InScene)
        let NodeList = Generator.MakeNodesFor(Attributes: Attributes)
        for Node in NodeList
        {
            let XLocation: Float = Float(Node.X - (Attributes.HorizontalBlocks / 2))
            let YLocation: Float = Float(Node.Y - (Attributes.VerticalBlocks / 2))
            let ZLocation = Float(Node.Prominence)
            Node.position = SCNVector3(XLocation * Float(Attributes.Side),
                                       YLocation * Float(Attributes.Side),
                                       ZLocation)
            InScene.rootNode.addChildNode(Node)
        }
    }
}
