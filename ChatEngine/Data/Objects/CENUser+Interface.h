#import "CENUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Standard interface declaration

@interface CENUser (Interface)


#pragma mark - State

/**
 * @brief Get cached state for user on specified \b {chat CENChat}.
 *
 * @discussion State populated and maintained by network updates.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @discussion Get cached \b {user's CENUser} state for \b {CENChatEngine.global} chat
 * @code
 * // objc 1a6586b2-ba57-430b-b2d6-265dd891a0a5
 *
 * CENUser *user = [self.client userWithUUID:@"PubNub"];
 *
 * NSLog(@"State for '%@' previously set on global chat: %@", user.uuid, [user stateForChat:nil]);
 * @endcode
 *
 * @discussion Get cached \b {user's CENUser} state for custom chat chat
 * @code
 * // objc 002ff26c-6835-442a-830f-dff739f20d65
 *
 * CENChat *chat = [self.client createChatWithName:nil private:NO autoConnect:YES metaData:nil];
 * CENUser *user = [self.client userWithUUID:@"PubNub"];
 *
 * NSLog(@"State for '%@' previously set on '%@' chat: %@", user.uuid, chat.name,
 *       [user stateForChat:chat]);
 * @endcode
 *
 * @param chat \b {Chat CENChat} for which \b {user's CENUser} state should be retrieved.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
 *
 * @return \a NSDictionary with \b {user's CENUser} state which has been set for \c chat earlier or
 * \c nil in case if not set.
 *
 * @since 0.10.0
 *
 * @ref 590b7902-9f8e-4ee1-b48d-d45f96916c70
 */
- (nullable NSDictionary *)stateForChat:(nullable CENChat *)chat;

/**
 * @brief Restore \b {user's CENUser} state for specific \b {chat CENChat}.
 *
 * @discussion Restore users' state from \b {CENChatEngine.global} chat
 * @code
 * // objc 74685ac2-2135-4b02-867e-285d27ce2494
 *
 * CENUser *user = [self.client createUserWithUUID:@"PubNub" state:nil];
 * [user restoreStateForChat:nil];
 * @endcode
 *
 * @discussion Restore users' state from custom chat
 * @code
 * // objc 28792db0-81bf-400e-adac-cc65b5e844b6
 *
 * CENChat *chat = [self.client createChatWithName:@"test-chat" private:NO autoConnect:YES
 *                                        metaData:nil];
 *
 * CENUser *user = [self.client createUserWithUUID:@"PubNub" state:nil];
 * [user restoreStateForChat:chat];
 * @endcode
 *
 * @param chat \b {Chat CENChat} from which state should be restored.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
 *
 * @since 0.10.0
 *
 * @ref ca77541f-c3f9-456f-8de4-ed8f3169853c
 */
- (void)restoreStateForChat:(nullable CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
