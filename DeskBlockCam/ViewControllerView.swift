//
//  ViewControllerView.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

@objc protocol DragDropDelegate: AnyObject
{
    func draggingEntered(ForView: ViewControllerView, sender: NSDraggingInfo) -> NSDragOperation
    func performDragOperation(ForView: ViewControllerView, sender: NSDraggingInfo) -> Bool
    func pasteboardWriter(ForView: ViewControllerView) -> NSPasteboardWriting
}

/// Main window view controller. Implements dropping files onto the main view.
class ViewControllerView: NSView
{
    /// The receiver of drop actions.
    var DragDelegate: DragDropDelegate? = nil

    /// Set up after the Nib awakens.
    override func awakeFromNib()
    {
        super.awakeFromNib()
        Overlay = NSView()
        addSubview(Overlay)
    }
    
    var Overlay: NSView!
    
    /// Handle dragging entered.
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        var Result: NSDragOperation = []
        if let delegate = DragDelegate
        {
            Result = delegate.draggingEntered(ForView: self, sender: sender)
        }
        return Result
    }
    
    /// Perform the drag operation.
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        return DragDelegate?.performDragOperation(ForView: self, sender: sender) ?? true
    }
    
    /// Dragging ended.
    override func draggingEnded(_ sender: NSDraggingInfo)
    {
    }
}
