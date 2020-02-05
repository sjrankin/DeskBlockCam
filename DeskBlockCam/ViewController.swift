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
class ViewController: NSViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
{
    /// Load and set up the UI.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        LiveView.wantsLayer = true
        LiveView.layer?.borderWidth = 1.0
        LiveView.layer?.borderColor = NSColor.systemYellow.cgColor
        LiveView.layer?.cornerRadius = 5.0
        LiveView.layer?.backgroundColor = NSColor.black.cgColor
        
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
        ShapeSelector.selectedSegment = 0
        OpenProcessedWindow()
        StatTable.reloadData()
    }
    
    var Started = false
    
    func OpenProcessedWindow()
    {
        let Storyboard = NSStoryboard(name: "Main", bundle: nil)
        let WindowController = Storyboard.instantiateController(withIdentifier: "ProcessedImageWindowUI") as? ProcessedViewWindowController
        if let Ctlr = WindowController as? ProcessedViewWindowController
        {
            Ctlr.showWindow(nil)
            ProcessSink = Ctlr.contentViewController as? ProcessedViewController
            ProcessedWindow = Ctlr
        }
    }
    
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
    
    func SetupLiveView()
    {
        LiveView.layerContentsPlacement = .scaleProportionallyToFill
        LiveView.layerContentsRedrawPolicy = .duringViewResize
        VideoPreviewLayer = AVCaptureVideoPreviewLayer(session: CaptureSession)
        VideoPreviewLayer.name = "VideoLayer"
        VideoPreviewLayer.videoGravity = .resizeAspect
        VideoPreviewLayer.connection?.videoOrientation = .portrait
        LiveView.layer?.addSublayer(VideoPreviewLayer)
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
    
    func WindowResized(To: NSSize)
    {
        if !Started
        {
            return
        }
        DispatchQueue.main.async
            {
                self.VideoPreviewLayer.frame = self.LiveView.bounds
        }
    }
    
    @objc func pictureTakerDidEnd(Sheet: IKPictureTaker,
                                  returnCode: NSInteger,
                                  contextInfo: UnsafeMutableRawPointer?)
    {
        //OriginalImage.image = Sheet.outputImage()
    }
    
    @IBAction func HandleCameraButton(_ sender: Any)
    {
        let Settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        StillImageOutput.capturePhoto(with: Settings, delegate: self)
    }
    
    var LastFrameTime = CACurrentMediaTime()
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
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
                    if let Reduction = CIFilter(name: "CIPixellate")
                    {
                        let Start = CACurrentMediaTime()
                        AddStat(ForItem: .CurrentFrame, NewValue: "\(FrameCount)")
                        Reduction.setDefaults()
                        Reduction.setValue(CIImg, forKey: kCIInputImageKey)
                        Reduction.setValue(16, forKey: kCIInputScaleKey)
                        if let Reduced: CIImage = (Reduction.value(forKey: kCIOutputImageKey) as? CIImage)
                        {
                            let Rep = NSCIImageRep(ciImage: Reduced)
                            let Pixellated: NSImage = NSImage(size: Rep.size)
                            Pixellated.addRepresentation(Rep)
                            let NSRep = NSCIImageRep(ciImage: CIImg)
                            let Source = NSImage(size: NSRep.size)
                            Source.addRepresentation(NSRep)
                            ProcessSink?.NewImage(Source, Pixellated, ShapeIndex, FrameCount)
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
                            
                            if DroppedFrames < ProcessSink!.DroppedFrameCount
                            {
                                DroppedFrames = ProcessSink!.DroppedFrameCount
                                AddStat(ForItem: .DroppedFrames, NewValue: "\(DroppedFrames)")
                            }
                            RenderedFrames = RenderedFrames + 1
                            RenderedDuration = RenderedDuration + TotalEnd
                            AddStat(ForItem: .RenderDuration, NewValue: RoundedString(RenderedDuration))
                            AddStat(ForItem: .RenderedFrames, NewValue: "\(RenderedFrames)")
                            let cFPS = RenderedDuration / Double(RenderedFrames)
                            AddStat(ForItem: .CalculatedFramesPerSecond, NewValue: RoundedString(cFPS))
                        }
                        else
                        {
                            print("No image returned from CIPixellate")
                        }
                    }
                }
        }
    }
    
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
    
    func WillClose()
    {
        if let Processed = ProcessedWindow
        {
            Processed.CloseWindow()
        }
    }
    
    var ProcessedWindow: ProcessedViewWindowController? = nil
    
    @IBAction func HandleShapeSelectorChanged(_ sender: Any)
    {
        if let Segment = sender as? NSSegmentedControl
        {
            let Index = Segment.selectedSegment
            ShapeIndex = Index
        }
    }
    
    var ShapeIndex: Int = 0
    
    @IBAction func HandleRecordButtonPressed(_ sender: Any)
    {
        if Recording
        {
            Recording = false
        }
        else
        {
            Recording = true
        }
        if Recording
        {
            RecordButton.image = NSImage(named: "BigRedCircle")
            ProcessSink?.SaveFrames = true
            AddStat(ForItem: .Recording, NewValue: "Yes")
        }
        else
        {
            RecordButton.image = NSImage(named: "BigCircle")
            ProcessSink?.SaveFrames = false
            AddStat(ForItem: .Recording, NewValue: "No")
        }
    }
    
    var Recording = false
    
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
            StatRowContainer(.Recording, "Recording", "No"),
    ]
    
    @IBOutlet weak var StatTable: NSTableView!
    @IBOutlet weak var RecordButton: NSButton!
    @IBOutlet weak var ShapeSelector: NSSegmentedControl!
    @IBOutlet weak var CameraButton: NSButton!
    @IBOutlet weak var LiveView: LiveViewer!
    @IBOutlet weak var BottomBar: NSView!
}

enum StatRows: Int, CaseIterable
{
    case CurrentFrame = 0
    case SkippedFrames = 1
    case CalculatedFramesPerSecond = 2
    case LastFrameDuration = 3
    case RollingMeanFrameDuration = 4
    case FrameDurationDelta = 5
    case Recording = 6
    case DroppedFrames = 7
    case RenderedFrames = 8
    case RenderDuration = 9
    case ThrottleValue = 10
}

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
