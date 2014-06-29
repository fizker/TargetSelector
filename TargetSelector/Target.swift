//
//  Target.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

@objc
class Target : Printable {
	let productDir:NSURL
	@objc
	var name:String {
		return productDir.absoluteString.lastPathComponent
	}
	@objc
	let icon: NSImage

	init(url: NSURL) {
		productDir = url

		let fileManager = NSFileManager.defaultManager()
		let primaryIconPath = productDir.URLByAppendingPathComponent("Icon120.png").path
		let secondaryIconPath = productDir.URLByAppendingPathComponent("Icon@2x.png").path
		let iconPath = fileManager.fileExistsAtPath(primaryIconPath)
			? primaryIconPath
			: secondaryIconPath

		icon = NSImage(contentsOfFile: iconPath)
	}

	var description:String {
		return name
	}
}
