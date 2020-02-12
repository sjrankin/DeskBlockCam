//
//  ProgramSettingsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class ProgramSettingsCode: NSViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowHistogramCheck.state = Settings.GetBoolean(ForKey: .ShowHistogram) ? .on : .off
        OpenShapeOptionsCheck.state = Settings.GetBoolean(ForKey: .AutoOpenShapeSettings) ? .on : .off
        SwitchOnDropCheck.state = Settings.GetBoolean(ForKey: .SwitchModesWithDroppedImages) ? .on : .off
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBAction func HandleShowHistogramChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBoolean(Check.state == .on, ForKey: .ShowHistogram)
        }
    }
    
    @IBAction func HandleOpenShapeOptionsChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBoolean(Check.state == .on, ForKey: .AutoOpenShapeSettings)
        }
    }
    
    @IBAction func HandleSwitchOnDropCheckChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBoolean(Check.state == .on, ForKey: .SwitchModesWithDroppedImages)
        }
    }
    
    @IBOutlet weak var SwitchOnDropCheck: NSButton!
    @IBOutlet weak var ShowHistogramCheck: NSButton!
    @IBOutlet weak var OpenShapeOptionsCheck: NSButton!
}
