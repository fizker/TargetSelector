//
//  Target.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation
import AppKit

class Target : NSObject {
	let productDir:URL
	dynamic var name:String {
		return productDir.absoluteString.lastPathComponent
	}
	dynamic let icon: NSImage

	init(url: URL) {
		productDir = url

		let fileManager = FileManager.default
		let primaryIconPath = productDir.appendingPathComponent("Icon120.png").path
		let secondaryIconPath = productDir.appendingPathComponent("Icon@2x.png").path
		let iconPath = fileManager.fileExists(atPath: primaryIconPath)
			? primaryIconPath
			: secondaryIconPath

		icon = NSImage(contentsOfFile: iconPath)!
	}

	override var description:String {
		return name
	}
}
