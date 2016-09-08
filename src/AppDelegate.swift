//
//  AppDelegate.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Cocoa

let USER_DEFAULTS_PROJECT_PATH = "projectPath"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!

	var targetsHelper:Targets?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		do {
			try loadTargets()
		} catch {
			reportUnknownError(error)
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	var projectPath:String? {
		return UserDefaults.standard.string(forKey: USER_DEFAULTS_PROJECT_PATH)
	}

	func loadTargets() throws {
		if let projectPath = projectPath {
			if Targets.isValidProjectDir(projectPath) {
				let targetsHelper = Targets(projectPath: projectPath)
				self.targetsHelper = targetsHelper

				self.currentTarget = nil
				let currentTarget = targetsHelper.getCurrentTarget()
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

	@IBAction func promptForProjectPath(_ sender: AnyObject) {
		promptForProjectPath()
	}

	func promptForProjectPath() {
		let openPanel = NSOpenPanel()
		openPanel.prompt = "Select ReturnTool project folder"
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.beginSheetModal(for: window, completionHandler: { buttonClicked in
			switch buttonClicked {
				case NSOKButton:
					let url = openPanel.url
					let path = url!.path

					if !Targets.isValidProjectDir(path) {
						break
					}

					UserDefaults.standard.set(path, forKey: USER_DEFAULTS_PROJECT_PATH)
					try! self.loadTargets()
				case NSCancelButton:
					break
				default:
					break
			}
		})
	}

	@IBOutlet var searchField: NSSearchField!
	@IBAction func setFocusToSearch(_ sender: AnyObject) {
		searchField.becomeFirstResponder()
	}

	@IBOutlet var collectionView: NSCollectionView!
	var selectedIndexes: IndexSet = IndexSet()

	private func targetForIndex(_ index:Int) -> Target? {
		do {
			let targets = try targetsHelper!.loadTargets()
			let searchText = searchField.stringValue
			let filteredTargets = searchText.isEmpty
				? targets
				: targets.filter() { target in
					target.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
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
	@IBAction func changeTarget(_ sender: AnyObject) {
		let index = selectedIndexes.first
		guard selectedIndexes.count == 1 && index != NSNotFound else {
			let alert = NSAlert()
			alert.alertStyle = .informational
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

		let target = targetForIndex(index!)!
		do {
			try targetsHelper!.setCurrentTarget(target)
			currentTarget = target
		} catch let error as TargetError {
			switch error {
			case .couldNotSetTarget(let reason):
				let alert = NSAlert()
				alert.alertStyle = .critical
				alert.messageText = NSLocalizedString(
					"Could not change target",
					tableName: "ErrorMessages",
					comment: "Title for the TargetError.couldNotSetTarget case"
				)
				alert.informativeText = reason
				alert.runModal()
				break
			}
		} catch {
			reportUnknownError(error)
		}
	}

	var currentTarget : Target? {
		didSet {
			if let target = currentTarget {
				currentTargetView.image = target.icon
				currentTargetView.label = target.name
			}
		}
	}

	@IBOutlet weak var screenshotProgressWindow: ScreenshotsProgressWindow!
	@IBAction func takeScreenshots(_ sender: AnyObject) {
		guard selectedIndexes.count > 0 else {
			let alert = NSAlert()
			alert.alertStyle = .informational
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

		let target = targetForIndex(selectedIndexes.first!)!

		screenshotProgressWindow.prepareForTarget(target, projectPath: projectPath!) {
			self.window.endSheet(self.screenshotProgressWindow)
		}

		window.beginSheet(screenshotProgressWindow, completionHandler: nil)

		/*
		let selectFolderPanel = NSOpenPanel()
		selectFolderPanel.message = NSLocalizedString("Choose location for putting screenshots",
			tableName: "Screenshots",
			comment: "Panel title for select-output dialog"
		)
		selectFolderPanel.prompt = NSLocalizedString("Choose",
			tableName: "Screenshots",
			comment: "Button title for select-output dialog"
		)
		selectFolderPanel.canChooseDirectories = true
		selectFolderPanel.canCreateDirectories = true
		selectFolderPanel.canChooseFiles = false
		selectFolderPanel.allowsMultipleSelection = false
		selectFolderPanel.beginSheetModalForWindow(window) { buttonClicked in
			switch buttonClicked {
			case NSOKButton:
				print(selectFolderPanel.URL.map { $0.absoluteString })
			default: break
			}
		}
		*/
	}

	private func reportUnknownError(_ error:Error) {
		let alert = NSAlert()
		alert.alertStyle = .critical
		alert.messageText = NSLocalizedString(
			"Unknown error",
			tableName: "ErrorMessages",
			comment: "Title for an unknown error"
		)
		alert.informativeText = error.localizedDescription
		alert.runModal()
	}
}
