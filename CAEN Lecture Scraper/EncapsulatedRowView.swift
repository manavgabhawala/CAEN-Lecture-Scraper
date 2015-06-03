//
//  ProgressCellView.swift
//  CAEN Lecture Scraper
//
//  Created by Manav Gabhawala on 6/3/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

class EncapsulatedRowView: NSTableRowView
{

	@IBOutlet var progressBar : ProgressCellView!
	@IBOutlet var fileName : NSTableCellView!
	@IBOutlet var statusLabel : NSTableCellView!
	
	var downloadURL : NSURL!
	var saveTo: NSURL!
	
	func setup(video: VideoData)
	{
		downloadURL = video.URL
		saveTo = video.filePath
	}
	
	func beginDownload()
	{
		
	}
	override func viewAtColumn(column: Int) -> AnyObject?
	{
		if column == 0
		{
			return fileName
		}
		else if column == 1
		{
			return progressBar
		}
		else
		{
			return statusLabel
		}
	}
}
