/**
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENUnreadMessagesExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENUnreadMessagesPlugin.h"
#import <CENChatEngine/CENChat.h>
#import <CENChatEngine/CENUser.h>


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENUnreadMessagesExtension ()


#pragma mark - Information

/**
 * @brief Currently unread messages / events count.
 */
@property (nonatomic, assign) NSUInteger unreadCount;

/**
 * @brief Whether chat currently active or not.
 */
@property (nonatomic, assign, getter = isActive) BOOL active;

/**
 * @brief Events handling block.
 */
@property (nonatomic, copy, nullable) CENEventHandlerBlock eventHandlerBlock;


#pragma mark - Handler

/**
 * @brief Process handled event payload.
 *
 * @discussion Use handler call to increment current values of unread messages / events.
 *
 * @param payload \a NSDictionary which contain information about event \b {sender CENUser} and
 *     \b {chat CENChat}.
 */
- (void)handleEvent:(NSDictionary *)payload;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENUnreadMessagesExtension


#pragma mark - Chat activity management

- (void)active {
    
    self->_active = YES;
    self.unreadCount = 0;
}

- (void)inactive {

    self->_active = NO;
}


#pragma mark - Handlers

- (void)onCreate {

    __weak __typeof(self) weakSelf = self;
    self.eventHandlerBlock = ^(CENEmittedEvent *localEvent) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSDictionary *event = localEvent.data;
        
        [strongSelf handleEvent:event];
    };
    
    for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
        [self.object handleEvent:event withHandlerBlock:self.eventHandlerBlock];
    }
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
        CENUnreadMessagesEvent.sender: user.uuid,
        CENUnreadMessagesEvent.event: payload,
        CENUnreadMessagesEvent.count: @(self.unreadCount)
    };
    
    [chat emitEventLocally:@"$unread", unreadMessagesEvent, nil];
}

#pragma mark -


@end
