#import <CENChatEngine/CEPExtension.h>


/**
 * @brief      \b CENChat unread messages/events counter.
 * @discussion Plugin workhorse which use passed configuration to figure out whether received event should be counted. Plugin
 *             keep events listeners updated on changes.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENUnreadMessagesExtension : CEPExtension


#pragma mark Information

/**
 * @brief  Stores reference on currently unread messages/events count.
 */
@property (nonatomic, readonly, assign) NSUInteger unreadCount;


#pragma mark - Chat activity management

/**
 * @brief      Mark \b CENChat as active chat.
 * @discussion \c unreadCount will be reset to \b 0 and won't be updated till \c active method call.
 */
- (void)active;

/**
 * @brief      Mark \b CENChat as  inactive chat.
 * @discussion Start \c unreadCount updateds and observers notification.
 */
- (void)inactive;

#pragma mark -


@end
