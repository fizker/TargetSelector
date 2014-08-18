//
//  PipeHandlers.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 30/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation


func stringFromDict(dict:NSDictionary, #key:String) -> String? {
	let val : AnyObject? = dict[key]
	return val as? String
}

func stringFromFileHandle(file:NSFileHandle) -> String? {
	if let data = file.availableData {
		return NSString(data: data, encoding: NSUTF8StringEncoding)
	}
	return nil
}

func stringFromPipe(pipe:NSPipe) -> String? {
	return stringFromFileHandle(pipe.fileHandleForReading)
}
