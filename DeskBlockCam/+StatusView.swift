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
    func ResetStatus()
    {
        DurationValue.isHidden = true
        DurationText.textColor = NSColor.gray
        PreparingTextDone.isHidden = true
        PreparingImageText.textColor = NSColor.gray
        PreparingImageIndicator.stopAnimation(self)
        ParsingImageDone.isHidden = true
        ParsingImageText.textColor = NSColor.gray
        ParsingImageIndicator.isHidden = true
        CreatingShapesDone.isHidden = true
        CreatingShapesText.textColor = NSColor.gray
        CreatingShapesIndicator.isHidden = true
        AddingShapesDone.isHidden = true
        AddingShapesText.textColor = NSColor.gray
        AddingShapesIndicator.stopAnimation(self)
    }
    
    /// Update status indicators.
    /// - Parameter With: Status command to execute.
    func UpdateStatus(With Command: StatusCommands)
    {
        OperationQueue.main.addOperation
            {
                self.RunStatus(Command)
        }
    }
    
    /// Update status indicators.
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
