/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSearchFilterPlugin.h"
#import "CENSearchFilterMiddleware.h"
#import "CEPPlugin+Developer.h"
#import "CENSearch.h"


#pragma mark Interface implementation

@implementation CENSearchFilterPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.search.filter";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class cls = nil;
    
    if (isOnLocation && [object isKindOfClass:[CENSearch class]]) {
        cls = [CENSearchFilterMiddleware class];
    }
    
    return cls;
}

#pragma mark -


@end
