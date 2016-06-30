//
//  AddApPProgressView.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 03/07/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Cocoa

class AddAppProgressView: NSView {
	@IBOutlet var progressSpinner: NSProgressIndicator!
	@IBOutlet var progressBar: NSProgressIndicator!
	@IBOutlet var makeCurrentButton: NSButton!
	@IBOutlet var doneButton: NSButton!

	func addProgress(_ progress:Progress) {
		progressBar.isIndeterminate = false;
		progressBar.maxValue = CDouble(progress.total)
		progressBar.doubleValue = CDouble(progress.completed)

		switch progress.type {
			case .start:
				makeCurrentButton.isEnabled = false
				doneButton.isEnabled = false
				progressSpinner.startAnimation(self)
			case .end:
				makeCurrentButton.isEnabled = true
				doneButton.isEnabled = true
				progressSpinner.stopAnimation(self)
			default:
				break
		}
	}
}
