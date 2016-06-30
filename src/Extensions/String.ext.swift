//
//  String.ext.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 01/07/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

extension String {
	var lastPathComponent:String {
		return (self as NSString).lastPathComponent
	}
}

extension String {
	var nsrange:NSRange {
		return NSRange(location: 0, length: utf16.count)
	}
}

extension NSString {
	var nsrange:NSRange {
		return NSRange(location: 0, length: length)
	}
}

extension String {
	var trimmed: String {
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}

extension String {
	func match(_ regex: RegularExpression, options: RegularExpression.MatchingOptions = []) -> [TextCheckingResult] {
		let matches = regex.matches(in: self, options: options, range: nsrange)
		return matches
	}
}

extension NSString {
	func match(_ regex: Regex, options: RegularExpression.MatchingOptions = []) -> [TextCheckingResult] {
		return regex.matcher.map { self.match($0, options: options) } ?? []
	}

	func match(_ regex: RegularExpression, options: RegularExpression.MatchingOptions = []) -> [TextCheckingResult] {
		return (self as String).match(regex, options: options)
	}
}
