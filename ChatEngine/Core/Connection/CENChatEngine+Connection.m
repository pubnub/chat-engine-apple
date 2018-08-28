/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
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
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+UserPrivate.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Session.h"
#import "CENChat+Private.h"
#import "CENLogMacro.h"
#import "CENMe.h"


#pragma mark Protected interface declaration

@interface CENChatEngine (ConnectionProtected)


#pragma mark - Handlers

/**
 * @brief      Handle local user setup preparation completion.
 * @discussion At moment of handler call, local user has been created along with it's connected \c direct and \c feed chats.
 *
 * @param state Reference on state which is expected to be set for user and available for everyone.
 */
- (void)handleLocalUserSetupWithState:(NSDictionary *)state;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENChatEngine (Connection)


#pragma mark - Connection

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENUserConnectBuilderInterface * (^)(NSString *))connect {
    
    CENUserConnectBuilderInterface *builder = nil;
    builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:^id(__unused NSArray<NSString *> *flags, NSDictionary *arguments) {
        NSDictionary *state = arguments[NSStringFromSelector(@selector(state))];
        NSString *authKey = arguments[NSStringFromSelector(@selector(authKey))];
        
        [self connectUser:arguments[@"uuid"] withState:state authKey:authKey];
        
        return self;
    }];
    
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

- (void)connectUser:(NSString *)userUUID withState:(NSDictionary *)state authKey:(NSString *)authKey {
    
    if (![state isKindOfClass:[NSDictionary class]] || !state.count) {
        state = nil;
    }
    
    if (![authKey isKindOfClass:[NSString class]] || !authKey.length) {
        authKey = nil;
    }
    
    authKey = authKey ?: [[NSUUID UUID] UUIDString];
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Connect '%@' using '%@' auth key.%@", userUUID, authKey,
                 state.count ? [@[@" State: ", state] componentsJoinedByString:@""] : @"");
    
    [self authorizeLocalUserWithUUID:userUUID authorizationKey:authKey completion:^{
        [self setupPubNubForUserWithUUID:userUUID authorizationKey:authKey];
        
        [self createGlobalChat];
        [self.global handleEventOnce:@"$.connected" withHandlerBlock:^{
            dispatch_group_t localUserCreationGroup = dispatch_group_create();
            dispatch_group_enter(localUserCreationGroup);
            dispatch_group_enter(localUserCreationGroup);
            
            [self createUserWithUUID:userUUID state:@{}];
            
            [self.me.direct handleEventOnce:@"$.connected" withHandlerBlock:^{
                dispatch_group_leave(localUserCreationGroup);
            }];
            
            [self.me.feed handleEventOnce:@"$.connected" withHandlerBlock:^{
                dispatch_group_leave(localUserCreationGroup);
            }];
            
            dispatch_group_notify(localUserCreationGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self handleLocalUserSetupWithState:state];
            });
        }];
    }];
}

- (void)reconnectUser {
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Reconnect '%@' using '%@' auth key.", self.pubNubUUID, self.pubNubAuthKey);
    
    __weak __typeof__(self) weakSelf = self;
    [self authorizeLocalUserWithCompletion:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf connectChats];
        [strongSelf connectToPubNub];
    }];
}

- (void)disconnectUser {
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Disconnect '%@'.", self.pubNubUUID);
    
    [self disconnectFromPubNub];
    [self disconnectChats];
}


#pragma mark - Handlers

- (void)handleLocalUserSetupWithState:(NSDictionary *)state {
    
    [self updateLocalUserState:state withCompletion:^{
        dispatch_sync(self.resourceAccessQueue, ^{
            self.ready = YES;
            [self emitEventLocally:@"$.ready", self.me, nil];
        });
        
        [self connectToPubNub];
        
        [self.global fetchParticipants];
        
        [self listenSynchronizationEvents];
        
        [self synchronizeSession];
    }];
}

#pragma mark -


@end
