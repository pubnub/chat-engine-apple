/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENMarkdownParser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENMarkdownParser (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure \c Markdown markup language parser.
 *
 * @param configuration \a NSDictionary with information which is required to set layout for various
 *     text styles which can be expressed by \c Markdown markup.
 *
 * @return Configured and ready to use parser.
 */
+ (instancetype)parserWithConfiguration:(nullable NSDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *)configuration;


#pragma mark - Parse

/**
 * @brief Perform \c Markdown markup string parsing.
 *
 * @param markdown String with \c Markdown markups.
 * @param completion Block / closure which will be called at the end of parse process and pass
 *     resulting string.
 */
- (void)parseMarkdownString:(NSString *)markdown withCompletion:(void(^)(id string))completion;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
