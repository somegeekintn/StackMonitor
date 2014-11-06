//
//  QSUser.h
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QSQuestion;

@interface QSUser : NSManagedObject

+ (QSUser *)			userFromRawInfo: (NSDictionary *) inRawInfo
							inManagedObjectContext: (NSManagedObjectContext *) inContext;
+ (QSUser *)			userWithID: (NSNumber *) inUserID
							inManagedObjectContext: (NSManagedObjectContext *) inContext;

- (void)				updateWithRawInfo: (NSDictionary *) inRawInfo;

@property (nonatomic, retain) NSNumber		*accept_rate;
@property (nonatomic, retain) NSString		*display_name;
@property (nonatomic, retain) NSString		*link;
@property (nonatomic, retain) NSString		*profile_image;
@property (nonatomic, retain) NSNumber		*reputation;
@property (nonatomic, strong) id			thumbnail;
@property (nonatomic, retain) NSNumber		*user_id;
@property (nonatomic, retain) NSString		*user_type;
@property (nonatomic, retain) NSSet			*questions;
@end

@interface QSUser (CoreDataGeneratedAccessors)

- (void)		addQuestionsObject: (QSQuestion *) inQuestion;
- (void)		removeQuestionsObject: (QSQuestion *) inQuestion;
- (void)		addQuestions: (NSSet *) inQuestions;
- (void)		removeQuestions: (NSSet *) inQuestions;

@end
