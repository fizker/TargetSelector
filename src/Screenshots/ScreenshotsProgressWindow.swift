//
//  ScreenshotsProgressWindow.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 20/08/15.
//  Copyright © 2015 ReturnTool ApS. All rights reserved.
//

import Foundation
import AppKit

class ScreenshotsProgressWindow : NSWindow {
	typealias OnClose = ()->Void
	var onClose:OnClose?
	@IBOutlet weak var spinner: NSProgressIndicator!
	@IBOutlet weak var targetPlaceholder: NSTextField!
	@IBOutlet weak var progressField: NSTextField!
	@IBOutlet weak var killButton: NSButton!
	@IBOutlet weak var hideButton: NSButton!

	private var task:TakeScreenshotsTask?

	func prepareForTarget(_ target:Target, projectPath:String, onClose:OnClose) {
		self.onClose = onClose

		progressField.stringValue = ""
		targetPlaceholder.stringValue = target.name
		spinner.isHidden = false
		spinner.startAnimation(nil)
		killButton.isEnabled = true
		hideButton.isEnabled = false

		let screenshotTask = TakeScreenshotsTask(projectPath: projectPath, target: target)
		screenshotTask.onError = { status, message in
			self.taskStopped()
			self.updateProgress("Screenshots exited with code \(status)")
			if let message = message {
				self.updateProgress("Message was \(message)")
			}
		}
		screenshotTask.onProgress = { message in
			self.updateProgress(message)
		}
		screenshotTask.onComplete = {
			self.taskStopped()
		}
		screenshotTask.start()
		task = screenshotTask
	}

	func updateProgress(_ message:String) {
		progressField.stringValue = progressField.stringValue + "\n" + message
	}

	@IBAction func killTask(_ sender: AnyObject) {
		task?.stop()
	}

	@IBAction func closeWindow(_ sender: AnyObject) {
		onClose?()
		onClose = nil
	}

	func taskStopped() {
		spinner.stopAnimation(nil)
		spinner.isHidden = true
		hideButton.isEnabled = true
		killButton.isEnabled = false
	}
}
