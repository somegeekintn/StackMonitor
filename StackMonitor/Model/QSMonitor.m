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

const NSString	*cStackEchangeSite = @"stackoverflow";
const NSString	*cStackEchangeTag = @"xcode;ios;iphone;objective-c";

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

- (NSURL *) monitorURL
{
	NSURL	*monitorURL;
	
#if 1
	monitorURL = [[NSBundle mainBundle] URLForResource: @"sample" withExtension: @"json"];
#else
	NSString	*URLString = [NSString stringWithFormat: @"http://api.stackexchange.com/2.2/search?order=desc&sort=creation&tagged=%@&site=%@&filter=!9YdnSJBlX", cStackEchangeTag, cStackEchangeSite];
	
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
		NSData				*rawResponse = [NSData dataWithContentsOfURL: [self monitorURL]];
		
		if (rawResponse != nil) {
//NSString	*rawString = [[NSString alloc] initWithData: rawResponse encoding: NSUTF8StringEncoding];
//NSLog(@"%@", rawString);
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
				}];
			}
			else {
				if (jsonError != nil) {
					NSLog(@"error creating json response: %@", [jsonError localizedDescription]);
				}
			}
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * 60.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self continueMonitoring];
		});
	}
}

- (void) endMonitoring
{
	self.monitoring = NO;
}

@end
