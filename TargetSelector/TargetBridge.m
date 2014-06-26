//
//  TargetBridge.m
//  TargetSelector
//
//  Created by Benjamin Horsleben on 26/06/14.
//  Copyright (c) 2014 ReturnTool ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TargetBridge.h"
#import "TargetSelector-Swift.h"

@interface TargetBridge ()
@property (nonatomic, strong) Target* target;
@end

@implementation TargetBridge

+(TargetBridge *)newWithTarget:(Target *)target {
	TargetBridge *bridge = [TargetBridge new];
	bridge.target = target;
	return bridge;
}

-(NSString *)name {
	return self.target.name;
}

-(NSImage *)icon {
	return self.target.icon;
}

@end