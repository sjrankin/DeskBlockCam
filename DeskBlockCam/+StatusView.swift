//
//  +StatusView.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension ViewController: StatusProtocol
{
    /// Reset the image view status indicators.
    /// - Note: Executed on the main UI thread.
    func ResetStatus()
    {
        OperationQueue.main.addOperation
            {
                self.DurationValue.isHidden = true
                self.DurationText.textColor = NSColor.gray
                self.PreparingTextDone.isHidden = true
                self.PreparingImageText.textColor = NSColor.gray
                self.PreparingImageIndicator.stopAnimation(self)
                self.ParsingImageDone.isHidden = true
                self.ParsingImageText.textColor = NSColor.gray
                self.ParsingImageIndicator.isHidden = true
                self.CreatingShapesDone.isHidden = true
                self.CreatingShapesText.textColor = NSColor.gray
                self.CreatingShapesIndicator.isHidden = true
                self.AddingShapesDone.isHidden = true
                self.AddingShapesText.textColor = NSColor.gray
                self.AddingShapesIndicator.stopAnimation(self)
        }
    }
    
    /// Update status indicators.
    /// - Note: Executed on the main UI thread.
    /// - Parameter With: Status command to execute.
    func UpdateStatus(With Command: StatusCommands)
    {
        OperationQueue.main.addOperation
            {
                self.RunStatus(Command)
        }
    }
    
    /// Update status indicators.
    /// - Note: Executed on the main UI thread.
    /// - Parameter With: Status command to execute.
    /// - Parameter PercentComplete: Operation percent complete (range: 0.0 to 100.0).
    func UpdateStatus(With Command: StatusCommands, PercentComplete: Double)
    {
        OperationQueue.main.addOperation
            {
                self.RunStatus(Command, Percent: PercentComplete)
        }
    }
    
    /// Display the current duration of still image processing.
    /// - Note: Executed on the main UI thread.
    /// - Parameter NewDuration: Number of seconds for the current duration of image processing.
    func UpdateDuration(NewDuration: Double)
    {
        OperationQueue.main.addOperation
            {
                self.DurationText.textColor = NSColor.systemBlue
                let Value = Utilities.RoundedString(NewDuration, ToMagnitude: 1) + "s"
                self.DurationValue.isHidden = false
                self.DurationValue.textColor = NSColor.systemBlue
                self.DurationValue.stringValue = Value
        }
    }
    
    /// Finalize the duration for the processing of a still image.
    /// - Note: Executed on the main UI thread.
    /// - Parameter WithDuration: The final duration to display.
    func FinalizeDuration(WithDuration: Double)
    {
        OperationQueue.main.addOperation
            {
                self.DurationText.textColor = NSColor.black
                let Value = Utilities.RoundedString(WithDuration, ToMagnitude: 1) + "s"
                self.DurationValue.isHidden = false
                self.DurationValue.textColor = NSColor.black
                self.DurationValue.stringValue = Value
        }
    }
    
    /// Run a status command.
    /// - Note: Execued on the main UI thread.
    /// - Parameter Command: The status command to run.
    /// - Parameter Percent: If present and `Command` supports it, the percent complete of
    ///                      an operation.
    func RunStatus(_ Command: StatusCommands, Percent: Double? = nil)
    {
        switch Command
        {
            case .ResetStatus:
                ResetStatus()
            
            case .PreparingImage:
                PreparingImageText.textColor = NSColor.systemBlue
                PreparingImageIndicator.startAnimation(self)
            
            case .PreparationDone:
                PreparingImageText.textColor = NSColor.black
                PreparingTextDone.isHidden = false
                PreparingImageIndicator.stopAnimation(self)
            
            case .ParsingImage:
                ParsingImageIndicator.isHidden = false
                ParsingImageIndicator.doubleValue = 0.0
                ParsingImageText.textColor = NSColor.systemBlue
            
            case .ParsingPercentUpdate:
                ParsingImageIndicator.doubleValue = Percent!
            
            case .ParsingDone:
                ParsingImageText.textColor = NSColor.black
                ParsingImageDone.isHidden = false
                ParsingImageIndicator.isHidden = true
            
            case .CreatingShapes:
                CreatingShapesIndicator.isHidden = false
                CreatingShapesIndicator.doubleValue = 0.0
                CreatingShapesText.textColor = NSColor.systemBlue
            
            case .CreatingPercentUpdate:
                CreatingShapesIndicator.doubleValue = Percent!
            
            case .CreatingDone:
                CreatingShapesText.textColor = NSColor.black
                CreatingShapesDone.isHidden = false
                CreatingShapesIndicator.isHidden = true
            
            case .AddingShapes:
                AddingShapesText.textColor = NSColor.systemBlue
                AddingShapesIndicator.startAnimation(self)
            
            case .AddingDone:
                AddingShapesText.textColor = NSColor.black
                AddingShapesDone.isHidden = false
                AddingShapesIndicator.stopAnimation(self)
        }
    }
}

/// Status commands for still images.
enum StatusCommands
{
    /// Reset all status indicators.
    case ResetStatus
    /// Image preparation completed.
    case PreparationDone
    /// Preparing image.
    case PreparingImage
    /// Parsing image.
    case ParsingImage
    /// Parsing percent change.
    case ParsingPercentUpdate
    /// Parsing image complete.
    case ParsingDone
    /// Creating shapes.
    case CreatingShapes
    /// Creating shapes percent change.
    case CreatingPercentUpdate
    /// Creating shapes done.
    case CreatingDone
    /// Adding shapes.
    case AddingShapes
    /// Adding shapes completed.
    case AddingDone
}
