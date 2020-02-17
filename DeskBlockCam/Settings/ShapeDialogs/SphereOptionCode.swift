//
//  SphereOptionCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class SphereOptionCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !NewCaption.isEmpty
        {
            Caption.stringValue = NewCaption
        }
        let Behavior = Settings.GetEnum(ForKey: .SphereBehavior, EnumType: SphereBehaviors.self,
                                        Default: .Size)
        switch Behavior
        {
            case .Height:
                BehaviorSegment.selectedSegment = 1
            
            case .Size:
                BehaviorSegment.selectedSegment = 0
        }
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
    
    @IBAction func HandleBehaviorChanged(_ sender: Any)
    {
        switch BehaviorSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(.Size, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
            
            case 1:
                Settings.SetEnum(.Height, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
            
            default:
                Settings.SetEnum(.Size, EnumType: SphereBehaviors.self, ForKey: .SphereBehavior)
        }
        Delegate?.UpdateCurrent()
    }
    
    func SetShape(_ Shape: Shapes)
    {
        CurrentShape = Shape
    }
    
    var CurrentShape: Shapes = .NoShape

    @IBOutlet weak var BehaviorSegment: NSSegmentedControl!
    @IBOutlet weak var Caption: NSTextField!
}
