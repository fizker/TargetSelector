//
//  Screenshots.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 19/08/15.
//  Copyright © 2015 ReturnTool ApS. All rights reserved.
//

import Foundation

class TakeScreenshotsTask {
	let target:Target
	let projectPath:String

	var onProgress:(String->Void)?
	var onComplete:(()->Void)?
	var onError:((status:Int, String?)->Void)?

	init(projectPath:String, target:Target) {
		self.projectPath = projectPath
		self.target = target
	}

	func start() {
		let errorPipe = NSPipe()
		let outputPipe = NSPipe()

		outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
			if let string = stringFromFileHandle(fileHandle)?.trim() {
				self.onProgress?(string)
			}
		}

		let task = NSTask()
		task.launchPath = "./take-screenshots"
		task.arguments = [ self.target.name ]
		task.standardError = errorPipe
		task.standardOutput = outputPipe
		task.currentDirectoryPath = projectPath

		var env = NSProcessInfo.processInfo().environment
		let path = env["PATH"] ?? ""
		env["PATH"] = path + ":/usr/local/bin"
		task.environment = env

		task.terminationHandler = { task in
			let exitCode = task.terminationStatus
			if exitCode == 0 {
				self.onComplete?()
			} else {
				self.onError?(status: Int(exitCode), stringFromPipe(errorPipe))
			}
		}
		task.launch()
	}
}
