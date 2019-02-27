#import "CENChatEngine+User.h"


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \c user instance management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (UserInterface)


#pragma mark - User

/**
 * @brief Create or retrieve reference on previously created \b {user CENUser} instance.
 *
 * @warning If specified user never used \b {CENChatEngine} client, further manipulation
 * with instance may fail.
 *
 * @discussion Create user w/o state
 * @code
 * // objc 163ed912-6ccb-4455-adcc-a800115e0ffe
 *
 * CENUser *user = [self.client createUserWithUUID:@"ChatEngineUser" state:nil];
 * @endcode
 *
 * @discussion Create user w/ state
 * @code
 * // objc 146a891a-3d6f-46ce-b3ce-f9a5bde1e573
 *
 * CENUser *user = [self.client createUserWithUUID:@"ChatEngineUser"
 *                                           state:@{ @"name": @"PubNub" }];
 * @endcode
 *
 * @param uuid Unique alphanumeric identifier for this \b {user CENUser}. It can be a device id,
 *     username, user id, email, etc.
 * @param state \a NSDictionary with \c user's information synchronized between all clients of the
 *     chat.
 *
 * @return Configured and ready to use \b {CENUser} instance.
 *
 * @ref 50cd442e-2aee-4ce7-bbd6-68ea40c42bca
 */
- (nullable CENUser *)createUserWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state;

/**
 * @brief Try to find and return previously created \b {user CENUser} instance.
 *
 * @discussion Retrieve previously created / online user
 * @code
 * // objc e734dc26-a698-4932-824f-6d77c45ef40d
 *
 * CENUser *user = [self.client userWithUUID:@"ChatEngineUser"];
 * @endcode
 *
 * @param uuid Identifier of user which has been created before.
 *
 * @return Previously created \b {user CENUser} instance or \c nil in case if it doesn't exists.
 *
 * @ref e6f42c44-c5eb-4da2-8ad3-a0faac1e521f
 */
- (nullable CENUser *)userWithUUID:(NSString *)uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
