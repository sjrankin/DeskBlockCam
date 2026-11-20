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
    
    /// Show how long a step took in place of "Done" in its row.
    /// - Note: Executed on the main UI thread.
    /// - Parameter For: The step.
    /// - Parameter Seconds: How long the step took.
    func ReportStepDuration(For Step: StatusSteps, Seconds: Double)
    {
        // Short enough ("0.42s", "9.31s", "12.3s") to fit where "Done" was.
        let Text: String
        if Seconds < 10.0
        {
            Text = Seconds.formatted(.number.precision(.fractionLength(2))) + "s"
        }
        else if Seconds < 100.0
        {
            Text = Seconds.formatted(.number.precision(.fractionLength(1))) + "s"
        }
        else
        {
            Text = Seconds.formatted(.number.precision(.fractionLength(0))) + "s"
        }
        OperationQueue.main.addOperation
            {
                switch Step
                {
                    case .Preparing:
                        self.PreparingTextDone.stringValue = Text
                    
                    case .Parsing:
                        self.ParsingImageDone.stringValue = Text
                    
                    case .Creating:
                        self.CreatingShapesDone.stringValue = Text
                    
                    case .Adding:
                        self.AddingShapesDone.stringValue = Text
                }
        }
    }
    
    /// Show that a step was skipped because its result was cached.
    /// - Note: Executed on the main UI thread.
    /// - Parameter For: The step.
    func ReportStepCached(For Step: StatusSteps)
    {
        OperationQueue.main.addOperation
            {
                switch Step
                {
                    case .Preparing:
                        self.PreparingTextDone.stringValue = "cached"
                    
                    case .Parsing:
                        self.ParsingImageDone.stringValue = "cached"
                    
                    case .Creating:
                        self.CreatingShapesDone.stringValue = "cached"
                    
                    case .Adding:
                        self.AddingShapesDone.stringValue = "cached"
                }
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
                ParsingImageIndicator.doubleValue = Percent ?? 0.0
            
            case .ParsingDone:
                ParsingImageText.textColor = NSColor.black
                ParsingImageDone.isHidden = false
                ParsingImageIndicator.isHidden = true
            
            case .CreatingShapes:
                CreatingShapesIndicator.isHidden = false
                CreatingShapesIndicator.doubleValue = 0.0
                CreatingShapesText.textColor = NSColor.systemBlue
            
            case .CreatingPercentUpdate:
                CreatingShapesIndicator.doubleValue = Percent ?? 0.0
            
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
