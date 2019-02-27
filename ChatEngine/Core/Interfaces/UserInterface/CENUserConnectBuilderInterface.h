#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENChatEngine, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {User CENUser} connection API access builder.
 *
 * @ref 33c4c8d0-01dd-4d8e-b4a9-9f45651288c6
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUserConnectBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief \b {Local user CENMe} global state addition block.
 *
 * @param state Object with \b {local user CENMe} state which will be publicly available from
 *     \b {CENChatEngine.global} chat.
 *     This object is sent to all other clients on the network, so no passwords!
 *     \b Default: \c @{}
 *
 * @return Builder instance which allow to complete local user connection call configuration.
 *
 * @ref b49bd0d0-876f-4080-8be2-f663f4131f16
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^state)(NSDictionary *state);

/**
 * @brief \b {Local user CENMe} authorization key addition block.
 *
 * @param authKey User authentication secret key. Will be sent to authentication backend for
 *     validation. This is usually an access token. See \b {Security concepts-security} for more.
 *     \b Default: \a [NSUUID UUID]
 *
 * @return Builder instance which allow to complete local user connection call configuration.
 *
 * @ref 317fba36-ca81-482d-8293-106da179683d
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^authKey)(id authKey);


#pragma mark - Call

/**
 * @brief Connect \b {local user CENMe} to real-time service using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain state.authKey.perform
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - authorization keys is not \a NSString or \a NSNumber.
 *
 * @fires
 * - \b {$.connected CENChat}
 * - \b {$.created.chat CENChat}
 * - \b {$.created.me CENMe}
 * - \b {$.created.session CENSession}
 * - \b {$.error.auth CENChat}
 * - \b {$.error.sync CENSession}
 * - \b {$.network.down.decryption}
 * - \b {$.network.down.denied}
 * - \b {$.network.down.issue}
 * - \b {$.network.down.offline}
 * - \b {$.network.down.tlsuntrusted}
 * - \b {$.network.up.connected}
 * - \b {$.network.up.reconnected}
 * - \b {$.ready}
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
 * @return \b {CENChatEngine} which can be used to chain other methods call.
 *
 * @ref 5b0b1530-d10d-443d-95e2-a1d853f23bab
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^perform)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
