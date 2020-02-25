//
//  BlocksWithOptionsCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/25/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BlocksWithOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        ShapeCombo.removeAllItems()
        ShapeCombo.addItems(withObjectValues:
        [
            Shapes.Spheres.rawValue,
            Shapes.Cones.rawValue,
            Shapes.Pyramids.rawValue,
            Shapes.Lines.rawValue,
            Shapes.Capsules.rawValue
        ])
        let ExShape = Settings.GetEnum(ForKey: .BlockWithShape, EnumType: Shapes.self, Default: Shapes.Cones)
        ShapeCombo.selectItem(withObjectValue: ExShape.rawValue)
    }
    
    var NewCaption: String = ""
    
    func ApplyAttributes(_ NewAttributes: ProcessingAttributes)
    {
    }
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
        ApplyAttributes(Attributes)
    }
    
    func UpdatedOptions(_ Updated: ProcessingAttributes)
    {
        ApplyAttributes(Updated)
    }
    
    func SetCaption(_ CaptionText: String)
    {
        NewCaption = CaptionText
        if Caption != nil
        {
            Caption.stringValue = NewCaption
        }
    }
    
    @IBAction func HandleNewShape(_ sender: Any)
    {
        if let Selected = ShapeCombo.objectValueOfSelectedItem as? String
        {
            if let NewShape = Shapes(rawValue: Selected)
            {
                Settings.SetEnum(NewShape, EnumType: Shapes.self, ForKey: .BlockWithShape)
                Delegate?.UpdateCurrent(With: CurrentShape)
            }
        }
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var ShapeCombo: NSComboBoxCell!
    @IBOutlet weak var Caption: NSTextField!
}

