/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTypingIndicatorPlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENTypingIndicatorExtension.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENTypingIndicatorConfigurationKeys CENTypingIndicatorConfiguration = {
    .timeout = @"t"
};


#pragma mark - Interface implementation

@implementation CENTypingIndicatorPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.typing-indicator";
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
    
    [chat extensionWithIdentifier:[self identifier]
                          context:^(CENTypingIndicatorExtension *extension) {
                              
        if (isTyping) {
            [extension startTyping];
        } else {
            [extension stopTyping];
        }
    }];
}

+ (void)checkIsTypingInChat:(CENChat *)chat withCompletion:(void(^)(BOOL isTyping))block {
    
    [chat extensionWithIdentifier:[self identifier]
                          context:^(CENTypingIndicatorExtension *extension) {
                              
        block(extension.isTyping);
    }];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    
    if (!configuration[CENTypingIndicatorConfiguration.timeout]) {
        configuration[CENTypingIndicatorConfiguration.timeout] = @(1.f);
    }
    
    self.configuration = configuration;
}

#pragma mark -


@end
