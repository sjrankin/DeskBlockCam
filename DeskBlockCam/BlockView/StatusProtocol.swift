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
    
    func UpdateDuration(NewDuration: Double)
    
    func FinalizeDuration(WithDuration: Double)
    
    /// Show how long a step of still image processing took (in place of "Done" in its row).
    /// - Parameter For: The step.
    /// - Parameter Seconds: How long the step took.
    func ReportStepDuration(For Step: StatusSteps, Seconds: Double)
    
    /// Show that a step was skipped because its result was already cached (in place of "Done" in its row).
    /// - Parameter For: The step.
    func ReportStepCached(For Step: StatusSteps)
}

/// The steps of still image processing that have a row in the status view.
enum StatusSteps
{
    /// Resizing and pixellating the image.
    case Preparing
    /// Reading the colors of the pixellated image.
    case Parsing
    /// Creating a shape for each color.
    case Creating
    /// Merging the shapes, preparing them for display and adding them to the scene.
    case Adding
}
