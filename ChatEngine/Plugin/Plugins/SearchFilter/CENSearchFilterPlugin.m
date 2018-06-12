/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENSearchFilterPlugin.h"
#import "CENSearchFilterMiddleware.h"
#import "CEPPlugin+Developer.h"
#import "CEPStructures.h"


#pragma mark Interface implementation

@implementation CENSearchFilterPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.search.filter";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)__unused object {
    
    return [location isEqualToString:CEPMiddlewareLocation.on] ? [CENSearchFilterMiddleware class] : nil;
}

#pragma mark -


@end
