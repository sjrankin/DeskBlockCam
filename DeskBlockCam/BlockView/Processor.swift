//
//  Processor.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class Processor
{
    var Parent: SCNNode? = nil
    
    /// Create a set of 3D nodes from a pixellated image based on the passed parameters.
    /// - Parameter Image: The pixellated image.
    /// - Parameter ProcessingAttributes: Attributes that determine how to create nodes.
    func Process(Image: NSImage, With Parameters: ProcessingAttributes) -> SCNNode?
    {
         Parent = SCNNode()
        Parent?.name = "Master Node"
        return Parent!
    }
}
