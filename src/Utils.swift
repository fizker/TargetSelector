//
//  PipeHandlers.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 30/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation


func stringFromDict(_ dict:NSDictionary, key:String) -> String? {
	let val : AnyObject? = dict[key]
	return val as? String
}

extension FileHandle {
	var stringContents:String? {
		guard let content = NSString(data: availableData, encoding: String.Encoding.utf8.rawValue) as String? else { return nil }
		let trimmedContent = content.trim()
		return trimmedContent.isEmpty ? nil : trimmedContent
	}
}

extension Pipe {
	var stringContents:String? {
		return fileHandleForReading.stringContents
	}
}
