#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client configuration.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENConfiguration : NSObject


#pragma mark Initialization and Configuration

/**
 * @brief Key which is used to publish data to chat(s).
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - assigned key is empty or not \a NSString.
 *
 * @note This key can be obtained on PubNub's administration \b {portal https://admin.pubnub.com}
 * after free registration.
 */
@property (nonatomic, copy) NSString *publishKey;

/**
 * @brief Key which is used to connect and receive updates from chat(s).
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - assigned key is empty or not \a NSString.
 *
 * @note This key can be obtained on PubNub's administration \b {portal https://admin.pubnub.com}
 * after free registration.
 */
@property (nonatomic, copy) NSString *subscribeKey;

/**
 * @brief Data encryption key.
 *
 * @discussion Key which is used to encrypt messages pushed to \b PubNub service and decrypt
 * received from \b {chats CENChat}.
 */
@property (nonatomic, copy) NSString *cipherKey;

/**
 * @brief Number of seconds which is used by server to track whether client still active or not.
 *
 * @discussion If within specified amount of time client won't notify server about it's presence, it
 * will 'timeout' for rest of users.
 *
 * @note Value can't be smaller then \c 5 seconds or larger than \c 300 seconds and will be reset to
 * it automatically.
 *
 * \b Default: \c 0
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;

/**
 * @brief Number of seconds which is used by client to notify \b PubNub what user still active.
 *
 * @note Value should be smaller then \c presenceHeartbeatValue for better presence control.
 *
 * \b Default: \c 300
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;

/**
 * @brief URI which should be used to access running \b PubNub Functions which is used as
 * \b {ChatEngine CENChatEngine} back-end.
 *
 * \b Default: \b {kCENPNFunctionsBaseURI}
 */
@property (nonatomic, copy) NSString *functionEndpoint;

/**
 * @brief Name of space where all \b {chats CENChat} is grouped.
 *
 * \b Default: \c chat-engine
 */
@property (nonatomic, copy) NSString *namespace;

/**
 * @brief Whether \b {ChatEngine CENChatEngine} client should create global chat on user connection
 * or not.
 *
 * @discussion \b {CENChatEngine.global} chat is the only chat to which will be connected all
 * \b {ChatEngine CENChatEngine} instances. This chats can be used for announcements which should be
 * delivered to all connected users.
 *
 * \b Default: \c YES
 *
 * @since 0.10.0
 */
@property (nonatomic, assign) BOOL enableGlobal;

/**
 * @brief Whether \b {user's CENMe} session should be synchronized between owm devices or not.
 *
 * @discussion With enabled synchronization, chats list change on \b {user's CENMe} devices
 * (mobile, desktop) will be synchronized.
 *
 * \b Default: \b NO
 */
@property (nonatomic, assign, getter = shouldSynchronizeSession) BOOL synchronizeSession
    NS_SWIFT_NAME(synchronizeSession);

/**
 * @brief Whether created \b {chats CENChat} should fetch their meta information from
 * \b {ChatEngine CENChatEngine} network or not.
 *
 * \b Default: \b NO
 */
@property (nonatomic, assign) BOOL enableMeta;

/**
 * @brief Whether \b {ChatEngine CENChatEngine} should print out all received events.
 *
 * @discussion Console will print out all events which has been emitted locally or by remote client.
 *
 * \b Default: \b NO
 *
 * @since 0.9.2
 */
@property (nonatomic, assign, getter = shouldDebugEvents) BOOL debugEvents
    NS_SWIFT_NAME(debugEvents);

/**
 * @brief Whether \b {ChatEngine CENChatEngine} should throw errors or not.
 *
 * \b Default: \b NO
 */
@property (nonatomic, assign, getter = shouldThrowExceptions) BOOL throwExceptions
    NS_SWIFT_NAME(throwExceptions);

/**
 * @brief Create and configure instance using minimal required data.
 *
 * @note All required keys can be found on https://admin.pubnub.com
 *
 * @throws \a NSInternalInconsistencyException exception in following cases:
 * - publish key is empty or not \a NSString,
 * - subscribe key is empty or not \a NSString.
 *
 * @param publishKey Key which allow client to publish data to chat(s).
 * @param subscribeKey Key which allow client to connect and receive updates from chat(s).
 *
 * @return Configured and ready to se configuration instance.
 */
+ (instancetype)configurationWithPublishKey:(NSString *)publishKey
                               subscribeKey:(NSString *)subscribeKey
    NS_SWIFT_NAME(init(publishKey:subscribeKey:));

/**
 * @brief Instantiation should be done using class method
 * \b [CENConfiguration configurationWithPublishKey:subscribeKey:].
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - attempt to create instance using \c new.
 
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype) __unavailable init;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
