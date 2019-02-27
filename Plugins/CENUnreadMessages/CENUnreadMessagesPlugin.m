/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
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
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    .sender = @"id",
#pragma GCC diagnostic pop
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

    CENUnreadMessagesExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    if (isActive) {
        [extension active];
    } else {
        [extension inactive];
    }
}

+ (BOOL)isChatActive:(CENChat *)chat {

    CENUnreadMessagesExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    return extension.isActive;
}

+ (NSUInteger)unreadCountForChat:(CENChat *)chat {

    CENUnreadMessagesExtension *extension = [chat extensionWithIdentifier:[self identifier]];

    return extension.unreadCount;
}

+ (void)fetchUnreadCountForChat:(CENChat *)chat withCompletion:(void(^)(NSUInteger count))block {

    block([self unreadCountForChat:chat]);
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
