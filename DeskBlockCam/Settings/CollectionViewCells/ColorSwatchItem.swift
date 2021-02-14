//
//  ColorSwatchItem.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa

class ColorSwatchItem: NSCollectionViewItem
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeView()
        SetColor(NSColor.systemYellow, WithName: "System Yellow")
    }
    
    func InitializeView()
    {
        self.view.wantsLayer = true
        self.view.layer?.borderWidth = 0.5
        self.view.layer?.borderColor = NSColor.black.cgColor
        self.view.layer?.cornerRadius = 5.0
        self.view.layer?.backgroundColor = NSColor.systemGray.cgColor//NSColor.white.cgColor
        ColorView.wantsLayer = true
        ColorView.layer?.borderWidth = 0.25
        ColorView.layer?.cornerRadius = 3.0
        ColorView.layer?.borderColor = NSColor.black.cgColor
        ColorName.textColor = NSColor(named: "SwatchTextColor")
    }
    
    func SetColor(_ Color: NSColor, WithName: String)
    {
        ColorView.layer?.backgroundColor = Color.cgColor
        ColorName.stringValue = WithName
    }

    func SetSelectionState(To IsSelected: Bool)
    {
        self.view.layer?.backgroundColor = IsSelected ? NSColor.systemYellow.cgColor : NSColor.systemGray.cgColor
    }
    
    @IBOutlet weak var ColorView: NSView!
    @IBOutlet weak var ColorName: NSTextField!
}
