#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Standard interface declaration

@interface CENMe (Interface)


#pragma mark - State

/**
 * @brief Update \b {local user CENMe} state in a \b {chat CENChat}.
 *
 * @discussion All other \b {users CENUser} will be notified of this change via \b {$.state}.
 * Retrieve state at any time with \b [CENUser stateForChat:].
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @discussion Update state in a \b {CENChatEngine.global} chat
 * @code
 * // objc a78cd174-e6cc-4b02-bc81-3b6177c82b27
 *
 * // Update local user state when it will be required.
 * [self.client.me updateState:@{ @"state": @"working" } forChat:nil];
 * @endcode
 *
 * @discussion Update state in a custom chat
 * @code
 * // objc 33b242f0-6909-497a-9e9c-fd0c06d923cc
 *
 * // Create chat which will be used by application to store users' state in it.
 * CENChat *stateChat = [self.client createChatWithName:@"users-state" private:NO autoConnect:YES
 *                                             metaData:nil];
 *
 * // Update local user state when it will be required.
 * [self.client.me updateState:@{ @"state": @"working" } forChat:stateChat];
 * @endcode
 *
 * @param state \a NSDictionary which contain updated state for \b {local user CENMe}.
 *     \b Default: \c @{}
 * @param chat \b {Chat CENChat} where state will be updated.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
 *
 * @ref fd42194b-4626-452d-8393-a9602283947b
 */
- (void)updateState:(nullable NSDictionary *)state forChat:(nullable CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
