//
//  ThreeTrianglesOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ThreeTrianglesOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        SidesTouchCheck.state = Settings.GetBoolean(ForKey: .SidesTouch) ? .on : .off
    }
    
    var NewCaption: String = ""
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
    }
    
    func SetCaption(_ CaptionText: String)
    {
        NewCaption = CaptionText
        if Caption != nil
        {
            Caption.stringValue = NewCaption
        }
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }

    @IBAction func HandleSidesTouchChanged(_ sender: Any)
    {
        Settings.SetBoolean(SidesTouchCheck.state == .on, ForKey: .SidesTouch)
        Delegate?.UpdateCurrent(With: CurrentShape)
    }
    
    var CurrentShape: Shapes = .NoShape

    @IBOutlet weak var SidesTouchCheck: NSButton!

    @IBOutlet weak var Caption: NSTextField!
}
