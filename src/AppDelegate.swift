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
	@IBOutlet var window: NSWindow!

	var targetsHelper:Targets?

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		loadTargets()
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func loadTargets() {
		if let projectPath = NSUserDefaults.standardUserDefaults().stringForKey(USER_DEFAULTS_PROJECT_PATH) {
			if Targets.isValidProjectDir(projectPath) {
				let targetsHelper = Targets(projectPath: projectPath)
				self.targetsHelper = targetsHelper

				self.currentTarget = nil
				let currentTarget = targetsHelper.getCurrentTarget()
				let targets = targetsHelper.loadTargets()
				for target in targets {
					if target.name == currentTarget {
						self.currentTarget = target
						break
					}
				}

				self.targets = targets
			}
		}

		if targetsHelper == nil {
			promptForProjectPath()
		}
	}

	@IBAction func promptForProjectPath(sender: AnyObject) {
		promptForProjectPath()
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
					let path = url!.path!

					if !Targets.isValidProjectDir(path) {
						break
					}

					NSUserDefaults.standardUserDefaults().setObject(path, forKey: USER_DEFAULTS_PROJECT_PATH)
					self.loadTargets()
				case NSCancelButton:
					break
				default:
					break
			}
		})
	}

	var lastAddedTarget: Target?
	@IBOutlet var addAppProgressSheet: NSPanel!
	@IBOutlet var addAddProgressView: AddAppProgressView!
	@IBAction func makeAddedAppCurrent(sender: AnyObject) {
		if let target = lastAddedTarget {
			changeTarget(target)
			loadTargets()
		}
		closeAddAppSheet(sender)
	}

	@IBAction func closeAddAppSheet(sender: AnyObject) {
		NSApp.endSheet(addAppProgressSheet)
		addAppProgressSheet.orderOut(sender)
	}

	@IBAction func addApp(sender: AnyObject) {
		let openPanel = NSOpenPanel()
		openPanel.prompt = "Add app"
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.allowsMultipleSelection = false
		openPanel.beginSheetModalForWindow(window, completionHandler: { buttonClicked in
			switch buttonClicked {
				case NSOKButton:
					NSApp.beginSheet(self.addAppProgressSheet, modalForWindow: self.window, modalDelegate: self, didEndSelector: nil, contextInfo: nil)
					let urls = openPanel.URLs
					let folders = urls.map { $0.path! }
					let addTasks = AddAppTasks(projectPath: self.targetsHelper!.projectPath, appFolders: folders)
					addTasks.onComplete = { newTargets in
						self.lastAddedTarget = newTargets[0]
						self.loadTargets()
					}
					addTasks.onError = { status, msg in
						print("Got error (\(status)): \(msg)")
					}
					addTasks.onProgress = self.addAddProgressView.addProgress

					addTasks.start()
				default:
					break
			}
		})
	}

	@IBOutlet var searchField: NSSearchField!
	@IBAction func setFocusToSearch(sender: AnyObject) {
		searchField.becomeFirstResponder()
	}

	@IBOutlet var collectionView: NSCollectionView!
	var selectedIndexes: NSIndexSet = NSIndexSet() {
		didSet {
			let index = selectedIndexes.firstIndex
			guard let target = targetForIndex(index) else { return }

			currentTarget = target
			changeTarget(target)

			let visibleRect = collectionView.frameForItemAtIndex(index)
			collectionView.scrollRectToVisible(visibleRect)
		}
	}

	private func targetForIndex(index:Int) -> Target? {
		guard let targets = targetsHelper?.loadTargets() else { return nil }
		let searchText = searchField.stringValue
		let filteredTargets = searchText.isEmpty
			? targets
			: targets.filter() { target in
				target.name.rangeOfString(searchText, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
			}

		if index >= filteredTargets.count || index < 0 {
			return nil
		}

		return filteredTargets[index]
	}

	func changeTarget(target:Target) {
		if let errorMessage = targetsHelper?.setCurrentTarget(target) {
			let alert = NSAlert()
			alert.alertStyle = .CriticalAlertStyle
			alert.messageText = errorMessage
			alert.runModal()
		}
	}

	dynamic var targets : [Target] = []

	@IBOutlet var currentTargetView : NSToolbarItem!
	var currentTarget : Target? {
		didSet {
			if let target = currentTarget {
				currentTargetView.image = target.icon
				currentTargetView.label = target.name
			}
		}
	}
}
