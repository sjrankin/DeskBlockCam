//
//  FileIO.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Simple wrappers around the `FileManager` class.
class FileIO
{
    /// Name of the BlockCam directory.
    public static var BlockCamDirectory = "DeskBlockCam"
    /// Name of the Frames directory under `BlockCamDirectory`.
    public static var FramesDirectory = "DeskBlockCam/Frames"
    
    /// Initialize `FileIO`.
    /// - Note: If not called, it is likely the app will crash.
    public static func Initialize()
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let AppDirURL = DocDirURL.appendingPathComponent(BlockCamDirectory)
        if !DirectoryExists(AppDirURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: AppDirURL.path,
                                                        withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                print("Error creating \(BlockCamDirectory) in Documents: \(error)")
                return
            }
        }
        let FrameURL = DocDirURL.appendingPathComponent(FramesDirectory)
        if !DirectoryExists(FrameURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: FrameURL.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch
            {
                print("Error creating \(FramesDirectory) in Documents: \(error)")
                return
            }
        }
        print("Verified or created application directories.")
    }
    
    /// Determines if the passed directory exists.
    /// - Parameter Name: The name of the directory.
    /// - Returns: True if the directory exists, false if not.
    public static func DirectoryExists(_ Name: String) -> Bool
    {
        var IsDir = ObjCBool(true)
        let WasFound = FileManager.default.fileExists(atPath: Name, isDirectory: &IsDir)
        return WasFound
    }
    
    /// Save a frame image in the `FramesDirectory`.
    /// - Note: The name of the image saved is `Frame_xxxx.png` where `xxxx` is the frame number (the
    ///         number of `x`s does *not* indicate the maximum number of frames that can be stored).
    /// - Parameter FrameImage: The image to saved.
    /// - Parameter FrameID: The frame number of the image to save. Assumed to be unique for a given
    ///                      session of saving frames. If not, older files with the same frame ID
    ///                      will be overwritten.
    /// - Returns: True on success, false on failure.
    public static func SaveFrame(_ FrameImage: NSImage, FrameID: Int) -> Bool
    {
        let Name = "Frame" + "_\(FrameID).png"
        let FramesURL = GetDirectoryURL(.Frames)
        return SaveImage(FrameImage, In: FramesURL.path, With: Name)
    }
    
    /// Save an image to the specified directory.
    /// - Note: If a file with the same name as specified by the `In`/`With' combination exists,
    ///         it will be overwritten.
    /// - Note: Images are saved in .png format.
    /// - Parameter Image: The image to save.
    /// - Parameter In: The name of the directory where to save the image.
    /// - Parameter With: The name to use to save the image.
    /// - Returns: True on success, false on failure.
    public static func SaveImage(_ Image: NSImage, In Directory: String, With Name: String) -> Bool
    {
        let FinalName = Directory + "/" + Name
        return Image.Write(To: FinalName)
    }
    
    /// Remove all items in the frames directory.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func ClearFramesDirectory() -> Bool
    {
        return ClearDirectory(GetDirectoryURL(.Frames))
    }
    
    /// Remove all items in the specified directory.
    /// - Parameter: DirURL: The URL of the directory to be cleared.
    /// - Returns: True on success, false on failure.
    public static func ClearDirectory(_ DirURL: URL) -> Bool
    {
        do
        {
            if FileManager.default.changeCurrentDirectoryPath(DirURL.path)
            {
                for File in try FileManager.default.contentsOfDirectory(atPath: ".")
                {
                    try FileManager.default.removeItem(atPath: File)
                }
            }
        }
        catch
        {
            print("Error clearing \(DirURL.path): \(error)")
            return false
        }
        return true
    }
    
    /// Returns the URL of the specified directory.
    /// - Parameter ForDirectory: Pre-defined directory whose URL will be returned.
    /// - Returns: URL of the predefined directory.
    public static func GetDirectoryURL(_ ForDirectory: Directories) -> URL
    {
        let DocURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        switch ForDirectory
        {
            case .Documents:
            return DocURL
            
            case .DeskBlockCam:
                return DocURL.appendingPathComponent(BlockCamDirectory)
            
            case .Frames:
                return DocURL.appendingPathComponent(FramesDirectory)
        }
    }
}

/// Pre-defined directories whose URLs can be returned by `GetDirectoryURL`.
enum Directories
{
    /// Main application directory - resides in the user's Documents directory.
    case DeskBlockCam
    /// Frame storage directory.
    case Frames
    /// The documents directory for the user.
    case Documents
}

/// Extension to add Png data exports and writing of images to `NSImage`. Found on the internet but
/// forgot to save the link.
extension NSImage
{
    /// Returns the image data in the instance as a Png representation.
    var Png: Data?
    {
        guard let Tiff = tiffRepresentation,
            let BImage = NSBitmapImageRep(data: Tiff) else
        {
            return nil
        }
        return BImage.representation(using: .png, properties: [:])
    }
    
    /// Write the instance data to the path in `To` as a Png file.
    /// - Parameter To: The path where the image will be written.
    /// - Parameter Options: Data writing options. Defaults to `.atomic`.
    /// - Returns: True on success, false on failure.
    func Write(To: String, Options: Data.WritingOptions = .atomic) -> Bool
    {
        do
        {
            try Png?.write(to: URL(fileURLWithPath: To), options: Options)
            return true
        }
        catch
        {
            print("Error writing image to \(To): \(error)")
            return false
        }
    }
}
