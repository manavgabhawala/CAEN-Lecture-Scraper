//
//  ProgressCellView.swift
//  CAEN Lecture Scraper
//
//  Created by Manav Gabhawala on 6/3/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

class ProgressCellView: NSTableCellView
{
	@IBOutlet var progressBar: NSProgressIndicator!
	
	var downloadURL : NSURL!
	var saveTo: NSURL!
	var isDownloading = false
	weak var statusCell : NSTableCellView!
	var task : NSURLSessionDownloadTask!
	func setup(video: VideoData)
	{
		downloadURL = video.URL
		saveTo = video.filePath
	}
	func delete()
	{
		if task != nil
		{
			task.suspend()
		}
		statusCell.textField!.stringValue = "Deleted"
	}
	
	func beginDownload()
	{
		if statusCell.textField!.stringValue != "Deleted"
		{
			statusCell.textField!.stringValue = "Queued"
			let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue())
			task = session.downloadTaskWithURL(downloadURL)
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
				dispatch_semaphore_wait(downloadsAllowed, DISPATCH_TIME_FOREVER)
				dispatch_async(dispatch_get_main_queue(), {
					self.statusCell.textField!.stringValue = "Downloading"
				})
				self.task.resume()
			})
		}
	}
}
extension ProgressCellView : NSURLSessionDownloadDelegate
{
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
	{
		progressBar.indeterminate = false
		progressBar.animator().doubleValue = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * progressBar.maxValue
	}
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
	{
		dispatch_semaphore_signal(downloadsAllowed)
		dispatch_async(dispatch_get_main_queue(), {
			self.statusCell.textField!.stringValue = "Downloaded"
		})
	}
	func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?)
	{
		let downloadedStuff = error?.userInfo
		println("Unhandled Error!")
		println(error!.localizedDescription)
	}
}
