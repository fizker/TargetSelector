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
		let data = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
		var error : NSError?
		let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as! [String:AnyObject]

		let typeName = stringFromDict(dict, key: "type")!
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
