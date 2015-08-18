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
	return NSString(data: file.availableData, encoding: NSUTF8StringEncoding) as String?
}

func stringFromPipe(pipe:NSPipe) -> String? {
	return stringFromFileHandle(pipe.fileHandleForReading)
}
