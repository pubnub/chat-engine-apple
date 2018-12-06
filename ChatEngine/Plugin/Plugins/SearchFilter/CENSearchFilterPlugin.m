/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENSearchFilterPlugin.h"
#import "CENSearchFilterMiddleware.h"
#import "CEPPlugin+Developer.h"


#pragma mark Interface implementation

@implementation CENSearchFilterPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.search.filter";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)__unused object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    
    return isOnLocation ? [CENSearchFilterMiddleware class] : nil;
}

#pragma mark -


@end
