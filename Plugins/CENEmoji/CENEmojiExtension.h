#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for emoji-to-text and text-to-emoji support.
 *
 * @ref 698ecfeb-f0b2-471e-bc43-06ac96e056a0
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENEmojiExtension : CEPExtension


#pragma mark - Preprocessing

/**
 * @brief Translate text emoji representation to native emoji (if enabled) or generate URL for
 * remote emoji PNG download.
 *
 * @discussion Get URL which can be used to fetch specified emoji visual representation
 * @code
 * // objc 089189e1-ae27-4cb3-b535-8a0308603f6d
 *
 * CENEmojiExtension *extension = self.chat.extension([CENEmojiPlugin class]);
 * NSLog(@"URL for ':gift:': %@", [extension emojiFrom:@":gift:"]);
 * @endcode
 *
 * @param string Stringified emoji representation for which visual representation should be
 *     retrieved.
 *
 * @return Native system emoji or URL to download image from remote server.
 *
 * @ref 24e24cf9-d543-4396-a533-e9d960c58aec
 */
- (NSString *)emojiFrom:(NSString *)string;


#pragma mark - Search

/**
 * @brief Find emoji names which fully or partly match to passed \c name.
 *
 * @discussion Search for emoji names which partly match to passed value
 * @code
 * // objc e69aad73-fd67-4dc3-be91-2d7ec32215a6
 *
 * CENEmojiExtension *extension = self.chat.extension([CENEmojiPlugin class]);
 * NSLog(@"Emoji which starts with ':smil': %@", [extension searchFor:@":smil"]);
 * @endcode
 *
 * @param name Full or partial name of emoji which should be found.
 *
 * @return List of emoji names which match to passed \c name.
 *
 * @ref 974494d6-cd5c-44f8-9ffa-aaffb56f0b66
 */
- (NSArray<NSString *> *)emojiWithName:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
