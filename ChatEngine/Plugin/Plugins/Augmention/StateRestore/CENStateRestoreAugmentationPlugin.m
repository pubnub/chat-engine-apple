/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENStateRestoreAugmentationPlugin.h"
#import "CENStateRestoreAugmentationMiddleware.h"
#import "CEPPlugin+Developer.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENStateRestoreAugmentationConfigurationKeys CENStateRestoreAugmentationConfiguration = {
    .chat = @"c"
};


#pragma mark - Interface implementation

@implementation CENStateRestoreAugmentationPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.sender.state-restore";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)__unused object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    
    return isOnLocation ? [CENStateRestoreAugmentationMiddleware class] : nil;
}

#pragma mark -


@end
