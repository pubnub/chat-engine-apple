/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENOpenGraphPlugin.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENOpenGraphMiddleware.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENOpenGraphConfigurationKeys CENOpenGraphConfiguration = {
    .events = @"ens",
    .messageKey = @"mk",
    .appID = @"ai",
    .openGraphKey = @"ogk"
};

CENOpenGraphDataKeys CENOpenGraphData = {
    .image = @"image",
    .url = @"url",
    .title = @"title",
    .description = @"description"
};


#pragma mark - Interface implementation

@implementation CENOpenGraphPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.opengraph";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if (isOnLocation && [object isKindOfClass:[CENChat class]]) {
        middlewareClass = [CENOpenGraphMiddleware class];
    }
    
    return middlewareClass;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSArray *configuredEvents = self.configuration[CENOpenGraphConfiguration.events];
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSMutableArray<NSString *> *events = [(configuredEvents ?: @[]) mutableCopy];
    
    if (!events.count) {
        [events addObject:@"message"];
    }
    
    if (!((NSString *)configuration[CENOpenGraphConfiguration.messageKey]).length) {
        configuration[CENOpenGraphConfiguration.messageKey] = @"text";
    }
    
    if (!((NSString *)configuration[CENOpenGraphConfiguration.openGraphKey]).length) {
        configuration[CENOpenGraphConfiguration.openGraphKey] = @"openGraph";
    }
    
    configuration[CENOpenGraphConfiguration.events] = events;
    self.configuration = configuration;
    
    [CENOpenGraphMiddleware replaceEventsWith:self.configuration[CENOpenGraphConfiguration.events]];
}


#pragma mark -


@end
