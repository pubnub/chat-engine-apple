#import "CENChatEngine+Connection.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \b {local user CENMe} connection
 * management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (ConnectionInterface)

/**
 * @brief Connect \b {CENChatEngine} to real-time network on behalf of
 * \b {local user CENMe} identified by his UUID.
 *
 * @code
 * // objc 350f01ba-9203-45ab-aeac-ab279a549667
 *
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param userUUID Unique alphanumeric identifier for \b {local user CENMe}. It can be a device id,
 *     username, user id, email, etc.
 *
 * @ref cfc27c80-2adb-421b-8633-6bfd596c2217
 */
- (void)connectUser:(NSString *)userUUID;

/**
 * @brief Connect \b {CENChatEngine} to real-time network on behalf of
 * \b {local user CENMe} identified by his UUID.
 *
 * @discussion Connect to real-time network with \b {local user CENMe} state
 * @code
 * // objc 0dd043e3-48a0-42d2-b48e-ffd64b4b604e
 *
 * [self.client connectUser:@"ChatEngine" withState:@{ @"name": @"PubNub" } authKey:nil];
 * @endcode
 *
 * @discussion Connect to real-time network with \b {local user CENMe} authorization key
 * @code
 * // objc 00fad9a3-1bc9-4e07-8fa2-f4628d79b9ce
 *
 * [self.client connectUser:@"ChatEngine" withState:@{ @"name": @"PubNub" } authKey:@"secret"];
 * @endcode
 *
 * @param userUUID Unique alphanumeric identifier for \b {local user CENMe}. It can be a device id,
 *     username, user id, email, etc.
 * @param state Object with \b {local user CENMe} state which will be publicly available from
 *     \b {CENChatEngine.global} chat.
 * @param authKey User authentication secret key. Will be sent to authentication backend for
 *     validation. This is usually an access token. See \b {Authentication authentication} for more.
 *     \b Default: \a NSUUID
 *
 * @ref ad1cb5a9-9626-4cc6-b47b-5f76d86b0486
 */
- (void)connectUser:(NSString *)userUUID
          withState:(nullable NSDictionary *)state
            authKey:(nullable id)authKey;

/**
 * @brief Performs authentication with server and restores connection to all sleeping
 * \b {CENChatEngine.chats}.
 *
 * @discussion Reconnect after client has been disconnected:
 * @code
 * // objc c24e2017-d181-43ef-b898-d8e703aa71cb
 *
 * // Create a new chat.
 * CENChat *chat = [self.client createChatWithName:nil private:NO autoConnect:YES metaData:nil];
 *
 * // Disconnect from ChatEngine.
 * [self.client disconnectUser];
 *
 * // Reconnect sometime later.
 * [self.client reconnectUser];
 * @endcode
 *
 * @ref adce6026-d56f-41e3-a8a5-cb95bf108016
 */
- (void)reconnectUser;

/**
 * @brief Disconnect \b {local user CENMe} from real-time service and stop receiving updates from
 * chat(s) to which he was connected.
 *
 * @discussion Disconnect ChatEngine from real-time network:
 * @code
 * // objc f780d7d6-995e-428f-b01b-d56dd579f211
 *
 * // Create a new chat.
 * CENChat *chat = [self.client createChatWithName:nil private:NO autoConnect:YES metaData:nil];
 *
 * // Disconnect from ChatEngine.
 * [self.client disconnectUser];
 * @endcode
 *
 * @ref cb8bb38c-827e-45c1-b85b-4c55b7cf599d
 */
- (void)disconnectUser;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
