#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client configuration wrapper.
 * @discussion Use this instance to provide values which should be by client to communicate with
 *             \b PubNub network.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENConfiguration : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief   Reference on key which is used to publish data to chat(s).
 * @note    This key can be obtained on PubNub's administration portal after free registration https://admin.pubnub.com
 */
@property (nonatomic, copy) NSString *publishKey;

/**
 * @brief   Reference on key which is used to connect and receive updates from chat(s).
 * @note    This key can be obtained on PubNub's administration portal after free registration https://admin.pubnub.com
 */
@property (nonatomic, copy) NSString *subscribeKey;

/**
 * @brief       Reference on encryption key.
 * @discussion  Key which is used to encrypt messages pushed to \b PubNub service and decrypt messages received
 *              from live feeds on which client subscribed at this moment.
 */
@property (nonatomic, copy) NSString *cipherKey;

/**
 * @brief      Reference on number of seconds which is used by server to track whether client still online or time out.
 * @discussion If within specified amount of time client won't notify server about it's presence, it will 'timeout' for rest
 *             of users.
 * @note       This value can't be smaller then \b 5 seconds or larger than \b 300 seconds and will be reset to it
 *             automatically.
 *
 * @default    \b 60 seconds.
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;

/**
 * @brief  Reference on number of seconds which is used by client to issue heartbeat requests to \b PubNub service.
 * @note   This value should be smaller then \c presenceHeartbeatValue for better presence control.
 *
 * @default \b 30 seconds.
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;

/**
 * @brief  Reference on URI which should be used to access running \b PubNub Functions which act as \b ChatEngine back-end.
 *
 * @default Defined by \c kCEPNFunctionsBaseURI constant.
 */
@property (nonatomic, copy) NSString *functionEndpoint;

/**
 * @brief      Reference on name of channel to which all has access.
 * @discussion \b ChatEngine has privacy settings which allow to make chats \c public or \c private.
 *             \c Public chats can be accessed by anyone by their name. Global chat is special kind of chat to which any
 *             \b ChatEngine instance will subscribe automatically after instantiation. This chat can be used for
 *             announCENMents or remote \b ChatEngine clients reconfiguration (depends on how new message from it will be
 *             handled).
 *
 * @default \b chat-engine seconds.
 */
@property (nonatomic, copy) NSString *globalChannel;

/**
 * @brief      Whether user session should be synchronized between different devices or not.
 * @discussion With enabled synchronization, all user devices (mobile, desktop) will be synchronized in part of active chats.
 
 * @default \b NO
 */
@property (nonatomic, assign, getter = shouldSynchronizeSession) BOOL synchronizeSession NS_SWIFT_NAME(synchronizeSession);

/**
 * @brief  Whether created / synchronized (if enabled \c synchronizeSession) chat instances should fetch meta
 *         information from \b ChatEngine network or not.
 *
 * @default \b NO
 */
@property (nonatomic, assign) BOOL enableMeta;

/**
 * @brief      Whether \b ChatEngine should print out all received events.
 * @discussion Console will print out all events which has been emitted locally or by remote client.
 *
 * @default \b NO
 *
 * @since 0.9.2
 */
@property (nonatomic, assign, getter = shouldDebugEvents) BOOL debugEvents NS_SWIFT_NAME(debugEvents);

/**
 * @brief  Whether \b ChatEngine should trhow errors or not.
 *
 * @default \b NO
 */
@property (nonatomic, assign, getter = shouldThrowExceptions) BOOL throwExceptions NS_SWIFT_NAME(throwExceptions);

/**
 * @brief  Create and configure instance using minimal required data.
 * @note   All required keys can be found on https://admin.pubnub.com
 *
 * @param publishKey   Key which allow client to publish data to chat(s).
 * @param subscribeKey Key which allow client to connect and receive updates from chat(s).
 *
 * @return Configured and ready to se configuration instance.
 */
+ (instancetype)configurationWithPublishKey:(NSString *)publishKey subscribeKey:(NSString *)subscribeKey
    NS_SWIFT_NAME(init(publishKey:subscribeKey:));

/**
 * @brief  Instantiation should be done using class method \c +configurationWithPublishKey:subscribeKey:.
 *
 * @throws \a NSException
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype) __unavailable init;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
