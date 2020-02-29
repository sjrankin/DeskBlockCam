//
//  Settings.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/9/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Wrapper around `UserDefaults.standard` to provide atomic-level change notification for settings.
/// - Note:
///   - See the enum `SettingKeys` for a description of each setting.
///   - Currently, settings are stored in `UserDefaults.standard`. However, it is straightforward to refactor this class to use
///     a different storage type, such as a database or .XML or .JSON file.
/// - Warning: If the caller tries to access a setting with the incorrect type (such as calling `GetBoolean` with a String-
///            backed setting), a fatal error will be generated. See `GetSettingType` for a way to avoid this.
class Settings
{
    /// Table of subscribers.
    private static var Subscribers = [(String, SettingChangedProtocol?)]()
    
    /// Initialize the class. Creates the default set of settings if they do not exist.
    public static func Initialize()
    {
        InitializeDefaults()
    }
    
    /// Initialize defaults if there are no current default settings available.
    public static func InitializeDefaults()
    {
        if UserDefaults.standard.string(forKey: SettingKeys.Initialized.rawValue) == nil
        {
            print("Initializing settings.")
            AddDefaultSettings()
        }
    }
    
    /// Create and add default settings.
    /// - Note: If called after initialize instantiation, all user-settings will be overwritten.
    /// - Note: Depending on whether the compilation was for a debug build or a release build, default settings may
    ///         vary. For each instance of a variance between the two build types, comments are provided. In general,
    ///         debug builds are not as stringent with privacy.
    public static func AddDefaultSettings()
    {
        UserDefaults.standard.set("Initialized", forKey: SettingKeys.Initialized.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.Shape.rawValue)
        UserDefaults.standard.set(16, forKey: SettingKeys.ShapeSize.rawValue)
        UserDefaults.standard.set(VerticalExaggerations.Medium.rawValue, forKey: SettingKeys.VerticalExaggeration.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.InvertHeight.rawValue)
        UserDefaults.standard.set(0.5, forKey: SettingKeys.Side.rawValue)
        UserDefaults.standard.set(HeightDeterminations.Brightness.rawValue, forKey: SettingKeys.HeightDetermination.rawValue)
        UserDefaults.standard.set(1024, forKey: SettingKeys.MaximumLength.rawValue)
        UserDefaults.standard.set(ConditionalColorTypes.None.rawValue, forKey: SettingKeys.ConditionalColor.rawValue)
        UserDefaults.standard.set(ConditionalColorActions.Grayscale.rawValue, forKey: SettingKeys.ConditionalColorAction.rawValue)
        UserDefaults.standard.set(ConditionalColorThresholds.Less50.rawValue, forKey: SettingKeys.ConditionalColorThreshold.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.InvertConditionalColor.rawValue)
        UserDefaults.standard.set(Backgrounds.Color.rawValue, forKey: SettingKeys.BackgroundType.rawValue)
        UserDefaults.standard.set(0xff000000, forKey: SettingKeys.BackgroundColor.rawValue)
        UserDefaults.standard.set("0xffffffff,0xff000000", forKey: SettingKeys.BackgroundGradientColors.rawValue)
        UserDefaults.standard.set(0xffffffff, forKey: SettingKeys.LightColor.rawValue)
        UserDefaults.standard.set(LightingTypes.Omni.rawValue, forKey: SettingKeys.LightType.rawValue)
        UserDefaults.standard.set(LightIntensities.Normal.rawValue, forKey: SettingKeys.LightIntensity.rawValue)
        UserDefaults.standard.set(LightModels.Lambert.rawValue, forKey: SettingKeys.LightModel.rawValue)
        UserDefaults.standard.set(AntialiasingModes.x4.rawValue, forKey: SettingKeys.Antialiasing.rawValue)
        UserDefaults.standard.set(6, forKey: SettingKeys.PolygonSideCount.rawValue)
        UserDefaults.standard.set(6, forKey: SettingKeys.Polygon2DSideCount.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.FullyExtrudeLetters.rawValue)
        UserDefaults.standard.set(36, forKey: SettingKeys.FontSize.rawValue)
        UserDefaults.standard.set(LetterSmoothnesses.Smooth.rawValue, forKey: SettingKeys.LetterSmoothness.rawValue)
        
        UserDefaults.standard.set(BlockChamferSizes.None.rawValue, forKey: SettingKeys.BlockChamfer.rawValue)
        UserDefaults.standard.set(Orientations.Horizontal.rawValue, forKey: SettingKeys.OvalOrientation.rawValue)
        UserDefaults.standard.set(Distances.Medium.rawValue, forKey: SettingKeys.OvalLength.rawValue)
        UserDefaults.standard.set(Orientations.Horizontal.rawValue, forKey: SettingKeys.DiamondOrientation.rawValue)
        UserDefaults.standard.set(Distances.Medium.rawValue, forKey: SettingKeys.DiamondLength.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.StackedShapeList.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.HueShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.SaturationShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.BrightnessShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.RedShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.GreenShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.BlueShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.CyanShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.MagentaShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.YellowShapes.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.BlackShapes.rawValue)
        UserDefaults.standard.set(VaryingComponents.Hue.rawValue, forKey: SettingKeys.VaryingComponent.rawValue)
        UserDefaults.standard.set(Shapes.Cones.rawValue, forKey: SettingKeys.BlockWithShape.rawValue)
        UserDefaults.standard.set(Shapes.Cones.rawValue, forKey: SettingKeys.SphereWithShape.rawValue)
        UserDefaults.standard.set(Shapes.Spheres.rawValue, forKey: SettingKeys.CapShape.rawValue)
        UserDefaults.standard.set(CapLocations.Top.rawValue, forKey: SettingKeys.CapLocation.rawValue)
        UserDefaults.standard.set(CappedLineLineColors.Same.rawValue, forKey: SettingKeys.CappedLineLineColor.rawValue)
        UserDefaults.standard.set(5, forKey: SettingKeys.StarApexCount.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.ApexesIncrease.rawValue)
        UserDefaults.standard.set(LineThicknesses.Thin.rawValue, forKey: SettingKeys.RadialLineThickness.rawValue)
        UserDefaults.standard.set(4, forKey: SettingKeys.LineCount.rawValue)
        UserDefaults.standard.set(CharacterSets.Latin.rawValue, forKey: SettingKeys.CharacterSet.rawValue)
        UserDefaults.standard.set(ConeTopSizes.Zero.rawValue, forKey: SettingKeys.ConeTopSize.rawValue)
        UserDefaults.standard.set(ConeBottomSizes.Side.rawValue, forKey: SettingKeys.ConeBottomSize.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.ConeSwapTopBottom.rawValue)
        UserDefaults.standard.set(Shapes.Blocks.rawValue, forKey: SettingKeys.LiveViewShape.rawValue)
        UserDefaults.standard.set(LiveViewImageSizes.Native.rawValue, forKey: SettingKeys.LiveViewImageSize.rawValue)
        UserDefaults.standard.set(MainModes.LiveView.rawValue, forKey: SettingKeys.CurrentMode.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.ShowHistogram.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.AutoOpenShapeSettings.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.SwitchModesWithDroppedImages.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.AutoOpenProcessedView.rawValue)
        UserDefaults.standard.set(SphereBehaviors.Size.rawValue, forKey: SettingKeys.SphereBehavior.rawValue)
        UserDefaults.standard.set(DonutHoleSizes.Medium.rawValue, forKey: SettingKeys.DonutHoleSize.rawValue)
        UserDefaults.standard.set(RingOrientations.Flat.rawValue, forKey: SettingKeys.RingOrientation.rawValue)
        UserDefaults.standard.set(1, forKey: SettingKeys.NextSequentialInteger.rawValue)
        UserDefaults.standard.set(9999, forKey: SettingKeys.LoopSequentialIntegerAfter.rawValue)
        UserDefaults.standard.set(1, forKey: SettingKeys.StartSequentialIntegerAt.rawValue)
        UserDefaults.standard.set(90.0, forKey: SettingKeys.LineZAngle.rawValue)
        UserDefaults.standard.set(LineThicknesses.Thin, forKey: SettingKeys.LineThickness.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.SidesTouch.rawValue)
        UserDefaults.standard.set(LongAxes.Z.rawValue, forKey: SettingKeys.CylinderAxis.rawValue)
        UserDefaults.standard.set(LongAxes.Z.rawValue, forKey: SettingKeys.LineAxis.rawValue)
        UserDefaults.standard.set(LongAxes.Z.rawValue, forKey: SettingKeys.CapsuleAxis.rawValue)
        
        #if DEBUG
        UserDefaults.standard.set(true, forKey: SettingKeys.AddUserDataToExif.rawValue)
        UserDefaults.standard.set("Stuart Rankin", forKey: SettingKeys.UserName.rawValue)
        UserDefaults.standard.set("CC by Attribution", forKey: SettingKeys.UserCopyright.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.SaveUserName.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKeys.SaveUserCopyright.rawValue)
        #else
        UserDefaults.standard.set(false, forKey: SettingKeys.AddUserDataToExif.rawValue)
        UserDefaults.standard.set("", forKey: SettingKeys.UserName.rawValue)
        UserDefaults.standard.set("", forKey: SettingKeys.UserCopyright.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.SaveUserName.rawValue)
        UserDefaults.standard.set(false, forKey: SettingKeys.SaveUserCopyright.rawValue)
        #endif
    }
    
