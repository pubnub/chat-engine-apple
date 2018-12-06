#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for unread messages / events counter support.
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENUnreadMessagesExtension : CEPExtension


#pragma mark Information

/**
 * @brief Currently unread messages/events count.
 */
@property (nonatomic, readonly, assign) NSUInteger unreadCount;


#pragma mark - Chat activity management

/**
 * @brief Mark \b {Chat CENChat} as active chat and stop unseen messages count.
 *
 * @code
 * // objc
 * self.chat.extension([CENUnreadMessagesPlugin class],
 *                     ^(CENUnreadMessagesExtension *extension) {
 *
 *     [extension active];
 * });
 * @endcode
 */
- (void)active;

/**
 * @brief Mark \b {Chat CENChat} as inactive chat and start unseen messages count.
 *
 * @code
 * // objc
 * self.chat.extension([CENUnreadMessagesPlugin class],
 *                     ^(CENUnreadMessagesExtension *extension) {
 *
 *     [extension inactive];
 * });
 * @endcode
 */
- (void)inactive;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
