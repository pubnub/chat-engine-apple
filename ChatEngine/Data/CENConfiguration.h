#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client configuration.
 *
 * @ref b0f198f3-1dde-4297-8c17-22ae7c374739
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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
 *
 * @ref dd852586-ccd6-4df0-b895-4b88a6ba2344
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
 *
 * @ref 85d21cf7-f782-481a-bd81-4f210a5349d8
 */
@property (nonatomic, copy) NSString *subscribeKey;

/**
 * @brief Data encryption key.
 *
 * @discussion Key which is used to encrypt messages pushed to \b PubNub service and decrypt
 * received from \b {chats CENChat}.
 *
 * @ref e2a8130b-f09c-4619-9cf9-914d4bde2f73
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
 * \b Default: \c 300 seconds.
 *
 * @ref 7be95c65-3532-4446-b327-fb301d81fdcc
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;

/**
 * @brief Number of seconds which is used by client to notify \b PubNub what user still active.
 *
 * @note Value should be smaller then \b {presenceHeartbeatValue} for better presence control.
 *
 * \b Default: \c 0
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;

/**
 * @brief URI which should be used to access running \b PubNub Functions which is used as
 * \b {CENChatEngine} back-end.
 *
 * \b Default: \b {kCENPNFunctionsBaseURI}
 *
 * @ref eb9b19fe-bdc0-4a2b-b93a-7a6b2888669e
 */
@property (nonatomic, copy) NSString *functionEndpoint;

/**
 * @brief Name of channel to which all has access.
 *
 * @discussion \b {CENChatEngine} has privacy settings which allow to make chats
 * \c public or \c private.
 * \c Public chats can be accessed by anyone by their name. Global chat is special kind of chat to
 * which any \b {CENChatEngine} instance will subscribe automatically after
 * instantiation. This chat can be used for announcements or remote \b {CENChatEngine}
 * clients reconfiguration (depends on how new message from it will be handled).
 *
 * \b Default: \c chat-engine.
 */
@property (nonatomic, copy) NSString *globalChannel;

/**
 * @brief Whether \b {user's CENMe} session should be synchronized between owm devices or not.
 *
 * @discussion With enabled synchronization, chats list change on \b {user's CENMe} devices
 * (mobile, desktop) will be synchronized.
 *
 * \b Default: \c NO
 *
 * @ref 121aa803-497a-48bc-91c1-ca8929e0cb5b
 */
@property (nonatomic, assign, getter = shouldSynchronizeSession) BOOL synchronizeSession
    NS_SWIFT_NAME(synchronizeSession);

/**
 * @brief Whether created \b {chats CENChat} should fetch their meta information from
 * \b {CENChatEngine} network or not.
 *
 * \b Default: \c NO
 *
 * @ref 88d12a0d-e95b-40e4-ae6a-c9dfabb595af
 */
@property (nonatomic, assign) BOOL enableMeta;

/**
 * @brief Whether \b {CENChatEngine} should print out all received events.
 *
 * @discussion Console will print out all events which has been emitted locally or by remote client.
 *
 * \b Default: \c NO
 *
 * @since 0.9.2
 *
 * @ref 9cf1b222-42a3-4ba2-a755-3cee376c4c2a
 */
@property (nonatomic, assign, getter = shouldDebugEvents) BOOL debugEvents
    NS_SWIFT_NAME(debugEvents);

/**
 * @brief Whether \b {CENChatEngine} should throw errors or not.
 *
 * \b Default: \c NO
 *
 * @ref 399bc18f-83f4-4a16-bcf7-ceb03c6db581
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
 *
 * @ref 8fc7902a-0baa-4e51-9fb9-8e4a4fe0c4ce
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
