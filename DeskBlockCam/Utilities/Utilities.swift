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
    /// Pad the passed string with specified leading characters to make the string no longer
    /// than `ForCount` characters in length.
    /// - Parameter Value: The value to pre-pad.
    /// - Parameter WithLeading: The string (assumed to be one character long) to use to pad
    ///                          the beginning of `Value`.
    /// - Parameter ForCount: The final total length of the returned string. If `Value` is already
    ///                       this length or greater, it is returned unchanged.
    /// - Returns: Padded string.
    public static func Pad(_ Value: String, _ WithLeading: String, _ ForCount: Int) -> String
    {
        if Value.count >= ForCount
        {
            return Value
        }
        let Delta = ForCount - Value.count
        let Many = String(repeating: WithLeading, count: Delta)
        return Many + Value
    }
    
    /// Pad the passed string with specified leading characters to make the string no longer
    /// than `ForCount` characters in length.
    /// - Parameter Value: The value to pre-pad. Passed as an integer.
    /// - Parameter WithLeading: The string (assumed to be one character long) to use to pad
    ///                          the beginning of `Value`.
    /// - Parameter ForCount: The final total length of the returned string. If `Value` is already
    ///                       this length or greater, it is returned unchanged.
    /// - Returns: Padded string.
    public static func Pad(_ Value: Int, _ WithLeading: String, _ ForCount: Int) -> String
    {
        return Pad("\(Value)", WithLeading, ForCount)
    }
    
    /// Pad the passed string with specified trailing characters to make the string no longer
    /// than `ForCount` characters in length.
    /// - Parameter Value: The value to post-pad.
    /// - Parameter WithLeading: The string (assumed to be one character long) to use to pad
    ///                          the ending of `Value`.
    /// - Parameter ForCount: The final total length of the returned string. If `Value` is already
    ///                       this length or greater, it is returned unchanged.
    /// - Returns: Padded string.
    public static func Pad(_ Value: String, WithTrailing: String, ForCount: Int) -> String
    {
        if Value.count >= ForCount
        {
            return Value
        }
        let Delta = ForCount - Value.count
        let Many = String(repeating: WithTrailing, count: Delta)
        return Value + Many
    }
    
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
    
    /// Returns a sequential integer. The integer is stored in the user settings and will reset (loop around to the start) once
    /// the value passes .LoopSequentialIntegerAfter and be set to the value in .StartSequentialIntegerAt.
    public static func GetNextSequentialInteger() -> Int
    {
        var SeqInt = Settings.GetInteger(ForKey: .NextSequentialInteger)
        if SeqInt > Settings.GetInteger(ForKey: .LoopSequentialIntegerAfter)
        {
            SeqInt = Settings.GetInteger(ForKey: .StartSequentialIntegerAt)
        }
        Settings.SetInteger(SeqInt + 1, ForKey: .NextSequentialInteger)
        return SeqInt
    }
    
    /// Creates a sequential name. This is a name with a string prefix, a sequenced number, and an extension, such as
    /// `Image0066.jpg`
    /// - Parameter Prefix: The prefix of the name. If not supplied, "Sequence" will be used instead.
    /// - Parameter Extension: The extension of the file. No periods should be supplied.
    /// - Returns: File name as described above.
    public static func MakeSequentialName(_ Prefix: String, Extension: String) -> String
    {
        let FilePrefix = Prefix.isEmpty ? "Sequence" : Prefix
        let Sequence = GetNextSequentialInteger()
        let SeqStr = Pad(Sequence, "0", 4)
        let Name = FilePrefix + SeqStr + "." + Extension
        return Name
    }
    
    /// Verifies a list of separated strings for ASCII-only characters.
    /// - Parameter Raw: List of delimited strings.
    /// - Parameter Separator: The string used to separate sub-strings. Also used to recombine ASCII-only sub-strings.
    /// - Returns: String with all sub-strings with non-ASCII characters removed.
    public static func ValidateKVPForASCIIOnly(_ Raw: String, Separator: String) -> String
    {
        let WordParts = Raw.split(separator: Separator.first!, omittingEmptySubsequences: true)
        var Words = [String]()
        for WordPart in WordParts
        {
            if String(WordPart).canBeConverted(to: .ascii)
            {
                Words.append(String(WordPart))
            }
        }
        var Result = ""
        for Word in Words
        {
            Result.append(Word)
            Result.append(";")
        }
        return Result
    }
}
