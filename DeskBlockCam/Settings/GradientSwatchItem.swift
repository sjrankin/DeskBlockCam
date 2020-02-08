//
//  GradientSwatchItem.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/8/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa

class GradientSwatchItem: NSCollectionViewItem
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.borderWidth = 0.5
        self.view.layer?.borderColor = NSColor.black.cgColor
        self.view.layer?.cornerRadius = 5.0
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        GradientView.wantsLayer = true
        GradientView.layer?.borderWidth = 0.25
        GradientView.layer?.cornerRadius = 3.0
        GradientView.layer?.borderColor = NSColor.black.cgColor
    }
    
    func SetGradient(_ Color1: NSColor, _ Color2: NSColor)
    {
        self.Color1 = Color1
        self.Color2 = Color2
        let Size = NSSize(width: GradientView.bounds.size.width + GradientView.frame.origin.x,
                          height: GradientView.bounds.size.height + GradientView.frame.origin.y)
        let Gradient = GradientFactory.CreateGradient(Color1, Color2, Size: Size)
        Gradient.frame = GradientView.bounds
        Gradient.zPosition = 1000
        GradientView.layer?.addSublayer(Gradient)
    }
    
    override func viewDidLayout()
    {
        let Size = NSSize(width: GradientView.bounds.size.width + GradientView.frame.origin.x,
                          height: GradientView.bounds.size.height + GradientView.frame.origin.y)
        let Gradient = GradientFactory.CreateGradient(Color1, Color2, Size: Size)
        Gradient.frame = GradientView.bounds
        GradientView.layer?.sublayers?.removeAll()
        Gradient.zPosition = 1000
        GradientView.layer?.addSublayer(Gradient)
    }
    
    var Color1: NSColor = NSColor.white
    var Color2: NSColor = NSColor.black
    
    func SetSelectionState(To IsSelected: Bool)
    {
        self.view.layer?.backgroundColor = IsSelected ? NSColor.yellow.cgColor : NSColor.white.cgColor
    }
    
    @IBOutlet weak var GradientView: NSView!
}
