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

	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(aNotification: NSNotification?) {
		// Insert code here to tear down your application
	}

	var targets : TargetBridge[] {
		return loadTargets("/Users/benjamin/Development/poteo/iphone").map({
			return TargetBridge.newWithTarget($0)
		})
	}
}
