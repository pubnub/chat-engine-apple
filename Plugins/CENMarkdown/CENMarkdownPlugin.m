/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMarkdownPlugin.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENChat.h>
#import "CENMarkdownMiddleware.h"


#pragma mark Externs

CENMarkdownConfigurationKeys CENMarkdownConfiguration = {
    .events = @"ens",
    .messageKey = @"mk",
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
    
    BOOL isEmitLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if (isEmitLocation && [object isKindOfClass:[CENChat class]]) {
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
    
    configuration[CENMarkdownConfiguration.events] = events;
    self.configuration = configuration;
    
    [CENMarkdownMiddleware replaceEventsWith:self.configuration[CENMarkdownConfiguration.events]];
}

#pragma mark -


@end
