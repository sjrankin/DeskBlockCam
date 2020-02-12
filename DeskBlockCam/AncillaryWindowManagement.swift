//
//  AncillaryWindowManagement.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ViewController: AncillaryWindowProtocol
{
    func ClosedAncillaryWindow(WindowName: String)
    {
        switch WindowName
        {
            case "DebugWindow":
            DebugWindow = nil
            
            default:
            break
        }
    }
}
