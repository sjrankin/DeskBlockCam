//
//  ErrorMessageController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ErrorMessageController: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ErrorMessageLabel.stringValue = ErrorMessage
    }

    private var _ErrorMessage: String = ""
    {
        didSet
        {
            if ErrorMessageLabel != nil
            {
                ErrorMessageLabel.stringValue = _ErrorMessage
            }
        }
    }
    public var ErrorMessage: String
    {
        get
        {
            return _ErrorMessage
        }
        set
        {
            _ErrorMessage = newValue
        }
    }
    
        @IBOutlet weak var ErrorMessageLabel: NSTextField!
}
