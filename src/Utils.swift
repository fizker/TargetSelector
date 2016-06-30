//
//  PipeHandlers.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 30/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation


extension FileHandle {
	var stringContents:String? {
		guard let content = String(data: availableData, encoding: .utf8)
		else { return nil }
		let trimmedContent = content.trimmed
		return trimmedContent.isEmpty ? nil : trimmedContent
	}
}

extension Pipe {
	var stringContents:String? {
		return fileHandleForReading.stringContents
	}
}
