#import <CENChatEngine/CEPPlugin.h>
#import "CENMuterExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 95a4beb5-5885-4bc8-81fd-c07f17cef6ce
 */
typedef struct CENMuterConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * \b Default: \c @[@"message"]
     *
     * @ref f5168557-e93b-468c-a0d1-af45c53aa537
     */
    __unsafe_unretained NSString *events;
} CENMuterConfigurationKeys;

extern CENMuterConfigurationKeys CENMuterConfiguration;


#pragma mark Class forward

@class CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} received data pre-processor filter.
 *
 * @discussion Plugin allow to filter out events from muted \b {users CENUser}
 *
 * @discussion Setup with default configuration and mute all 'message' events from specific user
 * @code
 * // objc 935f183e-fba3-4b6e-a744-e92cc8176ae5
 *
 * self.chat.plugin([CENMuterPlugin class]).store();
 *
 * [CENMuterPlugin muteUser:self.user inChat:self.chat];
 * @endcode
 *
 * @discussion Setup with custom events which won't be received from muted user
 * @code
 * // objc 0f5fa8f3-7dbd-498d-92f7-98bdbaf4491b
 *
 * self.chat.plugin([CENMuterPlugin class]).configuration(@{
 *     CENMuterConfiguration.events: @[@"ping", @"pong"]
 * }).store();
 *
 * if ([CENMuterPlugin isMutedUser:self.user inChat:self.chat]) {
 *     [CENMuterPlugin muteUser:self.user inChat:self.chat];
 * }
 * @endcode
 *
 * @ref ae50e590-b4ae-4342-bb8c-047b230db678
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENMuterPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Mute specific \b {user CENUser} in \b {chat CENChat}.
 *
 * @discussion Mute specific \b {user CENUser} in \b {chat CENChat}
 * @code
 * // objc 7e8b15a4-19c4-4a5a-b30c-fed3ebc9f28d
 *
 * [CENMuterPlugin muteUser:self.user inChat:self.chat];
 * @endcode
 *
 * @param user \b {User CENUser} from which \b {CENChatEngine} client should stop
 *     receiving messages in specified \b {chat CENChat}.
 * @param chat \b {Chat CENChat} in which \b {user CENUser} should be silenced.
 *
 * @ref d8eee02a-9727-4616-9ad9-63260ee3e91a
 */
+ (void)muteUser:(CENUser *)user inChat:(CENChat *)chat;

/**
 * @brief Unmute specific \b {user CENUser} in \b {chat CENChat}.
 *
 * @discussion Unmute specific \b {user CENUser} in \b {chat CENChat}
 * @code
 * // objc 89e092c1-4cca-4b2f-b435-ad2b5568a1b6
 *
 * [CENMuterPlugin unmuteUser:self.user inChat:self.chat];
 * @endcode
 *
 * @param user \b {User CENUser} from which \b {CENChatEngine} client should start
 *     receiving messages in specified \b {chat CENChat}.
 * @param chat \b {Chat CENChat} in which \b {user CENUser} should be able to send messages.
 *
 * @ref f8d839fb-0a2b-4fc9-8d13-f324c87f0991
 */
+ (void)unmuteUser:(CENUser *)user inChat:(CENChat *)chat;

/**
 * @brief Check whether specified \b {user CENUser} still muted in specific \b {chat CENChat} or
 * not.
 *
 * @discussion Check whether specified \b {user CENUser} still muted in specific \b {chat CENChat}
 * or not
 * @code
 * // objc 6fdeb4ca-c836-4137-a2f7-cc1a99619cb2
 *
 * BOOL isMuted = [CENMuterPlugin isMutedUser:self.user inChat:self.chat];
 *
 * NSLog(@"'%@' still muted? %@", self.user.uuid, isMuted ? @"YES" : @"NO");
 * @endcode
 *
 * @param user \b {User CENUser} for which should be checked ability to send messages to specified
 *     \b {chat CENChat}.
 * @param chat \b {Chat CENChat} inside of which check should be done.
 *
 * @return Whether specified \b {user CENUser} is muted in \b {chat CENChat} or not.
 *
 * @ref ea87e1a6-d29a-4190-b0f0-2c7510a748d9
 */
+ (BOOL)isMutedUser:(CENUser *)user inChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
