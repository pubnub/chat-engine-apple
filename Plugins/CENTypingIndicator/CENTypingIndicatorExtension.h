#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for typing indicator support.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENTypingIndicatorExtension : CEPExtension


#pragma mark Information

/**
 * @brief Stores whether user currently typing or not.
 */
@property (nonatomic, readonly, assign, getter = isTyping) BOOL typing;


#pragma mark - Chat activity management

/**
 * @brief Notify \b {chat CENChat} participants what \b {local user CENMe} started message input.
 *
 * @code
 * // objc
 * self.chat.extension([CENTypingIndicatorPlugin class],
 *                     ^(CENTypingIndicatorExtension *extension) {
 *
 *     [extension startTyping];
 * }];
 * @endcode
 */
- (void)startTyping;

/**
 * @brief Notify \b {chat CENChat} participants what \b {local user CENMe} stopped message input.
 *
 * @code
 * // objc
 * self.chat.extension([CENTypingIndicatorPlugin class],
 *                     ^(CENTypingIndicatorExtension *extension) {
 *
 *     [extension stopTyping];
 * }];
 * @endcode
 */
- (void)stopTyping;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
