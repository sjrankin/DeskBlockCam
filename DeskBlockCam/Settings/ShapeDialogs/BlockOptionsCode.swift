//
//  BlockOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class BlockOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Chamfer = Settings.GetEnum(ForKey: .BlockChamfer, EnumType: BlockChamferSizes.self,
                                       Default: .None)
        switch Chamfer
        {
            case .None:
                ChamferSegment.selectedSegment = 0
            
            case .Small:
                ChamferSegment.selectedSegment = 1
            
            case .Medium:
                ChamferSegment.selectedSegment = 2
            
            case .Heavy:
                ChamferSegment.selectedSegment = 3
        }
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
    
    @IBAction func HandleChamferChanged(_ sender: Any)
    {
        switch ChamferSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.None, EnumType: BlockChamferSizes.self, ForKey: .BlockChamfer)
            
            case 1:
                Settings.SetEnum(.Small, EnumType: BlockChamferSizes.self, ForKey: .BlockChamfer)
            
            case 2:
                Settings.SetEnum(.Medium, EnumType: BlockChamferSizes.self, ForKey: .BlockChamfer)
            
            case 3:
                Settings.SetEnum(.Heavy, EnumType: BlockChamferSizes.self, ForKey: .BlockChamfer)
            
            default:
                Settings.SetEnum(.None, EnumType: BlockChamferSizes.self, ForKey: .BlockChamfer)
        }
        Delegate?.UpdateCurrent() 
    }
    
    var CurrentShape: Shapes = .NoShape

    @IBOutlet weak var ChamferSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
