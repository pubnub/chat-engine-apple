#import "CENChatEngine.h"


#pragma mark Class forward

@class CENUser, CENMe;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for \c user instance management.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (User)


#pragma mark - Information

/**
 * @brief A map of all known \b {users CENUser} in this \b {ChatEngine CENChatEngine} client.
 *
 * @ref b7c9eeaf-386d-41f7-bb03-8c936821e978
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENUser *> *users;

/**
 * @brief This instance of \b {ChatEngine CENChatEngine} represented as a special \b {user CENUser}
 * known as \b {local user CENMe}.
 *
 * @ref 236037dc-b91a-4bfe-86a6-25eec92d5d00
 */
@property (nonatomic, nullable, readonly, strong) CENMe *me;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
