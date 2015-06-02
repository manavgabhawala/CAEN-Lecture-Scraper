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

	func applicationDidFinishLaunching(aNotification: NSNotification)
	{
		// Insert code here to initialize your application
		
		window.contentView = mainController.view
	}

	func applicationWillTerminate(aNotification: NSNotification)
	{
		// Insert code here to tear down your application
	}


}