    /// Add a subscriber to the notification list. Each subscriber is called just before a setting is committed and just after
    /// it is committed.
    /// - Parameter NewSubscriber: The delegate of the new subscriber.
    /// - Parameter Owner: The name of the owner.
    public static func AddSubscriber(_ NewSubscriber: SettingChangedProtocol, _ Owner: String)
    {
        Subscribers.append((Owner, NewSubscriber))
    }
    
    /// Remove a subscriber from the notification list.
    /// - Parameter Name: The name of the subscriber to remove. Must be identical to the name supplied to `AddSubscriber`.
    public static func RemoveSubscriber(_ Name: String)
    {
        Subscribers = Subscribers.filter{$0.0 != Name}
    }
    
    /// Call all subscribers in the notification list to let them know a setting will be changed.
    /// - Note: Callers have the opportunity to cancel the request. If the caller sets `CancelChange` in the protocol to
    ///         false, they want to cancel the settings change. If there are multiple subscribers and different responses,
    ///         the last response will take precedence.
    /// - Parameter WithKey: The key of the setting that will be changed.
    /// - Parameter AndValue: The new value (cast to Any).
    /// - Parameter CancelRequested: Will contain the caller's cancel change request on return.
    private static func NotifyWillChange(WithKey: SettingKeys, AndValue: Any, CancelRequested: inout Bool)
    {
        var RequestCancel = false
        Subscribers.forEach{$0.1?.WillChangeSetting(WithKey, NewValue: AndValue, CancelChange: &RequestCancel)}
        CancelRequested = RequestCancel
    }
    
