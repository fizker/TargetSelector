//
//  TargetCollectionViewItem.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 28/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Cocoa

class TargetCollectionViewItem: NSCollectionViewItem {

	override var selected:Bool {
		didSet {
			if let cell = view as? TargetCollectionViewCell {
				cell.selected = selected
			}
		}
	}

}
