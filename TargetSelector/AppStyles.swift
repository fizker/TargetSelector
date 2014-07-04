//
//  AppStyles.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 28/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation
import JavaScriptCore

class AppStyles {
	let server:String
	let name:String
	let target:String

	init(filePath:String) {
		let fileManager = NSFileManager.defaultManager()
		let appStylesContent = fileManager.contentsAtPath(filePath)
		var error : NSError?
		let appStyles = NSJSONSerialization.JSONObjectWithData(appStylesContent, options: nil, error: &error) as Dictionary<String, AnyObject>

		server = stringFromDict(appStyles, key: "server")!
		name = stringFromDict(appStyles, key: "name")!

		let context = JSContext()
		target = context.evaluateScript("'\(server)'.match(/https?:\\/\\/([^.]+)\\./)[1]").toString()
	}

}
