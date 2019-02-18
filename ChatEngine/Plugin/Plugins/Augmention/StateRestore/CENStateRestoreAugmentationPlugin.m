/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object {

    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class cls = nil;
    
    if (isOnLocation && [object isKindOfClass:[CENObject class]]) {
        cls = [CENStateRestoreAugmentationMiddleware class];
    }
    
    return cls;
}

#pragma mark -


@end
