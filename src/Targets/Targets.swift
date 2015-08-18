//
//  Targets.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 29/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

enum TargetError : ErrorType {
	case CouldNotSetTarget(String)
	case CouldNotLoadTarget
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

	func loadTargets() throws -> [Target] {
		let fileManager = NSFileManager.defaultManager()

		let url = NSURL(fileURLWithPath: projectPath + "/products")
		let contents = try fileManager.contentsOfDirectoryAtURL(
			url,
			includingPropertiesForKeys: [NSURLIsDirectoryKey],
			options: .SkipsHiddenFiles
		)

		return contents
			.filter {
				do {
					let values = try $0.resourceValuesForKeys([NSURLIsDirectoryKey])
					return values[NSURLIsDirectoryKey] as? Bool ?? false
				} catch {
					return false
				}
			}
			.map { Target(url: $0) }
	}

	func getCurrentTarget() throws -> String {
		let content = try NSString(contentsOfFile: projectPath + "/Target.xcconfig", encoding: NSUTF8StringEncoding)
		let matches = content.match("CURRENT_TARGET_NAME *= *(.+)")
		guard let firstMatch = matches.first else { throw TargetError.CouldNotLoadTarget }

		return content.substringWithRange(firstMatch.rangeAtIndex(1))
	}
	func setCurrentTarget(target:String) throws {
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
				throw TargetError.CouldNotSetTarget(contents)
			}
		}
	}
	func setCurrentTarget(target:Target) throws {
		return try setCurrentTarget(target.name)
	}
}
