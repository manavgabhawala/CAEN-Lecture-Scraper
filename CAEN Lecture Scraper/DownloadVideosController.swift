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
					cell.textField!.stringValue = "Queued"
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
		for cell in progressCells
		{
			cell.beginDownload()
		}
	}
	@IBAction func removeRow(sender: NSButton)
	{
		
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
		let selectedRow = tableView.selectedRow
		if selectedRow >= 0 && selectedRow < progressCells.count
		{
			
		}
	}
}