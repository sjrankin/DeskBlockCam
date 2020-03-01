//
//  ViewController.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/2/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Cocoa
import AppKit
import SceneKit
import Quartz
import AVKit
import AVFoundation
import CoreGraphics

/// Main window controller.
class ViewController: NSViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,
    NSFilePromiseProviderDelegate,
    SettingChangedProtocol,
    RedrawProtocol,
    DragDropDelegate
{
    /// Load and set up the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Settings.AddSubscriber(self, "ViewController")
        
        Colors.Initialize()
        StillImageView.wantsLayer = true
        StillImageView.isHidden = false
        OriginalImageView.wantsLayer = true
        OriginalImageView.layer?.borderWidth = 2.0
        OriginalImageView.layer?.backgroundColor = NSColor.black.cgColor
        OriginalImageView.layer?.borderColor = NSColor.systemYellow.cgColor
        ProcessedImage.wantsLayer = true
        ProcessedImage.layer?.backgroundColor = NSColor.black.cgColor
        ProcessedImage.StatusDelegate = self
        ImageSourceLabel.stringValue = ""
        
        BottomBar.wantsLayer = true
        BottomBar.layer?.backgroundColor = NSColor.systemYellow.cgColor
        
        GetCameraAccess()
        
        #if false
        let Taker = IKPictureTaker()
        Taker.setValue(NSNumber(value: true), forKey: IKPictureTakerAllowsVideoCaptureKey)
        Taker.beginSheet(for: self.view.window, withDelegate: self,
                         didEnd: #selector(pictureTakerDidEnd), contextInfo: nil)
        #endif
        
        FileIO.Initialize()
        FileIO.ClearFramesDirectory()
        
        Started = true
        if Settings.GetBoolean(ForKey: .AutoOpenShapeSettings)
        {
            OpenOptionsWindow(self)
        }
        
        ResetStatus()
        
        LiveHistogram.isHidden = !Settings.GetBoolean(ForKey: .ShowHistogram)
        ProcessedImage.InLiveViewMode = Settings.GetEnum(ForKey: .CurrentMode, EnumType: ProgramModes.self,
                                                         Default: ProgramModes.LiveView) == .LiveView
        ControllerView.DragDelegate = self
        view.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map {NSPasteboard.PasteboardType($0)})
        view.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    func SetProgramMode(ChangeSelector: Bool = false)
    {
        let Mode = Settings.GetEnum(ForKey: .CurrentMode, EnumType: MainModes.self, Default: MainModes.LiveView)
        switch Mode
        {
            case .ImageView:
                if ChangeSelector
                {
                    ModeSegment.selectedSegment = 1
                }
                StopCamera()
                ProcessedImage.InLiveViewMode = false
                ProcessedImage.ClearScene()
            
            case .LiveView:
                if ChangeSelector
                {
                    ModeSegment.selectedSegment = 0
                }
                StartCamera()
                ProcessedImage.InLiveViewMode = true
                OriginalImageView.image = nil
                ImageSourceLabel.stringValue = "Video stream"
            
            case .VideoView:
                break
        }
    }
    
    // MARK: - Drag and drop
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String
    {
        fatalError(fileType)
    }
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void)
    {
        fatalError()
    }
    
    private lazy var DestinationURL: URL =
    {
        let DestinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
        try? FileManager.default.createDirectory(at: DestinationURL, withIntermediateDirectories: true, attributes: nil)
        return DestinationURL
    }()
    
    private lazy var WorkQueue: OperationQueue =
    {
        let ProviderQueue = OperationQueue()
        ProviderQueue.qualityOfService = .userInitiated
        return ProviderQueue
    }()
    
    func draggingEntered(ForView: ViewControllerView, sender: NSDraggingInfo) -> NSDragOperation
    {
        return sender.draggingSourceOperationMask.intersection([.copy])
    }
    
    func performDragOperation(ForView: ViewControllerView, sender: NSDraggingInfo) -> Bool
    {
        let SupportedClasses = [NSFilePromiseReceiver.self, NSURL.self]
        let SearchOptions: [NSPasteboard.ReadingOptionKey: Any] =
            [
                .urlReadingFileURLsOnly: true,
                .urlReadingContentsConformToTypes: [kUTTypeImage]
        ]
        sender.enumerateDraggingItems(options: [], for: nil, classes: SupportedClasses, searchOptions: SearchOptions)
        {
            (draggingItem, _, _) in
            switch draggingItem.item
            {
                case let filePromiseReceiver as NSFilePromiseReceiver:
                    self.prepareForUpdate()
                    filePromiseReceiver.receivePromisedFiles(atDestination: self.DestinationURL, options: [:],
                                                             operationQueue: self.WorkQueue)
                    {
                        (fileURL, error) in
                        if let error = error
                        {
                            self.HandleDragDropError(error)
                        }
                        else
                        {
                            self.HandleDroppedFile(at: fileURL)
                        }
                }
                
                case let fileURL as URL:
                    self.HandleDroppedFile(at: fileURL)
                
                default:
                    fatalError()
            }
        }
        
        return true
    }
    
    func HandleDragDropError(_ error: Error)
    {
        ShowError(Message: "Drag drop error: \(error)")
    }
    
    func HandleDroppedFile(at url: URL)
    {
        let Image = NSImage(contentsOf: url)
        if Image == nil
        {
            ShowError(Message: "The file you dragged to BlockCam could not be read as an image file. Please verify your image and try again. If the error persists, try something else.",
                      WindowTitle: "Dropped File Error")
            return
        }
        ImageSourceLabel.stringValue = url.lastPathComponent
        if Settings.GetBoolean(ForKey: .SwitchModesWithDroppedImages)
        {
            OriginalImageView.image = Image
            Settings.SetEnum(MainModes.ImageView, EnumType: MainModes.self, ForKey: .CurrentMode)
            SetProgramMode(ChangeSelector: true)
            ProcessLoadedImage(Image!)
        }
    }
    
    func prepareForUpdate()
    {
        
    }
    
    func pasteboardWriter(ForView: ViewControllerView) -> NSPasteboardWriting
    {
        let provider = NSFilePromiseProvider(fileType: kUTTypeJPEG as String, delegate: self)
        return provider
    }
    
    // MARK: - Still image processing.
    
    func ProcessLoadedImage(_ Image: NSImage)
    {
        ProcessedImage.ProcessImage(Image)
    }
    
    // MARK: - Other stuff
    
    func WillChangeSetting(_ ChangedSetting: SettingKeys, NewValue: Any, CancelChange: inout Bool)
    {
    }
    
    func DidChangeSetting(_ ChangedSetting: SettingKeys)
    {
        switch ChangedSetting
        {
            case .ShowHistogram:
                LiveHistogram.isHidden = !Settings.GetBoolean(ForKey: .ShowHistogram)
            
            default:
                break
        }
    }
    
    var Started = false
    
    @IBAction func OpenOptionsWindow(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Settings", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ShapeOptionWindowUI2") as? ShapeOptionsWindowCode
        {
            WindowController.showWindow(nil)
            SettingsWindow = WindowController
            SettingsControl = WindowController.contentViewController as? ShapeOptionsCode
            SettingsControl?.ApplyDelegate = self
        }
    }
    
    var SettingsControl: ShapeOptionsCode? = nil
    var SettingsWindow: ShapeOptionsWindowCode? = nil
    
    // MARK: - Camera control.
    
    /// Get camera access from the user.
    func GetCameraAccess()
    {
        switch AVCaptureDevice.authorizationStatus(for: .video)
        {
            case .authorized:
                self.SetupCaptureSession()
            
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video)
                {
                    granted in
                    if granted
                    {
                        self.SetupCaptureSession()
                    }
            }
            
            case .denied:
                return
            
            case .restricted:
                return
            
            @unknown default:
                fatalError("huh?")
        }
    }
    
    var VideoPreviewLayer: AVCaptureVideoPreviewLayer!
    var StillImageOutput: AVCapturePhotoOutput!
    var CaptureSession: AVCaptureSession!
    var CaptureDevice: AVCaptureDevice!
    var VideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                       mediaType: .video, position: .unspecified)
    
    /// Stops the camera session.
    func StopCamera()
    {
        CaptureSession.stopRunning()
    }
    
    /// Starts the camera session. If the camera has not yet been initialized, it will be initialized
    /// here.
    func StartCamera()
    {
        if !CameraWasInitialized
        {
            GetCameraAccess()
        }
        CaptureSession.startRunning()
    }
    
    var CameraWasInitialized = false
    
    /// Set up the capture session so we get the camera's stream.
    func SetupCaptureSession()
    {
        CaptureSession = AVCaptureSession()
        CaptureSession.sessionPreset = .photo
        let PreferredPosition: AVCaptureDevice.Position!
        PreferredPosition = .unspecified
        let PreferredDevice = AVCaptureDevice.DeviceType.builtInWideAngleCamera
        let Devices = VideoDeviceDiscoverySession.devices
        CaptureDevice = nil
        if let Device = Devices.first(where: {$0.position == PreferredPosition && $0.deviceType == PreferredDevice})
        {
            CaptureDevice = Device
        }
        else
            if let Device = Devices.first(where: {$0.position == PreferredPosition})
            {
                CaptureDevice = Device
        }
        guard let InputCamera = CaptureDevice else
        {
            fatalError("No input camera")
        }
        do
        {
            let Input = try AVCaptureDeviceInput(device: InputCamera)
            StillImageOutput = AVCapturePhotoOutput()
            if CaptureSession.canAddInput(Input) && CaptureSession.canAddOutput(StillImageOutput)
            {
                CaptureSession.addInput(Input)
                CaptureSession.addOutput(StillImageOutput)
                SetupLiveView()
                SetupLiveViewProcessing()
            }
        }
        catch
        {
            fatalError("Error getting input camera.")
        }
        CameraWasInitialized = true
    }
    
    /// Hook up the camera stream to the output view.
    func SetupLiveView()
    {
        OperationQueue.main.addOperation
            {
                self.OriginalImageView.layerContentsPlacement = .scaleProportionallyToFill
                self.OriginalImageView.layerContentsRedrawPolicy = .duringViewResize
                //                self.LiveView.layerContentsPlacement = .scaleProportionallyToFill
                //                self.LiveView.layerContentsRedrawPolicy = .duringViewResize
                self.VideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.CaptureSession)
                self.VideoPreviewLayer.name = "VideoLayer"
                self.VideoPreviewLayer.videoGravity = .resizeAspect
                self.VideoPreviewLayer.connection?.videoOrientation = .portrait
                self.OriginalImageView.layer?.addSublayer(self.VideoPreviewLayer)
                //                self.LiveView.layer?.addSublayer(self.VideoPreviewLayer)
        }
        DispatchQueue.global(qos: .userInitiated).async
            {
                [weak self] in
                self!.CaptureSession.startRunning()
                DispatchQueue.main.async
                    {
                        self?.ImageSourceLabel.stringValue = "Video stream"
                        self?.OriginalImageView.image = nil
                        self!.VideoPreviewLayer.frame = self!.OriginalImageView.bounds
                        //self!.VideoPreviewLayer.frame = self!.LiveView.bounds
                }
        }
    }
    
    /// Enable getting each frame of the live view session.
    func SetupLiveViewProcessing()
    {
        let VideoOut = AVCaptureVideoDataOutput()
        VideoOut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        VideoOut.alwaysDiscardsLateVideoFrames = true
        VideoOut.setSampleBufferDelegate(self, queue: VOQueue)
        guard CaptureSession.canAddOutput(VideoOut) else
        {
            print("Error adding video output to capture session.")
            return
        }
        CaptureSession.addOutput(VideoOut)
        VideoConnection = VideoOut.connection(with: .video)
    }
    
    var VOQueue = DispatchQueue(label: "VideoOutputQueue")
    var VideoConnection: AVCaptureConnection? = nil
    
    /// Handle window resize events (passed to us from the window controller) to resize the live view
    /// to fit in parent's view.
    /// - Parameter To: New window size.
    func WindowResized(To: NSSize)
    {
        if !Started
        {
            return
        }
        if VideoPreviewLayer == nil
        {
            return
        }
        if OriginalImageView == nil
        {
            return
        }
        DispatchQueue.main.async
            {
                self.VideoPreviewLayer.frame = self.OriginalImageView.bounds
        }
    }
    
    @objc func pictureTakerDidEnd(Sheet: IKPictureTaker,
                                  returnCode: NSInteger,
                                  contextInfo: UnsafeMutableRawPointer?)
    {
        //OriginalImage.image = Sheet.outputImage()
    }
    
    /// Capture a still image from the camera view.
    /// - Note: For the duration of the save dialog existence, input processing will be paused.
    /// - Parameter sender: Not used.
    @IBAction func HandleCameraButton(_ sender: Any)
    {
        let Settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        StillImageOutput.capturePhoto(with: Settings, delegate: self)
        let Image = ProcessedImage.Snapshot()
        DoSaveImage(Image)
    }
    
    @IBAction func HandleAlignImageButton(_ sender: Any)
    {
        var Mode = Settings.GetEnum(ForKey: .CurrentMode, EnumType: MainModes.self, Default: .LiveView)
        if Mode == .VideoView
        {
            return
        }
        #if true
        switch ModeSegment.selectedSegment
        {
            case 0:
                Mode = .LiveView
            
            case 1:
                Mode = .ImageView
            
            default:
                return
        }
        /*
         if let POV = ProcessedImage.pointOfView
         {
         print("POV position: \(POV.position)")
         print("POV rotation: \(POV.rotation)")
         print("POV orientation: \(POV.orientation)\n")
         }
         */
        ProcessedImage.ResetCamera()
        let NewHeight = ProcessedImage.MinimizeBezel(IsLiveView: Mode == .LiveView)
        ProcessedImage.CameraNode?.position = SCNVector3(ProcessedImage.CameraNode!.position.x,
                                                         ProcessedImage.CameraNode!.position.y,
                                                         CGFloat(NewHeight))
        #else
        let NewHeight = ProcessedImage.MinimizeBezel(IsLiveView: Mode == .LiveView)
        print("Camera orientation: \(ProcessedImage.CameraNode!.orientation)")
        print("Camera euler angles: \(ProcessedImage.CameraNode!.eulerAngles)")
        ProcessedImage.CameraNode?.position = SCNVector3(ProcessedImage.CameraNode!.position.x,
                                                         ProcessedImage.CameraNode!.position.y,
                                                         CGFloat(NewHeight))
        #endif
    }
    
    /// Holds the last frame time. This is used with a throttle value to ensure we don't overwhelm
    /// the API with too much data.
    var LastFrameTime = CACurrentMediaTime()
    
    /// Capture the output of a frame of data from the live view. The data is sent to the
    /// processed view window for conversion to 3D and display.
    /// - Note: If either the image processor or main program are not in live view mode, control
    ///         returns immediately.
    /// - Parameter output: Not used.
    /// - Parameter didOutput: The buffer from the live view.
    /// - Parameter from: The conection that sent the data.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        if Settings.GetEnum(ForKey: .CurrentMode, EnumType: ProgramModes.self, Default: ProgramModes.LiveView) != .LiveView
        {
            return
        }
        if !ProcessedImage.InLiveViewMode
        {
            return
        }
        //Set up the throttle.
        let Throttle = 1.0
        AddStat(ForItem: .ThrottleValue, NewValue: "\(Throttle) s")
        FrameCount = FrameCount + 1
        let Now = CACurrentMediaTime()
        if Now - LastFrameTime > Throttle
        {
            LastFrameTime = Now
        }
        else
        {
            return
        }
        
        if CameraIsPaused
        {
            return
        }
        
        //If we don't run the following code in an autoreleasepool, we get a horrible
        //memory leak.
        autoreleasepool
            {
                if let Buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                {
                    let CIImg: CIImage = CIImage(cvPixelBuffer: Buffer)
                    if Settings.GetBoolean(ForKey: .ShowHistogram)
                    {
                        LiveHistogram.DisplayHistogram(For: CIImg)
                    }
                    
                    let Start = CACurrentMediaTime()
                    AddStat(ForItem: .CurrentFrame, NewValue: "\(FrameCount)")
                    ProcessedImage.ProcessLiveView(CIImg)
                    let TotalEnd = CACurrentMediaTime() - Start
                    Durations.append(TotalEnd)
                    if let RollingMean = RollingDurationMean()
                    {
                        AddStat(ForItem: .RollingMeanFrameDuration,
                                NewValue: Utilities.RoundedString(RollingMean))
                        let Delta = RollingMean - TotalEnd
                        AddStat(ForItem: .FrameDurationDelta, NewValue: Utilities.RoundedString(Delta))
                    }
                    AddStat(ForItem: .LastFrameDuration,
                            NewValue: Utilities.RoundedString(TotalEnd))
                    
                    RenderedFrames = RenderedFrames + 1
                    RenderedDuration = RenderedDuration + TotalEnd
                    AddStat(ForItem: .RenderDuration, NewValue: "\(Int(RenderedDuration)) s")
                    AddStat(ForItem: .RenderedFrames, NewValue: "\(RenderedFrames)")
                    let cFPS = RenderedDuration / Double(RenderedFrames)
                    AddStat(ForItem: .CalculatedFramesPerSecond, NewValue: Utilities.RoundedString(cFPS))
                }
        }
    }
    
    var CameraIsPaused = false
    
    /// Get the rolling mean for the processed view creation time per frame.
    /// - Returns: Rolling mean (as determined by `RollingWindow`) for the most recent set of
    ///            frame creation duration times. If the number of frames created is less than
    ///            the value of `RollingWindow`, nil is returned.
    func RollingDurationMean() -> Double?
    {
        if Durations.count < RollingWindow
        {
            return nil
        }
        var Accumulator: Double = 0.0
        for Index in stride(from: Durations.count - 1, to: Durations.count - 1 - RollingWindow, by: -1)
        {
            Accumulator = Accumulator + Durations[Index]
        }
        return Accumulator / Double(RollingWindow)
    }
    
    var Durations = [Double]()
    let RollingWindow = 30
    var DroppedFrames: Int = 0
    var RenderedDuration: Double = 0.0
    var RenderedFrames: Int = 0
    var FrameCount: Int = 0
    
    /// A photo of the live stream is available.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        if let error = error
        {
            print("Image capture error \(error)")
            return
        }
        guard let ImageData = photo.fileDataRepresentation() else
        {
            print("Error getting file representation for image.")
            return
        }
        let SavedImage = NSImage(data: ImageData)
    }
    
    override var representedObject: Any?
        {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    /// Handle the app closing event from the parent window. Make sure child windows are closed.
    /// Clear the frames directory.
    func WillClose()
    {
        StopCamera()
        if let Settings = SettingsWindow
        {
            Settings.CloseWindow()
        }
        if let MainS = MainSettings
        {
            MainS.CloseWindow()
        }
        if let About = AbtWindow
        {
            About.CloseWindow()
        }
        if let DebugW = DebugWindow
        {
            DebugW.CloseWindow()
        }
        if let SListWin = ShapeListWindow
        {
            SListWin.CloseWindow()
        }
        FileIO.ClearFramesDirectory()
    }
    
    var AbtWindow: AboutWindow? = nil
    
    var ShapeIndex: Int = 0
    
    @IBAction func HandleModeChanged(_ sender: Any)
    {
        switch ModeSegment.selectedSegment
        {
            case 0:
                Settings.SetEnum(MainModes.LiveView, EnumType: MainModes.self, ForKey: .CurrentMode)
            
            case 1:
                Settings.SetEnum(MainModes.ImageView, EnumType: MainModes.self, ForKey: .CurrentMode)
            
            default:
                return
        }
        SetProgramMode(ChangeSelector: false)
    }
    
    @IBAction func SelectLiveView(_ sender: Any)
    {
        Settings.SetEnum(MainModes.LiveView, EnumType: MainModes.self, ForKey: .CurrentMode)
        SetProgramMode(ChangeSelector: true)
    }
    
    @IBAction func SelectImageView(_ sender: Any)
    {
        Settings.SetEnum(MainModes.ImageView, EnumType: MainModes.self, ForKey: .CurrentMode)
        SetProgramMode(ChangeSelector: true)
    }
    
    @IBAction func SelectVideoView(_ sender: Any)
    {
        Settings.SetEnum(MainModes.VideoView, EnumType: MainModes.self, ForKey: .CurrentMode)
        SetProgramMode(ChangeSelector: true)
    }
    
    @IBAction func ShowAbout(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "AboutWindowUI") as? AboutWindow
        {
            WindowController.showWindow(nil)
            AbtWindow = WindowController
        }
    }
    
    @IBAction func ShowProgramSettings(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ProgramSettingsWindowUI") as? ProgramSettingsWindowController
        {
            WindowController.showWindow(nil)
            MainSettings = WindowController
        }
    }
    
    @IBAction func OpenFileFromMenu(_ sender: Any)
    {
        CameraIsPaused = true
        if let ImageURL = GetImageFileToOpen()
        {
            print("Load image at \(ImageURL.path)")
            StopCamera()
        }
        else
        {
            CameraIsPaused = false
        }
    }
    
    func DoSaveImage(_ Image: NSImage)
    {
        CameraIsPaused = true
        if let SaveURL = GetSaveImageLocation()
        {
            let Current = CurrentSettings.KVPs
            let OK = FileIO.SaveImageWithMetaData(Image, KeyValueString: Current, SaveTo: SaveURL)
            //let OK = FileIO.SaveImage(SaveMe, At: SaveURL)
            if !OK
            {
                print("Error saving image at \(SaveURL.path)")
            }
        }
        CameraIsPaused = false
    }
    
    @IBAction func SaveFileFromMenu(_ sender: Any)
    {
        let SaveMe = ProcessedImage.Snapshot()
        DoSaveImage(SaveMe)
    }
    
    @IBAction func CopyImageToPasteboardFromMenu(_ sender: Any)
    {
        let PasteMe = ProcessedImage.Snapshot()
        let Clipboard = NSPasteboard.general
        Clipboard.clearContents()
        let IData = PasteMe.tiffRepresentation
        let CopiedOK = Clipboard.setData(IData, forType: NSPasteboard.PasteboardType.tiff)
        //let CopiedOK = Clipboard.writeObjects([PasteMe])
        if !CopiedOK
        {
            print("Error copying image.")
        }
        print("Clipboard count: \(Clipboard.pasteboardItems!.count)")
    }
    
    @IBAction func PasteImageFromPasteboardFromMenu(_ sender: Any)
    {
        let Clipboard = NSPasteboard.general
        let DataType = NSPasteboard.PasteboardType.tiff
        guard let ImageData = Clipboard.data(forType: DataType) else
        {
            print("No image to copy from the pasteboard")
            return
        }
        if let PastedImage = NSImage(data: ImageData)
        {
            print("Got image from pasteboard")
        }
        else
        {
            print("Bad image pasted.")
        }
    }
    
    @IBAction func HandleProcessingSettingsButtonPressed(_ sender: Any)
    {
        OpenOptionsWindow(self)
    }
    
    @IBAction func ShowDebugWindow(_ sender: Any)
    {
        OpenDebug()
    }
    
    @IBAction func DebugResetSettings(_ sender: Any)
    {
        Settings.AddDefaultSettings()
    }
    
    @IBAction func ShowShapeList(_ sender: Any)
    {
        let Storyboard = NSStoryboard(name: "ShapeListUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ShapeListUIWindow") as? ShapeListUIWindow
        {
            WindowController.showWindow(nil)
            ShapeListWindow = WindowController
        }
    }
    
    var ShapeListWindow: ShapeListUIWindow? = nil
    
    func ImageForDebug(_ Image: NSImage, ImageType: DebugImageTypes)
    {
        AddImage(Type: ImageType, Image)
    }
    
    func RedrawImage()
    {
        if Settings.GetEnum(ForKey: .CurrentMode, EnumType: ProgramModes.self, Default: ProgramModes.LiveView) == .ImageView
        {
            ProcessedImage.ReprocessImage()
        }
    }
    
    func ResetLiveView()
    {
        if Settings.GetEnum(ForKey: .CurrentMode, EnumType: ProgramModes.self, Default: ProgramModes.LiveView) == .LiveView
        {
            ProcessedImage.ResetLiveView()
        }
    }
    
    var DebugWindow: DebugWindowCode? = nil
    var MainSettings: ProgramSettingsWindowController? = nil
    
    @IBOutlet weak var StillImageView: NSView!
    @IBOutlet weak var OriginalImageView: NSImageView!
    @IBOutlet var ControllerView: ViewControllerView!
    @IBOutlet weak var ModeSegment: NSSegmentedControl!
    @IBOutlet weak var ProcessedImage: BlockView!
    @IBOutlet weak var LiveHistogram: HistogramDisplay!
    @IBOutlet weak var CameraButton: NSButton!
    @IBOutlet weak var BottomBar: NSView!
    @IBOutlet weak var AlignImageButton: NSButton!
    @IBOutlet weak var ImageSourceLabel: NSTextField!
    
    // MARK: - Status controls
    
    @IBOutlet weak var DurationValue: NSTextField!
    @IBOutlet weak var DurationText: NSTextField!
    @IBOutlet weak var AddingShapesIndicator: NSProgressIndicator!
    @IBOutlet weak var CreatingShapesIndicator: NSProgressIndicator!
    @IBOutlet weak var ParsingImageIndicator: NSProgressIndicator!
    @IBOutlet weak var PreparingImageIndicator: NSProgressIndicator!
    @IBOutlet weak var AddingShapesDone: NSTextField!
    @IBOutlet weak var CreatingShapesDone: NSTextField!
    @IBOutlet weak var ParsingImageDone: NSTextField!
    @IBOutlet weak var PreparingTextDone: NSTextField!
    @IBOutlet weak var AddingShapesText: NSTextField!
    @IBOutlet weak var CreatingShapesText: NSTextField!
    @IBOutlet weak var ParsingImageText: NSTextFieldCell!
    @IBOutlet weak var PreparingImageText: NSTextField!
    @IBOutlet weak var StatusBox: NSBox!
}


