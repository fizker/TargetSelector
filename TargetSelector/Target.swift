//
//  Target.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation
import Cocoa
import JavaScriptCore

@objc
class Target : Printable {
	let productDir:NSURL
	@objc
	var name:String {
		return productDir.absoluteString.lastPathComponent
	}
	@objc
	let icon: NSImage

	init(url: NSURL) {
		productDir = url

		let fileManager = NSFileManager.defaultManager()
		let primaryIconPath = productDir.URLByAppendingPathComponent("Icon120.png").path
		let secondaryIconPath = productDir.URLByAppendingPathComponent("Icon@2x.png").path
		let iconPath = fileManager.fileExistsAtPath(primaryIconPath)
			? primaryIconPath
			: secondaryIconPath

		icon = NSImage(contentsOfFile: iconPath)
	}

	var description:String {
		return name
	}
}

class Targets {
	let projectPath: String
	init(projectPath:String) {
		self.projectPath = projectPath
	}

	class func isValidProjectDir(projectPath:String) -> Bool {
		let fileManager = NSFileManager.defaultManager()
		let requiredFiles = ["Target.xcconfig", "products", "scripts/set-current-target.js"]
		for file in requiredFiles {
			if !fileManager.fileExistsAtPath("\(projectPath)/\(file)") {
				return false
			}
		}
		return true
	}

	func loadTargets() -> Target[] {
		let fileManager = NSFileManager.defaultManager()
		var error : NSError?

		if let contents = fileManager.contentsOfDirectoryAtURL(
			NSURL(fileURLWithPath: projectPath + "/products"),
			includingPropertiesForKeys: [NSURLIsDirectoryKey],
			options: .SkipsHiddenFiles,
			error: &error) as? NSURL[]
		{
			return contents.map({
				Target(url: $0)
			})
		}

		println("Got error: \(error?.localizedDescription)")

		return []
	}

	func getCurrentTarget() -> String {
		let fileManager = NSFileManager.defaultManager()
		var error : NSError?

		if let content = String.stringWithContentsOfFile(projectPath + "/Target.xcconfig", encoding: NSUTF8StringEncoding, error: &error) {
			let context = JSContext()
			let result = context.evaluateScript("'\(content)'.match(/CURRENT_TARGET_NAME *= *(.+)/)[1]")
			return result.toString()
		}

		return ""
	}
	func setCurrentTarget(target:String) {
		let errorPipe = NSPipe()
		let task = NSTask()
		task.launchPath = "/usr/local/bin/node"
		task.arguments = [projectPath + "/scripts/set-current-target.js", target]
		task.standardError = errorPipe
		task.launch()
		task.waitUntilExit()

		let file = errorPipe.fileHandleForReading
		let data = file.readDataToEndOfFile()
		if data.length > 0 {
			let contents = NSString(data: data, encoding: NSUTF8StringEncoding)
			println("Error with running set-current-target: \(contents)")
		}
	}
	func setCurrentTarget(target:Target) {
		setCurrentTarget(target.name)
	}
}
