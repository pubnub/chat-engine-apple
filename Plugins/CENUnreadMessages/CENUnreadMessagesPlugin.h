#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief Structure which describe keys for unread message event payload.
 */
typedef struct CENUnreadMessagesEventKeys {
    /**
     * @brief \b {Chat CENChat} for which number of unread messages / events did change.
     */
    __unsafe_unretained NSString *chat
        DEPRECATED_MSG_ATTRIBUTE("This field deprecated since 1.1.0. Reference on chat available "
                                 "during registration on event or as part of local event object");
    
    /**
     * @brief Stores reference on name of key under which stored sender \c uuid.
     */
    __unsafe_unretained NSString *sender;
    
    /**
     * @brief Stores reference on name of key under which stored reference on \a raw event payload.
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief Stores reference on name of key under which stored current number of unread
     * messages / events.
     */
    __unsafe_unretained NSString *count;
} CENUnreadMessagesEventKeys;

extern CENUnreadMessagesEventKeys CENUnreadMessagesEvent;

/**
 * @brief Structure which describe available configuration option key names.
 */
typedef struct CENUnreadMessagesConfigurationKeys {
    /**
     * @brief List of event names which should be treated as \c message and count.
     *
     * @\b Default: \c @[@"message"]
     */
    __unsafe_unretained NSString *events;
} CENUnreadMessagesConfigurationKeys;

extern CENUnreadMessagesConfigurationKeys CENUnreadMessagesConfiguration;


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} unread messages counting plugin.
 *
 * @discussion Plugin allow to count unread messages for \c inactive \b {chat CENChat}.
 *
 * @discussion Setup with default configuration:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).store();
 *
 * self.chat.on(@"$unread", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *
 *     NSLog(@"%@ sent a message you haven't seen (there is %@ unread messages) in %@ the full "
 *           "event is: %@", payload[CENUnreadMessagesEvent.sender],
 *           payload[CENUnreadMessagesEvent.count], chat.name,
 *           payload[CENUnreadMessagesEvent.event]);
 * });
 * @endcode
 *
 * @discussion Setup with custom events list:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).configuration(@{
 *     CENUnreadMessagesConfiguration.events = @[@"ping", @"pong"]
 * }).store();
 *
 * self.chat.on(@"$unread", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *
 *     NSLog(@"%@ sent a message you haven't seen (there is %@ unread messages) in %@ the full "
 *           "event is: %@", payload[CENUnreadMessagesEvent.sender],
 *           payload[CENUnreadMessagesEvent.count], chat.name,
 *           payload[CENUnreadMessagesEvent.event]);
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENUnreadMessagesPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Update chat activity.
 *
 * @code
 * // objc
 * // Focused on the chat room.
 * [CENUnreadMessagesPlugin setChat:self.chat active:YES];
 *
 * // Looking at any other chat room.
 * [CENUnreadMessagesPlugin setChat:self.chat active:NO];
 * @endcode
 *
 * @param chat \b {Chat CENChat} for which activity should be changed.
 * @param isActive Whether \b {chat CENChat} active at this moment or not.
 */
+ (void)setChat:(CENChat *)chat active:(BOOL)isActive;

/**
 * @brief Get current unread messages count for \c chat.
 *
 * @code
 * // objc
 * [CENUnreadMessagesPlugin fetchUnreadCountForChat:self.chat withCompletion:^(NSUInteger count) {
 *     // Handle received value.
 * }];
 * @endcode
 
 * @param chat Reference on \c chat instance for which count should be fetched.
 * @param block Block / closure which will be called at the end of fetch process and pass number of
 *     unread events count.
 */
+ (void)fetchUnreadCountForChat:(CENChat *)chat withCompletion:(void(^)(NSUInteger count))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
