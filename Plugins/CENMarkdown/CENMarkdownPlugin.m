/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENMarkdownPlugin.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENSearch.h>
#import <CENChatEngine/CENChat.h>
#import "CENMarkdownMiddleware.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENMarkdownConfigurationKeys CENMarkdownConfiguration = {
    .events = @"ens",
    .messageKey = @"mk",
    .parsedMessageKey = @"pmk",
    .parser = @"ps",
    .parserConfiguration = @"pc"
};


#pragma mark - Interface implementation

@implementation CENMarkdownPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.markdown";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object {
    
    BOOL suitableObject = ([object isKindOfClass:[CENChat class]] ||
                           [object isKindOfClass:[CENSearch class]]);
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if (isOnLocation && suitableObject) {
        middlewareClass = [CENMarkdownMiddleware class];
    }
    
    return middlewareClass;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSArray *configuredEvents = self.configuration[CENMarkdownConfiguration.events];
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSMutableArray<NSString *> *events = [(configuredEvents ?: @[]) mutableCopy];
    
    if (!events.count) {
        [events addObject:@"message"];
    }
    
    if (!((NSString *)configuration[CENMarkdownConfiguration.messageKey]).length) {
        configuration[CENMarkdownConfiguration.messageKey] = @"text";
    }
    
    if (!((NSString *)configuration[CENMarkdownConfiguration.parsedMessageKey]).length) {
        configuration[CENMarkdownConfiguration.parsedMessageKey] = @"text";
    }
    
    configuration[CENMarkdownConfiguration.events] = events;
    self.configuration = configuration;
    
    [CENMarkdownMiddleware replaceEventsWith:self.configuration[CENMarkdownConfiguration.events]];
}

#pragma mark -


@end
