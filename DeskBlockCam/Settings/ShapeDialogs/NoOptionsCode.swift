//
//  NoOptionsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class NoOptionsCode: NSViewController, ToOptionsDialogProtocol
{
    weak var Delegate: ToOptionsParentProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !CaptionString.isEmpty
        {
        Caption2.stringValue = CaptionString
        }
    }
    
    var CaptionString = ""
    
    func SetAttributes(_ Attributes: ProcessingAttributes)
    {
    }
    
    func SetCaption(_ CaptionText: String)
    {
        CaptionString = CaptionText
        if Caption2 != nil
        {
            Caption2.stringValue = CaptionString
        }
    }
    
    @IBOutlet weak var Caption2: NSTextField!
}
