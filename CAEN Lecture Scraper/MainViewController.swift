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
let baseURL = "https://leccap.engin.umich.edu"
typealias VideoData = (filePath: NSURL, URL: NSURL)

class MainViewController: NSViewController
{
	
	@IBOutlet var webView : WebView!
	@IBOutlet var instructionsLabel: NSTextField!
	@IBOutlet var URLInputter : NSTextField!
	
	var viewerLinks = [NSURL]() // Stores the viewer links.
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
				directory = dialog.URLs.first! as NSURL
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
		if (HTML.rangeOfString("new-viewer-popup-inner") != nil)
		{
			// Using the old player, redirect to the new player's main URL
			guard let rangeIndex = HTML.rangeOfString("Try it out!")
			else
			{
				showError("Unable to Automatically Convert to HTML 5 Player", informativeText: "In earlier versions we required you to use only the HTML 5 Player to be able to download the videos. However, we have added the feature to switch to the new player automatically without any work on your part. Unfortunately, we we were unable to convert the old player that you provided into the HTML 5 Player so  you will have to do it manually and paste the new URL here.")
				return
			}
			var index = rangeIndex.startIndex
			while (HTML.characters[index] != "\"")
			{
				index = index.predecessor()
			}
			let endIndex = index
			index = index.predecessor()
			while (HTML.characters[index] != "\"")
			{
				index = index.predecessor()
			}
			
			let redirectURL = baseURL + HTML.substringWithRange(Range<String.Index>(start: index, end: endIndex))
			
			webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: redirectURL)!))
			return
		}
		
		// Extract the viewer links from the HTML provided.
		var links = [String]()
		for item in HTML.componentsSeparatedByString("<a class=\"btn btn-primary btn-small\" href=\"")
		{
			var link = baseURL // We need to append the base URL here.
			for char in item.characters
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
		print(viewerLinks)
		if self.viewerLinks.count > 1
		{
			webView.removeFromSuperview() // Remove the webview so that the user doesn't have to see the constant redirection.
			// Go to the last viewer link so that we can extract it's direct download link.
			redirectToURL(self.viewerLinks.last!)
		}
		
	}
	// Redirects the frame to the required URL.
	func redirectToURL(URL: NSURL)
	{
		webView.mainFrame.loadRequest(NSURLRequest(URL: URL))
	}
	
	// Get's the direct download URL for the currently loaded frame on the webview
	func fetchDownloadOfNextVideo()
	{
		print("Downloading...")
		if webView.mainFrameDocument.body.outerHTML.rangeOfString("<video autoplay=") != nil
		{
			timer.invalidate()
			findVideoURLInHTML(webView.mainFrameDocument.body.outerHTML)
			if viewerLinks.count > 0
			{
				redirectToURL(viewerLinks.last!)
			}
			else
			{
				webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: "https://google.com")!))
				NSNotificationCenter.defaultCenter().postNotificationName(finishedAcquiringLinksNotification, object: nil)
				print("\n\n\n\n\n")
			}
		}
	}
	
	// Helper that actually extracts the download URL and appends it to an ivar.
	func findVideoURLInHTML(HTML: String)
	{
		if let item = HTML.componentsSeparatedByString("<video autoplay=\"autoplay\" x-webkit-airplay=\"allow\" src=\"//").last
		{
			var link = "https://"
			for char in item.characters
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
extension MainViewController : WebFrameLoadDelegate
{
	func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!)
	{
		if sender.mainFrameURL.rangeOfString("\(baseURL)/leccap/viewer") != nil
		{
			// In each viewer that we are in we need to extract the direct download URL
			if viewerLinks.count > 0
			{
				viewerLinks.removeLast()
				timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "fetchDownloadOfNextVideo", userInfo: nil, repeats: true)
			}
		}
		else if sender.mainFrameURL.rangeOfString(baseURL) != nil
		{
			let components = sender.mainFrameURL.componentsSeparatedByString("?")
			if components.count > 1
			{
				if components[1].rangeOfString("mode=flash") != nil
				{
					let URL = NSURL(string: "\(components[0])?lti=1")!
					frame.loadRequest(NSURLRequest(URL: URL))
					return
				}
			}
			// If we are in the general leccap page then extract the viewers' URLs
			let HTML = String(data : frame.dataSource!.data)
			if HTML?.rangeOfString("<a class=\"button\" href=\"") != nil
			{
				findAllVideoPlayerLinksFromHTML(HTML!)
			}
			else { return }
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
}