//
//  QSQuestion.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSQuestion.h"
#import "QSObjGraphMgr.h"
#import "QSUser.h"


@implementation QSQuestion

@dynamic accepted_answer_id;
@dynamic answer_count;
@dynamic body;
@dynamic bounty_amount;
@dynamic bounty_closes_date;
@dynamic closed_date;
@dynamic closed_reason;
@dynamic community_owned_date;
@dynamic creation_date;
@dynamic is_answered;
@dynamic last_activity_date;
@dynamic last_edit_date;
@dynamic link;
@dynamic locked_date;
@dynamic protected_date;
@dynamic question_id;
@dynamic score;
@dynamic tags;
@dynamic title;
@dynamic view_count;
@dynamic owner;

+ (NSArray *) skippedRawAttributeNames
{
	static NSArray	*sSkippedNames = nil;
	
	if (sSkippedNames == nil) {
		sSkippedNames = @[ @"question_id", @"owner", @"tags", @"title", @"body" ];
	}
	
	return sSkippedNames;
}

+ (QSQuestion *) updateQuestionWithRawInfo: (NSDictionary *) inRawInfo
{
	NSManagedObjectContext	*context = [QSObjGraphMgr sharedManager].managedObjectContext;
	
	return [QSQuestion updateQuestionWithRawInfo: inRawInfo inManagedObjectContext: context];
}

+ (QSQuestion *) updateQuestionWithRawInfo: (NSDictionary *) inRawInfo
	inManagedObjectContext: (NSManagedObjectContext *) inContext
{
	QSQuestion		*question = nil;
	NSNumber		*questionID = inRawInfo[@"question_id"];
	
	if (questionID != nil) {
		question = [QSQuestion questionWithID: questionID inManagedObjectContext: inContext];
		[question updateWithRawInfo: inRawInfo];
	}
	
	return question;
}

+ (QSQuestion *) questionWithID: (NSNumber *) inQuestionID
	inManagedObjectContext: (NSManagedObjectContext *) inContext
{
	QSQuestion		*question = nil;
	NSFetchRequest	*request = [NSFetchRequest fetchRequestWithEntityName: @"Question"];
	
	request.predicate = [NSPredicate predicateWithFormat: @"question_id == %@", inQuestionID];
	question = [[inContext executeFetchRequest: request error: nil] lastObject];
	if (question == nil) {
		question = [NSEntityDescription insertNewObjectForEntityForName: @"Question" inManagedObjectContext: inContext];
		question.question_id = inQuestionID;
	}
	
	return question;
}

- (NSString *) stripHTMLString: (NSString *) inHTMLString
{
	// this is probably the least efficient way to do this, but convenient for the time being
	NSString		*strippedString = inHTMLString;
	
	if (inHTMLString != nil) {
		NSData				*stringData = [inHTMLString dataUsingEncoding: NSUTF8StringEncoding];
		NSAttributedString	*attrString = [[NSAttributedString alloc] initWithHTML: stringData documentAttributes: nil];
		
		strippedString = [attrString string];
	}
	
	return strippedString;
}

- (void) updateWithRawInfo: (NSDictionary *) inRawInfo
{
	NSDictionary	*ownerInfo = inRawInfo[@"owner"];
	NSArray			*tags = inRawInfo[@"tags"];
	
	if (self.owner == nil) {
		self.owner = [QSUser userFromRawInfo: ownerInfo inManagedObjectContext: self.managedObjectContext];
	}
	
	self.tags = [tags componentsJoinedByString: @","];
	self.title = [self stripHTMLString: inRawInfo[@"title"]];
	self.body = [self stripHTMLString: inRawInfo[@"body"]];
	[self.owner updateWithRawInfo: ownerInfo];
	
	for (NSPropertyDescription *property in self.entity) {
		if ([property isKindOfClass: [NSAttributeDescription class]]) {
			NSAttributeDescription	*attrDesc = (NSAttributeDescription *)property;
			NSString				*attrName = attrDesc.name;
			
			if (![[QSQuestion skippedRawAttributeNames] containsObject: attrName]) {
				id		value = inRawInfo[attrName];
				
				if (value != nil) {
					if (attrDesc.attributeType == NSDateAttributeType) {
						value = [NSDate dateWithTimeIntervalSince1970: [value doubleValue]];
					}
				
					[self setValue: value forKey: attrName];
				}
			}
		}
	}
}

@end
