/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENUnreadMessagesExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import "CENUnreadMessagesPlugin.h"
#import <CENChatEngine/CENChat.h>
#import <CENChatEngine/CENUser.h>


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENUnreadMessagesExtension ()


#pragma mark - Information

/**
 * @brief  Stores reference on currently unread messages/events count.
 */
@property (nonatomic, assign) NSUInteger unreadCount;

/**
 * @brief  Stores whether chat currently active or not.
 */
@property (nonatomic, assign, getter = isActive) BOOL active;

/**
 * @brief  Stores reference on events handling block.
 * @note   Reference on block required to make it possible to remove it from event listeners.
 */
@property (nonatomic, copy, nullable) void(^eventHandlerBlock)(NSDictionary *event);


#pragma mark - Handler

/**
 * @brief      Process handled event payload.
 * @discussion Use handler call to increment current values of unread messages / events.
 *
 * @param payload Reference on payload which contain information about event sender and chat.
 */
- (void)handleEvent:(NSDictionary *)payload;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENUnreadMessagesExtension


#pragma mark - Chat activity management

- (void)active {
    
    self.active = YES;
    self.unreadCount = 0;
}

- (void)inactive {
    
    if (!self.isActive) {
        return;
    }
    
    self.active = NO;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSString *identifier = self.identifier;
    
    self.eventHandlerBlock = ^(NSDictionary *event) {
        CENChat *chat = event[CENEventData.chat];
        
        [chat extensionWithIdentifier:identifier context:^(CENUnreadMessagesExtension *extension) {
            [extension handleEvent:event];
        }];
    };
    
    for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
        [self.object handleEvent:event withHandlerBlock:self.eventHandlerBlock];
    }
    
    self.eventHandlerBlock = nil;
}

- (void)onDestruct {
    
    for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
        [self.object removeHandler:self.eventHandlerBlock forEvent:event];
    }
}

- (void)handleEvent:(NSDictionary *)payload {
    
    if (self.isActive) {
        return;
    }
    
    CENChat *chat = payload[CENEventData.chat];
    CENUser *user = payload[CENEventData.sender];
    
    self.unreadCount++;
    
    NSDictionary *unreadMessagesEvent = @{
        CENUnreadMessagesEvent.chat: chat,
        CENUnreadMessagesEvent.sender: user.uuid,
        CENUnreadMessagesEvent.event: payload,
        CENUnreadMessagesEvent.count: @(self.unreadCount)
    };
    
    [chat emitEventLocally:@"$unread", unreadMessagesEvent, nil];
}


#pragma mark -


@end
