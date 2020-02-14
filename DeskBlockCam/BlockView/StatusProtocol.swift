//
//  StatusProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for communicating status changes to the UI.
protocol StatusProtocol: class
{
    /// Update the status view with the passed command.
    /// - Parameter With: The command to execute.
    func UpdateStatus(With Command: StatusCommands)
    
    /// Update the status view with the passed command.
    /// - Parameter With: The command to execute.
    /// - Parameter PercentComplete: Percent complete (from 0.0 to 100.0) of an operation.
    func UpdateStatus(With Command: StatusCommands, PercentComplete: Double)
}
