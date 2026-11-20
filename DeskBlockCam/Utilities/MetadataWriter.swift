//
//  MetadataWriter.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/19/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

extension FileIO
{
    /// Save an image with metadata. This is intended to be used to save processed images.
    /// - Note:
    ///    - Some data is not saved unless the user explicitly tells BlockCam to save it. Specifically:
    ///      1. User name is not saved without explicit permission.
    ///      2. User copyright/legal is not saved without explicit permission.
    ///    - This function adds meta data with the following steps:
    ///      1. Save the image in the scratch directory.
    ///      2. Update the image file with metadata.
    ///      3. Save the updated image to the scratch directory.
    ///      4. Delete the original image.
    ///      5. Move the updated image from the scratch directory to the final directory.
    ///    - See:
    ///      - [CGImageMetadata.swift](https://gist.github.com/lacyrhoades/09d8a367125b6225df5038aec68ed9e7)
    ///      - [Set an EXIF user comment.](https://gist.github.com/kwylez/a4b6ec261e52970e1fa5dd4ccfe8898f)
    ///      - [Missing image metadata when saving update image into PhotoKit](https://stackoverflow.com/questions/41169156/missing-image-metadata-when-saving-updated-image-into-photokit)
    /// - Parameter ThisImage: The image to save.
    /// - Parameter KeyValueString: It is assumed this is a list of parameters used to create the image and as such, is stored
    ///                         in the `Keywords` XMP section. **If the passed string contains any non-ASCII characters, the entire
    ///                         sub-string will be removed before it is saved as metadata.**
    /// - Parameter SaveTo: URL of the destination of the image file.
    /// - Parameter Completion: Completion closure. Passes a Bool indicating whether the save was successful (true) or not.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SaveImageWithMetaData(_ ThisImage: NSImage, KeyValueString: String, SaveTo: URL,
                                                                Completion: ((Bool) -> ())? = nil) -> Bool
    {
        let UserString = Utilities.ValidateKVPForASCIIOnly(KeyValueString, Separator: ";")
        // Every step below can fail (an unreadable image, a full disk, a metadata problem); report that instead of crashing.
        func Fail(_ Reason: String) -> Bool
        {
            print("Error saving image with metadata: \(Reason)")
            Completion?(false)
            return false
        }
        guard let cgi = ThisImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else
        {
            return Fail("the image has no bitmap data")
        }
        let bmpR = NSBitmapImageRep(cgImage: cgi)
        guard let ImageData = bmpR.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:]),
              let ImageSource = CGImageSourceCreateWithData(ImageData as CFData, nil) else
        {
            return Fail("the image could not be encoded as a JPEG")
        }
        let FinalName = Utilities.MakeSequentialName("ImageSrc", Extension: "jpg")
        SaveImageInScratch(ThisImage, FinalName)
        let FileURL = GetDirectoryURL(.Scratch).appendingPathComponent(FinalName)
        let DestURL = GetDirectoryURL(.Scratch).appendingPathComponent(Utilities.MakeSequentialName("ImageEx", Extension: "jpg"))
        print("FileURL=\(FileURL.path)")
        print("DestURL=\(DestURL.path)")
        guard let Destination = CGImageDestinationCreateWithURL(DestURL as CFURL, kUTTypeJPEG, 1, nil) else
        {
            return Fail("the destination file could not be created")
        }
        
        let SoftwareTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceTIFF,
                                                   kCGImageMetadataPrefixTIFF,
                                                   kCGImagePropertyTIFFSoftware,
                                                   .string,
                                                   Versioning.ApplicationName + ", " + Versioning.MakeVersionString() + " " + Versioning.MakeBuildString() as CFString)
        
        let MetaData = CGImageMetadataCreateMutable()
        var TagPath = "tiff:Software" as CFString
        guard let SoftwareTag = SoftwareTag else
        {
            return Fail("the software tag could not be created")
        }
        var result = CGImageMetadataSetTagWithPath(MetaData, nil, TagPath, SoftwareTag)
        
        if Settings.GetBoolean(ForKey: .AddUserDataToExif)
        {
            if let RawCopyright = Settings.GetString(ForKey: .UserCopyright)
            {
                if RawCopyright.count > 0
                {
                    let CopyrightPath = "\(kCGImageMetadataPrefixTIFF):\(kCGImagePropertyTIFFCopyright)" as CFString
                    guard let CopyrightTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceTIFF,
                                                                      kCGImageMetadataPrefixTIFF, kCGImagePropertyTIFFCopyright,
                                                                      .string,
                                                                      RawCopyright as CFString) else
                    {
                        print("Error creating user copyright tag.")
                        Completion?(false)
                        return false
                    }
                    CGImageMetadataSetTagWithPath(MetaData, nil, CopyrightPath, CopyrightTag)
                }
            }
            if let RawUserName = Settings.GetString(ForKey: .UserName)
            {
                if RawUserName.count > 0
                {
                    let ArtistPath = "\(kCGImageMetadataPrefixTIFF):\(kCGImagePropertyTIFFArtist)" as CFString
                    guard let AuthorTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceTIFF,
                                                                   kCGImageMetadataPrefixTIFF, kCGImagePropertyTIFFArtist,
                                                                   .string,
                                                                   RawUserName as CFString) else
                    {
                        print("Error creating user name tag.")
                        Completion?(false)
                        return false
                    }
                    CGImageMetadataSetTagWithPath(MetaData, nil, ArtistPath, AuthorTag)
                }
            }
        }
        
        let KeywordArray = NSMutableArray()
        let WordParts = UserString.split(separator: ";", omittingEmptySubsequences: true)
        for Word in WordParts
        {
            KeywordArray.add(String(Word))
        }
        let KeyWordsTag = CGImageMetadataTagCreate(kCGImageMetadataNamespaceIPTCCore,
                                                   kCGImageMetadataPrefixIPTCCore,
                                                   kCGImagePropertyIPTCKeywords,
                                                   .arrayOrdered,
                                                   KeywordArray as CFTypeRef)
        TagPath = "\(kCGImageMetadataPrefixXMPBasic):\(kCGImagePropertyIPTCKeywords)" as CFString
        guard let KeyWordsTag = KeyWordsTag else
        {
            return Fail("the keywords tag could not be created")
        }
        result = CGImageMetadataSetTagWithPath(MetaData, nil, TagPath, KeyWordsTag)
        
        guard let XMPData = CGImageMetadataCreateXMPData(MetaData, nil),
              let XMP = String(data: XMPData as Data, encoding: .utf8),
              let FinalXMPData = XMP.data(using: .ascii),
              let FinalMeta = CGImageMetadataCreateFromXMPData(FinalXMPData as CFData) else
        {
            return Fail("the metadata could not be converted")
        }
        
        let DestOptions: [String: Any] =
            [
                kCGImageDestinationMergeMetadata as String: NSNumber(value: 1),
                kCGImageDestinationMetadata as String: FinalMeta
        ]
        var CompletedOK = true
        let CFDestOptions = DestOptions as CFDictionary
        var error: Unmanaged<CFError>? = nil
        withUnsafeMutablePointer(to: &error,
                                 {
                                    ptr in
                                    result = CGImageDestinationCopyImageSource(Destination, ImageSource, CFDestOptions, ptr)
                                    if !result
                                    {
                                        CompletedOK = false
                                        print("Error saving image: \(DestURL.path)")
                                    }
        })
        if !CompletedOK
        {
            print("CGImageDestinationCopyImageSource failed: error: \(String(describing: error))")
            Completion?(false)
            return false
        }
        
        do
        {
            print("Moving \(FileURL.path) to \(SaveTo.path)")
            DeleteFile(SaveTo)
            try FileManager.default.moveItem(at: FileURL, to: SaveTo)
        }
        catch
        {
            print("Error moving file \(FileURL.path) to \(SaveTo.path)")
        }
        
        Completion?(CompletedOK)
        return true
    }
}
