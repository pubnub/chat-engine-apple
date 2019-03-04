#import <CENChatEngine/CEPPlugin.h>
#import "CENEmojiExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 21bd8606-530d-4ae0-82f4-b06bd85ba803
 */
typedef struct CENEmojiConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * \b Default: \c @[@"message"]
     *
     * @ref ce010d4d-f8e8-4804-84c0-e26d15c34c0a
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief Key or key-path in \a data payload where string which should be pre-processed.
     *
     * \b Default: \c text
     *
     * @ref 93048cb0-d7ba-44df-94f5-89c3f8a862a4
     */
    __unsafe_unretained NSString *messageKey;
    
    /**
     * @brief Boolean which specify whether system emoji should be used during translation from
     * text.
     *
     * @discussion Native Apple's emoji doesn't have representation for: \c bowtie, \c octocat,
     * \c squirrel, \c gun, \c neckbeard, \c feelsgood, \c finnadie, \c goberserk, \c godmode,
     * \c hurtrealbad, \c rage1, \c rage2, \c rage3, \c rage4, \c suspect, \c trollface, \c shipit.
     *
     * \b Default: \c NO
     *
     * @ref 34267e6c-e8b5-4880-87f8-5e57769438bf
     */
    __unsafe_unretained NSString *useNative;
    
    /**
     * @brief URL where emoji PNG images is stored.
     *
     * @discussion By default plugin uses \a NSAttributedString to render emoji images from their
     * text representation. If required, it is possible to change host from which images is pulled
     * out using this configuration property.
     *
     * \b Default: \c https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis
     *
     * @ref 8e4ca473-1171-4772-a9bc-e3ddd2f27544
     */
    __unsafe_unretained NSString *emojiURL;
} CENEmojiConfigurationKeys;

extern CENEmojiConfigurationKeys CENEmojiConfiguration;


#pragma mark - Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} emitted / received data pre-processor to textify / emojify emoji.
 *
 * @discussion This plugin automatically replace known emoji names from received message with emoji
 * from specified emoji host (or system if configured) and vice versa when sending message.
 *
 * @discussion Setup with default configuration
 * @code
 * // objc 566ae131-5d26-43db-a183-924ca3e7c0cf
 *
 * self.client.proto(@"Chat", [CENEmojiPlugin class]).store();
 *
 * self.chat.on(@"message", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *
 *     if ([payload[CENEventData.data] isKindOfClass:[NSAttributedString class]]) {
 *         // Use attributed string created from string with Markdown markup.
 *     } else {
 *         // There was no Markdown markup in received event.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom events and system emoji
 * @code
 * // objc 13b0ce68-ed37-4264-b6a0-427feee3b7f8
 *
 * self.client.proto(@"Chat", [CENEmojiPlugin class]).configuration(@{
 *     CENEmojiConfiguration.events: @[@"ping", @"pong"],
 *     CENEmojiConfiguration.useNative: @YES
 * }).store();
 *
 * self.chat.on(@"pong", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *
 *     // Output data as regular string, since system's emoji used which doesn't require special
 *     // treatment.
 * });
 * @endcode
 *
 * @ref 4e48d883-1539-4c36-8a8f-7b6d2f1aff9e
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENEmojiPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Translate text emoji representation to native emoji (if enabled) or generate URL for
 * remote emoji PNG download.
 *
 * @discussion Get URL which can be used to fetch specified emoji visual representation
 * @code
 * // objc e71cea38-c9fe-485c-a968-f1c4f4a37acd
 *
 * NSLog(@"URL for ':gift:': %@", [CENEmojiPlugin emojiFrom:@":gift:" usingChat:self.chat]);
 * @endcode
 *
 * @param string Stringified emoji representation for which visual representation should be
 *     retrieved.
 * @param chat \b {Chat CENChat} which is used to get extension with proper configuration.
 *
 * @return URL or native emoji representation (if configured by setting
 * \b {CENEmojiConfiguration.useNative} to \c YES).
 *
 * @ref 247de945-b7db-4e6a-8f94-d2c2ee886d72
 */
+ (nullable NSString *)emojiFrom:(NSString *)string usingChat:(CENChat *)chat;

/**
 * @brief Find emoji names which fully or partly match to passed \c name.
 *
 * @discussion Search for emoji names which partly match to passed value
 * @code
 * // objc 646cf59d-6c26-4170-8ca8-d07989b9e536
 *
 * NSArray<NSString *> *emoji = [CENEmojiPlugin emojiWithName:@":smil" usingChat:self.chat];
 * NSLog(@"Emoji which starts with ':smil': %@", emoji);
 * @endcode
 *
 * @param name Full or partial name of emoji which should be found.
 * @param chat \b {Chat CENChat} which is used to get extension with proper configuration.
 *
 * @return List of emoji names which match to passed \c name.
 *
 * @ref 2d1df2c3-30e2-4e4f-b5f1-44218ce5a656
 */
+ (NSArray<NSString *> *)emojiWithName:(NSString *)name usingChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
