/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
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

@property (nonatomic, readonly, strong) CENTemporaryObjectsManager *temporaryObjectsManager;
@property (nonatomic, getter = isReady, assign) BOOL ready NS_SWIFT_NAME(ready);
@property (nonatomic, readonly, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, nullable, strong) CENSession *synchronizationSession;
@property (nonatomic, readonly, strong) CENPluginsManager *pluginsManager;
@property (nonatomic, readonly, strong) CENUsersManager *usersManager;
@property (nonatomic, readonly, strong) CENChatsManager *chatsManager;
@property (nonatomic, readonly, copy) CENConfiguration *configuration;
@property (nonatomic, strong) PNConfiguration *pubNubConfiguration;
@property (nonatomic, strong) CENPNFunctionClient *functionsClient;
@property (nonatomic, assign) BOOL connectedToPubNub;
@property (nonatomic, strong) PubNub *pubnub;
@property (nonatomic, strong) CENChat *global;


#pragma mark - Temporary objects

- (void)storeTemporaryObject:(id)object;


#pragma mark - Clean up

- (void)unregisterAllFromObjects:(CENObject *)object;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
