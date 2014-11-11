//
//  QSTintedView.h
//  StackMonitor
//
//  Created by Casey Fleser on 11/6/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kTintedViewTag	1000

IB_DESIGNABLE

@interface QSTintedView : NSView

@property (nonatomic, strong) IBInspectable NSColor		*fillColor;

@end
