#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \b {local user CENMe} authorization
 * management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (Authorization)

/**
 * @brief Re-authorize \b {local user CENMe} with new \c authorization key.
 *
 * @discussion Disconnects, changes authentication token, performs handshake with server and
 * reconnects with new auth key. Used for extending logged in session for active user.
 *
 * @discussion Change current user authorization key
 * @code
 * // objc 0ca25956-aed6-4dab-b013-37c87ddac012
 *
 * // After some time, maybe after some access token expiration.
 * [self.client reauthorizeUserWithKey:authKey];
 *
 * [self.client handleEventOnce:@"$.connected" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle connection again after authorization with different key.
 * }];
 * @endcode
 *
 * @param authKey Access token (\a NSString or \a NSNumber) which will be used for
 *     \b {local user CENMe} from now on.
 *     \b Default: \a NSUUID
 *
 * @ref 4d8e03e8-9e8a-4e3a-b932-acf1a499c55e
 */
- (void)reauthorizeUserWithKey:(nullable id)authKey;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
