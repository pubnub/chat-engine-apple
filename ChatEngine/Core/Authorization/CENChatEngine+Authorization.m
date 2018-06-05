/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+AuthorizationBuilderInterface.h"
#import "CENChatEngine+AuthorizationPrivate.h"
#import "CENChatEngine+ConnectionInterface.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+Private.h"
#import "CENErrorCodes.h"
#import "CENStructures.h"
#import "CENChat.h"


#pragma mark Interface implementation

@implementation CENChatEngine (Authorization)


#pragma mark - Confgiuration

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENChatEngine * (^)(NSString * authKey))reauthorize {
    
    return ^CENChatEngine * (NSString *authKey){
        [self reauthorizeUserWithKey:authKey];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)reauthorizeUserWithKey:(NSString *)authKey {
    
    [self.global handleEventOnce:@"$.disconnected" withHandlerBlock:^{
        [self changePubNubAuthorizationKey:authKey withCompletion:^{
            NSString *globalChat = self.currentConfiguration.globalChannel;
            
            [self.functionsClient setDefaultDataWithGlobalChat:globalChat userUUID:[self pubNubUUID] userAuth:authKey];
            [self reconnectUser];
        }];
    }];
    
    [self disconnectUser];
}


#pragma mark - Access management

- (void)authorizeLocalUserWithCompletion:(dispatch_block_t)block {
    
    [self authorizeLocalUserWithUUID:[self pubNubUUID] authorizationKey:[self pubNubAuthKey] completion:block];
}

- (void)authorizeLocalUserWithUUID:(NSString *)uuid authorizationKey:(NSString *)authorizationKey completion:(dispatch_block_t)block {
    
    NSString *globalChat = self.currentConfiguration.globalChannel;
     NSArray<NSDictionary *> *routes = @[
        @{ @"route": @"bootstrap", @"method": @"post" },
        @{ @"route": @"user_read", @"method": @"post" },
        @{ @"route": @"user_write", @"method": @"post" },
        @{ @"route": @"group", @"method": @"post" }
    ];
    
    __weak __typeof(self) weakSelf = self;
    [self.functionsClient setDefaultDataWithGlobalChat:globalChat userUUID:uuid userAuth:authorizationKey];
    [self.functionsClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (success) {
            block();
            
            return;
        }
        
        id errorInformation = responses.firstObject ?: @"Unknown error";
        NSString *description = [NSString stringWithFormat:@"There was a problem logging into the auth server (%@).",
                                 strongSelf.currentConfiguration.functionEndpoint];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description, NSUnderlyingErrorKey: errorInformation };
        NSError *error = [NSError errorWithDomain:kCEPNFunctionErrorDomain code:kCEPNAuthorizationError userInfo:userInfo];
        
        [strongSelf throwError:error forScope:@"auth" from:strongSelf propagateFlow:CEExceptionPropagationFlow.direct];
    }];
}

- (void)handshakeChatAccess:(CENChat *)chat withCompletion:(void (^)(BOOL, NSDictionary *))block {
    
    if (self.pubnub) {
        NSDictionary *dictionaryRepresentation = [chat dictionaryRepresentation];
        __block NSArray<NSDictionary *> *routes = @[
            @{ @"route": @"grant", @"method": @"post",  @"body": @{ @"chat": dictionaryRepresentation } },
            @{ @"route": @"join", @"method": @"post",  @"body": @{ @"chat": dictionaryRepresentation } },
        ];
        __weak __typeof(self) weakSelf = self;
        
        [self.functionsClient callRouteSeries:routes withCompletion:^(BOOL success, __unused NSArray *responses) {
            routes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": chat.channel } }];
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            if (!strongSelf.configuration.enableMeta || !success) {
                block(!success, nil);
                
                return;
            }
            
            [strongSelf fetchRemoteStateForChat:chat withCompletion:block];
        }];
        
        return;
    }
    
    NSString *description = @"You must call -[chatEngine connect] and wait for the $.ready event before creating new Chats.";
    NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
    NSError *error = [NSError errorWithDomain:kCEErrorDomain code:kCEClientNotConnectedError userInfo:errorInformation];
    
    [self throwError:error forScope:@"auth" from:chat propagateFlow:CEExceptionPropagationFlow.middleware];
}

#pragma mark -


@end
