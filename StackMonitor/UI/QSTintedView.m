//
//  QSTintedView.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/6/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSTintedView.h"

@implementation QSTintedView

- (void) drawRect: (NSRect) inRect
{
    [super drawRect: inRect];

	[self.fillColor set];
	NSRectFill(self.bounds);
}

- (NSInteger) tag
{
	return kTintedViewTag;
}

- (void) setFillColor: (NSColor *) inFillColor
{
	if (![_fillColor isEqual: inFillColor]) {
		_fillColor = inFillColor;
		
		[self setNeedsDisplay: YES];
	}
}

@end
