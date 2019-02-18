/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+Private.h"
#import "CENChatEngine+ConnectionInterface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENChatEngine+ConnectionBuilderInterface.h"
    #import "CENUserConnectBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+AuthorizationPrivate.h"
#import "CENChatEngine+UserInterface.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Session.h"
#import "CENChat+Private.h"
#import "CENMe+Interface.h"
#import "CENErrorCodes.h"
#import "CENLogMacro.h"
#import "CENDefines.h"


#pragma mark Protected interface declaration

@interface CENChatEngine (ConnectionProtected)


#pragma mark - Handlers

/**
 * @brief Handle initial bootstrap process completion during user connection.
 *
 * @param globalChannel Name of channel which will represent \b {CENChatEngine.global} chat for all
 *     connected clients.
 * @param state Object with \b {local user CENMe} state which will be publicly available from
 *     \b {CENChatEngine.global} chat.
 */
- (void)handleLocalUserInitialConnectWithGlobal:(nullable NSString *)globalChannel
                                          state:(nullable NSDictionary *)state;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENChatEngine (Connection)


#pragma mark - Connection

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENUserConnectBuilderInterface * (^)(NSString *))connect {

    CENInterfaceCallCompletionBlock block = ^id(__unused NSArray *flags, NSDictionary *args) {
        NSDictionary *state = args[NSStringFromSelector(@selector(state))];
        NSString *authKey = args[NSStringFromSelector(@selector(authKey))];

        [self connectUser:args[@"uuid"] withState:state authKey:authKey];
        return self;
    };

    CENUserConnectBuilderInterface *builder = nil;
    builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    
    return ^CENUserConnectBuilderInterface * (NSString *uuid) {
        [builder setArgument:uuid forParameter:@"uuid"];
        return builder;
    };
}

- (CENChatEngine * (^)(void))reconnect {
    
    return ^CENChatEngine * {
        [self reconnectUser];
        return self;
    };
}

- (CENChatEngine * (^)(void))disconnect {
    
    return ^CENChatEngine * {
        [self disconnectUser];
        return self;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)connectUser:(NSString *)userUUID {
    
    [self connectUser:userUUID withState:nil authKey:nil];
}

- (void)connectUser:(NSString *)userUUID withState:(NSDictionary *)state authKey:(id)authKey {
    
    if (self.pubnub) {
        return;
    }
    
    if (![state isKindOfClass:[NSDictionary class]] || !state.count) {
        state = nil;
    }

    if (!authKey || ([authKey isKindOfClass:[NSString class]] && !((NSString *)authKey).length)) {
        authKey = [[NSUUID UUID] UUIDString];
    }

    if ([(id)authKey isKindOfClass:[NSNumber class]]) {
        authKey = ((NSNumber *)(id)authKey).stringValue;
    }

    CELogAPICall(self.logger, @"<ChatEngine::API> Connect '%@' using '%@' auth key.", userUUID,
        authKey);

    [self authorizeLocalUserWithUUID:userUUID authorizationKey:authKey completion:^{
        [self setupPubNubForUserWithUUID:userUUID authorizationKey:authKey];
        [self handleLocalUserInitialConnectWithGlobal:self.configuration.globalChannel state:state];
    }];
}

- (void)reconnectUser {
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Reconnect '%@' using '%@' auth key.",
        self.pubNubUUID, self.pubNubAuthKey);

    [self authorizeLocalUserWithCompletion:^{
        [self connectChats];
        [self connectToPubNubWithCompletion:^{
            [self synchronizeSession];
        }];
    }];
}

- (void)disconnectUser {
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Disconnect '%@'.", self.pubNubUUID);
    
    [self disconnectFromPubNub];
    [self disconnectChats];
}


#pragma mark - Handlers

- (void)handleLocalUserInitialConnectWithGlobal:(NSString *)globalChannel
                                          state:(NSDictionary *)state {

    dispatch_block_t preparationCompletionHandler = ^{
        dispatch_group_t localUserCreationGroup = dispatch_group_create();
        dispatch_group_enter(localUserCreationGroup);
        dispatch_group_enter(localUserCreationGroup);

        [self createUserWithUUID:[self pubNubUUID] state:@{}];

        [self.me.direct handleEventOnce:@"$.connected"
                       withHandlerBlock:^(CENEmittedEvent * __unused event) {
                           
            dispatch_group_leave(localUserCreationGroup);
        }];

        [self.me.feed handleEventOnce:@"$.connected"
                     withHandlerBlock:^(CENEmittedEvent * __unused event) {
                         
            dispatch_group_leave(localUserCreationGroup);
        }];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_notify(localUserCreationGroup, queue, ^{
            CENWeakify(self);
            
            [self connectToPubNubWithCompletion:^{
                CENStrongify(self);
                
                dispatch_sync(self.resourceAccessQueue, ^{
                    self.ready = YES;
                    [self.me updateState:state];
                    [self emitEventLocally:@"$.ready", self.me, nil];
                });
                
                [self listenSynchronizationEvents];
                [self synchronizeSession];
            }];
        });
    };

    [self createGlobalChatWithChannel:globalChannel];
    [self.global handleEventOnce:@"$.connected"
                withHandlerBlock:^(CENEmittedEvent * __unused event) {
                    
        preparationCompletionHandler();
    }];
}

#pragma mark -


@end
