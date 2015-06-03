//
//  MainViewController.swift
//  CAEN Lecture Scraper
//
//  Created by Manav Gabhawala on 6/3/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Cocoa
import WebKit

var directory : NSURL!

typealias VideoData = (filePath: NSURL, URL: NSURL)

class MainViewController: NSViewController
{
	
	@IBOutlet var webView : WebView!
	@IBOutlet var instructionsLabel: NSTextField!
	@IBOutlet var URLInputter : NSTextField!
	
	var viewerLinks = [NSURL]() // Stores the viewer links.
//	var videoDownloadLinks = [VideoData]() // Stores the download URLs.
	var timer : NSTimer!
	weak var controller : DownloadVideosController?
	
	// MARK: - Initialization and Lifecycle
	override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
	}
    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
		webView.frameLoadDelegate = self
		webView.policyDelegate = self
//		webView.mainFrameURL = "https://google.com"
    }
	
	// MARK: - Generic Helper methods
	func showError(messageText: String, informativeText: String, error: NSError? = nil)
	{
		let alert : NSAlert
		if let error = error
		{
			alert = NSAlert(error: error)
		}
		else
		{
			alert = NSAlert()
			alert.messageText = messageText
			alert.informativeText = informativeText
			alert.alertStyle = .CriticalAlertStyle
		}
		alert.addButtonWithTitle("Okay")
		alert.beginSheetModalForWindow(view.window!, completionHandler: nil)
	}
	
	// MARK: - Actions
	@IBAction func downloadVideos(sender: NSButton)
	{
		if let URL = NSURL(string: URLInputter.stringValue)
		{
			let dialog = NSOpenPanel()
			dialog.canChooseFiles = false
			dialog.canChooseDirectories = true
			dialog.canCreateDirectories = true
			dialog.allowsMultipleSelection = false
			if dialog.runModal() == NSFileHandlingPanelOKButton
			{
				directory = dialog.URLs.first! as! NSURL
				webView.mainFrame.loadRequest(NSURLRequest(URL: URL))
				assert(webView.loading)
				instructionsLabel.stringValue = "Login to your umich account which has access to the CTools page you linked to. Then wait and let the magic happen. Remember patience is key... (especially with slower internet connections)"
			}
		}
		else
		{
			showError("URL Parsing Error", informativeText: "The URL you provided wasn't really a URL we could use to download videos from CAEN now was it?")
		}
	}
	
	// MARK: - HTML Parsing Methods
	// Extracts viewer links from HTML code
	func findAllVideoPlayerLinksFromHTML(HTML: String)
	{
		// Extract the viewer links from the HTML provided.
		var links = [String]()
		for item in HTML.componentsSeparatedByString("<a class=\"button\" href=\"")
		{
			var link = "https://leccap.engin.umich.edu" // We need to append the base URL here.
			for char in item
			{
				if char == "\""
				{
					links.append(link) // Add on the extension to the URL.
					break
				}
				link += "\(char)"
			}
		}
		// Remove the garbage value that's caused when creating the array by splitting the HTML code.
		links.removeAtIndex(0)
		self.viewerLinks = links.map { NSURL(string: $0)! } // Map each string into a URL and save it in an ivar.
		println(viewerLinks)
		if self.viewerLinks.count > 1
		{
			webView.removeFromSuperview() // Remove the webview so that the user doesn't have to see the constant redirection.
			// Go to the last viewer link so that we can extract it's direct download link.
			redirectToURL(self.viewerLinks.last!)
		}
		/*
		else
		{
			if !webView.loading
			{
				showError("Could not extract Videos", informativeText: "It seems like the URL you provided is not what we expected. Please make sure the URL is correct and that you have the new player enabled when you pasted the URL.")
			}
			
		}*/
	}
	// Redirects the frame to the required URL.
	func redirectToURL(URL: NSURL)
	{
		webView.mainFrame.loadRequest(NSURLRequest(URL: URL))
	}
	
	// Get's the direct download URL for the currently loaded frame on the webview
	func fetchDownloadOfNextVideo()
	{
		println("Downloading...")
		var error: NSError?
		if webView.mainFrameDocument.body.outerHTML.rangeOfString("<video autoplay=") != nil
		{
			timer.invalidate()
			findVideoURLInHTML(webView.mainFrameDocument.body.outerHTML)
			// TODO: Change to > 0
			if viewerLinks.count > 0
			{
				redirectToURL(viewerLinks.last!)
			}
			else
			{
				webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: "https://google.com")!))
				NSNotificationCenter.defaultCenter().postNotificationName(finishedAcquiringLinksNotification, object: nil)
				println("\n\n\n\n\n")
			}
		}
	}
	
	// Helper that actually extracts the download URL and appends it to an ivar.
	func findVideoURLInHTML(HTML: String)
	{
		if let item = HTML.componentsSeparatedByString("<video autoplay=\"autoplay\" x-webkit-airplay=\"allow\" src=\"//").last
		{
			var link = "https://"
			for char in item
			{
				if char == "\""
				{
					break
				}
				link += "\(char)"
			}
			let title = HTML.textBetween("<span class=\"content-header-recording-title\">", end: "</span>") ?? "Unknown Title \(random())"
			if let URL = NSURL(string: link)
			{
				if controller == nil
				{
					controller = (NSApplication.sharedApplication().delegate as! AppDelegate).switchToTableView()
				}
				controller!.videos.append((filePath: directory.URLByAppendingPathComponent(title.safeString()).URLByAppendingPathExtension("mp4"), URL: URL))
				return
			}
		}
		viewerLinks.removeAll(keepCapacity: true)
		showError("Could not extract Videos", informativeText: "It seems like the URL you provided is not what we expected. Please make sure the URL is correct and that you have the newest player (HTML 5 not that old flash stuff..) enabled when you pasted the URL.")
		webView.mainFrame.stopLoading()
	}
}
// MARK: - Webview load delegate
extension MainViewController
{
	override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!)
	{
		if sender.mainFrameURL.rangeOfString("https://leccap.engin.umich.edu/leccap/viewer") != nil
		{
			// In each viewer that we are in we need to extract the direct download URL
			let HTML = String(data : frame.dataSource?.data)
			if viewerLinks.count > 0
			{
				viewerLinks.removeLast()
				timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "fetchDownloadOfNextVideo", userInfo: nil, repeats: true)
			}
		}
		else if sender.mainFrameURL.rangeOfString("https://leccap.engin.umich.edu/") != nil
		{
			// If we are in the general leccap page then extract the viewers' URLs
			let HTML = String(data : frame.dataSource!.data)
			if HTML?.rangeOfString("<a class=\"button\" href=\"") != nil
			{
				findAllVideoPlayerLinksFromHTML(HTML!)
			}
			else { fatalError("Something went wrong in the webview delegate. Try process again.") }
		}
		else if sender.mainFrameURL.rangeOfString("https://ctools.umich.edu/portal/site/") != nil
		{
			// If we are given the ctools page extract the video player links from the HTML code.
			findAllVideoPlayerLinksFromHTML(frame.DOMDocument!.body.outerHTML)
		}
		else if sender.mainFrameURL.rangeOfString("https://weblogin.umich.edu/") != nil {}
		else if sender.mainFrameURL.rangeOfString("google") != nil { }
		else
		{
			showError("Incorrect URL!", informativeText: "The URL you pasted did not contain anything from which we can download videos. If you believe that you pasted the correct URL, you should ensure that HTML 5 player is enabled before pasting the URL.")
		}
	}
//	override func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
//	{
//		listener.use()
//	}
}