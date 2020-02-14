//
//  ErrorMessageHandling.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ViewController
{
    /// Show an error message in a pop-up window.
    /// - Parameter Message: The text of the message to display.
    /// - Parameter WindowTitle: The title of the window. If nil, "Error" will be shown.
    func ShowError(Message: String, WindowTitle: String? = nil)
    {
        print("\(WindowTitle ?? "Error"): \(Message)")
        let Storyboard = NSStoryboard(name: "ErrorMessage", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ErrorMessageWindowID") as? ErrorMessageWindowCode
        {
            let ErrorWindow = WindowController.window
            if let ErrorTitle = WindowTitle
            {
                WindowController.SetTitle(NewTitle: ErrorTitle)
            }
            #if true
            self.view.window?.beginSheet(ErrorWindow!, completionHandler: nil)
            #else
            WindowController.showWindow(nil)
            #endif
            WindowController.SetErrorMessage(Message)
        }
    }
}
