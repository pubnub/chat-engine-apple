#import <CENChatEngine/CEPPlugin.h>
#import "CENUnreadMessagesExtension.h"


#pragma mark Structures

/**
 * @brief Structure which describe available configuration option key names.
 *
 * @ref a5a1b777-cc4d-4307-ab90-b5cee60a5772
 */
typedef struct CENUnreadMessagesConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * @\b Default: \c @[@"message"]
     *
     * @ref f1eae727-cf67-41bb-9b8d-80623b2d6a9a
     */
    __unsafe_unretained NSString *events;
} CENUnreadMessagesConfigurationKeys;

extern CENUnreadMessagesConfigurationKeys CENUnreadMessagesConfiguration;

/**
 * @brief Structure which provides keys under which stored unread message event data.
 *
 * @ref bf828c03-d61e-4979-9b00-482ae4d470bc
 */
typedef struct CENUnreadMessagesEventKeys {
    /**
     * @brief \b {Chat CENChat} for which number of unread messages / events did change.
     *
     * @ref ca7411df-b5ca-4865-87c6-c890fd1ff357
     */
    __unsafe_unretained NSString *chat
        DEPRECATED_MSG_ATTRIBUTE("This field deprecated since 0.0.2. Reference on chat available "
                                 "during registration on event or as part of local event object.");
    
    /**
     * @brief \b {User CENUser} which sent last unread message / event.
     *
     * @ref 3ea3138c-3919-47a9-bc19-1f8a38f91c3f
     */
    __unsafe_unretained NSString *sender
        DEPRECATED_MSG_ATTRIBUTE("This field deprecated since 0.0.2. Reference on sender can be "
                                 "received from CENUnreadMessagesEvent.event which store original"
                                 "event payload with CENEventData.sender.");
    
    /**
     * @brief \a NSDictionary original event payload from last unread / event  where data stored
     * under \b {CENEventData} keys.
     *
     * @ref 7be311b9-cae1-4f88-bcf6-c8aaccb79734
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief Number of unread messages / events.
     *
     * @ref 4625fe2d-9ea6-4353-9d7e-e2b3e96e3927
     */
    __unsafe_unretained NSString *count;
} CENUnreadMessagesEventKeys;

extern CENUnreadMessagesEventKeys CENUnreadMessagesEvent;


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} unread messages counting plugin.
 *
 * @discussion Plugin allow to count unread messages for \c inactive \b {chat CENChat}.
 *
 * @discussion Setup with default configuration
 * @code
 * // objc 08874dbc-2360-482e-8eb1-76d83e81e640
 *
 * self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).store();
 *
 * self.chat.on(@"$unread", ^(CENEmittedEvent *event) {
 *     NSDictionary *pluginPayload = event.data;
 *     NSDictionary *eventPayload = pluginPayload[CENUnreadMessagesEvent.event];
 *     CENUser *sender = eventPayload[CENEventData.sender];
 *
 *     NSLog(@"%@ sent a message you haven't seen (there is %@ unread messages) in %@ the full "
 *           "event is: %@", sender.uuid, pluginPayload[CENUnreadMessagesEvent.count],
 *           self.chat.name, eventPayload);
 * });
 * @endcode
 *
 * @discussion Setup with custom events list
 * @code
 * // objc 65714f73-d5ab-4396-b29f-b24346e970ae
 *
 * self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).configuration(@{
 *     CENUnreadMessagesConfiguration.events: @[@"ping", @"pong"]
 * }).store();
 *
 * self.chat.on(@"$unread", ^(CENEmittedEvent *event) {
 *     NSDictionary *pluginPayload = event.data;
 *     NSDictionary *eventPayload = pluginPayload[CENUnreadMessagesEvent.event];
 *     CENUser *sender = eventPayload[CENEventData.sender];
 *
 *     NSLog(@"%@ sent a message you haven't seen (there is %@ unread messages) in %@ the full "
 *           "event is: %@", sender.uuid, pluginPayload[CENUnreadMessagesEvent.count],
 *           self.chat.name, eventPayload);
 * });
 * @endcode
 *
 * @ref c42cac43-5326-4140-8835-e0890dd51e3a
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUnreadMessagesPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Update \b {chat's CENChat} activity.
 *
 * @discussion Change \b {chat's CENChat} \c active state to start / stop unread message counting
 * @code
 * // objc 56eaa0d6-5a1d-42a4-be47-3aa6529077fa
 *
 * // Focused on the chat room.
 * [CENUnreadMessagesPlugin setChat:self.chat active:YES];
 *
 * // Looking at any other chat room.
 * [CENUnreadMessagesPlugin setChat:self.chat active:NO];
 * @endcode
 *
 * @param chat \b {Chat CENChat} for which activity should be changed.
 * @param isActive Whether \b {chat CENChat} active at this moment or not.
 *
 * @ref 33ec5d6f-776f-4ee4-8908-b7f0271acb4d
 */
+ (void)setChat:(CENChat *)chat active:(BOOL)isActive;

/**
 * @brief Check whether \b {chat CENChat} marked as active or not.
 *
 * @discussion Retrieve current \b {chat CENChat} activity (visibility) state
 * @code
 * // objc ec34476d-3c19-4157-b2f5-52f988e1c9e0
 *
 * // Focused on the chat room.
 * [CENUnreadMessagesPlugin setChat:self.chat active:YES];
 *
 * BOOL isActive = [CENUnreadMessagesPlugin isChatActive:self.chat];
 * @endcode
 *
 * @param chat \b {Chat CENChat} for which activity should be checked.
 *
 * @return Whether \b {chat CENChat} active at this moment or not.
 *
 * @since 0.0.2
 *
 * @ref df109989-11f3-406f-9385-fea8f86e7373
 */
+ (BOOL)isChatActive:(CENChat *)chat;

/**
 * @brief Get current unread messages count for \b {chat CENChat}.
 *
 * @discussion Retrieve number of messages sent to inactive \b {chat CENChat}
 * @code
 * // objc 100a0889-deb2-45b0-8601-33c5c492c29d
 *
 * NSUInteger unreadCount = [CENUnreadMessagesPlugin unreadCountForChat:self.chat];
 * @endcode

 * @param chat \b {chat CENChat} for which count should be fetched.
 *
 * @return Number of unread events count.
 *
 * @since 0.0.2
 *
 * @ref 8cb40fb0-8112-4edd-ac82-fa614c327413
 */
+ (NSUInteger)unreadCountForChat:(CENChat *)chat;

/**
 * @brief Get current unread messages count for \c chat.
 *
 * @discussion Retrieve number of messages sent to inactive \b {chat CENChat}
 * @code
 * // objc ce1bc63f-0b80-4810-891e-15627850195b
 *
 * [CENUnreadMessagesPlugin fetchUnreadCountForChat:self.chat withCompletion:^(NSUInteger count) {
 *     // Handle received value.
 * }];
 * @endcode
 
 * @param chat Reference on \c chat instance for which count should be fetched.
 * @param block Block / closure which will be called at the end of fetch process and pass number of
 *     unread events count.
 *
 * @deprecated 0.0.2
 *
 * @ref 296e5709-5713-482a-90cf-d8ebc4ebe643
 */
+ (void)fetchUnreadCountForChat:(CENChat *)chat withCompletion:(void(^)(NSUInteger count))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "+unreadCountForChat: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
