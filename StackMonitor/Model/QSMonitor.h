//
//  QSMonitor.h
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const		QSNotificationMonitorStateChange;

@interface QSMonitor : NSObject

+ (QSMonitor *)			sharedMonitor;

- (void)				beginMonitoring;
- (void)				endMonitoring;

@property (nonatomic, strong) NSArray		*tags;
@property (nonatomic, assign) BOOL			monitoring;
@property (nonatomic, readonly) BOOL		updating;

@end
