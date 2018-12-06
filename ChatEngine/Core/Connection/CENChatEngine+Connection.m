/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
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
 */
- (void)handleLocalUserInitialConnectWithGlobal:(nullable NSString *)globalChannel;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENChatEngine (Connection)


#pragma mark - Connection

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENUserConnectBuilderInterface * (^)(NSString *))connect {

    CENInterfaceCallCompletionBlock block = ^id(__unused NSArray *flags, NSDictionary *args) {
        NSString *authKey = args[NSStringFromSelector(@selector(authKey))];
        NSString *globalChannel = args[NSStringFromSelector(@selector(globalChannel))];

        [self connectUser:args[@"uuid"] withAuthKey:authKey globalChannel:globalChannel];
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

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"
- (void)connectUser:(NSString *)userUUID {

    [self connectUser:userUUID withAuthKey:nil globalChannel:nil];
}
#pragma GCC diagnostic pop

- (void)connectUser:(NSString *)userUUID
        withAuthKey:(NSString *)authKey
      globalChannel:(NSString *)globalChannel {

    if (self.pubnub) {
        return;
    }

    if (!authKey || ([authKey isKindOfClass:[NSString class]] && !authKey.length)) {
        authKey = [[NSUUID UUID] UUIDString];
    }

    if ([(id)authKey isKindOfClass:[NSNumber class]]) {
        authKey = ((NSNumber *)(id)authKey).stringValue;
    }

    if (![authKey isKindOfClass:[NSString class]]) {
        NSString *description = @"Auth key must be a string or integer. You may be using a connect "
                                "call from v0.9.x, please migrate your connect call to v0.10.x";
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENInvalidAuthKeyError
                                         userInfo:errorInformation];

        [self throwError:error
                forScope:@"connect.invalidAuthKey"
                    from:self
           propagateFlow:CEExceptionPropagationFlow.direct];

        return;
    }

    CELogAPICall(self.logger, @"<ChatEngine::API> Connect '%@' using '%@' auth key.", userUUID,
        authKey);

    [self authorizeLocalUserWithUUID:userUUID authorizationKey:authKey completion:^{
        [self setupPubNubForUserWithUUID:userUUID authorizationKey:authKey];
        [self handleLocalUserInitialConnectWithGlobal:globalChannel];
    }];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"
- (void)connectUser:(NSString *)userUUID
          withState:(NSDictionary *)__unused state
            authKey:(NSString *)authKey {

    [self connectUser:userUUID withAuthKey:authKey globalChannel:nil];
}
#pragma GCC diagnostic pop

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

- (void)handleLocalUserInitialConnectWithGlobal:(NSString *)globalChannel {

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
                    [self emitEventLocally:@"$.ready", self.me, nil];
                });
                
                [self listenSynchronizationEvents];
                [self synchronizeSession];
            }];
        });
    };

    if (self.configuration.enableGlobal) {
        [self createGlobalChatWithChannel:globalChannel];
        [self.global handleEventOnce:@"$.connected"
                    withHandlerBlock:^(CENEmittedEvent * __unused event) {
                        
            preparationCompletionHandler();
        }];
    } else {
        preparationCompletionHandler();
    }
}

#pragma mark -


@end
