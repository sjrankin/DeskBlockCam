//
//  ProcessedProtocol.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

protocol ProcessedProtocol: class
{
    func ImageForDebug(_ Image: NSImage, ImageType: DebugImageTypes)
}
