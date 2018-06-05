#import "CENEventEmitter.h"
#import <PubNub/PubNub.h>


#pragma mark Class forward

@class CENConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client core class which is responsible for organization of user(s) interaction through chat
 *         application and provide responses back to completion block/delegates.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine : CENEventEmitter


#pragma mark - Information

/**
 * @brief  Retrieve copy of configuration instance which has been used to setup \b ChatEngine.
 */
@property (nonatomic, readonly, copy) CENConfiguration *currentConfiguration;

/**
 * @brief  Stores reference on current \b ChatEngine SDK version.
 */
@property (class, nonatomic, readonly, strong) NSString *sdkVersion;

/**
 * @brief  Reference on \b ChatEngine client logger instance which can be used to inser additional logs into console (if
 *         enabled) and file (if enabled).
 */
@property (nonatomic, readonly, strong) PNLLogger *logger;


#pragma mark - Initialization and Configuration

/**
 * @brief      Create and configure new \b ChatEngine client instance with pre-defined configuration.
 * @discussion If all keys will be specified, client will be able to connect to chat(s) and send messages to other connected
 *             user(s).
 * @note       Client will make configuration deep copy and further changes in \b CENConfiguration after it has been passed to
 *             the client won't take any effect on client.
 *
 * @discussion \b ChatEngine itself may emit following events:
 * @code
 * // To handle properly next events, handler block should accept additional parameter and it will have reference on
 * // PubNub status object when called:
 * // '$.network.down.offline' - when ChatEngine has been unexpectedly disconnected from real-time network.
 * // '$.network.down.issue' - when ChatEngine has been disconnected from real-time network because of issues with connection.
 * // '$.network.down.denied' - when ChatEngine has been disconnected from real-time network because of unauthorized attempt
 * //                           to access to chats to which local user doesn't have access.
 * // '$.network.down.disconnected' - when ChatEngine has been disconnected from real-time network on user request.
 * // '$.network.down.tlsuntrusted' - when ChatEngine was unable to connect to real-time network because of SSL/TLS issues.
 * // '$.network.down.badrequest' - when ChatEngine was unable to connect to real-time network because of incomplete
 * //                               configuration of used PubNub client API.
 * // '$.network.down.decryption' - when ChatEngine was unabled to decrypt received data.
 * // '$.network.up.connected' - when ChatEngine has been connected to real-time network on user request.
 * // '$.network.up.reconnected' - when ChatEngine has been re-connected to real-time network after connection issues.
 * //
 * // To handle properly next events, handler block should accept additional parameter which will have reference on
 * // NSError when called:
 * // '$.error.sync' - when ChatEngine was unabled to synchronize local user session.
 * //
 * // To handle properly next events, handler block should accept additional parameter which will have reference on
 * // CENMe instance when called:
 * // '$.ready' - when ChatEngine complete local user initialization and connection to real-time network.
 * //
 * // To handle properly next events, handler block should accept additional parameter which will have reference on
 * // CENUser instance when called:
 * // '$.state' - when ChatEngine user instance updates it's state information.
 * @endcode
 *
 * @discussion \b Example:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * @endcode

 * @param configuration Reference on instance which store all user-provided information about how client should operate and
 *                      handle events.
 *
 * @throws NSException Session restore issues (if \c throwExceptions is set).
 *
 * @return Configured and ready to use \b CENChatEngine client.
 */
+ (instancetype)clientWithConfiguration:(CENConfiguration *)configuration NS_SWIFT_NAME(clientWithConfiguration(_:));


#pragma mark - Clean up

/**
 * @brief      Completely terminate \b ChatEngine.
 * @discussion This method should be always called, when there is no more need in \b ChatEngine instance. It ensure, what all
 *             accrued resources will be released.
 */
- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
