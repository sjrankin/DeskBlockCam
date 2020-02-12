//
//  Utilities.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class Utilities
{
    /// Rounds a double value.
    /// - Warning: If `ToMagnitude` is not power of 10, the original value is returned unchanged.
    /// - Parameter Raw: The value to round.
    /// - Parameter ToMagnitude: The magnitude to round to. The bigger the number the more the digits. This
    ///                          parameter must be a power of 10. If not, the original number is returned
    ///                          unchanged. Defaults to 10000.0
    /// - Returns: Rounded value.
    public static func Rounded(_ Raw: Double, ToMagnitude: Double = 10000.0) -> Double
    {
        if !Int(ToMagnitude).isMultiple(of: 10)
        {
            return Raw
        }
        return Double(Int(Raw * ToMagnitude)) / ToMagnitude
    }
    
    /// Rounds a double value and returns the result as a string.
    /// - Warning: If `ToMagnitude` is not power of 10, the original value is returned unchanged.
    /// - Parameter Raw: The value to round.
    /// - Parameter ToMagnitude: The magnitude to round to. The bigger the number the more the digits. This
    ///                          parameter must be a power of 10. If not, the original number is returned
    ///                          unchanged. Defaults to 10000.0
    /// - Returns: Rounded value converted to a string.
    public static func RoundedString(_ Raw: Double, ToMagnitude: Double = 10000.0) -> String
    {
        return "\(Rounded(Raw))"
    }
}
