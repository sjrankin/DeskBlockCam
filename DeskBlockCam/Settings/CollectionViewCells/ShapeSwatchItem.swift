//
//  ShapeSwatchItem.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/27/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa

class ShapeSwatchItem: NSCollectionViewItem
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.borderColor = NSColor.black.cgColor
        self.view.layer?.borderWidth = 2.0
        self.view.layer?.cornerRadius = 5.0
    }
    
    func SetShape(_ Name: String, Index: Int, ID: UUID)
    {
        ShapeName.stringValue = Name
        self.ID = ID
    }
    
    func SetSelectionState(To Selected: Bool)
    {
        self.view.layer?.backgroundColor = Selected ? NSColor.systemYellow.cgColor : NSColor.white.cgColor
    }
    
    var ID: UUID = UUID()

    @IBOutlet weak var ShapeName: NSTextField!
}
