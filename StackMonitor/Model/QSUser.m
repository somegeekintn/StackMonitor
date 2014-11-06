//
//  QSUser.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSUser.h"
#import "QSObjGraphMgr.h"
#import "QSQuestion.h"


@implementation QSUser

@dynamic accept_rate;
@dynamic display_name;
@dynamic link;
@dynamic profile_image;
@dynamic reputation;
@dynamic thumbnail;
@dynamic user_id;
@dynamic user_type;
@dynamic questions;

+ (NSArray *) skippedRawAttributeNames
{
	static NSArray	*sSkippedNames = nil;
	
	if (sSkippedNames == nil) {
		sSkippedNames = @[ @"user_id", @"thumbnail"];
	}
	
	return sSkippedNames;
}

+ (QSUser *) userFromRawInfo: (NSDictionary *) inRawInfo
	inManagedObjectContext: (NSManagedObjectContext *) inContext
{
	QSUser			*user = nil;
	NSNumber		*userID = inRawInfo[@"user_id"];
	
	if (userID != nil) {
		user = [QSUser userWithID: userID inManagedObjectContext: inContext];
	}
	
	return user;
}

+ (QSUser *) userWithID: (NSNumber *) inUserID
	inManagedObjectContext: (NSManagedObjectContext *) inContext
{
	QSUser			*user = nil;
	NSFetchRequest	*request = [NSFetchRequest fetchRequestWithEntityName: @"User"];
	
	request.predicate = [NSPredicate predicateWithFormat: @"user_id == %@", inUserID];
	user = [[inContext executeFetchRequest: request error: nil] lastObject];
	if (user == nil) {
		user = [NSEntityDescription insertNewObjectForEntityForName: @"User" inManagedObjectContext: inContext];
		user.user_id = inUserID;
	}
	
	return user;
}

- (void) updateWithRawInfo: (NSDictionary *) inRawInfo
{
	for (NSPropertyDescription *property in self.entity) {
		if ([property isKindOfClass: [NSAttributeDescription class]]) {
			NSAttributeDescription	*attrDesc = (NSAttributeDescription *)property;
			NSString				*attrName = attrDesc.name;
			
			if (![[QSUser skippedRawAttributeNames] containsObject: attrName]) {
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

- (void) fetchThumbnail
{
	NSURL	*thumbnailURL = [NSURL URLWithString: self.profile_image];
	
	if (thumbnailURL != nil) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSImage		*thumbnailImage = [[NSImage alloc] initWithContentsOfURL: thumbnailURL];

			if (thumbnailImage != nil) {
				[self.managedObjectContext performBlock:^{
					self.thumbnail = thumbnailImage;
				}];
			}
		});
	}
}

#pragma mark - Setters / Getters

- (id) thumbnail
{
	id	thumbnailImage;

	[self willAccessValueForKey: @"thumbnail"];
	thumbnailImage = [self primitiveValueForKey: @"thumbnail"];
	[self didAccessValueForKey: @"thumbnail"];
	
	if (thumbnailImage == nil) {
		[self fetchThumbnail];
	}
	
	return thumbnailImage;
}

@end
