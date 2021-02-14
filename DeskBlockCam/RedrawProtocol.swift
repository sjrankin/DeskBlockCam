//
//  RedrawProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for telling the main view when to redraw an image or live view
/// due to user setting changes.
protocol RedrawProtocol: AnyObject
{
    /// Redraw the still image.
    func RedrawImage()
    
    /// Reset the live view image.
    func ResetLiveView()
    
    /// Call when the settings window closes.
    func SettingsWindowClosing()
}
