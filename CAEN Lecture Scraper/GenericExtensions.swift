//
//  GenericExtensions.swift
//  CAEN Lecture Scraper
//
//  Created by Manav Gabhawala on 6/3/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Foundation


extension String
{
	init?(data: NSData?)
	{
		if let data = data
		{
			if let some = NSString(data: data, encoding: NSUTF8StringEncoding)
			{
				self = some as String
				return
			}
			return nil
		}
		return nil
	}
	func textBetween(start: String, end: String) -> String?
	{
		let startIndex = self.rangeOfString(start)?.endIndex
		if (startIndex == nil)
		{
			return nil
		}
		let endIndex = self.rangeOfString(end, range: Range(start: startIndex!, end: self.endIndex))?.startIndex
		if startIndex != nil && endIndex != nil
		{
			return self.substringWithRange(Range(start: startIndex!, end: endIndex!))
		}
		return nil
	}
	mutating func safeString()
	{
		self = self.safeString()
	}
	func safeString() -> String
	{
		return self.stringByReplacingOccurrencesOfString("Lecture recorded on ", withString: "").stringByReplacingOccurrencesOfString("/", withString: "-")
	}
}

/*
let fileManager = NSFileManager.defaultManager()
if !fileManager.fileExistsAtPath(directory.absoluteString!)
{
fileManager.createDirectoryAtPath(directory.absoluteString!, withIntermediateDirectories: true, attributes: nil, error: nil)
}
*/