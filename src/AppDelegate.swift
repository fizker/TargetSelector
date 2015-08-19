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
		try! loadTargets()
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func loadTargets() throws {
		if let projectPath = NSUserDefaults.standardUserDefaults().stringForKey(USER_DEFAULTS_PROJECT_PATH) {
			if Targets.isValidProjectDir(projectPath) {
				let targetsHelper = Targets(projectPath: projectPath)
				self.targetsHelper = targetsHelper

				self.currentTarget = nil
				let currentTarget = try targetsHelper.getCurrentTarget()
				let targets = try targetsHelper.loadTargets()
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
					try! self.loadTargets()
				case NSCancelButton:
					break
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
	var selectedIndexes: NSIndexSet = NSIndexSet()

	private func targetForIndex(index:Int) -> Target? {
		do {
			let targets = try targetsHelper!.loadTargets()
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
		} catch {
			print("Failed to find index:\n\(error)")
			return nil
		}
	}

	dynamic var targets : [Target] = []

	@IBOutlet var currentTargetView : NSToolbarItem!
	@IBAction func changeTarget(sender: AnyObject) {
		let index = selectedIndexes.firstIndex
		guard selectedIndexes.count == 1 && index != NSNotFound else {
			let alert = NSAlert()
			alert.alertStyle = .InformationalAlertStyle
			alert.messageText = NSLocalizedString("Single selection required",
				tableName: "ErrorMessages",
				comment: "Title for the only-select-one alert"
			)
			alert.informativeText = NSLocalizedString(
				"Please select a single item before attempting to change the " +
				"current target",
				tableName: "ErrorMessages",
				comment: "Body text for the selection-required alert"
			)
			alert.runModal()
			return
		}

		let target = targetForIndex(index)!
		try! targetsHelper!.setCurrentTarget(target)
		currentTarget = target
	}

	var currentTarget : Target? {
		didSet {
			if let target = currentTarget {
				currentTargetView.image = target.icon
				currentTargetView.label = target.name
			}
		}
	}

	@IBAction func takeScreenshots(sender: AnyObject) {
		guard selectedIndexes.count > 0 else {
			let alert = NSAlert()
			alert.alertStyle = .InformationalAlertStyle
			alert.messageText = NSLocalizedString("Selection required",
				tableName: "Screenshots",
				comment: "Title for the selection-required-for-screenshots alert"
			)
			alert.informativeText = NSLocalizedString(
				"Please select the items for which to take screenshots",
				tableName: "Screenshots",
				comment: "Body text for the selection-required-for-screenshots alert"
			)
			alert.runModal()
			return
		}

		print("Take screenshots")
	}
}
