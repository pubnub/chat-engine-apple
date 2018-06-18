#import "CENChatEngine+User.h"


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user instance management.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (UserInterface)


#pragma mark - User

/**
 * @brief  Create and configure new \b CENUser instance.
 *
 * @discussion Create user w/o state information:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     CENUser *user = [self.client createUserWithUUID:@"ChatEngineUser" state:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @discussion After user has been created, it is possible to try to invite him to chat.
 * @warning    If specified user never used \b ChatEngine network, further manipulation with instance may fail.
 *
 * @param uuid  Reference on unique user's identifier.
 * @param state Reference on dictionary which may conatin additional information about \c user and publicly available from
 *              \b ChatEngine network.
 *
 * @return Configured and ready to use \b CENChat instance.
 */
- (CENUser *)createUserWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state;

/**
 * @brief  Try to find and return previously created \b CENUser instance.
 *
 * @discussion Retrieve previously created/noticed user:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * CENUser *user = [self.client userWithUUID:@"ChatEngineUser"];
 * @endcode
 *
 * @param uuid Reference on unique user's instance identifier which has been created before.
 *
 * @return Previously created \b CENUser instance or \c nil in case if it doesn't exists.
 */
- (nullable CENUser *)userWithUUID:(NSString *)uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
