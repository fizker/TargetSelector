//
//  Regex.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 19/08/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

protocol RegularExpressionMatchable {
	func test(_ string:String, options: RegularExpression.MatchingOptions) -> Bool
}

struct Regex : RegularExpressionMatchable {
	let pattern: String
	let options: RegularExpression.Options
	let matcher: RegularExpression?

	init(pattern:String, options:RegularExpression.Options = []) {
		self.pattern = pattern
		self.options = options
		matcher = try? RegularExpression(pattern: pattern, options: options)
	}

	func test(_ string: String, options: RegularExpression.MatchingOptions = []) -> Bool {
		let numberOfMatches = matcher?.numberOfMatches(in: string, options: options, range: NSRangeFromString(string))
		return (numberOfMatches ?? 0) != 0
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
