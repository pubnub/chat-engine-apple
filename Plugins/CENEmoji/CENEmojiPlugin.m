/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEmojiPlugin.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENSearch.h>
#import "CENEmojiEmitMiddleware.h"
#import <CENChatEngine/CENChat.h>
#import "CENEmojiOnMiddleware.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENEmojiConfigurationKeys CENEmojiConfiguration = {
    .events = @"ens",
    .messageKey = @"mk",
    .useNative = @"n",
    .emojiURL = @"eu"
};


#pragma mark - Interface implementation

@implementation CENEmojiPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.emoji";
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)object {
    
    BOOL isOnLocation = [location isEqualToString:CEPMiddlewareLocation.on];
    Class middlewareClass = nil;
    
    if ([object isKindOfClass:[CENChat class]] || [object isKindOfClass:[CENSearch class]]) {
        middlewareClass = (isOnLocation ? [CENEmojiOnMiddleware class]
                                        : [CENEmojiEmitMiddleware class]);
    }
    
    return middlewareClass;
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENEmojiExtension class];
    }
    
    return extensionClass;
}

+ (NSString *)emojiFrom:(NSString *)string usingChat:(CENChat *)chat {
    
    CENEmojiExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    return [extension emojiFrom:string];
}

+ (NSArray<NSString *> *)emojiWithName:(NSString *)name usingChat:(CENChat *)chat {
    
    CENEmojiExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    
    return [extension emojiWithName:name];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSArray *configuredEvents = self.configuration[CENEmojiConfiguration.events];
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSMutableArray<NSString *> *events = [(configuredEvents ?: @[]) mutableCopy];
    
    if (!events.count) {
        [events addObject:@"message"];
    }
    
    if (!((NSString *)configuration[CENEmojiConfiguration.messageKey]).length) {
        configuration[CENEmojiConfiguration.messageKey] = @"text";
    }
    
    if (!((NSString *)configuration[CENEmojiConfiguration.emojiURL]).length) {
        NSString *url = @"https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis";
        configuration[CENEmojiConfiguration.emojiURL] = url;
    }
    
    configuration[CENEmojiConfiguration.events] = events;
    self.configuration = configuration;
    
    [CENEmojiEmitMiddleware replaceEventsWith:self.configuration[CENEmojiConfiguration.events]];
    [CENEmojiOnMiddleware replaceEventsWith:self.configuration[CENEmojiConfiguration.events]];
}

#pragma mark -


@end
