/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+ChatInterface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENChatEngine+ChatBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
    #import "CENChatBuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+AuthorizationPrivate.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+UserInterface.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+Session.h"
#import "CENChatEngine+Private.h"
#import "CENChat+Interface.h"
#import "CENChat+Private.h"
#import "CENUser+Private.h"
#import "CENEmittedEvent.h"
#import "CENLogMacro.h"
#import "CENDefines.h"
#import "CENError.h"
#import "CENMe.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENChatGroups CENChatGroup = {
    .system = @"system",
    .custom = @"custom"
};


#pragma mark - Interface implementation

@implementation CENChatEngine (Chat)


#pragma mark - Information

- (NSDictionary<NSString *,CENChat *> *)chats {
    
    return self.chatsManager.chats;
}

- (CENChat *)global {
    
    return self.chatsManager.global;
}


#pragma mark - Chat

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChatBuilderInterface * (^)(void))Chat {

    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *args) {
        NSNumber *isPrivate = args[NSStringFromSelector(@selector(private))];
        NSNumber *shouldAutoConnect = args[NSStringFromSelector(@selector(autoConnect))];
        NSDictionary *meta = args[NSStringFromSelector(@selector(meta))];
        CENChat *chat = nil;

        if ([flags containsObject:NSStringFromSelector(@selector(create))]) {
            chat = [self createChatWithName:args[@"name"]
                                      group:nil
                                    private:(isPrivate ? isPrivate.boolValue : NO)
                                autoConnect:(shouldAutoConnect ? shouldAutoConnect.boolValue : YES)
                                   metaData:meta];
        } else {
            chat = [self chatWithName:args[@"name"] private:(isPrivate ? isPrivate.boolValue : NO)];
        }

        return chat;
    };

    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];

    return ^CENChatBuilderInterface * {
        return builder;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (CENChat *)createChatWithName:(NSString *)name
                        private:(BOOL)isPrivate
                    autoConnect:(BOOL)autoConnect
                       metaData:(NSDictionary *)meta {
    
    return [self createChatWithName:name
                              group:nil
                            private:isPrivate
                        autoConnect:autoConnect
                           metaData:meta];
}

- (CENChat *)createChatWithName:(NSString *)name
                          group:(NSString *)group
                        private:(BOOL)isPrivate
                    autoConnect:(BOOL)autoConnect
                       metaData:(NSDictionary *)meta {

    return [self.chatsManager createGlobalChat:NO
                                      withName:name
                                         group:group
                                       private:isPrivate
                                   autoConnect:autoConnect
                                      metaData:meta];
}

- (CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate {
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Get '%@' %@ chat.", name,
        isPrivate ? @"private" : @"public");
    
    return [self.chatsManager chatWithName:name private:isPrivate];
}


#pragma mark -  Chats management

- (void)createGlobalChatWithChannel:(NSString *)channel {

    NSString *namespace = self.configuration.globalChannel;
    
    [self.chatsManager createGlobalChat:YES
                               withName:(channel ?: namespace)
                                  group:CENChatGroup.system
                                private:NO
                            autoConnect:YES
                               metaData:nil];
}

- (CENChat *)createDirectChatForUser:(CENUser *)user {

    NSString *namespace = self.configuration.globalChannel;
    NSArray<NSString *> *nameComponents = @[namespace, @"user", user.uuid, @"write.", @"direct"];
    
    return [self createChatWithName:[nameComponents componentsJoinedByString:@"#"]
                              group:CENChatGroup.system
                            private:NO
                        autoConnect:NO
                           metaData:nil];
}

- (CENChat *)createFeedChatForUser:(CENUser *)user {

    NSString *namespace = self.configuration.globalChannel;
    NSArray<NSString *> *nameComponents = @[namespace, @"user", user.uuid, @"read.", @"feed"];
    
    return [self createChatWithName:[nameComponents componentsJoinedByString:@"#"]
                              group:CENChatGroup.system
                            private:NO
                        autoConnect:NO
                           metaData:nil];
}

- (void)removeChat:(CENChat *)chat {
    
    [self.chatsManager removeChat:chat];
}


#pragma mark - Chat meta

- (void)fetchMetaForChat:(CENChat *)chat
          withCompletion:(void(^)(BOOL success, NSArray *responses))block {
    
    NSArray<NSDictionary *> *routes = @[
        @{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": chat.channel } }
    ];
    
    [self.functionClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        NSDictionary *information = (NSDictionary *)responses.lastObject;
        NSDictionary *meta = success ? information : nil;
        
        if (success) {
            [chat updateMetaWithFetchedData:meta];
        }
        
        block(success, responses);
    }];
}

- (void)pushUpdatedChatMeta:(CENChat *)chat withRepresentation:(NSDictionary *)representation {
    
    NSArray<NSDictionary *> *routes = @[
        @{ @"route": @"chat", @"method": @"post", @"body": @{ @"chat": representation } }
    ];

    [self.functionClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        if (!success) {
            NSString *description = @"Something went wrong while trying to update metadata.";
            NSError *error = [CENError errorFromPubNubFunctionError:responses
                                                    withDescription:description];
            
            [self throwError:error
                    forScope:@"chat"
                        from:chat
               propagateFlow:CEExceptionPropagationFlow.direct];
        }
    }];
}


