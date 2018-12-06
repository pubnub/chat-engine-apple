/**
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENUnreadMessagesPlugin.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENUnreadMessagesExtension.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Externs

/**
 * @brief Unread messages event payload data structure values assignment.
 */
CENUnreadMessagesEventKeys CENUnreadMessagesEvent = {
    .sender = @"id",
    .event = @"e",
    .count = @"c"
};

/**
 * @brief Configuration keys structure values assignment.
 */
CENUnreadMessagesConfigurationKeys CENUnreadMessagesConfiguration = {
    .events = @"e"
};


#pragma mark - Interface implementation

@implementation CENUnreadMessagesPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.unread-messages";
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENChat class]]) {
        extensionClass = [CENUnreadMessagesExtension class];
    }
    
    return extensionClass;
}

+ (void)setChat:(CENChat *)chat active:(BOOL)isActive {
    
    [chat extensionWithIdentifier:[self identifier]
                          context:^(CENUnreadMessagesExtension *extension) {
                              
        if (isActive) {
            [extension active];
        } else {
            [extension inactive];
        }
    }];
}

+ (void)fetchUnreadCountForChat:(CENChat *)chat withCompletion:(void(^)(NSUInteger count))block {
    
    [chat extensionWithIdentifier:[self identifier]
                          context:^(CENUnreadMessagesExtension *extension) {
                              
        block(extension.unreadCount);
    }];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    
    if (!((NSArray<NSString *> *)configuration[CENUnreadMessagesConfiguration.events]).count) {
        configuration[CENUnreadMessagesConfiguration.events] = @[@"message"];
    }
    
    self.configuration = configuration;
}

#pragma mark -


@end
