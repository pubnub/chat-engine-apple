#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CETypingIndicatorConfigurationKeys {
    
    /**
     * @brief      Stores reference on name of key under which stored active typing timeout.
     * @discussion This is delay or user inactivity to send 'stop typing' event.
     */
    __unsafe_unretained NSString *timeout;
} CENTypingIndicatorConfigurationKeys;

extern CENTypingIndicatorConfigurationKeys CENTypingIndicatorConfiguration;


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b CEChat typing indicator plugin.
 * @discussion This plugin adds the ability to send updates when user start / stop typing message.
 *
 * @discussion Register plugin with pre-defined time to switch indicator off:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENTypingIndicatorConfiguration.timeout: @(1.f)
 * }).store();
 * @endcode
 *
 * @discussion Listen for typing indicator activity:
 * @code
 * chat.on(@"$typingIndicator.startTyping", ^{
 *     // Handle typing activity in chat started.
 * });
 *
 * chat.on(@"$typingIndicator.stopTyping", ^{
 *     // Handle typing activity in chat stopped.
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
 * @brief      Update typing indicator state.
 * @discussion Set whether user currently typing or not.
 *
 * @discussion Manage typing indicator activity:
 * @code
 * // Emit the typing event.
 * [CENTypingIndicatorPlugin setTyping:YES inChat:chat];
 *
 * // Manually emit the stop tying event this is automagically emitted after the timeout period, or when a message is sent.
 * [CENTypingIndicatorPlugin setTyping:NO inChat:chat];
 * @endcode
 *
 * @param isTyping Reference on flag which allow to specify whether user typing at this moment or not.
 * @param chat     Reference on \c chat instance for which typing indicator should be changed.
 */
+ (void)setTyping:(BOOL)isTyping inChat:(CENChat *)chat;

/**
 * @brief  Check whether typing indicator currently \a ON in \c chat or not.
 *
 * @discussion \b Example:
 * @code
 * [CENTypingIndicatorPlugin checkIsTypingInChat:chat withCompletion:^(BOOL isTyping) {
 *     // Handle received value.
 * }];
 * @endcode
 
 * @param chat  Reference on \c chat instance for which check should be done.
 * @param block Reference on block which will be called at the end of verification process. Block pass only one
 *              argument - whether typing indicator is active or not.
 */
+ (void)checkIsTypingInChat:(CENChat *)chat withCompletion:(void(^)(BOOL isTyping))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
