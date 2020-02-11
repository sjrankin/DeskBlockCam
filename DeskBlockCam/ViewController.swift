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
    DragDropDelegate
{
    /// Load and set up the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Settings.AddSubscriber(self, "ViewController")
        
        LiveView.wantsLayer = true
        LiveView.layer?.borderWidth = 1.0
        LiveView.layer?.borderColor = NSColor.systemYellow.cgColor
        LiveView.layer?.cornerRadius = 5.0
        LiveView.layer?.backgroundColor = NSColor.black.cgColor
        LiveView.isHidden = false
        
        ProcessedImage.wantsLayer = true
        ProcessedImage.isHidden = true
        
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
        
        ModeSelector.removeAllItems()
        ModeSelector.addItems(withTitles: ["Live View", "Still Image", "Videos"])
        
        Started = true
        if Settings.GetBoolean(ForKey: .AutoOpenShapeSettings)
        {
            OpenOptionsWindow()
        }
        OpenProcessedWindow()
        StatTable.reloadData()
        
        LiveHistogram.isHidden = !Settings.GetBoolean(ForKey: .ShowHistogram)
        
        ControllerView.DragDelegate = self
        view.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map {NSPasteboard.PasteboardType($0)})
        view.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
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
            print("\(draggingItem.item)")
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
                            self.handleError(error)
                        }
                        else
                        {
                            self.handleFile(at: fileURL)
                        }
                }
                
                case let fileURL as URL:
                    self.handleFile(at: fileURL)
                
                default:
                    fatalError()
            }
        }
        
        return true
    }
    
    func handleError(_ error: Error)
    {
        print("Error: \(error)")
    }
    
    func handleFile(at url: URL)
    {
        let Image = NSImage(contentsOf: url)
        if Image == nil
        {
            print("Error reading image.")
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
    
    func RunProgramSettings()
    {
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ProgramSettingsWindowUI") as? ProgramSettingsWindowController
        {
            WindowController.showWindow(nil)
            MainSettings = WindowController
        }
    }
    
    var MainSettings: ProgramSettingsWindowController? = nil
    
    /// Open the processed video window.
    func OpenProcessedWindow()
    {
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ProcessedImageWindowUI") as? ProcessedViewWindowController
        {
            WindowController.showWindow(nil)
            ProcessSink = WindowController.contentViewController as? ProcessedViewController
            ProcessedWindow = WindowController
        }
    }
    
    func OpenOptionsWindow()
    {
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "ShapeOptionWindowUI") as? ShapeOptionsWindowCode
        {
            WindowController.showWindow(nil)
            SettingsWindow = WindowController
            SettingsControl = WindowController.contentViewController as? ShapeOptionsCode
        }
    }
    
    var SettingsControl: ShapeOptionsCode? = nil
    var SettingsWindow: ShapeOptionsWindowCode? = nil
    
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
    }
    
    /// Hook up the camera stream to the output view.
    func SetupLiveView()
    {
        OperationQueue.main.addOperation
            {
                self.LiveView.layerContentsPlacement = .scaleProportionallyToFill
                self.LiveView.layerContentsRedrawPolicy = .duringViewResize
                self.VideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.CaptureSession)
                self.VideoPreviewLayer.name = "VideoLayer"
                self.VideoPreviewLayer.videoGravity = .resizeAspect
                self.VideoPreviewLayer.connection?.videoOrientation = .portrait
                self.LiveView.layer?.addSublayer(self.VideoPreviewLayer)
        }
        DispatchQueue.global(qos: .userInitiated).async
            {
                [weak self] in
                self!.CaptureSession.startRunning()
                DispatchQueue.main.async
                    {
                        self!.VideoPreviewLayer.frame = self!.LiveView.bounds
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
        DispatchQueue.main.async
            {
                self.VideoPreviewLayer.frame = self.LiveView.bounds
                self.ProcessedImage.frame = self.LiveView.bounds
        }
    }
    
    @objc func pictureTakerDidEnd(Sheet: IKPictureTaker,
                                  returnCode: NSInteger,
                                  contextInfo: UnsafeMutableRawPointer?)
    {
        //OriginalImage.image = Sheet.outputImage()
    }
    
    /// Capture a still image from the camera view.
    /// - Parameter sender: Not used.
    @IBAction func HandleCameraButton(_ sender: Any)
    {
        let Settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        StillImageOutput.capturePhoto(with: Settings, delegate: self)
    }
    
    /// Holds the last frame time. This is used with a throttle value to ensure we don't overwhelm
    /// the API with too much data.
    var LastFrameTime = CACurrentMediaTime()
    
    /// Capture the output of a frame of data from the live view. For now, the data is sent to the
    /// processed view window for conversion to 3D and display.
    /// - Parameter output: Not used.
    /// - Parameter didOutput: The buffer from the live view.
    /// - Parameter from: The conection that sent the data.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
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
                    ProcessSink?.NewImage(CIImg, FrameCount)
                    let TotalEnd = CACurrentMediaTime() - Start
                    Durations.append(TotalEnd)
                    if let RollingMean = RollingDurationMean()
                    {
                        AddStat(ForItem: .RollingMeanFrameDuration,
                                NewValue: RoundedString(RollingMean))
                        let Delta = RollingMean - TotalEnd
                        AddStat(ForItem: .FrameDurationDelta, NewValue: RoundedString(Delta))
                    }
                    AddStat(ForItem: .LastFrameDuration,
                            NewValue: RoundedString(TotalEnd))
                    
                    if ProcessSink != nil
                    {
                        if DroppedFrames < ProcessSink!.DroppedFrameCount
                        {
                            DroppedFrames = ProcessSink!.DroppedFrameCount
                            AddStat(ForItem: .DroppedFrames, NewValue: "\(DroppedFrames)")
                        }
                    }
                    RenderedFrames = RenderedFrames + 1
                    RenderedDuration = RenderedDuration + TotalEnd
                    AddStat(ForItem: .RenderDuration, NewValue: "\(Int(RenderedDuration)) s")
                    AddStat(ForItem: .RenderedFrames, NewValue: "\(RenderedFrames)")
                    let cFPS = RenderedDuration / Double(RenderedFrames)
                    AddStat(ForItem: .CalculatedFramesPerSecond, NewValue: RoundedString(cFPS))
                }
        }
    }
    
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
    
    var ProcessSink: ProcessedViewController? = nil
    
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
        if let Processed = ProcessedWindow
        {
            Processed.CloseWindow()
        }
        if let Settings = SettingsWindow
        {
            Settings.CloseWindow()
        }
        if let MainS = MainSettings
        {
            MainS.CloseWindow()
        }
        FileIO.ClearFramesDirectory()
    }
    
    var ProcessedWindow: ProcessedViewWindowController? = nil
    
    var ShapeIndex: Int = 0
    
    /// Table of statistics and labels to show in the stat table.
    var CurrentStats: [StatRowContainer] =
        [
            StatRowContainer(.CurrentFrame, "Frame", ""),
            StatRowContainer(.SkippedFrames, "Skipped", ""),
            StatRowContainer(.DroppedFrames, "Dropped", ""),
            StatRowContainer(.RenderedFrames, "Rendered", ""),
            StatRowContainer(.RenderDuration, "Render duration", ""),
            StatRowContainer(.CalculatedFramesPerSecond, "FPS", ""),
            StatRowContainer(.LastFrameDuration, "Last Duration", ""),
            StatRowContainer(.RollingMeanFrameDuration, "Rolling Mean", "not yet"),
            StatRowContainer(.FrameDurationDelta, "Delta Duration", "not yet"),
            StatRowContainer(.ThrottleValue, "Throttle", ""),
    ]
    
    @IBAction func HandleModeSelectorChanged(_ sender: Any)
    {
        if let Selector = sender as? NSPopUpButton
        {
            let Index = Selector.indexOfSelectedItem
            print("Selected \((Selector.titleOfSelectedItem)!)")
        }
    }
    
    @IBOutlet var ControllerView: ViewControllerView!
    @IBOutlet weak var ModeSelector: NSPopUpButton!
    @IBOutlet weak var ProcessedImage: SCNView!
    @IBOutlet weak var LiveHistogram: HistogramDisplay!
    @IBOutlet weak var StatTable: NSTableView!
    @IBOutlet weak var CameraButton: NSButton!
    @IBOutlet weak var LiveView: LiveViewer!
    @IBOutlet weak var BottomBar: NSView!
}

enum ProgramModes: String, CaseIterable
{
    case Video = "Video"
    case Snapshot = "Snapshot"
    case StillImage = "StillImage"
}

enum StatRows: Int, CaseIterable
{
    case CurrentFrame = 0
    case SkippedFrames = 1
    case CalculatedFramesPerSecond = 2
    case LastFrameDuration = 3
    case RollingMeanFrameDuration = 4
    case FrameDurationDelta = 5
    case DroppedFrames = 7
    case RenderedFrames = 8
    case RenderDuration = 9
    case ThrottleValue = 10
}

/// Contains information for one row of the stat table UI.
class StatRowContainer
{
    init(_ Type: StatRows, _ Label: String, _ Value: String)
    {
        RowType = Type
        RowLabel = Label
        RowValue = Value
    }
    
    public var RowType: StatRows = .CurrentFrame
    public var RowLabel: String = ""
    public var RowValue: String = ""
}
