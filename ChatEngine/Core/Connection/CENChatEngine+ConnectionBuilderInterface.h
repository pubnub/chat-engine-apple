#import "CENChatEngine+Connection.h"


#pragma mark Class forward

@class CENUserConnectBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for \b {local user CENMe} connection
 * management.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (ConnectionBuilderInterface)

/**
 * @brief \b {ChatEngine CENChatEngine} client connection API builder.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Connect to real-time network with \b {local user CENMe} identifier
 * @code
 * // objc bfeda931-4a5f-440c-acd7-d5f8ca3bd1ee
 *
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Connect to real-time network with \b {local user CENMe} authorization key
 * @code
 * // objc 96b69724-b16a-462b-8c62-98e98f32457f
 *
 * self.client.connect(@"ChatEngine").authKey(@"secret").perform();
 * @endcode
 *
 * @param uuid Unique alphanumeric identifier for \b {local user CENMe}. It can be a device id,
 *     username, user id, email, etc.
 *
 * @return Builder instance which allow to complete local user connection call configuration.
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^connect)(NSString *uuid);

/**
 * @brief Performs authentication with server and restores connection to all sleeping chats.
 *
 * @code
 * // objc c24e2017-d181-43ef-b898-d8e703aa71cb
 *
 * // Create a new chat
 * CENChat *chat = self.client.Chat().create();
 *
 * // Disconnect from ChatEngine
 * self.client.disconnect();
 *
 * // Reconnect sometime later.
 * self.client.reconnect();
 * @endcode
 *
 * @return \b {ChatEngine CENChatEngine} client which can be used to chain other methods call.
 *
 * @ref adce6026-d56f-41e3-a8a5-cb95bf108016
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^reconnect)(void);

/**
 * @brief Disconnect \b {local user CENMe} from real-time service and stop receiving updates from
 * chat(s) to which he was connected.
 *
 * @code
 * // objc f780d7d6-995e-428f-b01b-d56dd579f211
 *
 * // Create a new chat
 * CENChat *chat = self.client.Chat().create();
 *
 * // Disconnect from ChatEngine.
 * self.client.disconnect();
 * @endcode
 *
 * @return \b {ChatEngine CENChatEngine} client which can be used to chain other methods call.
 *
 * @ref cb8bb38c-827e-45c1-b85b-4c55b7cf599d
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^disconnect)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
