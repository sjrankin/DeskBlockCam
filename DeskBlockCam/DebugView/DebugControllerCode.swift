//
//  DebugControllerCode.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/12/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

class DebugControllerCode: NSViewController,
    NSTableViewDelegate, NSTableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LiveViewTable.reloadData()
        HistogramImage.wantsLayer = true
        HistogramImage.layer?.borderColor = NSColor.black.cgColor
        HistogramImage.layer?.borderWidth = 0.5
        HistogramImage.layer?.cornerRadius = 5.0
        PixellatedImage.wantsLayer = true
        HistogramImage.layer?.borderColor = NSColor.black.cgColor
        PixellatedImage.layer?.borderWidth = 0.5
        PixellatedImage.layer?.cornerRadius = 5.0
        SnapshotImage.wantsLayer = true
        SnapshotImage.layer?.borderColor = NSColor.black.cgColor
        SnapshotImage.layer?.borderWidth = 0.5
        SnapshotImage.layer?.cornerRadius = 5.0
        OriginalImage.wantsLayer = true
        OriginalImage.layer?.borderColor = NSColor.black.cgColor
        OriginalImage.layer?.borderWidth = 0.5
        OriginalImage.layer?.cornerRadius = 5.0
    }
    
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
    
    /// Returns the number of rows of data to display in the stat table.
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return CurrentStats.count
    }
    
    /// Returns a view for the stat table.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var CellContents = ""
        var CellIdentifier = ""
        if tableColumn == tableView.tableColumns[0]
        {
            CellIdentifier = "ItemColumn"
            CellContents = CurrentStats[row].RowLabel
        }
        if tableColumn == tableView.tableColumns[1]
        {
            CellIdentifier = "ValueColumn"
            CellContents = CurrentStats[row].RowValue
        }
        let Cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifier), owner: self) as? NSTableCellView
        if CurrentStats[row].RowType == .FrameDurationDelta && CellIdentifier == "ValueColumn"
        {
            if let Value = Double(CurrentStats[row].RowValue)
            {
                if Value < 0.0
                {
                    Cell?.textField?.textColor = NSColor.red
                }
                else
                {
                    Cell?.textField?.textColor = NSColor.black
                }
            }
        }
        Cell?.textField?.stringValue = CellContents
        return Cell
    }
    
    /// Updates a single statistic for the stat table.
    /// - Parameter ForItem: Indicates which row to updated. If this row is not in the table, no
    ///                      action is taken.
    /// - Parameter NewValue: The new value for the specified row.
    func AddStat(ForItem: StatRows, NewValue: String)
    {
        for Item in CurrentStats
        {
            if Item.RowType == ForItem
            {
                Item.RowValue = NewValue
                OperationQueue.main.addOperation
                    {
                        self.LiveViewTable.reloadData()
                }
                return
            }
        }
    }
    
    /// Updates a set of statistics for the stat table all at once.
    /// - Parameter List: Array of tuples of row indicators and new values.
    func AddStats(_ List: [(StatRows, String)])
    {
        for (Row, Value) in List
        {
            for Item in CurrentStats
            {
                if Item.RowType == Row
                {
                    Item.RowValue = Value
                }
            }
        }
        OperationQueue.main.addOperation
            {
                self.LiveViewTable.reloadData()
        }
    }
    
    func AddImage(Type: DebugImageTypes, _ Image: NSImage)
    {
        OperationQueue.main.addOperation
            {
                switch Type
                {
                    case .Histogram:
                        self.HistogramImage.image = Image
                    
                    case .Original:
                        self.OriginalImage.image = Image
                    
                    case .Pixellated:
                        self.PixellatedImage.image = Image
                    
                    case .Snapshot:
                        self.SnapshotImage.image = Image
                }
        }
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.view.window?.close()
    }
    
    @IBOutlet weak var HistogramImage: NSImageView!
    @IBOutlet weak var PixellatedImage: NSImageView!
    @IBOutlet weak var SnapshotImage: NSImageView!
    @IBOutlet weak var OriginalImage: NSImageView!
    @IBOutlet weak var LiveViewTable: NSTableView!
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
