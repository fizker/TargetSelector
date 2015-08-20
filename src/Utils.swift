//
//  PipeHandlers.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 30/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation


func stringFromDict(dict:NSDictionary, key:String) -> String? {
	let val : AnyObject? = dict[key]
	return val as? String
}

extension NSFileHandle {
	var stringContents:String? {
		guard let content = NSString(data: availableData, encoding: NSUTF8StringEncoding) as String? else { return nil }
		let trimmedContent = content.trim()
		return trimmedContent.isEmpty ? nil : trimmedContent
	}
}

extension NSPipe {
	var stringContents:String? {
		return fileHandleForReading.stringContents
	}
}
