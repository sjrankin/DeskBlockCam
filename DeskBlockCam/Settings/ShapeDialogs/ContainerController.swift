//
//  ContainerController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/17/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Small base class for the container view for shape options. This class updates the child windows in
/// the container to make sure the bounds and frames are the same size as the parent (eg, container)
/// because AppKit does not seem to pass size changes to child views.
class ContainerController: NSView
{
    /// Send the new bounds value to child views.
    override var bounds: NSRect
    {
        didSet
        {
            for Child in subviews
            {
                Child.bounds = bounds
            }
        }
    }

    /// Update each child's frame.
    override var frame: NSRect
        {
        didSet
        {
            for Child in subviews
            {
                let NewFrame = NSRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                Child.frame = NewFrame
            }
        }
    }

}
