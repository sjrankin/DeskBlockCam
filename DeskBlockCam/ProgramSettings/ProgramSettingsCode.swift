//
//  ProgramSettingsCode.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/10/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

class ProgramSettingsCode: NSViewController, NSTextFieldDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowHistogramCheck.state = Settings.GetBoolean(ForKey: .ShowHistogram) ? .on : .off
        OpenShapeOptionsCheck.state = Settings.GetBoolean(ForKey: .AutoOpenShapeSettings) ? .on : .off
        SwitchOnDropCheck.state = Settings.GetBoolean(ForKey: .SwitchModesWithDroppedImages) ? .on : .off
        InitializePrivacyTab()
    }
    
    func InitializePrivacyTab()
    {
        CopyrightTextBox.delegate = self
        CopyrightTextBox.stringValue = Settings.GetString(ForKey: .UserCopyright) ?? ""
        NameTextBox.delegate = self
        NameTextBox.stringValue = Settings.GetString(ForKey: .UserName) ?? ""
        SaveMetadataCheck.state = Settings.GetBoolean(ForKey: .AddUserDataToExif) ? .on : .off
        IncludeCopyrightCheck.state = Settings.GetBoolean(ForKey: .SaveUserCopyright) ? .on : .off
        IncludeNameCheck.state = Settings.GetBoolean(ForKey: .SaveUserName) ? .on : .off
        UpdateUI()
    }
    
    func UpdateUI()
    {
        if Settings.GetBoolean(ForKey: .SaveUserCopyright)
        {
            CopyrightTextBox.stringValue = Settings.GetString(ForKey: .UserCopyright) ?? ""
            CopyrightTextBox.isEnabled = true
        }
        else
        {
            CopyrightTextBox.stringValue = ""
            CopyrightTextBox.isEnabled = false
        }
        if Settings.GetBoolean(ForKey: .SaveUserName)
        {
            NameTextBox.stringValue = Settings.GetString(ForKey: .UserName) ?? ""
            NameTextBox.isEnabled = true
        }
        else
        {
            NameTextBox.stringValue = ""
            NameTextBox.isEnabled = false
        }
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
    
    @IBAction func HandleNameCheckChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBoolean(Check.state == .on, ForKey: .SaveUserName)
            UpdateUI()
        }
    }
    
    @IBAction func HandleCopyrightCheckChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBoolean(Check.state == .on, ForKey: .SaveUserCopyright)
            UpdateUI()
        }
    }
    
    @IBAction func HandleSaveMetadataChanged(_ sender: Any)
    {
        if let Check = sender as? NSButton
        {
            Settings.SetBoolean(Check.state == .on, ForKey: .AddUserDataToExif)
        }
    }
    
     func controlTextDidChange(_ notification: Notification)
    {
        if let Field = notification.object as? NSTextField
        {
            switch Field
            {
                case CopyrightTextBox:
                    Settings.SetString(CopyrightTextBox.stringValue, ForKey: .UserCopyright)
                
                case NameTextBox:
                    Settings.SetString(NameTextBox.stringValue, ForKey: .UserName)
                
                default:
                break
            }
        }
    }
    
    @IBOutlet weak var CopyrightTextBox: NSTextField!
    @IBOutlet weak var NameTextBox: NSTextField!
    @IBOutlet weak var IncludeCopyrightCheck: NSButton!
    @IBOutlet weak var IncludeNameCheck: NSButton!
    @IBOutlet weak var SaveMetadataCheck: NSButton!
    @IBOutlet weak var SwitchOnDropCheck: NSButton!
    @IBOutlet weak var ShowHistogramCheck: NSButton!
    @IBOutlet weak var OpenShapeOptionsCheck: NSButton!
}
