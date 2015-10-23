//
//  AppDelegate.swift
//  CAEN Lecture Scraper
//
//  Created by Manav Gabhawala on 6/3/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	var mainController = MainViewController(nibName: "MainViewController", bundle: nil)!
	var tableController = DownloadVideosController(nibName: "DownloadVideosController", bundle: nil)!
	func applicationDidFinishLaunching(aNotification: NSNotification)
	{
		// Insert code here to initialize your application
		
		window.contentView = mainController.view
	}

	func applicationWillTerminate(aNotification: NSNotification)
	{
		// Insert code here to tear down your application
	}
	func switchToTableView() -> DownloadVideosController
	{
		addViewToWindow(window, view: tableController.view)
		return tableController
	}
	func addViewToWindow(window: NSWindow, view: NSView)
	{
		window.contentView = view
		let heightDifference = view.frame.height - window.contentView!.frame.height
		let widthDifference = view.frame.width - window.contentView!.frame.width
		
		var frame = window.frame
		frame.size.width += widthDifference
		frame.size.height += heightDifference
		frame.origin.y -= heightDifference
		
		window.setFrame(frame, display: true, animate: true)
		view.frame.origin = CGPointZero
	}
}

