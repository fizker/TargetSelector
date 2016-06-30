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

	var generator : IndexingIterator<Array<String>>

	init(projectPath: String, appFolders: [String]) {
		self.projectPath = projectPath
		self.appFolders = appFolders

		generator = appFolders.makeIterator()
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

		let resultingUrl = URL(fileURLWithPath: "\(self.projectPath)/products/\(appStyles.target)")

		let task = Task(launchPath: projectPath + "/add-product-gfx", arguments: [appFolder, appStyles.target])
		task.currentDirectoryPath = projectPath
		task.onComplete = { self.onComplete?(Target(url: resultingUrl)) }
		task.onError = onError
		task.onProgress = {string in
			let progress = string.components(separatedBy: CharacterSet.newlines)
			for s in progress {
				self.onProgress?(Progress(json: s))
			}
		}
		task.start()
	}
}
