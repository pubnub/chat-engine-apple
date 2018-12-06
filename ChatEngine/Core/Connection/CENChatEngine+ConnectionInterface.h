#import "CENChatEngine+Connection.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for \b {local user CENMe} connection
 * management.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (ConnectionInterface)

/**
 * @brief Connect \b {ChatEngine CENChatEngine} to real-time network on behalf of
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
 * @deprecated 0.10.0
 *
 * @ref cfc27c80-2adb-421b-8633-6bfd596c2217
 */
- (void)connectUser:(NSString *)userUUID
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.10.0. Please use "
                             "-connectUser:withAuthKey:globalChannel: method instead.");

/**
 * @brief Connect \b {ChatEngine CENChatEngine} to real-time network on behalf of
 * \b {local user CENMe} identified by his UUID.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - authorization keys is not \a NSString or \a NSNumber.
 *
 * @discussion Connect to real-time network with \b {local user CENMe} identifier
 * @code
 * // objc bfeda931-4a5f-440c-acd7-d5f8ca3bd1ee
 *
 * [self.client connectUser:@"ChatEngine" withAuthKey:nil globalChannel:@"chat-engine"];
 * @endcode
 *
 * @discussion Connect to real-time network with \b {local user CENMe} authorization key
 * @code
 * // objc 96b69724-b16a-462b-8c62-98e98f32457f
 *
 * [self.client connectUser:@"ChatEngine" withAuthKey:@"secret" globalChannel:nil];
 * @endcode
 *
 * @param userUUID Unique alphanumeric identifier for \b {local user CENMe}. It can be a device id,
 *     username, user id, email, etc.
 * @param authKey User authentication secret key. Will be sent to authentication backend for
 *     validation. This is usually an access token. See \b {Authentication authentication} for more.
 *     \b Default: \a NSUUID
 * @param globalChannel Name of channel which will represent \b {CENChatEngine.global} chat for all
 *     connected clients.
 *     To use this parameter \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration.
 *     \b Default: \c global
 *
 * @since 0.10.0
 *
 * @ref 5b0b1530-d10d-443d-95e2-a1d853f23bab
 */
- (void)connectUser:(NSString *)userUUID
        withAuthKey:(nullable NSString *)authKey
      globalChannel:(nullable NSString *)globalChannel;

/**
 * @brief Connect \b {ChatEngine CENChatEngine} to real-time network on behalf of
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
 *     To use this parameter \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration.
 * @param authKey User authentication secret key. Will be sent to authentication backend for
 *     validation. This is usually an access token. See \b {Authentication authentication} for more.
 *     \b Default: \a NSUUID
 *
 * @deprecated 0.10.0
 *
 * @ref ad1cb5a9-9626-4cc6-b47b-5f76d86b0486
 */
- (void)connectUser:(NSString *)userUUID
          withState:(nullable NSDictionary *)state
            authKey:(nullable NSString *)authKey
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.10.0. Please use "
                             "-[CENMe updateState:forChat:] method, to change local user state "
                             "when client will complete connection (on '$.ready' event).");

/**
 * @brief Performs authentication with server and restores connection to all sleeping
 * \b {CENChatEngine.chats}.
 *
 * @code
 * // objc c24e2017-d181-43ef-b898-d8e703aa71cb
 *
 * // Create a new chat.
 * CENChat *chat = [self.client createChatWithName:nil group:nil private:NO autoConnect:YES
 *                                        metaData:nil];
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
 * @code
 * // objc f780d7d6-995e-428f-b01b-d56dd579f211
 *
 * // Create a new chat.
 * CENChat *chat = [self.client createChatWithName:nil group:nil private:NO autoConnect:YES
 *                                        metaData:nil];
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
