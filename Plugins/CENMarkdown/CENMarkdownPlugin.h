#import <CENChatEngine/CEPPlugin.h>
#import "CENMarkdownParser.h"


#pragma mark Types & Structures

/**
 * @brief Block / closure which should be passed for 'CENMarkdownConfiguration.parser' if custom
 * parser used.
 */
typedef void(^CENMarkdownParserCallback)(NSString *string, void(^completion)(id parsedData));

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 1478a96b-9368-4acd-b16a-598e621fad68
 */
typedef struct CENMarkdownConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * \b Default: \c @[@"message"]
     *
     * @ref b60d187f-d0b1-41ab-9282-3f88c53c3f10
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief Key or key-path in \a data payload where string with Markdown markup is stored.
     *
     * \b Default: \c text
     *
     * @ref b5696613-b48e-4304-acfa-46c13f89136e
     */
    __unsafe_unretained NSString *messageKey;
    
    /**
     * @brief Key or key-path in \a data payload where processed data will be stored.
     *
     * \b Default: \c text
     *
     * @since 0.0.2
     *
     * @ref cad87bbf-d8ec-453b-92c9-7980724b5cc7
     */
    __unsafe_unretained NSString *parsedMessageKey;
    
    /**
     * @brief Block / closure which can be used to call own Markdown markup processor.
     *
     * @discussion Block / closure aside of message with Markdown markup will pass reference on
     * processing completion block / closure which will expect for processed data. Resulting data
     * by default will replace original (if \b {parsedMessageKey} not configured).
     *
     * @ref 07469e5a-9396-41bb-9ca2-850f6485ae1b
     */
    __unsafe_unretained NSString *parser;
    
    /**
     * @brief \a NSDictionary with \b CENMarkdownParser configuration options.
     *
     * @discussion \b CENMarkdownParser allow to configure fonts which should be used for various
     * traits by specifying keys used by \a NSAttributedString. Please see \b CENMarkdownParser
     * header for more information about configuration options.
     *
     * @ref 45a86c5d-9fcc-4892-9e91-236d2cc44c09
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
 * @discussion Setup with default configuration
 * @code
 * // objc e0206d47-61d5-420f-a074-1c4bf8ab9b60
 *
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).store();
 *
 * self.chat.on(@"message", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *
 *     if ([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]) {
 *         // Use attributed string created from string with Markdown markup.
 *     } else {
 *         // There was no Markdown markup in received event.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom events and bold font
 * @code
 * // objc 17720548-8e06-4972-aeb8-dab5e3c8e9c7
 *
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENMarkdownConfiguration.events: @[@"ping", @"pong"],
 *     CENMarkdownConfiguration.parserConfiguration: @{
 *         CENMarkdownParserElement.boldAttributes: @{
 *             NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f],
 *             NSForegroundColorAttributeName: [UIColor redColor]
 *         }
 *     }
 * }).store();
 *
 * self.chat.on(@"message", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *
 *     if ([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]) {
 *         // Use attributed string created from string with Markdown markup.
 *     } else {
 *         // There was no Markdown markup in received event.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom Markdown processor and result store key
 * @code
 * // objc 919ac917-5207-4310-82fe-3c54f48cfb8b
 *
 * void(^parser)(NSString *, void(^)(id)) = ^(NSString *markup, void(^completion)(id parsed)) {
 *     [self.parser processMarkup:markup withCompletion:^(NSAttributedString *parsedMarkup) {
 *         completion(parsedMarkup);
 *     }];
 * };
 *
 * self.client.proto(@"Chat", [CENMarkdownPlugin class]).configuration(@{
 *     CENMarkdownConfiguration.parsedMessageKey: @"processedMarkdown",
 *     CENMarkdownConfiguration.parser: parser
 * }).store();
 *
 * self.chat.on(@"message", ^(CENEmittedEvent *event) {
 *     NSDictionary *payloadData = event.data[CENEventData.data];
 *
 *     if ([payloadData[@"processedMarkdown"] isKindOfClass:[NSAttributedString class]]) {
 *         // Use attributed string created from string with Markdown markup.
 *     } else {
 *         // There was no Markdown markup in received event.
 *     }
 * });
 * @endcode
 *
 * @ref 76d3e436-4fcf-4d0d-b3f6-373806f254e0
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENMarkdownPlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
