#import <CENChatEngine/CEPExtension.h>


/**
 * @brief      \b CENChat unread messages/events counter.
 * @discussion Plugin workhorse which use passed configuration to figure out when typing indicator should be reset.
 *             Notify remote users about typing indicator change for local user.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENTypingIndicatorExtension : CEPExtension


#pragma mark Information

/**
 * @brief  Stores whether user currently typing or not.
 */
@property (nonatomic, readonly, assign, getter = isTyping) BOOL typing;


#pragma mark - Chat activity management

/**
 * @brief      Mark \b CENChat as active chat.
 * @discussion \c unreadCount will be reset to \b 0 and won't be updated till \c active method call.
 */
- (void)startTyping;

/**
 * @brief      Mark \b CENChat as  inactive chat.
 * @discussion Start \c unreadCount updateds and observers notification.
 */
- (void)stopTyping;

#pragma mark -


@end
