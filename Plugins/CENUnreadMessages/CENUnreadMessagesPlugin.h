#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief  Structure wich describe keys within unread message event payload.
 */
typedef struct CENUnreadMessagesEventKeys {
    
    /**
     * @brief  Stores reference on name of key under which stored chat for which number of unread messages / events did
     *         change.
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief  Stores reference on name of key under which stored sender \c uuid.
     */
    __unsafe_unretained NSString *sender;
    
    /**
     * @brief  Stores reference on name of key under which stored reference on \a raw event payload.
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief  Stores reference on name of key under which stored current number of unread messages / events.
     */
    __unsafe_unretained NSString *count;
} CENUnreadMessagesEventKeys;

extern CENUnreadMessagesEventKeys CENUnreadMessagesEvent;

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CENUnreadMessagesConfigurationKeys {
    
    /**
     * @brief  Stores reference on name of key under which stored list of event names which should be treated as \c message
     *         and count.
     */
    __unsafe_unretained NSString *events;
} CENUnreadMessagesConfigurationKeys;

extern CENUnreadMessagesConfigurationKeys CENUnreadMessagesConfiguration;


#pragma mark Class forward

@class CENChat;


/**
 * @brief      \b CENChat unread messages counting plugin.
 * @discussion This plugin adds the ability to count unread messages for \a inactive chat instances (not focues).
 *
 * @discussion Register plugin which by default handle 'message' events to count unread:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client registerProtoPlugin:[CENUnreadMessagesPlugin class] forObjectType:@"Chat" configuration:nil];
 * @endcode
 *
 * @discussion Register plugin which will hanlde custom events to count unread:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [CENUnreadMessagesPlugin class]).configuration(@{
 *     CENUnreadMessagesConfiguration.events = @[@"ping", @"pong"]
 * }).store();
 * @endcode
 *
 * @discussion Listen for unread count change:
 * @code
 * chat.on(@"$unread", ^(NSDictionary *payload) {
 *     CENChat *chat = payload[CENUnreadMessagesEvent.chat];
 *
 *     NSLog(@"%@ sent a message you havn't seen (there is %@ unread messages) in %@ the full event is: %@",
 *           payload[CENUnreadMessagesEvent.sender], payload[CENUnreadMessagesEvent.count], chat.name,
 *           payload[CENUnreadMessagesEvent.event]);
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENUnreadMessagesPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief      Update chat activity.
 * @discussion Set whether chat currently active or not.
 *
 * @discussion Manage chat activity :
 * @code
 * // Focused on the chatroom.
 * [CENUnreadMessagesPlugin setChat:chat active:YES];
 *
 * // Looking at any other chatroom.
 * [CENUnreadMessagesPlugin setChat:chat active:NO];
 * @endcode
 *
 * @param chat     Reference on \c chat instance for which activity should be changed.
 * @param isActive Reference on flag which allow to specify whether \c chat active at this moment or not.
 */
+ (void)setChat:(CENChat *)chat active:(BOOL)isActive;

/**
 * @brief  Get current unread messages count for \c chat.
 *
 * @discussion \b Example:
 * @code
 * [CENUnreadMessagesPlugin fetchUnreadCountForChat:chat withCompletion:^(NSUInteger count) {
 *     // Handle received value.
 * }];
 * @endcode
 
 * @param chat  Reference on \c chat instance for which count should be fetched.
 * @param block Reference on block which will be called at the end of fetch process. Block pass only one argument - count of
 *              unread messages.
 */
+ (void)fetchUnreadCountForChat:(CENChat *)chat withCompletion:(void(^)(NSUInteger count))block;

#pragma mark -


@end
