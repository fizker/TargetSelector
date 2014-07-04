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
