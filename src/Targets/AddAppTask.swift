//
//  AddAppTask.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 29/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

class AddAppTasks {
	var onProgress : ((Progress)->())?
	var onComplete : (([Target])->())?
	var onError : ((status: Int, String?)->())?

	let projectPath : String
	let appFolders : [String]

	var generator : IndexingGenerator<Array<String>>

	init(projectPath: String, appFolders: [String]) {
		self.projectPath = projectPath
		self.appFolders = appFolders

		generator = appFolders.generate()
	}

	var targets: [Target] = []

	func start() {
		if let next = generator.next() {
			let task = AddAppTask(projectPath: projectPath, appFolder: next)
			//onProgress?("Starting on \(next)")
			task.onProgress = onProgress
			task.onError = onError
			task.onComplete = { target in
				self.targets.append(target)
				self.start()
			}
			task.start()
		} else {
			onComplete?(targets)
		}
	}
}

class AddAppTask {
	var onProgress : ((Progress)->())?
	var onComplete : ((Target)->())?
	var onError : ((status: Int, String?)->())?

	let projectPath : String
	let appFolder : String

	init(projectPath: String, appFolder: String) {
		self.projectPath = projectPath
		self.appFolder = appFolder
	}

	func start() {
		print("TODO: Test if the folder contains proper files before blindly continuing.")
		let appStyles = AppStyles(filePath: appFolder + "/AppStyles.json")

		let errorPipe = NSPipe()
		let outputPipe = NSPipe()

		outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
			let string = stringFromFileHandle(fileHandle)?.trim()
			let progress = string?.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
			if let progress = progress {
				for s in progress {
					self.onProgress?(Progress(json: s))
				}
			}
		}

		let resultingUrl = NSURL(fileURLWithPath: "\(self.projectPath)/products/\(appStyles.target)")

		let task = NSTask()
		task.launchPath = projectPath + "/add-product-gfx"
		task.arguments = [appFolder, appStyles.target]
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
				self.onComplete?(Target(url: resultingUrl))
			} else {
				self.onError?(status: Int(exitCode), stringFromPipe(errorPipe))
			}
		}
		task.launch()
	}
}
