/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatAugmentationPlugin.h"
#import "CENChatAugmentationMiddleware.h"
#import "CEPPlugin+Developer.h"


#pragma mark Interface implementation

@implementation CENChatAugmentationPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.emit-payload.chat";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)__unused object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    
    return isOnLocation ? [CENChatAugmentationMiddleware class] : nil;
}

#pragma mark -


@end
