//
//  Target.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

class Target : Printable {
	var name:String {
		return productDir.absoluteString.lastPathComponent
	}
	let productDir:NSURL

	init(url: NSURL) {
		productDir = url
	}

	var description:String {
		return name
	}
}

func loadTargets(projectPath:String) -> Target[] {
	let fileManager = NSFileManager.defaultManager()
	var error : NSError?

	if let contents = fileManager.contentsOfDirectoryAtURL(
		NSURL(fileURLWithPath: projectPath + "/products"),
		includingPropertiesForKeys: [NSURLIsDirectoryKey],
		options: .SkipsHiddenFiles,
		error: &error) as? NSURL[]
	{
		return contents.map({
			Target(url: $0)
		})
	}

	println("Got error: \(error?.localizedDescription)")

	return []
}
