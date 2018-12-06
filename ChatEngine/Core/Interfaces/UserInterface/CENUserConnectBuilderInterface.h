#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENChatEngine, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {User CENUser} connection API access builder.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
@interface CENUserConnectBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief \b {Local user CENMe} global state addition block.
 *
 * @param state Object with \b {local user CENMe} state which will be publicly available from
 *     \b {CENChatEngine.global} chat.
 *     To use this parameter \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration.
 *     \b Default: \c @{}
 *
 * @return Builder instance which allow to complete local user connection call configuration.
 *
 * @deprecated Since 0.10.0
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^state)(NSDictionary *state)
    DEPRECATED_MSG_ATTRIBUTE("This option deprecated since 0.10.0. Please use CENMe.update() "
                             "instance method, to change local user state when client will "
                             "complete connection (on '$.ready' event).");

/**
 * @brief \b {Local user CENMe} authorization key addition block.
 *
 * @param authKey User authentication secret key. Will be sent to authentication backend for
 *     validation. This is usually an access token. See \b {Authentication authentication} for more.
 *     \b Default: \a NSUUID
 *
 * @return Builder instance which allow to complete local user connection call configuration.
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^authKey)(id authKey);

/**
 * @brief \b {Global CENChatEngine.global} chat name addition block.
 *
 * @param globalChannel Name of channel which will represent \b {global CENChatEngine.global} chat
 *     for all connected clients.
 *     To use this parameter \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration.
 *     \b Default: \c global
 *
 * @return Builder instance which allow to complete local user connection call configuration.
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^globalChannel)(NSString *globalChannel);


#pragma mark - Call

/**
 * @brief Connect \b {local user CENMe} to real-time service using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain authKey.globalChannel.perform
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - authorization keys is not \a NSString or \a NSNumber.
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
 * @return \b {ChatEngine CENChatEngine} which can be used to chain other methods call.
 *
 * @ref 5b0b1530-d10d-443d-95e2-a1d853f23bab
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^perform)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
