#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for unread messages / events counter support.
 *
 * @ref 548594c1-273a-452a-9fcb-2a9b8797b80e
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUnreadMessagesExtension : CEPExtension


#pragma mark Information

/**
 * @brief Whether chat currently active or not.
 *
 * @since 0.0.2
 *
 * @ref 2e85d125-a544-46ab-a9dd-dbbdfba989fd
 */
@property (nonatomic, readonly, getter = isActive, assign) BOOL active NS_SWIFT_NAME(active);

/**
 * @brief Currently unread messages / events count.
 *
 * @ref 36913093-42b9-4778-af44-d567d83405a9
 */
@property (nonatomic, readonly, assign) NSUInteger unreadCount;


#pragma mark - Chat activity management

/**
 * @brief Mark \b {chat CENChat} as active and stop unseen messages count.
 *
 * @discussion Mark specified \b {chat CENChat} as \c active
 * @code
 * // objc a3889068-e113-4116-a2ab-06e48ff83df1
 *
 * CENUnreadMessagesExtension *extension = self.chat.extension([CENUnreadMessagesPlugin class]);
 * [extension active];
 * @endcode
 *
 * @ref e4526183-4678-47ba-932a-ce4e4b24ecc0
 */
- (void)active;

/**
 * @brief Mark \b {chat CENChat} as inactive and start unseen messages count.
 *
 * @discussion Mark specified \b {chat CENChat} as \c inactive
 * @code
 * // objc e91e94dd-23be-4bc7-9ac2-f34e9931722a
 *
 * CENUnreadMessagesExtension *extension = self.chat.extension([CENUnreadMessagesPlugin class]);
 * [extension inactive];
 * @endcode
 *
 * @ref 8634f663-48bb-43e1-8e68-1e041fca09bc
 */
- (void)inactive;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
