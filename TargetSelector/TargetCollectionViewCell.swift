//
//  TargetCollectionViewCell.swift
//  TargetSelector
//
//  Created by Benjamin Horsleben on 27/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

import Cocoa

class TargetCollectionViewCell: NSView {
	var selected:Bool = false {
		didSet {
			setNeedsDisplayInRect(visibleRect)
		}
	}

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
		if selected {
			NSColor.blueColor().set()
		} else {
			NSColor.clearColor().set()
		}
		NSBezierPath(rect: dirtyRect).fill()
    }
}
