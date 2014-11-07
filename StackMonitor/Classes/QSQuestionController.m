//
//  QSQuestionController.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/7/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSQuestionController.h"
#import "QSQuestion.h"


@interface QSQuestionController ()
@end


@implementation QSQuestionController

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"last_activity_date" ascending: NO]]];
}

- (void) handleDoubleAction: (NSArray *) inSelectedObjects
{
	QSQuestion	*question = [inSelectedObjects lastObject];
	NSURL		*questionLink = [NSURL URLWithString: question.link];

	if (questionLink != nil) {
		[[NSWorkspace sharedWorkspace] openURL: questionLink];
	}
}

@end
