//
//  QSQuestion.h
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QSUser;

@interface QSQuestion : NSManagedObject

+ (QSQuestion *)		updateQuestionWithRawInfo: (NSDictionary *) inRawInfo;
+ (QSQuestion *)		updateQuestionWithRawInfo: (NSDictionary *) inRawInfo
							inManagedObjectContext: (NSManagedObjectContext *) inContext;
+ (QSQuestion *)		questionWithID: (NSNumber *) inQuestionID
							inManagedObjectContext: (NSManagedObjectContext *) inContext;

- (void)				updateWithRawInfo: (NSDictionary *) inRawInfo;

@property (nonatomic, strong) NSNumber		*accepted_answer_id;
@property (nonatomic, strong) NSNumber		*answer_count;
@property (nonatomic, strong) NSString		*body;
@property (nonatomic, strong) NSNumber		*bounty_amount;
@property (nonatomic, strong) NSDate		*bounty_closes_date;
@property (nonatomic, strong) NSDate		*closed_date;
@property (nonatomic, strong) NSString		*closed_reason;
@property (nonatomic, strong) NSDate		*community_owned_date;
@property (nonatomic, strong) NSDate		*creation_date;
@property (nonatomic, strong) NSNumber		*is_answered;
@property (nonatomic, strong) NSDate		*last_activity_date;
@property (nonatomic, strong) NSDate		*last_edit_date;
@property (nonatomic, strong) NSString		*link;
@property (nonatomic, strong) NSDate		*locked_date;
@property (nonatomic, strong) NSDate		*protected_date;
@property (nonatomic, strong) NSNumber		*question_id;
@property (nonatomic, strong) NSNumber		*score;
@property (nonatomic, strong) NSString		*tags;
@property (nonatomic, strong) NSString		*title;
@property (nonatomic, strong) NSNumber		*view_count;
@property (nonatomic, strong) QSUser		*owner;

@end
