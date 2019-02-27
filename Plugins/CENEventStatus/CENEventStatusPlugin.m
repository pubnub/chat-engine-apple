/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENEventStatusEmitMiddleware.h"
#import "CENEventStatusOnMiddleware.h"
#import "CENEventStatusExtension.h"
#import <CENChatEngine/CENEvent.h>
#import <CENChatEngine/CENChat.h>
#import "CENEventStatusPlugin.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENEventStatusConfigurationKeys CENEventStatusConfiguration = {
    .events = @"ens"
};

CENEventStatusDataKeys CENEventStatusData = {
    .data = @"eventStatus",
    .identifier = @"id"
};


#pragma mark - Interface implementation

@implementation CENEventStatusPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.event-status";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if ([object isKindOfClass:[CENChat class]] ||
        (isOnLocation && [object isKindOfClass:[CENEvent class]])) {
        
        middlewareClass = (isOnLocation ? [CENEventStatusOnMiddleware class]
                                        : [CENEventStatusEmitMiddleware class]);
    }
    
    return middlewareClass;
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENEventStatusExtension class];
    }
    
    return extensionClass;
}

+ (void)readEvent:(NSDictionary *)event inChat:(CENChat *)chat {
    
    CENEventStatusExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    [extension readEvent:event];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSArray *configuredEvents = self.configuration[CENEventStatusConfiguration.events];
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSMutableArray<NSString *> *events = [(configuredEvents ?: @[]) mutableCopy];
    
    if (!events.count) {
        [events addObject:@"message"];
    }
    
    configuration[CENEventStatusConfiguration.events] = events;
    self.configuration = configuration;
    
    [CENEventStatusEmitMiddleware replaceEventsWith:[events copy]];
    [CENEventStatusOnMiddleware replaceEventsWith:[events arrayByAddingObject:@"$.emitted"]];
}

#pragma mark -


@end
