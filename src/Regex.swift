//
//  Regex.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 19/08/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

protocol RegularExpressionMatchable {
	func test(string:String, options: NSMatchingOptions) -> Bool
}

struct Regex : RegularExpressionMatchable {
	let pattern: String
	let options: NSRegularExpressionOptions

	var matcher: NSRegularExpression? {
		do {
			return try NSRegularExpression(pattern: pattern, options: options)
		} catch _ {
			return nil
		}
	}

	init(pattern:String, options:NSRegularExpressionOptions = []) {
		self.pattern = pattern
		self.options = options
	}

	func test(string: String, options: NSMatchingOptions = []) -> Bool {
		guard let matcher = matcher else { return false }
		return matcher.numberOfMatchesInString(string, options: options, range: NSRangeFromString(string)) != 0
	}
}

extension Regex : StringLiteralConvertible {
	init(unicodeScalarLiteral value: UnicodeScalarType) {
		self.init(pattern: value)
	}

	init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
		self.init(pattern: value)
	}

	init(stringLiteral value: StringLiteralType) {
		self.init(pattern: value)
	}
}

infix operator =~ { associativity left precedence 130 }

func =~<T:RegularExpressionMatchable> (left:T, right: String) -> Bool {
	return left.test(right, options: [])
}
