//
//  PSCNNode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import SceneKit

/// Slight enhancement on `SCNNode` objects to record a logical X and Y coordinate.
class PSCNNode: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Note: Set to private access to stop external usage of this initializer because without
    ///         X and Y set, nodes do not show up in the processed view.
    /// - Parameter geometry: The geometry of the node.
    private init(geometry: SCNGeometry)
    {
        super.init()
        self.geometry = geometry
    }
    
    /// Initializer.
    /// - Parameter Geometry: The geometry of the node.
    /// - Parameter X: Horizontal location in the processed view.
    /// - Parameter Y: Vertical location in the processed view.
    convenience init(geometry: SCNGeometry, X: Int, Y: Int)
    {
        self.init(geometry: geometry)
        _X = X
        _Y = Y
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Holds the horizontal location.
    private var _X: Int = 0
    /// Get or set the horizontal location of the node.
    public var X: Int
    {
        get
        {
            return _X
        }
        set
        {
            _X = newValue
        }
    }
    
    /// Holds the vertical location.
    private var _Y: Int = 0
    /// Get orset the vertical location of the node.
    public var Y: Int
    {
        get
        {
            return _Y
        }
        set
        {
            _Y = newValue
        }
    }
}
