//
//  Shrinker.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit
import CoreImage

class Shrinker
{
    /// Resizes an NSImage such that the longest dimension of the returned image is `Longest`.
    /// - Parameter Image: The image to resize.
    /// - Parameter Longest: The new longest dimension.
    /// - Returns: Resized image. If the longest dimension of the original image is less than `Longest`, the
    ///            original image is returned unchanged.
    public static func ResizeImage(Image: NSImage, Longest: CGFloat) -> NSImage
    {
        #if true
        let ImageMax = max(Image.size.width, Image.size.height)
        let Ratio = Longest / ImageMax
        if Ratio >= 1.0
        {
            return Image
        }
        let NewSize = NSSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        let NewImage = NSImage(size: NewSize)
        NewImage.lockFocus()
        Image.draw(in: NSMakeRect(0, 0, NewSize.width, NewSize.height),
                   from: NSMakeRect(0, 0, Image.size.width, Image.size.height),
                   operation: NSCompositingOperation.sourceOver,
                   fraction: CGFloat(1))
        NewImage.unlockFocus()
        NewImage.size = NewSize
        return NewImage
        #else
        let ImageMax = max(Image.size.width, Image.size.height)
        let Ratio = Longest / ImageMax
        if Ratio >= 1.0
        {
            return Image
        }
        let NewSize = CGSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        let Rect = CGRect(x: 0, y: 0, width: NewSize.width, height: NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, 1.0)
        Image.draw(in: Rect)
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return NewImage!
        #endif
    }
}
