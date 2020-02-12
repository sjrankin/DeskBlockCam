//
//  ErrorMessageWindowCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ErrorMessageWindowCode: NSWindowController
{
    func SetTitle(NewTitle: String)
    {
        self.window?.title = NewTitle
    }
    
    func SetErrorMessage(_ Message: String)
    {
        if let VC = self.contentViewController as? ErrorMessageController
        {
            VC.ErrorMessage = Message
        }
    }
    
    func CloseWindow()
    {
        self.close()
    }
}
