//
//  AboutController.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class AboutController: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        VersionBlock.stringValue = Versioning.MakeVersionBlock()
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var VersionBlock: NSTextField!
}
