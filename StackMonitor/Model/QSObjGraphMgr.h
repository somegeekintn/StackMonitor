//
//  QSObjGraphMgr.h
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QSObjGraphMgr : NSObject

+ (QSObjGraphMgr *)			sharedManager;

- (void)					save;
- (void)					shutdown;

@property (nonatomic, readonly) NSManagedObjectContext		*managedObjectContext;

@end
