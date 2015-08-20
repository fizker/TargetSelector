//
//  Task.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 20/08/15.
//  Copyright © 2015 ReturnTool ApS. All rights reserved.
//

import Foundation

class Task {
	let launchPath:String
	let arguments:[String]
	var currentDirectoryPath:String?

	var onProgress:(String->Void)?
	var onComplete:(()->Void)?
	var onError:((status:Int, String?)->Void)?

	private let task:NSTask

	init(launchPath:String, arguments:[String] = []) {
		self.launchPath = launchPath
		self.arguments = arguments

		task = NSTask()

		setupTask()
	}

	private func setupTask() {
		let errorPipe = NSPipe()
		let outputPipe = NSPipe()

		outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
			if let string = fileHandle.stringContents {
				self.onProgress?(string)
			}
		}

		task.launchPath = launchPath
		task.arguments = arguments
		task.standardError = errorPipe
		task.standardOutput = outputPipe
		if let cwd = currentDirectoryPath {
			task.currentDirectoryPath = cwd
		}

		var env = NSProcessInfo.processInfo().environment
		let path = env["PATH"] ?? ""
		env["PATH"] = path + ":/usr/local/bin"
		task.environment = env

		task.terminationHandler = { task in
			let exitCode = task.terminationStatus
			if exitCode == 0 {
				self.onComplete?()
			} else {
				self.onError?(status: Int(exitCode), errorPipe.stringContents)
			}
		}
	}

	func start() {
		task.launch()
	}

	func stop() {
		task.terminate()
	}
}
