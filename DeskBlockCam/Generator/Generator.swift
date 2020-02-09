//
//  Generator.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

class Generator
{
    /// Create a set of nodes to display in an SCNView.
    /// - Parameter Attributes: Data that tells how to construct each node as well as containing
    ///                         color data.
    /// - Returns: Array of shape nodes.
    public static func MakeNodesFor(Attributes: ProcessingAttributes) -> [PSCNNode]
    {
        let Results = [PSCNNode]()
        if Attributes.Colors.count < 1
        {
            return Results
        }
        
        for Y in 0 ..< Attributes.Colors.count
        {
            for X in 0 ..< Attributes.Colors[Y].count
            {
                autoreleasepool
                    {
                        
                }
            }
        }
        
        return Results
    }
}
