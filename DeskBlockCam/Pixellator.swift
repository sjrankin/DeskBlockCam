//
//  Pixellator.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/6/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreImage

/// Class to reduce a passed image to a pixellated image.
class Pixellator
{
    /// Lock to prevent simultaneous accesses.
    private static var PixellateLock = NSObject()
    
    /// Pixellate the passed image.
    /// - Parameter Image: The image to pixellate.
    /// - Parameter BlockSize: Size of pixel regions.
    /// - Returns: Pixellated image on success, nil on error.
    public static func Pixellate(_ Image: CIImage, _ BlockSize: Int = 16) -> NSImage?
    {
        objc_sync_enter(PixellateLock)
        defer{ objc_sync_exit(PixellateLock) }
        if let Reduction = CIFilter(name: "CIPixellate")
        {
            Reduction.setDefaults()
            Reduction.setValue(Image, forKey: kCIInputImageKey)
            Reduction.setValue(BlockSize, forKey: kCIInputScaleKey)
            var Reduced: CIImage? = nil
                    Reduced = (Reduction.value(forKey: kCIOutputImageKey) as? CIImage)
            if Reduced != nil
            {
                let Rep = NSCIImageRep(ciImage: Reduced!)
                let Pixellated: NSImage = NSImage(size: Rep.size)
                Pixellated.addRepresentation(Rep)
                return Pixellated
            }
            /*
            OperationQueue.main.addOperation
                {

                    if let Reduced: CIImage = (Reduction.value(forKey: kCIOutputImageKey) as? CIImage)
                    {
                        let Rep = NSCIImageRep(ciImage: Reduced)
                        /*let Pixellated: NSImage = NSImage(size: Rep.size)*/
                        Pixellated = NSImage(size: Rep.size)
                        Pixellated.addRepresentation(Rep)
                        //                return Pixellated
                    }

            }
 */
        }
        return nil
    }
}
