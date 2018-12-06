/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChatEngine.h"
#import <PubNub/PubNub.h>
#import "CENTemporaryObjectsManager.h"
#import "CENPrivateStructures.h"
#import "CENPNFunctionClient.h"
#import "CENPluginsManager.h"
#import "CENConfiguration.h"
#import "CENUsersManager.h"
#import "CENChatsManager.h"
#import "CENSession.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENChatEngine (Private)


#pragma mark - Information

/**
 * @brief Temporary objects (\b {search CENSearch} and \b {event CENEvents}) presence manager.
 */
@property (nonatomic, readonly, strong) CENTemporaryObjectsManager *temporaryObjectsManager;

/**
 * @brief Block which will be used during initial connection and called after PubNub instance
 * completes subscription to user's channel groups.
 */
@property (nonatomic, nullable, copy) dispatch_block_t pubNubSubscribeCompletion;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, readonly, strong) dispatch_queue_t resourceAccessQueue;

/**
 @brief \b {Local user CENMe} chats list synchronization manager.
 */
@property (nonatomic, nullable, strong) CENSession *synchronizationSession;

/**
 * @brief \b {Object CENObject} interface extension and middleware plugins manager.
 */
@property (nonatomic, readonly, strong) CENPluginsManager *pluginsManager;

/**
 * @brief Active \b {users CENUser} manager.
 */
@property (nonatomic, readonly, strong) CENUsersManager *usersManager;

/**
 * @brief Active \b {chats CENChat} manager.
 */
@property (nonatomic, readonly, strong) CENChatsManager *chatsManager;

/**
 * @brief Current client's configuration.
 */
@property (nonatomic, readonly, copy) CENConfiguration *configuration;

/**
 * @brief Current \b PubNub client configuration.
 */
@property (nonatomic, strong) PNConfiguration *pubNubConfiguration;

/**
 * @brief \b PubNub Function access manager.
 */
@property (nonatomic, strong) CENPNFunctionClient *functionClient;

/**
 * @brief Whether \b {ChatEngine CENChatEngine} connected to \b PubNub real-time network or not.
 */
@property (nonatomic, assign) BOOL connectedToPubNub;

@property (nonatomic, getter = isReady, assign) BOOL ready;
@property (nonatomic, nullable, strong) CENChat *global;
@property (nonatomic, strong) PubNub *pubnub;


#pragma mark - Temporary objects

/**
 * @brief Temporary store passed object.
 *
 * @param object Object which should be temporary stored within client.
 */
- (void)storeTemporaryObject:(id)object;


#pragma mark - Clean up

/**
 * @brief Remove any listeners and plugins from specific \c object.
 *
 * @param object \b {Object CENObject} which should be released from any retains from listeners
 *     and plugins.
 */
- (void)unregisterAllFromObjects:(CENObject *)object;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
