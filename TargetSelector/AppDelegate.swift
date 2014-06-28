//
//  AppDelegate.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow

	let targetsHelper = Targets(projectPath: "/Users/benjamin/Development/poteo/iphone")

	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		// Insert code here to initialize your application
		var i = 0
		let currentTarget = targetsHelper.getCurrentTarget()
		for target in targets {
			if target.name == currentTarget {
				println("Found current app: \(target.name)")
				break
			}
			i++
		}
		selectedIndexes = NSIndexSet(index: i)
	}

	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
	}

	var selectedIndexes: NSIndexSet = NSIndexSet() {
		didSet {
			let index = selectedIndexes.firstIndex
			let target = targetsHelper.loadTargets()[index]
			targetsHelper.setCurrentTarget(target)
		}
	}

	var targets : TargetBridge[] {
		return targetsHelper.loadTargets().map({
			return TargetBridge.newWithTarget($0)
		})
	}
}
