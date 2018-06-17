#import "CENChatEngine+Connection.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user's connection management.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (ConnectionInterface)


#pragma mark - Connection

/**
 * @brief  Prepare and connect \b ChatEngine to real-time network on behalf of user identified by his UUID.
 *
 * @discussion Connect to real-time network with user identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param userUUID Reference on unique local user identifier (used with \c CENMe class). It can be a device id, username, user
 *                 id, email, etc. Must be alphanumeric.
 */
- (void)connectUser:(NSString *)userUUID;

/**
 * @brief  Prepare and connect \b ChatEngine to real-time network on behalf of user identified by his UUID.
 *
 * @discussion Connect to real-time network with user state:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client connectUser:@"ChatEngine" withState:@{ @"name": @"PubNub" } authKey:nil];
 * @endcode
 *
 * @discussion Connect to real-time network with user authorization key:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client connectUser:@"ChatEngine" withState:@{ @"name": @"PubNub" } authKey:@"secret"];
 * @endcode
 *
 * @param userUUID Reference on unique local user identifier (used with \c CENMe class). It can be a device id, username, user
 *                 id, email, etc. Must be alphanumeric.
 * @param state    Reference on object containing information about this client and publicly available.
 * @param authKey  Reference on authentication secret. Will be sent to authentication backend for validation. This is usually
 *                 an access token or password. This is different from UUID as a user can have a single UUID but multiple
 *                 auth keys.
 */
- (void)connectUser:(NSString *)userUUID withState:(nullable NSDictionary *)state authKey:(nullable NSString *)authKey;

/**
 * @brief      Performs authentication with server and restores connection to all sleeping chats.
 * @discussion Restores activity of previously disconnected \b ChatEngine instance.
 *
 * @discussion Reconnect after client has been disconnected:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * // user requested to disconnect from ChatEngine real-time network or there was another issues which caused client
 * // disconnection.
 * // .....
 * // user requested to restore real-time data update.
 * [self.client reconnectUser];
 * @endcode
 */
- (void)reconnectUser;

/**
 * @brief  Disconnect local \c user from real-time service and stop receiving updates from chat(s) to which he was connected.
 *
 * @discussion Disconnect ChatEngine from real-time network:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * // user requested to disconnect from ChatEngine real-time network.
 * [self.client disconnectUser];
 * @endcode
 */
- (void)disconnectUser;

@end

NS_ASSUME_NONNULL_END