    /// Send a notification to all subscribers that a settings change occurred.
    /// - Parameter WithKey: The key that changed.
    private static func NotifyDidChange(WithKey: SettingKeys)
    {
        Subscribers.forEach{$0.1?.DidChangeSetting(WithKey)}
    }
    
    /// Saves a boolean value to the settings.
    /// - Note: If `ForKey` is not a boolean setting, a fatal error will be generated.
    /// - Parameter NewValue: The boolean value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetBoolean(_ NewValue: Bool, ForKey: SettingKeys)
    {
        if BooleanFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a boolean setting.")
        }
    }
    
    /// Saves a boolean value to the settings.
    /// - Note: If `ForKey` is not a boolean setting, a fatal error will be generated.
    /// - Parameter NewValue: The boolean value to set.
    /// - Parameter ForKey: The key to set.
    /// - Parameter Completed: Completion handler.
    public static func SetBoolean(_ NewValue: Bool, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if BooleanFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a boolean setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of a boolean setting.
    /// - Note: If `ForKey` is not a boolean setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned.
    public static func GetBoolean(ForKey: SettingKeys) -> Bool
    {
        if BooleanFields.contains(ForKey)
        {
            return UserDefaults.standard.bool(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a boolean setting.")
        }
    }
    
    /// Saves a Double value to the settings.
    /// - Note: If `ForKey` is not a Double setting, a fatal error will be generated.
    /// - Parameter NewValue: The Double value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetDouble(_ NewValue: Double, ForKey: SettingKeys)
    {
        if DoubleFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a double setting.")
        }
    }
    
    /// Saves a Double value to the settings.
    /// - Note: If `ForKey` is not a Double setting, a fatal error will be generated.
    /// - Parameter NewValue: The Double value to set.
    /// - Parameter ForKey: The key to set.
    /// - Parameter Completed: Completion handler.
    public static func SetDouble(_ NewValue: Double, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if DoubleFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a double setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of a Double setting.
    /// - Note: If `ForKey` is not a Double setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned.
    public static func GetDouble(ForKey: SettingKeys) -> Double
    {
        if DoubleFields.contains(ForKey)
        {
            return UserDefaults.standard.double(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a double setting.")
        }
    }
    
    /// Saves an integer value to the settings.
    /// - Note: If `ForKey` is not an integer setting, a fatal error will be generated.
    /// - Parameter NewValue: The integer value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetInteger(_ NewValue: Int, ForKey: SettingKeys)
    {
        if IntegerFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to an integer setting.")
        }
    }
    
    /// Saves an integer value to the settings.
    /// - Note: If `ForKey` is not an integer setting, a fatal error will be generated.
    /// - Parameter NewValue: The integer value to set.
    /// - Parameter ForKey: The key to set.
    /// - Completed: Completion handler.
    public static func SetInteger(_ NewValue: Int, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if IntegerFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to an integer setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of an integer setting.
    /// - Note: If `ForKey` is not an integer setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned.
    public static func GetInteger(ForKey: SettingKeys) -> Int
    {
        if IntegerFields.contains(ForKey)
        {
            return UserDefaults.standard.integer(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to an integer setting.")
        }
    }
    
    /// Saves a string value to the settings.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter NewValue: The string value to set.
    /// - Parameter ForKey: The key to set.
    public static func SetString(_ NewValue: String, ForKey: SettingKeys)
    {
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Saves a string value to the settings.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter NewValue: The string value to set.
    /// - Parameter ForKey: The key to set.
    /// - Parameter Completed: Completion handler.
    public static func SetString(_ NewValue: String, ForKey: SettingKeys, Completed: ((SettingKeys) -> Void))
    {
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
        Completed(ForKey)
    }
    
    /// Returns the value of a string setting.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter ForKey: The setting whose value will be returned. Nil will be returned if the contents of
    ///                     `ForKey` are not set.
    /// - Returns: The string pointed to by `ForKey`. If no string has been stored, nil is returned.
    public static func GetString(ForKey: SettingKeys) -> String?
    {
        if StringFields.contains(ForKey)
        {
            return UserDefaults.standard.string(forKey: ForKey.rawValue)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Returns the value of a string setting. Guarenteed to always return a string.
    /// - Note: If `ForKey` is not a string setting, a fatal error will be generated.
    /// - Parameter ForKey: The settings whose value will be returned.
    /// - Parameter Default: The value to return if there is no stored value. This value will
    ///                      also be used to populate the setting.
    /// - Returns: The string value pointed to by `ForKey` on success, the contents of `Default`
    ///            if there is no value in the setting pointed to by `ForKey`.
    public static func GetString(ForKey: SettingKeys, _ Default: String) -> String
    {
        if StringFields.contains(ForKey)
        {
            let StoredString = UserDefaults.standard.string(forKey: ForKey.rawValue)
            if StoredString == nil
            {
                UserDefaults.standard.set(Default, forKey: ForKey.rawValue)
                return Default
            }
            return StoredString!
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Return an enum case value from user settings.
    /// - Note: A fatal error is generated if `ForKey` does not point to a string setting.
    /// - Note: See: [Pass an enum type name](https://stackoverflow.com/questions/38793536/possible-to-pass-an-enum-type-name-as-an-argument-in-swift)
    /// - Parameter ForKey: The setting key that points to where the enum case is stored (as a string).
    /// - Parameter EnumType: The type of the enum to return.
    /// - Parameter Default: The default value returned for when `ForKey` has yet to be set.
    /// - Returns: Enum value (of type `EnumType`) for the specified setting key.
    public static func GetEnum<T: RawRepresentable>(ForKey: SettingKeys, EnumType: T.Type, Default: T) -> T where T.RawValue == String
    {
        if StringFields.contains(ForKey)
        {
            if let Raw = GetString(ForKey: ForKey)
            {
                guard let Value = EnumType.init(rawValue: Raw) else
                {
                    return Default
                }
                return Value
            }
            return Default
        }
        else
        {
            fatalError("\(ForKey) does not point to a string setting.")
        }
    }
    
    /// Saves an enum value to user settings. This function will convert the enum value into a string (so the
    /// enum *must* be `String`-based) and save that.
    /// - Note: Fatal errors are generated if:
    ///   - `NewValue` is not from `EnumType`.
    ///   - `ForKey` does not point to a String setting.
    /// - Parameter NewValue: Enum case to save.
    /// - Parameter EnumType: The type of enum the `NewValue` is based on. If `NewValue` is not from `EnumType`,
    ///                       a fatal error will occur.
    /// - Parameter ForKey: The settings key to use to indicate where to save the value.
    /// - Parameter Completed: Closure called at the end of the saving process.
    public static func SetEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingKeys,
                                                    Completed: ((SettingKeys) -> Void)) where T.RawValue == String
    {
        //If there is no error, this merely sets Raw equal to NewValue. We do this to make sure
        //the caller didn't use an enum case from the wrong enum with EnumType.
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum A to Enum B.")
        }
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue.rawValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
        Completed(ForKey)
    }
    
    /// Saves an enum value to user settings. This function will convert the enum value into a string (so the
    /// enum *must* be `String`-based) and save that.
    /// - Note: Fatal errors are generated if:
    ///   - `NewValue` is not from `EnumType`.
    ///   - `ForKey` does not point to a String setting.
    /// - Parameter NewValue: Enum case to save.
    /// - Parameter EnumType: The type of enum the `NewValue` is based on. If `NewValue` is not from `EnumType`,
    ///                       a fatal error will occur.
    /// - Parameter ForKey: The settings key to use to indicate where to save the value.
    public static func SetEnum<T: RawRepresentable>(_ NewValue: T, EnumType: T.Type, ForKey: SettingKeys) where T.RawValue == String
    {
        //If there is no error, this merely sets Raw equal to NewValue. We do this to make sure
        //the caller didn't use an enum case from the wrong enum with EnumType.
        guard let _ = EnumType.init(rawValue: NewValue.rawValue) else
        {
            fatalError("Invalid enum conversion. Most likely tried to convert an enum case from Enum type 'A' to Enum type 'B'.")
        }
        if StringFields.contains(ForKey)
        {
            var Cancel = false
            NotifyWillChange(WithKey: ForKey, AndValue: NewValue.rawValue as Any, CancelRequested: &Cancel)
            if Cancel
            {
                return
            }
            UserDefaults.standard.set(NewValue.rawValue, forKey: ForKey.rawValue)
            NotifyDidChange(WithKey: ForKey)
        }
        else
        {
            fatalError("The key \(ForKey.rawValue) does not point to a string setting.")
        }
    }
    
    /// Returns the type of the backing data for the passed setting.
    /// - Parameter ForSetting: The setting whose backing type will be returned.
    /// - Returns: Backing type for the setting. `.Unknown` is returned if the type system does not yet comprehend the passed setting.
    public static func GetSettingType(_ ForSetting: SettingKeys) -> SettingTypes
    {
        if BooleanFields.contains(ForSetting)
        {
            return .Boolean
        }
        if IntegerFields.contains(ForSetting)
        {
            return .Integer
        }
        if DoubleFields.contains(ForSetting)
        {
            return .Double
        }
        if StringFields.contains(ForSetting)
        {
            return .String
        }
        return .Unknown
    }
    
    /// Contains a list of all boolean-type fields.
    public static let BooleanFields: [SettingKeys] =
        [
            .InvertHeight,
            .InvertConditionalColor,
            .ApexesIncrease,
            .ConeSwapTopBottom,
            .ShowHistogram,
            .AutoOpenShapeSettings,
            .SwitchModesWithDroppedImages,
            .AutoOpenProcessedView,
            .AddUserDataToExif,
            .SaveUserName,
            .SaveUserCopyright,
            .FullyExtrudeLetters,
            .SidesTouch
    ]
    
    /// Contains a list of all integer-type fields.
    public static let IntegerFields: [SettingKeys] =
        [
            .MaximumLength,
            .BackgroundColor,
            .LightColor,
            .StarApexCount,
            .LineCount,
            .ShapeSize,
            .NextSequentialInteger,
            .LoopSequentialIntegerAfter,
            .StartSequentialIntegerAt,
            .PolygonSideCount,
            .Polygon2DSideCount,
            .FontSize,
    ]
    
    /// Contains a list of all string-type fields.
    public static let StringFields: [SettingKeys] =
        [
            .Shape,
            .VerticalExaggeration,
            .HeightDetermination,
            .ConditionalColor,
            .ConditionalColorAction,
            .ConditionalColorThreshold,
            .BackgroundType,
            .BackgroundGradientColors,
            .LightType,
            .LightIntensity,
            .LightModel,
            .BlockChamfer,
            .OvalLength,
            .OvalOrientation,
            .DiamondLength,
            .DiamondOrientation,
            .StackedShapeList,
            .HueShapes,
            .SaturationShapes,
            .BrightnessShapes,
            .RedShapes,
            .GreenShapes,
            .BlueShapes,
            .CyanShapes,
            .MagentaShapes,
            .YellowShapes,
            .BlackShapes,
            .CapShape,
            .CapLocation,
            .RadialLineThickness,
            .ConeTopSize,
            .ConeBottomSize,
            .LiveViewShape,
            .LiveViewImageSize,
            .CurrentMode,
            .SphereBehavior,
            .CharacterSet,
            .DonutHoleSize,
            .RingOrientation,
            .UserCopyright,
            .UserName,
            .Antialiasing,
            .LineThickness,
            .LetterSmoothness,
            .VaryingComponent,
            .CappedLineLineColor,
            .BlockWithShape,
            .SphereWithShape,
            .CapsuleAxis,
            .LineAxis,
            .CylinderAxis,
    ]
    
    /// Contains a list of all double-type fields.
    public static let DoubleFields: [SettingKeys] =
        [
            .Side,
            .LineZAngle,
    ]
}

/// Keys for user settings.
/// - Note: This enum implements the `Comparable` and `Hashable` protocols to allow for efficient manipulation
///         of lists of setting keys.
enum SettingKeys: String, CaseIterable, Comparable, Hashable
{
    /// For enabling the `Comparable` protocol.
    /// - Parameter lhs: Left hand side.
    /// - Parameter rhs: Right hand side.
    /// - Returns: True if `lhs` is less than `rhs`, false otherwise.
    static func < (lhs: SettingKeys, rhs: SettingKeys) -> Bool
    {
        return lhs.rawValue < rhs.rawValue
    }
    
    //Initialization settings.
    /// String: Holds the initialized string. Used to detect if settings have been initialized.
    case Initialized = "Initialized"
    
    //Shape settings.
    /// String/Enum: Holds the current shape.
    case Shape = "Shape"
    /// Integer: Size of each shape.
    case ShapeSize = "ShapeSize"
    /// String/Enum: Holds the conditional color determination.
    case ConditionalColor = "ConditionalColor"
    /// String/Enum: Holds the action to take if conditional colors are active.
    case ConditionalColorAction = "ConditionalColorAction"
    /// String/Enum: Holds the threshold for running conditional colors.
    case ConditionalColorThreshold = "ConditionalColorThreshold"
    /// Boolean: Invert the conditional color threshold comparison.
    case InvertConditionalColor = "InvertConditionalColor"
    
    //Individual shape settings.
    //Block optional settings.
    /// String/Enum: Holds the chamfer value for blocks.
    case BlockChamfer = "BlockChamfer"
    
    //Polygon optional settings.
    /// Integer: Holds the number of sides for a polygon.
    case PolygonSideCount = "PolygonSideCount"
    /// Integer: Holds the number of sides for a 2D polygon.
    case Polygon2DSideCount = "Polygon2DSideCount"
    
    //Oval optional settings.
    /// String/Enum: Holds the orientation of oval shapes.
    case OvalOrientation = "OvalOrientation"
    /// String/Enum: Holds the length of oval shapes.
    case OvalLength = "OvalLength"
    
    //Diamond optional settings.
    /// String/Enum: Holds the orientation of diamond shapes.
    case DiamondOrientation = "DiamondOrientation"
    /// String/Enum: Holds the length of diamond shapes.
    case DiamondLength = "DiamondLength"
    
    //Stacked shapes optional settings.
    /// String: List of stacked shapes.
    case StackedShapeList = "StackedShapeList"
    
    //Ring optional settings.
    /// String/Enum: Holds the size of the donut hole.
    case DonutHoleSize = "DonutHoleSize"
    /// String/Enum: Holds the orientation of the ring.
    case RingOrientation = "RingOrientation"
    
    //Blocks+ shape settings.
    /// String/Enum: Extra shape with a block.
    case BlockWithShape = "BlockWithShape"
    
    //Spheres+ shape settings.
    /// String/Enum: Extra shape with a sphere.
    case SphereWithShape = "SphereWithShape"
    
    //Channel-varying shapes optional settings.
    /// String/Enum: Which component is used to determine shape.
    case VaryingComponent = "VaryingComponent"
    /// String: List of shapes for hue varying shapes.
    case HueShapes = "HueShapes"
    /// String: List of shapes for saturation varying shapes.
    case SaturationShapes = "SaturationShapes"
    /// String: List of shapes for brightness varying shapes.
    case BrightnessShapes = "BrightnessShapes"
    /// String: List of shapes for the red component.
    case RedShapes = "RedShapes"
    /// String: List of shapes for the green component.
    case GreenShapes = "GreenShapes"
    /// String: List of shapes for the blue component.
    case BlueShapes = "BlueShapes"
    /// String: List of shapes for the cyan component.
    case CyanShapes = "CyanShapes"
    /// String: List of shapes for the magenta component.
    case MagentaShapes = "MagentaShapes"
    /// String: List of shapes for the yellow component.
    case YellowShapes = "YellowShapes"
    /// String: List of shapes for the black component.
    case BlackShapes = "BlackShapes"
    
    //Three triangle settings.
    /// Boolean. If true, the sides of the three triangles touch. If false, an apex touches.
    case SidesTouch = "SidesTouch"
    
    //Capped-line shape optional settings.
    /// String/Enum: The shape of the cap for the capped-line.
    case CapShape = "CapShape"
    /// String/Enum: The location of the cap for the capped-line.
    case CapLocation = "CapLocation"
    /// String/Enum: Determines the line color for capped lines.
    case CappedLineLineColor = "CappedLineLineColor"
    
    //Sphere optional settings.
    /// String/Enum: How the sphere behaves in terms of prominence.
    case SphereBehavior = "SphereBehavior"
    
    //Star optional settings.
    /// Int: Number of apexes.
    case StarApexCount = "StarApexCount"
    /// Boolean: The number of apexes increases with the intensity of the exaggeration.
    case ApexesIncrease = "ApexesIncrease"
    
    //Radial lines settings.
    /// String/Enum: Thickness of radial lines.
    case RadialLineThickness = "RadialLineThickness"
    /// Int: Number of radial lines.
    case LineCount = "LineCount"
    
    //Lines settings.
    /// String/Enum: Thickness of non-radial lines.
    case LineThickness = "LineThickness"
    /// Double: Line angle away from perpendicular to the viewing plane.
    case LineZAngle = "LineZAngle"
    
    //Character set settings.
    /// String/Enum: The character set from which to draw random characters.
    case CharacterSet = "CharacterSet"
    /// String/Enum: Smoothness of letters.
    case LetterSmoothness = "LetterSmoothness"
    /// Boolean: Determines if letters are fully extruded.
    case FullyExtrudeLetters = "FullyExtrudeLetters"
    /// Integer: Font size for extruded characters.
    case FontSize = "FontSize"
    
    //Cone settings.
    /// String/Enum: Determines the size of the top of the cone.
    case ConeTopSize = "ConeTopSize"
    /// String/Enum: Determines the size of the bottom of the cone.
    case ConeBottomSize = "ConeBottomSize"
    /// Bool: Cone sizes are swapped.
    case ConeSwapTopBottom = "SwapConeTopAndBottom"
    
    //Long shape settings.
    /// String/Enum: Determines the axis capsules line on.
    case CapsuleAxis = "CapsuleAxis"
    /// String/Enum: Determines the axis lines line on.
    case LineAxis = "LineAxis"
    /// String/Enum: Determines the axis cylinders line on.
    case CylinderAxis = "CylinderAxis"
    
    //Processing settings.
    /// String/Enum: Holds the vertical exaggeration.
    case VerticalExaggeration = "VerticalExaggeration"
    /// Boolean: Holds the invert height flag.
    case InvertHeight = "InvertHeight"
    /// Double: Holds the side value of the square that defines a logical shape.
    case Side = "Side"
    /// String/Enum: Holds how hight is determined.
    case HeightDetermination = "HeightDetermination"
    /// Int: Holds the resize value for the maximum dimension.
    case MaximumLength = "MaximumLength"
    
    //General scene settings.
    /// String/Enum: Holds the type of the background.
    case BackgroundType = "BackgroundType"
    /// Int: Holds the background color.
    case BackgroundColor = "BackgroundColor"
    /// String: Holds a list (Ints converted to strings, comma-spearated) of colors for the
    ///         background gradient.
    case BackgroundGradientColors = "BackgroundGradientColors"
    /// Int: Holds the color of the light.
    case LightColor = "LightColor"
    /// String/Enum: Type of light.
    case LightType = "LightType"
    /// String/Enum: Light intensity.
    case LightIntensity = "LightIntensity"
    /// String/Enum: Light material model.
    case LightModel = "LightModel"
    /// String/Enum: Holds the antialiasing mode.
    case Antialiasing = "Antialiasing"
    
    //Live view settings.
    /// String/Enum. The shape to use for live views.
    case LiveViewShape = "LiveViewShape"
    /// String/Enum. The resize value for live view image streams.
    case LiveViewImageSize = "LiveViewImageSize"
    
    //Main view settings.
    /// String/Enum. The current mode for the main view.
    case CurrentMode = "CurrentMode"
    /// Bool: Shows or hides the histogram for the live view.
    case ShowHistogram = "ShowHistogram"
    /// Bool: Automatically open shape settings.
    case AutoOpenShapeSettings = "AutoOpenShapeSettings"
    /// Bool: Automatically switch modes if the user drops an image on the program.
    case SwitchModesWithDroppedImages = "SwitchModesWithDroppedImages"
    /// Bool: Automatically open the processed view window when switching to live view.
    case AutoOpenProcessedView = "AutoOpenProcessedView"
    
    //Sequential integers.
    /// Integer: The next available sequential integer.
    case NextSequentialInteger = "NextSequentialInteger"
    /// Integer: When to wrap around the set of sequential integers.
    case LoopSequentialIntegerAfter = "LoopSequentialIntegerAfter"
    /// Integer: Where to start sequential integers after wrapping around.
    case StartSequentialIntegerAt = "StartSequentialIntegerAt"
    
    //EXIF and privacy settings.
    /// Boolean: If true, user-related data is saved to images.
    case AddUserDataToExif = "AddUserDataToExif"
    /// String: User copyright information.
    case UserCopyright = "UserCopyright"
    /// String: User name.
    case UserName = "UserName"
    /// String: Determines if the user name is saved.
    case SaveUserName = "SaveUserName"
    /// String: Determines if the user copyright is saved.
    case SaveUserCopyright = "SaveUserCopyright"
}

/// Types of setting data recognized by the SettingsManager.
enum SettingTypes: String, CaseIterable
{
    /// Returned when the caller finds a setting that is not yet integrated into the type system.
    case Unknown = "Unknown Type"
    /// `Bool` types.
    case Boolean = "Boolean"
    /// `String` types.
    case String = "String"
    /// `Int` types.
    case Integer = "Integer"
    /// `Double` types.
    case Double = "Double"
}
