//
//  Screenshots.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 19/08/15.
//  Copyright © 2015 ReturnTool ApS. All rights reserved.
//

import Foundation

class TakeScreenshotsTask : Task {
	let target:Target
	let projectPath:String

	init(projectPath:String, target:Target) {
		self.projectPath = projectPath
		self.target = target
		super.init(launchPath: projectPath + "/take-screenshots", arguments: [ target.name ])

		currentDirectoryPath = projectPath
	}
}
