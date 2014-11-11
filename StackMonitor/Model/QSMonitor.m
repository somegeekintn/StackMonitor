//
//  QSMonitor.m
//  StackMonitor
//
//  Created by Casey Fleser on 11/5/14.
//  Copyright (c) 2014 Quiet Spark. All rights reserved.
//

#import "QSMonitor.h"
#import "QSObjGraphMgr.h"
#import "QSQuestion.h"


#define kRefreshInterval	(3.0 * 60.0)

NSString * const	cStackEchangeSite = @"stackoverflow";
NSString * const	QSNotificationMonitorStateChange = @"QSNotificationMonitorStateChange";


@interface QSMonitor ()

@property (nonatomic, assign) BOOL		updating;

@end


@implementation QSMonitor

+ (QSMonitor *) sharedMonitor
{
	static dispatch_once_t		sOnceToken;
	static QSMonitor			*sSharedMonitor = nil;
	
	dispatch_once(&sOnceToken, ^{
		sSharedMonitor = [[QSMonitor alloc] init];
	});
	
	return sSharedMonitor;
}

- (id) init
{
	if ((self = [super init]) != nil) {
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleDefaultsChange:) name: NSUserDefaultsDidChangeNotification object: nil];
		self.tags = [[NSUserDefaults standardUserDefaults] arrayForKey: @"monitor_tags"];
	}
	
	return self;
}

- (NSURL *) monitorURL
{
	NSURL		*monitorURL;

#if 0
	// for testing
	monitorURL = [[NSBundle mainBundle] URLForResource: @"sample" withExtension: @"json"];
#else
	NSString	*monitorTags = [self.tags componentsJoinedByString: @";"];
	NSString	*URLString = [NSString stringWithFormat: @"http://api.stackexchange.com/2.2/search?order=desc&sort=creation&site=%@&filter=!9YdnSJBlX", cStackEchangeSite];

	if ([monitorTags length]) {
		URLString = [URLString stringByAppendingString: [NSString stringWithFormat: @"&tagged=%@", monitorTags]];
	}
	
	monitorURL = [NSURL URLWithString: URLString];
#endif
	
	 return monitorURL;
}

- (void) beginMonitoring
{
	self.monitoring = YES;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self continueMonitoring];
	});
}

- (void) continueMonitoring
{
	if (self.monitoring) {
		NSData				*rawResponse;
		
		self.updating = YES;
		rawResponse = [NSData dataWithContentsOfURL: [self monitorURL]];
		if (rawResponse != nil) {
			NSError				*jsonError = nil;
			NSDictionary		*jsonResponse = [NSJSONSerialization JSONObjectWithData: rawResponse options: 0 error: &jsonError];
			
			if (jsonResponse != nil) {
				NSArray					*itemList = [jsonResponse objectForKey: @"items"];
				NSManagedObjectContext	*context = [QSObjGraphMgr sharedManager].managedObjectContext;
				
				[context performBlock: ^{
					[itemList enumerateObjectsUsingBlock: ^(id inObject, NSUInteger inIndex, BOOL *outStop) {
						[QSQuestion updateQuestionWithRawInfo: inObject];
					}];

					[[QSObjGraphMgr sharedManager] save];
					self.updating = NO;
				}];
			}
			else {
				if (jsonError != nil) {
					NSLog(@"error creating json response: %@", [jsonError localizedDescription]);
				}
				self.updating = NO;
			}
		}
		else {
			self.updating = NO;
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self continueMonitoring];
		});
	}
}

- (void) endMonitoring
{
	self.monitoring = NO;
}

- (void) setUpdating: (BOOL) inUpdating
{
	if (_updating != inUpdating) {
		_updating = inUpdating;
		
		dispatch_async(dispatch_get_main_queue(), ^{
//		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_updating ? 0.0 : 5.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName: QSNotificationMonitorStateChange object: self userInfo: @{ @"state" : @(_updating) }];
		});
	}
}

- (void) handleDefaultsChange: (NSNotification *) inNotification
{
	self.tags = [[NSUserDefaults standardUserDefaults] arrayForKey: @"monitor_tags"];
}

@end
