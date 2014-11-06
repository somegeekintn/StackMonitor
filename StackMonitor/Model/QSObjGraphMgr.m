//
//  QSObjGraphMgr.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSObjGraphMgr.h"

@interface QSObjGraphMgr ()

@property (nonatomic, strong) NSPersistentStoreCoordinator	*persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel			*managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext		*managedObjectContext;

@end

static QSObjGraphMgr		*sSharedManager = nil;

@implementation QSObjGraphMgr

+ (QSObjGraphMgr *) sharedManager
{
	return sSharedManager;
}

- (void) awakeFromNib
{
	[super awakeFromNib];

	sSharedManager = self;
}

- (NSURL *) applicationDocumentsDirectory
{
    NSURL	*appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask] lastObject];
	
    return [appSupportURL URLByAppendingPathComponent: @"com.quietspark.StackMonitor"];
}

- (void) save
{
    NSError		*error = nil;

    if (![[self managedObjectContext] commitEditing]) {
		NSLog(@"%s Core Data unable to commit editing before saving", __PRETTY_FUNCTION__);
    }
    
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save: &error]) {
        [[NSApplication sharedApplication] presentError: error];
    }
}

- (void) shutdown
{
    if ([[self managedObjectContext] commitEditing]) {
		if ([[self managedObjectContext] hasChanges]) {
			NSError		*error = nil;
			
			if (![[self managedObjectContext] save: &error]) {
				NSLog(@"%s Core Data error: %@", __PRETTY_FUNCTION__, error);
			}
		}
	}
}

#pragma mark - Setters / Getters

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext == nil) {
		NSPersistentStoreCoordinator	*coordinator = self.persistentStoreCoordinator;
		
		if (coordinator != nil) {
			_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
			[_managedObjectContext setPersistentStoreCoordinator: coordinator];
		}
	}

    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
		NSFileManager	*fileManager = [NSFileManager defaultManager];
		NSURL			*applicationDocumentsDirectory = [self applicationDocumentsDirectory];
		BOOL			shouldFail = NO;
		NSError			*cdError = nil;
		NSString		*failureReason = @"There was an error creating or loading the application's saved data.";
		NSDictionary	*properties = [applicationDocumentsDirectory resourceValuesForKeys: @[ NSURLIsDirectoryKey ] error: &cdError];
		
		// Make sure the application files directory is there
		if (properties) {
			if (![properties[NSURLIsDirectoryKey] boolValue]) {
				failureReason = [NSString stringWithFormat: @"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
				shouldFail = YES;
			}
		}
		else if ([cdError code] == NSFileReadNoSuchFileError) {
			cdError = nil;
			[fileManager createDirectoryAtPath: [applicationDocumentsDirectory path] withIntermediateDirectories: YES attributes: nil error: &cdError];
		}
		
		if (!shouldFail && cdError == nil) {
			NSPersistentStoreCoordinator	*coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
			NSURL							*storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent: @"stackmon.sqlite"];
			
			if (![coordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL options: nil error: &cdError]) {
				NSFileManager	*fileManager = [NSFileManager defaultManager];
				NSURL			*movedStoreURL = [storeURL URLByAppendingPathExtension: @"bad"];
				
				NSLog(@"Core Data: Error %@, %@", cdError, [cdError userInfo]);
				NSLog(@"Will move old store and create new");
				
				cdError = nil;
				[fileManager removeItemAtURL: movedStoreURL error: nil];
				if (![fileManager moveItemAtURL: storeURL toURL: movedStoreURL error: &cdError]) {
					NSLog(@"Failed with %@ trying to move %@ to %@", cdError, storeURL, movedStoreURL);
					coordinator = nil;
				}
				else if (![coordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL options: nil error: &cdError]) {
					NSLog(@"Core Data: removed old store but still...");
					NSLog(@"Core Data: Error %@, %@", cdError, [cdError userInfo]);
					coordinator = nil;
				}
			}
			_persistentStoreCoordinator = coordinator;
		}
		
		if (shouldFail || cdError != nil) {
			NSMutableDictionary		*dict = [NSMutableDictionary dictionary];
			
			dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
			dict[NSLocalizedFailureReasonErrorKey] = failureReason;
			if (cdError != nil) {
				dict[NSUnderlyingErrorKey] = cdError;
			}
			cdError = [NSError errorWithDomain: @"QSCoreData" code: 9999 userInfo: dict];
			[[NSApplication sharedApplication] presentError: cdError];
		}
	}
	
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *) managedObjectModel
{
    if (_managedObjectModel == nil) {
		NSURL	*modelURL = [[NSBundle mainBundle] URLForResource: @"StackMonitor" withExtension: @"momd"];
		
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
	}
	
    return _managedObjectModel;
}

@end
