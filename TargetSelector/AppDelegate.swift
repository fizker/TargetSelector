//
//  AppDelegate.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Cocoa

let USER_DEFAULTS_PROJECT_PATH = "projectPath"

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow

	var targetsHelper:Targets?

	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		loadTargets()
	}

	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
	}

	func loadTargets() {
		if let projectPath = NSUserDefaults.standardUserDefaults().stringForKey(USER_DEFAULTS_PROJECT_PATH) {
			if Targets.isValidProjectDir(projectPath) {
				targetsHelper = Targets(projectPath: projectPath)
			}
		}

		if let targetsHelper = self.targetsHelper {
			var i = 0
			let currentTarget = targetsHelper.getCurrentTarget()
			for target in targetsHelper.loadTargets() {
				if target.name == currentTarget {
					println("Found current app: \(target.name)")
					break
				}
				i++
			}
			selectedIndexes = NSIndexSet(index: i)
			willChangeValueForKey("targets")
			didChangeValueForKey("targets")
		} else {
			promptForProjectPath()
		}
	}

	func promptForProjectPath() {
		let openPanel = NSOpenPanel()
		openPanel.prompt = "Select ReturnTool project folder"
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.beginSheetModalForWindow(window, completionHandler: { buttonClicked in
			switch buttonClicked {
				case NSOKButton:
					let url = openPanel.URL
					let path = url.path

					if !Targets.isValidProjectDir(path) {
						fallthrough
					}

					NSUserDefaults.standardUserDefaults().setObject(url.path, forKey: USER_DEFAULTS_PROJECT_PATH)
					self.loadTargets()
				case NSCancelButton:
					fallthrough
				default:
					self.promptForProjectPath()
			}
		})
	}

	var selectedIndexes: NSIndexSet = NSIndexSet() {
		didSet {
			let index = selectedIndexes.firstIndex
			if let targets = targetsHelper?.loadTargets() {
				if index >= targets.count {
					return
				}
				let target = targets[index]
				targetsHelper?.setCurrentTarget(target)
			}
		}
	}

	var targets : TargetBridge[] {
		if let targetsHelper = self.targetsHelper {
			return targetsHelper.loadTargets().map({
				return TargetBridge.newWithTarget($0)
			})
		} else {
			return []
		}
	}
}
