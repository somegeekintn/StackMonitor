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

@end


@implementation AppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
	[[QSMonitor sharedMonitor] beginMonitoring];
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
