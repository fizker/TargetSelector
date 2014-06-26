//
//  TargetBridge.h
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

@import Cocoa;

@class Target;

@interface TargetBridge : NSObject
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) NSString *name;

+(TargetBridge*)newWithTarget:(Target*)target;
@end
