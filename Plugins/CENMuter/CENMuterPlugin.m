/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENMuterPlugin.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENChat.h>
#import "CENMuterMiddleware.h"
#import "CENMuterExtension.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENMuterConfigurationKeys CENMuterConfiguration = {
    .events = @"ens"
};


#pragma mark - Interface implementation

@implementation CENMuterPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.muter";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if (isOnLocation && [object isKindOfClass:[CENChat class]]) {
        middlewareClass = [CENMuterMiddleware class];
    }
    
    return middlewareClass;
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENMuterExtension class];
    }
    
    return extensionClass;
}

+ (void)muteUser:(CENUser *)user inChat:(CENChat *)chat {
    
    CENMuterExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    [extension muteUser:user];
}

+ (void)unmuteUser:(CENUser *)user inChat:(CENChat *)chat {
    
    CENMuterExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    [extension unmuteUser:user];
}

+ (BOOL)isMutedUser:(CENUser *)user inChat:(CENChat *)chat {
    
    CENMuterExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    return [extension isMutedUser:user];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSArray *configuredEvents = self.configuration[CENMuterConfiguration.events];
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSMutableArray<NSString *> *events = [(configuredEvents ?: @[]) mutableCopy];
    
    if (!events.count) {
        [events addObject:@"message"];
    }
    
    configuration[CENMuterConfiguration.events] = events;
    self.configuration = configuration;
    
    [CENMuterMiddleware replaceEventsWith:self.configuration[CENMuterConfiguration.events]];
}

#pragma mark -


@end
