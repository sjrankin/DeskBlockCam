//
//  +StatTable.swift
//  DeskBlockCam
//
//  Created by Stuart Rankin on 2/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Handles debug data/statistics table view.
extension ViewController: NSTableViewDelegate, NSTableViewDataSource
{
    /// Rounds a double value.
    /// - Warning: If `ToMagnitude` is not power of 10, the original value is returned unchanged.
    /// - Parameter Raw: The value to round.
    /// - Parameter ToMagnitude: The magnitude to round to. The bigger the number the more the digits. This
    ///                          parameter must be a power of 10. If not, the original number is returned
    ///                          unchanged. Defaults to 10000.0
    /// - Returns: Rounded value.
    func Rounded(_ Raw: Double, ToMagnitude: Double = 10000.0) -> Double
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
    func RoundedString(_ Raw: Double, ToMagnitude: Double = 10000.0) -> String
    {
        return "\(Rounded(Raw))"
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
                        self.StatTable.reloadData()
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
                self.StatTable.reloadData()
        }
    }
    
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
}
