#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for user mute / unmute support.
 *
 * @ref 96a16dd3-fcc6-433a-ab47-43f87bca1706
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENMuterExtension : CEPExtension


#pragma mark - Extension

/**
 * @brief Mute specific \b {user CENUser} in \b {chat CENChat}.
 *
 * @discussion Mute specific \b {user CENUser} in \b {chat CENChat}
 * @code
 * // objc d8963873-68da-4237-ac00-fa38c1c4f756
 *
 * CENMuterExtension *extension = self.chat.extension([CENMuterPlugin class]);
 * [extension muteUser:self.user];
 * @endcode
 *
 * @param user \b {User CENUser} from which \b {CENChatEngine} client should stop
 *     receiving messages in specified \b {chat CENChat}.
 *
 * @ref 66e5972c-1f6a-4e6a-9f02-fcd733ec8ebd
 */
- (void)muteUser:(CENUser *)user;

/**
 * @brief Unmute specific \b {user CENUser} in \b {chat CENChat}.
 *
 * @discussion Unmute specific \b {user CENUser} in \b {chat CENChat}
 * @code
 * // objc c7351257-a3a8-4d03-b804-0bde2ab14263
 *
 * CENMuterExtension *extension = self.chat.extension([CENMuterPlugin class]);
 * [extension unmuteUser:self.user];
 * @endcode
 *
 * @param user \b {User CENUser} from which \b {CENChatEngine} client should start
 *     receiving messages in specified \b {chat CENChat}.
 *
 * @ref bf2b7df5-6b20-4123-abff-ca6096bdcfe7
 */
- (void)unmuteUser:(CENUser *)user;

/**
 * @brief Check whether specified \b {user CENUser} still muted in specific \b {chat CENChat} or
 * not.
 *
 * @discussion Check whether specified \b {user CENUser} still muted in specific \b {chat CENChat}
 * or not
 * @code
 * // objc 98ccc86b-3989-4b05-b93d-c240db469b12
 *
 * CENMuterExtension *extension = self.chat.extension([CENMuterPlugin class]);
 * if ([extension isMutedUser:self.user]) {
 *     NSLog(@"'%@' still muted", self.user.uuid);
 * }
 * @endcode
 *
 * @param user \b {User CENUser} for which should be checked ability to send messages to specified
 *     \b {chat CENChat}.
 *
 * @return Whether \b {user CENUser} is muted in \b {chat CENChat} for which extension has been
 * called or not.
 *
 * @ref 8c6e2618-b0cc-459d-8bfd-358f8ceb15b2
 */
- (BOOL)isMutedUser:(CENUser *)user;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
