#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CENChatEngine, CENUser, CENMe;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} users manager.
 *
 * @discussion Manager responsible for \b {user CENUser} creation and maintenance.
 *
 * @ref 805698a6-04a1-427c-9144-de7601de7007
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUsersManager : NSObject


#pragma mark - Information

/**
 * @brief Map of user identifiers to \b {user CENUser} instance which they represent.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENUser *> *users;

/**
 * @brief Currently active local user.
 */
@property (nonatomic, nullable, readonly, strong) CENMe *me;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure users manager.
 *
 * @param chatEngine \b {CENChatEngine} instance which manage list of active / known
 *     users.
 *
 * @return Configured and ready to use users manager instance.
 */
+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Instantiate users manager.
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - attempt to create instance using \c new.
 *
 * @return \c nil.
 */
- (instancetype) __unavailable init;


#pragma mark - Creation

/**
 * @brief Create new user or return existing.
 *
 * @param uuid Unique identifier of \b {user CENUser} which should be created.
 * @param state State which can be bound to user on \b {CENChatEngine.global} chat.
 *
 * @return New or existing \b {user CENUser}.
 */
- (CENUser *)createUserWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state;

/**
 * @brief Create list of \b {users CENUser} using provided list of identifiers.
 *
 * @param uuids List of unique identifiers for which \b {users CENUser} should be created.
 *
 * @return List of \b {users CENUser} for each of provided \c uuids.
 */
- (NSArray<CENUser *> *)createUsersWithUUID:(NSArray<NSString *> *)uuids;


#pragma mark - Audition

/**
 * @brief Try to find and return previously created \b {user CENUser}.
 *
 * @param uuid Unique identifier of \b {user CENUser} which has been created before.
 *
 * @return Previously created \b {user CENUser} or \c nil in case if it doesn't exists.
 */
- (nullable CENUser *)userWithUUID:(NSString *)uuid;


#pragma mark - Clean up

/**
 * @brief Clean up all used resources.
 *
 * @discussion Clean up all resources which has been provided to create and manage active users.
 */
- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
