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
	let server:String = "http://demo.returntool.com"
	let name:String = "Returntool"
	let target:String = "returntool"

	init(filePath:String) {
		let fileManager = NSFileManager.defaultManager()
		let appStylesContent = fileManager.contentsAtPath(filePath)
		var error : NSError?
		if let fileContent = appStylesContent {
			let appStyles = NSJSONSerialization.JSONObjectWithData(fileContent, options: nil, error: &error) as [String:AnyObject]

			server = stringFromDict(appStyles, key: "server")!
			name = stringFromDict(appStyles, key: "name")!

			let context = JSContext()
			target = context.evaluateScript("'\(server)'.match(/https?:\\/\\/([^.]+)\\./)[1]").toString()
		}
		// TODO: Add error handling
	}
}
