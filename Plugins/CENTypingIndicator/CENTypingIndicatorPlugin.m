/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENTypingIndicatorPlugin.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENTypingIndicatorMiddleware.h"
#import "CENTypingIndicatorExtension.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENTypingIndicatorConfigurationKeys CENTypingIndicatorConfiguration = {
    .timeout = @"t",
    .events = @"e"
};


#pragma mark - Interface implementation

@implementation CENTypingIndicatorPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.typing-indicator";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {

    BOOL isEmitLocation = [location isEqualToString:CEPMiddlewareLocation.emit];
    Class middlewareClass = nil;

    if (isEmitLocation && [object isKindOfClass:[CENChat class]]) {
        middlewareClass = [CENTypingIndicatorMiddleware class];
    }

    return middlewareClass;
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENTypingIndicatorExtension class];
    }
    
    return extensionClass;
}

+ (void)setTyping:(BOOL)isTyping inChat:(CENChat *)chat {

    CENTypingIndicatorExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    if (isTyping) {
        [extension startTyping];
    } else {
        [extension stopTyping];
    }
}

+ (BOOL)isTypingInChat:(CENChat *)chat {

    CENTypingIndicatorExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    return extension.isTyping;
}

+ (void)checkIsTypingInChat:(CENChat *)chat withCompletion:(void(^)(BOOL isTyping))block {

    block([self isTypingInChat:chat]);
}


#pragma mark - Handlers

- (void)onCreate {

    NSArray *configuredEvents = self.configuration[CENTypingIndicatorConfiguration.events];
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSMutableArray<NSString *> *events = [(configuredEvents ?: @[]) mutableCopy];

    if (!events.count) {
        [events addObject:@"message"];
    }
    
    if (!configuration[CENTypingIndicatorConfiguration.timeout]) {
        configuration[CENTypingIndicatorConfiguration.timeout] = @(1.f);
    }

    configuration[CENTypingIndicatorConfiguration.events] = events;
    self.configuration = configuration;

    [CENTypingIndicatorMiddleware replaceEventsWith:events];
}

#pragma mark -


@end
