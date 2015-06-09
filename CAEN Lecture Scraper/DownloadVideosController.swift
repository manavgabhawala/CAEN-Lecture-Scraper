//
//  DownloadVideosController.swift
//  CAEN Lecture Scraper
//
//  Created by Manav Gabhawala on 6/3/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

let downloadsAllowed = dispatch_semaphore_create(3)
let finishedAcquiringLinksNotification = "FinishedAcquiringLinksNotification"
class DownloadVideosController: NSViewController
{
	@IBOutlet var tableView : NSTableView!
	@IBOutlet var downloadButton: NSButton!
	@IBOutlet var removeRowButton : NSButton!
	@IBOutlet var addRowButton: NSButton!
	@IBOutlet var clearDeleted: NSButton!
	
	var beginDownloading = false
	var videos = [VideoData]()
	{
		didSet
		{
			remakeCells()
			tableView.reloadData()
		}
	}
	var progressCells = [ProgressCellView]()
	var fileNameCells = [NSTableCellView]()
	var statusCells = [NSTableCellView]()
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
		remakeCells()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedAcquiringLinks", name: finishedAcquiringLinksNotification, object: nil)
    }
	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
	}
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	func finishedAcquiringLinks()
	{
		downloadButton.enabled = true
	}
	func remakeCells()
	{
		fileNameCells.removeAll(keepCapacity: true)
		progressCells.removeAll(keepCapacity: true)
		statusCells.removeAll(keepCapacity: true)
		for video in videos
		{
			if let progressCell = tableView.makeViewWithIdentifier("progress", owner: self) as? ProgressCellView
			{
				progressCell.setup(video)
				progressCells.append(progressCell)
				if let cell = tableView.makeViewWithIdentifier("status", owner: self) as? NSTableCellView
				{
					progressCell.statusCell = cell // Give it a weak reference to status so it can update it when necessary. Not the best way to do this but works.
					cell.textField!.stringValue = "Waiting to Queue"
					statusCells.append(cell)
				}
			}
			if let cell = tableView.makeViewWithIdentifier("file", owner: self) as? NSTableCellView
			{
				cell.textField!.stringValue = video.filePath.lastPathComponent!
				fileNameCells.append(cell)
			}
		}
	}
	@IBAction func beginDownloads(sender: NSButton)
	{
		beginDownloading = true
		for cell in progressCells
		{
			cell.beginDownload()
		}
	}
	@IBAction func removeRow(sender: NSButton)
	{
		for selectedRow in tableView.selectedRowIndexes
		{
			let rowToDelete = selectedRow
			if rowToDelete >= 0 && rowToDelete < progressCells.count
			{
				progressCells[rowToDelete].delete()
				clearDeleted.enabled = true
			}
			else
			{
				removeRowButton.enabled = false
			}
		}
		removeRowButton.enabled = false
		tableView.selectRowIndexes(NSIndexSet(index: -1), byExtendingSelection: false)
	}
	@IBAction func clearDeletedRows(sender: NSButton)
	{
		var rowsToDelete = [Int]()
		for (i, row) in statusCells.enumerate()
		{
			if row.textField!.stringValue == "Deleted"
			{
				rowsToDelete.append(i)
			}
		}
		for rowToDelete in rowsToDelete.reverse()
		{
			statusCells.removeAtIndex(rowToDelete)
			progressCells.removeAtIndex(rowToDelete)
			fileNameCells.removeAtIndex(rowToDelete)
			videos.removeAtIndex(rowToDelete)
			tableView.removeRowsAtIndexes(NSIndexSet(index: rowToDelete), withAnimation: .SlideLeft)
		}
		clearDeleted.enabled = false
	}
	@IBAction func addRowBack(sender: NSButton)
	{
		for selectedRow in tableView.selectedRowIndexes
		{
			let rowToAdd = selectedRow
			if rowToAdd >= 0 && rowToAdd < progressCells.count && statusCells[rowToAdd].textField!.stringValue == "Deleted"
			{
				statusCells[rowToAdd].textField!.stringValue = "Waiting to Queue"
				if beginDownloading
				{
					progressCells[rowToAdd].beginDownload()
				}
			}
		}
		tableView.selectRowIndexes(NSIndexSet(index: -1), byExtendingSelection: false)
		addRowButton.enabled = false
	}
}
//MARK: - TableViewStuff
extension DownloadVideosController : NSTableViewDelegate, NSTableViewDataSource
{
	func numberOfRowsInTableView(tableView: NSTableView) -> Int
	{
		return progressCells.count
	}
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		if tableColumn?.identifier == "progressColumn"
		{
			return progressCells[row]
		}
		else if tableColumn?.identifier == "fileColumn"
		{
			return fileNameCells[row]
		}
		else if tableColumn?.identifier == "statusColumn"
		{
			return statusCells[row]
		}
		return nil
	}
	func tableViewSelectionDidChange(notification: NSNotification)
	{
		var setDeleteTo = false
		var setAddTo = false
		for selectedRow in tableView.selectedRowIndexes
		{
			if selectedRow >= 0 && selectedRow < progressCells.count
			{
				if statusCells[selectedRow].textField!.stringValue == "Deleted"
				{
					setAddTo = true
				}
				else
				{
					setDeleteTo = true
				}
			}
		}
		removeRowButton.enabled = setDeleteTo
		addRowButton.enabled = setAddTo
	}
}