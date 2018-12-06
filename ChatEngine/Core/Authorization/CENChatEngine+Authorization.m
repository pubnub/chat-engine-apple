/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChatEngine+AuthorizationBuilderInterface.h"
#import "CENChatEngine+AuthorizationPrivate.h"
#import "CENChatEngine+ConnectionInterface.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+Private.h"
#import "CENChat+Interface.h"
#import "CENChat+Private.h"
#import "CENErrorCodes.h"
#import "CENLogMacro.h"
#import "CENDefines.h"
#import "CENError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENChatEngine (AuthorizationProtected)


#pragma mark - Misc

/**
 * @brief Prepare and throw exception because PubNub client not ready yet.
 *
 * @param chat \b {Chat CENChat} for which user tried to grant access rights for connection.
 */
- (void)throwPubNubNotReadyConnectToChat:(CENChat *)chat;

/**
 * @brief Prepare and throw exception because of troubles in communication with \b PubNub Function.
 *
 * @param responses Responses from \b PubNub Function which contain error description.
 * @param chat \b {Chat CENChat} for which \b PubNub Function has been used.
 */
- (void)throwPubNubFunctionHandshakeError:(NSArray *)responses forChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENChatEngine (Authorization)


#pragma mark - Access management

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChatEngine * (^)(id authKey))reauthorize {

    return ^CENChatEngine * (id authKey){
        [self reauthorizeUserWithKey:authKey];
        return self;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)reauthorizeUserWithKey:(id)authKey {
    
    authKey = authKey ?: [[NSUUID UUID] UUIDString];
    
    if ([authKey isKindOfClass:[NSNumber class]]) {
        authKey = ((NSNumber *)authKey).stringValue;
    }

    CELogAPICall(self.logger, @"<ChatEngine::API> Re-authorize with key: %@", authKey);

    CENWeakify(self)
    dispatch_block_t disconnectionHandler = ^{
        CENStrongify(self)

        [self changePubNubAuthorizationKey:authKey withCompletion:^{
            NSString *namespace = self.currentConfiguration.namespace;
            NSString *uuid = [self pubNubUUID];
            
            [self.functionClient setWithNamespace:namespace userUUID:uuid userAuth:authKey];
            [self reconnectUser];
        }];
    };
    
    [self.global handleEventOnce:@"$.disconnected"
                withHandlerBlock:^(CENEmittedEvent * __unused event) {
                    
        disconnectionHandler();
    }];
    [self disconnectUser];
    [self resetChatsConnection];
    
    if (!self.configuration.enableGlobal) {
        disconnectionHandler();
    }
}


#pragma mark - Access management

- (void)authorizeLocalUserWithCompletion:(dispatch_block_t)block {

    [self authorizeLocalUserWithUUID:[self pubNubUUID]
                    authorizationKey:[self pubNubAuthKey]
                          completion:block];
}

- (void)authorizeLocalUserWithUUID:(NSString *)uuid
                  authorizationKey:(NSString *)authKey
                        completion:(dispatch_block_t)block {

    NSString *namespace = self.currentConfiguration.namespace;
    NSArray<NSDictionary *> *routes = @[
        @{ @"route": @"bootstrap", @"method": @"post" },
        @{ @"route": @"user_read", @"method": @"post" },
        @{ @"route": @"user_write", @"method": @"post" },
        @{ @"route": @"group", @"method": @"post" }
    ];

    [self.functionClient setWithNamespace:namespace userUUID:uuid userAuth:authKey];

    CENWeakify(self)
    [self.functionClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        CENStrongify(self)

        if (success) {
            block();
            return;
        }

        NSString *functionEndpoint = self.currentConfiguration.functionEndpoint;
        NSString *description = [NSString stringWithFormat:@"There was a problem logging into the "
                                 "auth server (%@).", functionEndpoint];
        NSError *error = [CENError errorFromPubNubFunctionError:responses
                                                withDescription:description];

        [self throwError:error
                forScope:@"connect.handshake"
                    from:self
           propagateFlow:CEExceptionPropagationFlow.direct];
    }];
}

- (void)handshakeChatAccess:(CENChat *)chat withCompletion:(dispatch_block_t)block {

    if (!self.pubnub) {
        [self throwPubNubNotReadyConnectToChat:chat];
        return;
    }

    NSDictionary *chatRepresentation = [chat dictionaryRepresentation];
    __block NSArray<NSDictionary *> *routes = @[
        @{ @"route": @"grant", @"method": @"post", @"body": @{ @"chat": chatRepresentation } },
        @{ @"route": @"join", @"method": @"post", @"body": @{ @"chat": chatRepresentation } },
    ];
    void (^errorHandlerBlock)(NSArray *) = ^(NSArray *responses) {
        [self throwPubNubFunctionHandshakeError:responses forChat:chat];
    };
    void (^handleMetaFetch)(BOOL, NSArray *) = ^(BOOL success, NSArray *responses) {
        if (!success) {
            errorHandlerBlock(responses);
            return;
        }
        
        block();
    };

    [self.functionClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        if (!self.configuration.enableMeta || !success) {
            if (!success) {
                errorHandlerBlock(responses);
            } else {
                block();
            }

            return;
        }
        
        if (![chat.group isEqualToString:CENChatGroup.system] && ![chat isEqual:self.global]) {
            [self fetchMetaForChat:chat withCompletion:handleMetaFetch];
        } else {
            block();
        }
        
    }];
}


#pragma mark - Misc

- (void)throwPubNubNotReadyConnectToChat:(CENChat *)chat {

    NSString *description = @"You must call chatEngine.connect() and wait for the $.ready event "
                            "before creating new Chats.";
    NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
    NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                         code:kCENClientNotConnectedError
                                     userInfo:errorInformation];

    [self throwError:error
            forScope:@"connection.notReady"
                from:chat
       propagateFlow:CEExceptionPropagationFlow.direct];
}

- (void)throwPubNubFunctionHandshakeError:(NSArray *)responses forChat:(CENChat *)chat {

    NSString *functionEndpoint = self.currentConfiguration.functionEndpoint;
    NSString *description = [NSString stringWithFormat:@"There was a problem logging into the auth "
                                                       "server (%@).", functionEndpoint];
    NSError *error = [CENError errorFromPubNubFunctionError:responses withDescription:description];

    [self throwError:error
            forScope:@"connection.handshake"
                from:chat
       propagateFlow:CEExceptionPropagationFlow.direct];
}

#pragma mark -


@end
