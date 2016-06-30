//
//  Progress.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 03/07/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Foundation

enum ProgressType {
	case end, start, update
}

class Progress {
	let type: ProgressType
	let total:Int
	let completed:Int
	init(json:String) {
		let data = json.data(using: String.Encoding.utf8, allowLossyConversion: false)!
		let dict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]

		let typeName = dict["type"] as! String
		switch typeName {
			case "update":
				type = .update
			case "end":
				type = .end
			default:
				type = .start
		}

		total = dict["total"] as? Int ?? 0
		completed = dict["completed"] as? Int ?? 0
	}
}
