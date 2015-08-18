//
//  String.ext.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 01/07/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

extension String {
	var nsrange:NSRange {
		return NSRange(location: 0, length: count(utf16))
	}
}

extension NSString {
	var nsrange:NSRange {
		return NSRange(location: 0, length: length)
	}
}

extension String {
	func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
}

extension String {
	func match(regex: NSRegularExpression, options: NSMatchingOptions = nil) -> [NSTextCheckingResult] {
		let matches = regex.matchesInString(self, options: options, range: nsrange)
		return matches as? [NSTextCheckingResult] ?? []
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
		return (self as String).match(regex, options: options)
	}
}
