//
//  String.ext.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 01/07/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

extension String {
	func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
}

extension NSString {
	func match(regex: Regex, options: NSMatchingOptions = nil) -> [NSTextCheckingResult] {
		if regex.matcher == nil {
			return []
		}
		return match(regex.matcher!, options: options)
	}

	func match(regex: NSRegularExpression, options: NSMatchingOptions = nil) -> [NSTextCheckingResult] {
		let matches = regex.matchesInString(self, options: options, range: NSMakeRange(0, self.length))
		return matches as? [NSTextCheckingResult] ?? []
	}
}
