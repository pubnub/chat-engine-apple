#import <CENChatEngine/CEPPlugin.h>
#import "CENTypingIndicatorExtension.h"


#pragma mark Structures

/**
 * @brief Structure which describe available configuration option key names.
 *
 * @ref e7aeed2e-d6cf-47e2-a1e4-ea76c3a7141c
 */
typedef struct CETypingIndicatorConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * @\b Default: \c @[@"message"]
     *
     * @ref d85907fd-d160-4377-a5ad-fa35bdbe5903
     */
    __unsafe_unretained NSString *events;
    /**
     * @brief Typing event timeout.
     *
     * \b Default: \c 1.0
     *
     * @ref 1de049a8-3338-4a52-95ed-5c36a2e03189
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
 * @discussion Setup with default configuration
 * @code
 * // objc 88b5eaf7-4c3f-48d9-9ea9-29ef2fba9f9e
 *
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();
 *
 * chat.on(@"$typingIndicator.*", ^(CENEmittedEvent *event) {
 *     CENUser *user = ((NSDictionary *)event.data)[CENEventData.sender];
 *
 *     if ([event.event isEqualToString:@"$typingIndicator.startTyping"]) {
 *         // Handle typing activity in chat started by 'user'.
 *     } else {
 *         // Handle typing activity in chat stopped by 'user'.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom timeout value
 * @code
 * // objc c6f6155f-64e8-47be-bcec-43217c74e35a
 *
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENTypingIndicatorConfiguration.timeout: @(5.f)
 * }).store();
 *
 * chat.on(@"$typingIndicator.*", ^(CENEmittedEvent *event) {
 *     CENUser *user = ((NSDictionary *)event.data)[CENEventData.sender];
 *
 *     if ([event.event isEqualToString:@"$typingIndicator.startTyping"]) {
 *         // Handle typing activity in chat started by 'user'.
 *     } else {
 *         // Handle typing activity in chat stopped by 'user'.
 *     }
 * });
 * @endcode
 *
 * @ref 9a103a9b-8be3-4f1f-9473-38c3af6511f0
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENTypingIndicatorPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Update typing indicator state.
 *
 * @discussion Change typing indicator state for specified \b {chat CENChat}
 * @code
 * // objc af2dcbc1-ed94-4cb1-b687-b5ccc7d3b91e
 *
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
 *
 * @ref 935f8ed3-e79c-4327-ae8f-84bb140c2b6e
 */
+ (void)setTyping:(BOOL)isTyping inChat:(CENChat *)chat;

/**
 * @brief Check whether typing indicator currently \a ON in \b {chat CENChat} or not.
 *
 * @discussion Check whether typing indicator is on in specified {chat CENChat} or off
 * @code
 * // objc 3cdffe03-652c-4581-abb8-aa2dec3e27ca
 *
 * BOOL isTyping = [CENTypingIndicatorPlugin isTypingInChat:self.chat];
 * @endcode

 * @param chat \b {Chat CENChat} for which check should be done.
 *
 * @return Whether typing indicator currently on in specified \b {chat CENChat} or off.
 *
 * @since 0.0.2
 *
 * @ref 5ab2601e-c5dd-4b9a-944e-26b182e056e2
 */
+ (BOOL)isTypingInChat:(CENChat *)chat;

/**
 * @brief Check whether typing indicator currently \a ON in \b {chat CENChat} or not.
 *
 * @discussion Check whether typing indicator is on in specified {chat CENChat} or off
 * @code
 * // objc 50b72e68-b287-4df8-a87d-067db6b7c4c2
 *
 * [CENTypingIndicatorPlugin checkIsTypingInChat:self.chat withCompletion:^(BOOL isTyping) {
 *     // Handle received value.
 * }];
 * @endcode
 
 * @param chat \b {Chat CENChat} for which check should be done.
 * @param block Block / closure which will be called at the end of check and pass whether typing
 *     indicator currently on or off.
 *
 * @deprecated 0.0.2
 *
 * @ref c664d5c5-4e17-4ebb-8631-55627b7d2bfd
 */
+ (void)checkIsTypingInChat:(CENChat *)chat withCompletion:(void(^)(BOOL isTyping))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "+isTypingInChat: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
