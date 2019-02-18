#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for typing indicator support.
 *
 * @ref c4003553-c08e-43b2-8a1d-cb3392c16fe5
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENTypingIndicatorExtension : CEPExtension


#pragma mark Information

/**
 * @brief Whether user currently typing or not.
 *
 * @ref 9eec1e63-7f8d-413c-94f4-6f3730a02ffd
 */
@property (nonatomic, readonly, assign, getter = isTyping) BOOL typing;


#pragma mark - Chat activity management

/**
 * @brief Notify \b {chat CENChat} participants what \b {local user CENMe} started message input.
 *
 * @discussion Set \c typing indicator for specified \b {chat CENChat}
 * @code
 * // objc 674322a2-340f-40e3-8eef-3bc8346cc9bb
 *
 * CENTypingIndicatorExtension *extension = self.chat.extension([CENTypingIndicatorPlugin class]);
 * [extension startTyping];
 * @endcode
 *
 * @ref ce94881b-6b7c-47c1-88c9-d0bbfd014825
 */
- (void)startTyping;

/**
 * @brief Notify \b {chat CENChat} participants what \b {local user CENMe} stopped message input.
 *
 * @discussion Remove \c typing indicator for specified \b {chat CENChat}
 * @code
 * // objc 40af909b-5378-4127-aa16-1aa4326a5c71
 *
 * CENTypingIndicatorExtension *extension = self.chat.extension([CENTypingIndicatorPlugin class]);
 * [extension stopTyping];
 * @endcode
 *
 * @ref c6ab7dd8-5a72-4483-a98a-00945678aad7
 */
- (void)stopTyping;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
