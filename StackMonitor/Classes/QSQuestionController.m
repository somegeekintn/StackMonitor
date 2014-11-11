//
//  QSQuestionController.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/7/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSQuestionController.h"
#import "QSMonitor.h"
#import "QSObjGraphMgr.h"
#import "QSQuestion.h"
#import "QSTintedView.h"


@interface QSQuestionController ()

@property (nonatomic, weak) IBOutlet NSProgressIndicator	*updatingIndicator;

@end


@implementation QSQuestionController

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"creation_date" ascending: NO]]];
//	[self setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"last_activity_date" ascending: NO]]];
	[self setFilterPredicate: [NSPredicate predicateWithFormat: @"wasHidden == NO"]];

	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleMonitorStateChange:) name: QSNotificationMonitorStateChange object: nil];
}

- (void) tableView: (NSTableView *) inTableView
	didAddRowView: (NSTableRowView *) inRowView
	forRow: (NSInteger) inRow
{
	[self updateTintForRowView: inRowView atRowIndex: inRow];
}

- (NSIndexSet *) tableView: (NSTableView *) inTableView
	selectionIndexesForProposedSelection: (NSIndexSet *) inProposedSelectionIndexes
{
	__block BOOL	didMark = NO;
	
	[inProposedSelectionIndexes enumerateIndexesUsingBlock: ^(NSUInteger inIndex, BOOL *outStop) {
		QSQuestion		*question = [self.arrangedObjects objectAtIndex: inIndex];

		if (![question.wasViewed boolValue]) {
			NSTableRowView		*rowView = [inTableView rowViewAtRow: inIndex makeIfNecessary: NO];
			
			question.wasViewed = @(YES);
			didMark = YES;
			[self updateTintForRowView: rowView atRowIndex: inIndex];
		}
	}];
	
	if (didMark) {
		[[QSObjGraphMgr sharedManager] save];
	}
	
	return inProposedSelectionIndexes;
}

- (void) updateTintForRowView: (NSTableRowView *) inRowView
	atRowIndex: (NSInteger) inRow
{
	QSTintedView	*tintedView = [inRowView viewWithTag: kTintedViewTag];
	
	if (tintedView != nil && [tintedView isKindOfClass: [QSTintedView class]]) {
		QSQuestion	*question = [self.arrangedObjects objectAtIndex: inRow];
		
		tintedView.fillColor = [question.wasViewed boolValue] ?
									[NSColor colorWithCalibratedRed: 0.9 green: 0.9 blue: 0.9 alpha: 1.0] :
									[NSColor colorWithCalibratedHue: 0.6 saturation: 0.1 brightness: 1.0 alpha: 1.0];
	}
}

- (void) handleMonitorStateChange: (NSNotification *) inNotification
{
	NSNumber	*updating = [[inNotification userInfo] objectForKey: @"state"];
	
	if ([updating boolValue]) {
		[self.updatingIndicator startAnimation: self];
	}
	else {
		[self.updatingIndicator stopAnimation: self];
	}
}

- (void) handleDoubleAction: (NSArray *) inSelectedObjects
{
	for (QSQuestion	*question in inSelectedObjects) {
		NSURL		*questionLink = [NSURL URLWithString: question.link];

		if (questionLink != nil) {
			[[NSWorkspace sharedWorkspace] openURL: questionLink];
		}
	}
}

- (IBAction) handleClearViewed: (id) inSender
{
	NSArray		*questionsToHide;
	
	questionsToHide = [self.arrangedObjects filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"wasViewed == YES && wasHidden == NO"]];
	if ([questionsToHide count]) {
		for (QSQuestion *question in questionsToHide) {
			question.wasHidden = @(YES);
		}

		[[QSObjGraphMgr sharedManager] save];
	}
}

@end
