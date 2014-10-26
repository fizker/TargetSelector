//
//  Target.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation
import AppKit

class Target : NSObject, Printable {
	let productDir:NSURL
	dynamic var name:String {
		return productDir.absoluteString!.lastPathComponent
	}
	dynamic let icon: NSImage

	init(url: NSURL) {
		productDir = url

		let fileManager = NSFileManager.defaultManager()
		let primaryIconPath = productDir.URLByAppendingPathComponent("Icon120.png").path!
		let secondaryIconPath = productDir.URLByAppendingPathComponent("Icon@2x.png").path!
		let iconPath = fileManager.fileExistsAtPath(primaryIconPath)
			? primaryIconPath
			: secondaryIconPath

		icon = NSImage(contentsOfFile: iconPath)!
	}

	override var description:String {
		return name
	}
}
