//
//  Targets.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 29/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

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

	func loadTargets() -> [Target] {
		let fileManager = NSFileManager.defaultManager()
		var error : NSError?

		if let url = NSURL(fileURLWithPath: projectPath + "/products") {
			if let contents = fileManager.contentsOfDirectoryAtURL(
				url,
				includingPropertiesForKeys: [NSURLIsDirectoryKey],
				options: .SkipsHiddenFiles,
				error: &error) as? [NSURL]
			{
				return contents.map({
					Target(url: $0)
				})
			}
		}

		println("Got error: \(error?.localizedDescription)")

		return []
	}

	func getCurrentTarget() -> String {
		let fileManager = NSFileManager.defaultManager()
		var error : NSError?

		if let content = NSString(contentsOfFile: projectPath + "/Target.xcconfig", encoding: NSUTF8StringEncoding, error: &error) {
			let matches = content.match("CURRENT_TARGET_NAME *= *(.+)")
			if let firstMatch = matches.first {
				return content.substringWithRange(firstMatch.rangeAtIndex(1))
			}
		}

		return ""
	}
	func setCurrentTarget(target:String) -> String? {
		let errorPipe = NSPipe()
		let task = NSTask()
		task.launchPath = "/usr/local/bin/node"
		task.arguments = [projectPath + "/scripts/set-current-target.js", target]
		task.standardError = errorPipe
		task.launch()
		task.waitUntilExit()

		let file = errorPipe.fileHandleForReading
		let data = file.readDataToEndOfFile()
		if let contents = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
			if !contents.isEmpty {
				return contents
			}
		}

		return nil
	}
	func setCurrentTarget(target:Target) -> String? {
		return setCurrentTarget(target.name)
	}
}
