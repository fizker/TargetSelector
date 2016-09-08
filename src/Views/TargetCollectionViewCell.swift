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
			setNeedsDisplay(visibleRect)
		}
	}

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
		if selected {
			NSColor.blue.set()
		} else {
			NSColor.clear.set()
		}
		NSBezierPath(rect: dirtyRect).fill()
    }
}
