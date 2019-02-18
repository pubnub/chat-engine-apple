#import "CENChatEngine+User.h"


#pragma mark Class forward

@class CENUserBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \c user instance management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (UserBuilderInterface)


#pragma mark - User

/**
 * @brief \b {Users CENUser} management API builder.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Create user w/o state
 * @code
 * // objc 163ed912-6ccb-4455-adcc-a800115e0ffe
 *
 * CENUser *user = self.client.User(@"ChatEngineUser").create();
 * @endcode
 *
 * @discussion Create user w/ state
 * @code
 * // objc 146a891a-3d6f-46ce-b3ce-f9a5bde1e573
 *
 * CENUser *user = self.client.User(@"ChatEngineUser").state(@{ @"name": @"PubNub" }).create();
 * @endcode
 *
 * @discussion Retrieve previously created / online user
 * @code
 * // objc e734dc26-a698-4932-824f-6d77c45ef40d
 *
 * CENUser *user = self.client.User(@"ChatEngineUser").get();
 * @endcode
 *
 * @param uuid Unique alphanumeric identifier for this \b {user CENUser}. It can be a device id,
 *     username, user id, email, etc.
 *
 * @return Builder instance which allow to complete users management call configuration.
 */
@property (nonatomic, readonly, strong) CENUserBuilderInterface * (^User)(NSString *uuid);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
