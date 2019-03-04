/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Standard interface declaration

@interface CENMe (Interface)


#pragma mark - State

/**
 * @brief Update \b {local user CENMe} state in a \b {CENChatEngine.global} chat.
 *
 * @discussion All other \b {users CENUser} will be notified of this change via \b {$.state}.
 * Retrieve state at any time with \b {CENUser.state}.
 *
 * @discussion Update state
 * @code
 * // objc a78cd174-e6cc-4b02-bc81-3b6177c82b27
 *
 * // Update local user state when it will be required.
 * [self.client.me updateState:@{ @"state": @"working" }];
 * @endcode
 *
 * @param state \a NSDictionary which contain updated state for \b {local user CENMe}.
 *     \b Default: \c @{}
 *
 * @ref fd42194b-4626-452d-8393-a9602283947b
 */
- (void)updateState:(nullable NSDictionary *)state;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
