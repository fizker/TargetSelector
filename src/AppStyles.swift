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
		let fileManager = FileManager.default()
		let appStylesContent = fileManager.contents(atPath: filePath)

		if let fileContent = appStylesContent {
			let appStyles = try! JSONSerialization.jsonObject(with: fileContent, options: []) as! [String:AnyObject]

			server = appStyles["server"] as! String
			name = appStyles["name"] as! String

			let context = JSContext()
			target = (context?.evaluateScript("'\(server)'.match(/https?:\\/\\/([^.]+)\\./)[1]").toString())!
		} else {
			// TODO: Add error handling
			name = "Returntool"
			server = "http://demo.returntool.com"
			target = "returntool"
		}
	}
}
