//
//  OptionsProtocol.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/7/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ToOptionsDialogProtocol: class
{
    func SetCaption(_ CaptionText: String)
    func SetAttributes(_ Attributes: ProcessingAttributes)
}

protocol ToOptionsParentProtocol: class
{
    func UpdatedOptions(_ Updated: ProcessingAttributes)
}
