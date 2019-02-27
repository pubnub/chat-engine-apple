/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+PubNub.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENChatEngine (PubNubPrivate)


#pragma mark - Information

/**
 * @brief PubNub callbacks (messages, presence events and status events) will be fired on.
 */
@property (nonatomic, readonly, strong) dispatch_queue_t pubNubCallbackQueue;

/**
 * @brief User authentication secret key. Will be sent to authentication backend for validation.
 * This is usually an access token.
 */
@property (nonatomic, readonly, strong) NSString *pubNubAuthKey;

/**
 * @brief Unique identifier of user, which currently connected with \b {CENChatEngine}
 * client.
 */
@property (nonatomic, readonly, strong) NSString *pubNubUUID;


#pragma mark - Configuration

/**
 * @brief Setup \c PubNub client for specific user.
 *
 * @param uuid Unique identifier for which \b {CENChatEngine} should be prepared
 *     \b {local user CENMe} instance.
 * @param authorizationKey User authentication secret key.
 */
- (void)setupPubNubForUserWithUUID:(NSString *)uuid authorizationKey:(NSString *)authorizationKey;

/**
 * @brief Update authentication secret key which is used by current user.
 *
 * @param authorizationKey New user authentication secret key.
 * @param block Block which will be called at the end of key update process.
 */
- (void)changePubNubAuthorizationKey:(NSString *)authorizationKey
                      withCompletion:(dispatch_block_t)block;


#pragma mark - Connection

/**
 * @brief Subscribe on channel groups and add handlers for messages, presence events and status
 * events.
 *
 * @param completion Block which will be called at the end of subscribe request completion (even
 *     after error).
 */
- (void)connectToPubNubWithCompletion:(nullable dispatch_block_t)completion;

/**
 * @brief Unsubscribe from data channel groups and remove event handlers.
 */
- (void)disconnectFromPubNub;


#pragma mark - History

/**
 * @brief Perform search of messages in specific channel.
 *
 * @param channel Name \b {chat CENChat} channel inside of which messages should be searched.
 * @param date Reference date which is used to search older messages in \c channel.
 * @param limit How many messages should be returned at once.
 * @param block Block which will be called at the end of search process and pass search results
 *     or error status.
 */
- (void)searchMessagesIn:(NSString *)channel
               withStart:(NSNumber *)date
                   limit:(NSUInteger)limit
              completion:(PNHistoryCompletionBlock)block;


#pragma mark - Presence

/**
 * @brief Retrieve list of participants in specific channel.
 *
 * @param channel Name \b {chat CENChat} channel for which participants should be fetched.
 * @param block Block which will be called at the end of presence fetch and pass result or error
 *     status.
 */
- (void)fetchParticipantsForChannel:(NSString *)channel completion:(PNHereNowCompletionBlock)block;

/**
 * @brief Update state of \b {local user CENMe} at specific channel.
 *
 * @param state \a NSDictionary with information which should be bound to user at specified
 *     \c channel.
 * @param channel Name \b {chat CENChat} channel to which user's \c state will be set.
 * @param block Block which will be called at the end of state set and pass acknowledgment or error
 *     status.
 */
- (void)setClientState:(NSDictionary *)state
            forChannel:(NSString *)channel
        withCompletion:(nullable PNSetStateCompletionBlock)block;


#pragma mark - Publishing

/**
 * @brief Publish data to specific channel.
 *
 * @param shouldStoreInHistory Whether published \c data should be available with PubNub history API
 *     or not.
 * @param data \a NSDictionary object which data which should be published to \c channel.
 * @param channel Name \b {chat CENChat} channel to which \c data should be sent.
 */
- (void)publishStorable:(BOOL)shouldStoreInHistory
                   data:(NSDictionary *)data
              toChannel:(NSString *)channel
         withCompletion:(PNPublishCompletionBlock)block;


#pragma mark - Stream controller

/**
 * @brief Retrieve list of channels registered for specified \c group.
 *
 * @param group Name of group under which channels registered (one of \b {CENChatGroups} enum
 *     fields).
 * @param block Block which will be called at the end of fetch process and pass list of channels for
 *     group or error status.
 */
- (void)channelsForGroup:(NSString *)group
          withCompletion:(void(^)(NSArray<NSString *> * __nullable chats,
                                  PNErrorStatus * __nullable status))block;


#pragma mark - Clean up

/**
 * @brief Clean up all used resources.
 *
 * @discussion Clean up all resources which has been provided to support PubNub.
 */
- (void)destroyPubNub;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
