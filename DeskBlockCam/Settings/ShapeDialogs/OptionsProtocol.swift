//
//  OptionsProtocol.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ToOptionsDialogProtocol: AnyObject
{
    func SetShape(_ Shape: Shapes)
    func SetCaption(_ CaptionText: String)
    func SetAttributes(_ Attributes: ProcessingAttributes)
}

protocol ToOptionsParentProtocol: AnyObject
{
    func UpdateCurrent(With Shape: Shapes)
    func UpdatedOptions(_ Updated: ProcessingAttributes)
    func WasSelected(_ Shape: Shapes)
}
