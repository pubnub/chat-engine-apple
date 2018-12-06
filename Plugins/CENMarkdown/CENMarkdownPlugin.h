#import <CENChatEngine/CEPPlugin.h>
#import "CENMarkdownParser.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 */
typedef struct CENMarkdownConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * \b Default: \c @[@"message"]
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief Key or key-path in \a data payload where string with Markdown markup is stored.
     *
     * \b Default: \c text
     */
    __unsafe_unretained NSString *messageKey;
    
    /**
     * @brief \a NSDictionary with \b CENMarkdownParser configuration options.
     *
     * @discussion \b CENMarkdownParser allow to configure fonts which should be used for various
     * traits by specifying keys used by \a NSAttributedString. Please see \b CENMarkdownParser
     * header for more information about configuration options.
     */
    __unsafe_unretained NSString *parserConfiguration;
} CENMarkdownConfigurationKeys;

extern CENMarkdownConfigurationKeys CENMarkdownConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} even data pre-formatter to parse received Markdown markup.
 *
 * @discussion This plugin allow automatically parse Markdown markup to \a NSAttributedString for
 * configured events.
 *
 * @discussion Setup with default configuration:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();
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
 * @discussion Setup with custom events and bold font:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENMarkdownConfiguration.events: @[@"ping", @"pong"],
 *     CENMarkdownConfiguration.parserConfiguration: @{
 *         CENMarkdownParserElement.boldAttributes: @{
 *             // For macOS use corresponding classes.
 *             NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f],
 *             NSForegroundColorAttributeName: [UIColor redColor]
 *         }
 *     }
 * }).store();
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
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMarkdownPlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
