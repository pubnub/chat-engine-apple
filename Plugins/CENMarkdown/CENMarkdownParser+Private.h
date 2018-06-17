/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMarkdownParser.h"


#pragma mark Private interface declaration

@interface CENMarkdownParser (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configure \a Markdown markup parser.
 *
 * @discussion \b Example (macOS):
 * @code
 * CENMarkdownParser *parser = [CENMarkdownParser parserWithConfiguration:@{
 *     CENMarkdownParserElement.italicAttributes: @{
 *         NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Italic" size:16.f],
 *         NSForegroundColorAttributeName: NSColor.darkGrayColor
 *     }
 * }];
 * @endcode
 *
 * @discussion \b Example (other):
 * @code
 * CENMarkdownParser *parser = [CENMarkdownParser parserWithConfiguration:@{
 *     CENMarkdownParserElement.italicAttributes: @{
 *         NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Italic" size:16.f],
 *         NSForegroundColorAttributeName: UIColor.darkGrayColor
 *     }
 * }];
 * @endcode
 *
 * @note It is possible to specify \a NSFontAttributeName only for \a CENMarkdownParserElement.defaultAttributes and
 *       corresponding traits will be applied on it for \a italic and \a bold. \a CENMarkdownParserElement.codeAttributes is
 *       exlusion which will use privately specified font to set defaults (if not passed during configuration).
 * @note It is possible to specify \a NSForegroundColorAttributeName only for \a CENMarkdownParserElement.defaultAttributes
 *       and it will be used by default for rest attribute types.
 *
 * @param configuration Reference on dictionary where under keys defined in \b CENMarkdownParserElement struct keys stored
 *                      corresponding text attributes which will be applied to corresponding portions of text (basing on
 *                      current \a Markdown element type).
 *
 * @return Configured and ready to use parser instance.
 */
+ (instancetype)parserWithConfiguration:(nullable NSDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *)configuration;


#pragma mark - Parse

/**
 * @brief      Parse passed string which which may include Markdown markup elements.
 * @discussion Parsing will be done asynchronous to make it possible to handle embedded images (download itself is
 *             synchronous) and not to block thread from which parsing has been called.
 *
 * @param markdown   Reference on string which should be processed.
 * @param completion Reference on parse completion block. Block pass only one argument - reference on parsed object (it can
 *                   be \a NSAttributesString if \c markdown contain Markdown markup elements or \a NSString if not).
 */
- (void)parseMarkdownString:(NSString *)markdown withCompletion:(void(^)(id string))completion;

#pragma mark -


@end
