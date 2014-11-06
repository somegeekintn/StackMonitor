//
//  AppDelegate.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "AppDelegate.h"
#import "QSMonitor.h"
#import "QSObjGraphMgr.h"


@interface AppDelegate ()

@property (nonatomic, weak) IBOutlet NSWindow				*window;
@property (nonatomic, strong) IBOutlet NSArrayController	*questionController;

@end


@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
//	self.testController = [[NSArrayController alloc] init];
//	[self.testController setManagedObjectContext: [QSObjGraphMgr sharedManager].managedObjectContext];
//	[self.testController setEntityName: @"Question"];

	[self.questionController setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"last_activity_date" ascending: NO]]];
	[[QSMonitor sharedMonitor] beginMonitoring];
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		NSLog(@"Will Fetch");
//		
//		[self.testController fetch: nil];
//		
//		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//			NSLog(@"Objects: %@", [self.testController arrangedObjects]);
//		});
//	});
}

- (void) applicationWillTerminate: (NSNotification *) inNotification
{
	[[QSMonitor sharedMonitor] endMonitoring];
	[[QSObjGraphMgr sharedManager] shutdown];
}

- (IBAction) saveAction: (id) inSender
{
	[[QSObjGraphMgr sharedManager] save];
}

@end