#pragma mark - Chat state

- (void)updateChatState:(CENChat *)chat
               withData:(NSDictionary *)data
             completion:(void(^)(NSError *error))block {
    
    [self setClientState:data
              forChannel:chat.channel
          withCompletion:^(PNClientStateUpdateStatus *status) {

        if (block) {
            block(status.isError ? [CENError errorFromPubNubStatus:status] : nil);
        }
    }];
}


#pragma mark - Chat connection

- (void)connectToChat:(CENChat *)chat withCompletion:(dispatch_block_t)block {
    
    [self handshakeChatAccess:chat withCompletion:^{
        block();

        CENWeakify(self)
        void (^handshakeCompletionOnConnect)(CENMe *) = ^(__unused CENMe *me) {
            CENStrongify(self)
            [self synchronizeSessionChatJoin:chat];
        };
        
        if(self.isReady && self.me) {
            handshakeCompletionOnConnect(self.me);
        } else {
            [self handleEventOnce:@"$.ready" withHandlerBlock:^(CENEmittedEvent *event) {
                handshakeCompletionOnConnect(event.data);
            }];
        }
    }];
}

- (void)connectChats {
    
    [self.chatsManager connectChats];
}

- (void)resetChatsConnection {
    
    [self.chatsManager resetChatsConnection];
}

- (void)disconnectChats {
    
    [self.chatsManager disconnectChats];
}


#pragma mark - Participation

- (void)inviteToChat:(CENChat *)chat user:(CENUser *)user {
    
    NSDictionary *representation = [chat dictionaryRepresentation];
    NSArray<NSDictionary *> *routes = @[@{
        @"route": @"invite",
        @"method": @"post",
        @"body": @{ @"to": user.uuid, @"chat": representation }
    }];

    [self.functionClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        if (success) {
            [user.direct emitEvent:@"$.invite" withData:@{ @"channel": chat.channel }];
            return;
        }
        
        NSString *description = @"Something went wrong while making a request to authentication "
                                "server.";
        NSError *error = [CENError errorFromPubNubFunctionError:responses
                                                withDescription:description];
        
        [self throwError:error
                forScope:@"auth"
                    from:chat
           propagateFlow:CEExceptionPropagationFlow.middleware];
    }];
}

- (void)leaveChat:(CENChat *)chat {
    
    if (![chat.group isEqualToString:CENChatGroup.custom] || [chat isEqual:self.global]) {
        return;
    }

    NSDictionary *dictionaryRepresentation = [chat dictionaryRepresentation];
    NSArray<NSDictionary *> *routes = @[@{
        @"route": @"leave",
        @"method": @"post",
        @"body": @{ @"chat": dictionaryRepresentation }
    }];

    [self.functionClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        if (success) {
            [chat handleLeave];
            [chat emitEvent:@"$.system.leave" withData:@{ @"subject": dictionaryRepresentation }];
            
            [self synchronizeSessionChatLeave:chat];
            return;
        }
        
        NSString *description = @"Something went wrong while making a request to chat server.";
        NSError *error = [CENError errorFromPubNubFunctionError:responses
                withDescription:description];
        
        [self throwError:error
                forScope:@"leave"
                    from:chat
           propagateFlow:CEExceptionPropagationFlow.direct];
    }];
}

- (void)fetchParticipantsForChat:(CENChat *)chat {

    [self fetchParticipantsForChannel:chat.channel
                           completion:^(PNPresenceChannelHereNowResult *result,
                                        PNErrorStatus *status) {
        
        if (!status) {
            NSMutableArray<CENUser *> *participants = [NSMutableArray new];
            NSMutableDictionary *states = [NSMutableDictionary new];
            
            for (id presenceData in result.data.uuids) {
                NSString *uuid = presenceData;
                NSDictionary *state = @{};

                if ([presenceData isKindOfClass:[NSDictionary class]]) {
                    uuid = presenceData[@"uuid"];
                    state = presenceData[@"state"];
                }
                
                CENUser *user = [self createUserWithUUID:uuid state:nil];
                [user assignState:state forChat:chat];
                states[user.uuid] = state;
                
                [participants addObject:user];
            }
            
            [chat handleRemoteUsersRefresh:participants withStates:states];
            return;
        }
        
        NSString *description = @"Getting presence of this Chat. Make sure PubNub presence is "
                                "enabled for this key";
        NSError *error = [CENError errorFromPubNubStatus:status withDescription:description];
        
        [self throwError:error
                forScope:@"presence"
                    from:chat
           propagateFlow:CEExceptionPropagationFlow.middleware];
    }];
}


#pragma mark - Clean up

- (void)destroyChats {
    
    [self.chatsManager destroy];
}

#pragma mark -


@end
