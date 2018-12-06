/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChatEngine+User.h"


#pragma mark CLass forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENChatEngine (UserPrivate)


#pragma mark - State

/**
 * @brief Retrieve user's state for specific \b {chat CENChat} from \b PubNub K/V storage.
 *
 * @param user \b {User CENUser} for which state should be fetched from \b PubNub K/V storage.
 * @param chat \b {Chat CENChat} to which state for user bound in \b PubNub K/V storage.
 * @param block Fetch completion block which pass \a NSDictionary with user's state for
 *     \b {chat CENChat}.
 */
- (void)fetchUserState:(CENUser *)user
               forChat:(CENChat *)chat
        withCompletion:(void(^)(NSDictionary *state))block;


#pragma mark - Clean up

/**
 * @brief Clean up all used resources.
 *
 * @discussion Clean up all resources which has been provided to create and manage active users.
 */
- (void)destroyUsers;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
