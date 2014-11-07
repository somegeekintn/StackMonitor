//
//  QSQuestionRowView.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/7/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSQuestionRowView.h"

@implementation QSQuestionRowView

- (void) drawSelectionInRect: (NSRect) inDirtyRect
{
	if (self.selected) {
		NSRect			bounds = self.bounds;
		const NSRect	*rects = NULL;
		NSInteger		count = 0;

		[[NSColor colorWithCalibratedRed: 0.9 green: 0.9 blue: 0.9 alpha: 1.0] set];
		[self getRectsBeingDrawn: &rects count: &count];
		for (NSInteger i = 0; i < count; i++) {
			NSRectFillUsingOperation(NSIntersectionRect(bounds, rects[i]), NSCompositeSourceOver);
		}
		
//		NSGradient		*gradient = [[NSGradient alloc] initWithColors: @[
//										[NSColor colorWithCalibratedRed: 0.95 green: 0.95 blue: 0.95 alpha: 1.0],
//										[NSColor colorWithCalibratedRed: 0.85 green: 0.85 blue: 0.85 alpha: 1.0]]];
//		
//		[gradient drawInRect: self.bounds angle: 90.0];
	}
}

- (void) drawSeparatorInRect: (NSRect) inDirtyRect
{
	NSRect		sepRect, remainder;

	CGRectDivide(self.bounds, &sepRect, &remainder, 1.0, CGRectMaxYEdge);
	sepRect = NSIntersectionRect(sepRect, inDirtyRect);
	if (!NSIsEmptyRect(sepRect)) {
		[[NSColor colorWithCalibratedRed: 0.7 green: 0.7 blue: 0.7 alpha: 1.0] set];
		NSRectFill(sepRect);
	}
}

- (NSBackgroundStyle) interiorBackgroundStyle
{
	return NSBackgroundStyleLight;
}

@end
