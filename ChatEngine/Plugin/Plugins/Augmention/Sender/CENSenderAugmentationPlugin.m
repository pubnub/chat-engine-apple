/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSenderAugmentationPlugin.h"
#import "CENSenderAugmentationMiddleware.h"
#import "CEPPlugin+Developer.h"


#pragma mark Interface implementation

@implementation CENSenderAugmentationPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.emit-payload.sender";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)__unused object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    
    return isOnLocation ? [CENSenderAugmentationMiddleware class] : nil;
}

#pragma mark -


@end
