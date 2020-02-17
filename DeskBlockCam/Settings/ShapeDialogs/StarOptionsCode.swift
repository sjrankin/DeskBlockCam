//
//  StarOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class StarOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Varies = Settings.GetBoolean(ForKey: .ApexesIncrease)
        let Apexes = Settings.GetInteger(ForKey: .StarApexCount)
        ApexSegment.selectedSegment = Apexes - 4
        VariableApexesCheck.state = Varies ? .on : .off
    }
    
    var NewCaption: String = ""
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
    }
    
    func UpdatedOptions(_ Updated: ProcessingAttributes)
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
    
    @IBAction func HandleVariableApexesChanged(_ sender: Any)
    {
        Settings.SetBoolean(VariableApexesCheck.state == .on, ForKey: .ApexesIncrease)
        Delegate?.UpdateCurrent()
    }
    
    @IBAction func HandleApexCountChanged(_ sender: Any)
    {
        let Index = ApexSegment.selectedSegment + 4
        Settings.SetInteger(Index, ForKey: .StarApexCount)
        Delegate?.UpdateCurrent()
    }
    
    var CurrentShape: Shapes = .NoShape
    
    @IBOutlet weak var VariableApexesCheck: NSButton!
    @IBOutlet weak var ApexSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
