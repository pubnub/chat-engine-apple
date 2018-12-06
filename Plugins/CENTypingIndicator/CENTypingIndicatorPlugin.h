#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief Structure which describe available configuration option key names.
 */
typedef struct CETypingIndicatorConfigurationKeys {
    /**
     * @brief Typing event timeout.
     *
     * \b Default: \c 1.0
     */
    __unsafe_unretained NSString *timeout;
} CENTypingIndicatorConfigurationKeys;

extern CENTypingIndicatorConfigurationKeys CENTypingIndicatorConfiguration;


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} typing indicator plugin.
 *
 * @discussion Plugin adds the ability to send updates when user start / stop typing message.
 *
 * @discussion Setup with default configuration:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();
 *
 * chat.on(@"$typingIndicator.*", ^(CENEmittedEvent *event) {
 *     if ([event.event isEqualToString:@"$typingIndicator.startTyping"]) {
 *         // Handle typing activity in chat started.
 *     } else {
 *         // Handle typing activity in chat stopped.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom timeout value:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENTypingIndicatorConfiguration.timeout: @(5.f)
 * }).store();
 *
 * chat.on(@"$typingIndicator.*", ^(CENEmittedEvent *event) {
 *     if ([event.event isEqualToString:@"$typingIndicator.startTyping"]) {
 *         // Handle typing activity in chat started.
 *     } else {
 *         // Handle typing activity in chat stopped.
 *     }
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENTypingIndicatorPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Update typing indicator state.
 *
 * @code
 * // objc
 * // Emit the typing event.
 * [CENTypingIndicatorPlugin setTyping:YES inChat:self.chat];
 *
 * // Manually emit the stop tying event this is automatically emitted after the timeout period,
 * // or when a message is sent.
 * [CENTypingIndicatorPlugin setTyping:NO inChat:self.chat];
 * @endcode
 *
 * @param isTyping Whether user typing at this moment or not.
 * @param chat \b {Chat CENChat} for which typing indicator should be changed.
 */
+ (void)setTyping:(BOOL)isTyping inChat:(CENChat *)chat;

/**
 * @brief Check whether typing indicator currently \a ON in \b {chat CENChat} or not.
 *
 * @code
 * // objc
 * [CENTypingIndicatorPlugin checkIsTypingInChat:self.chat withCompletion:^(BOOL isTyping) {
 *     // Handle received value.
 * }];
 * @endcode
 
 * @param chat \b {Chat CENChat} for which check should be done.
 * @param block Block / closure which will be called at the end of check and pass whether typing
 *     indicator currently on or off.
 */
+ (void)checkIsTypingInChat:(CENChat *)chat withCompletion:(void(^)(BOOL isTyping))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
