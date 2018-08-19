/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
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
#import "CENSession+Private.h"
#import "CENChat+Interface.h"
#import "CENChat+Private.h"
#import "CENUser+Private.h"
#import "CENStructures.h"
#import "CENErrorCodes.h"
#import "CENLogMacro.h"
#import "CENError.h"
#import "CENMe.h"


#pragma mark Externs

CENChatGroups CENChatGroup = { .system = @"system", .custom = @"custom" };


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
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:^id(NSArray<NSString *> *flags,
                                                                                            NSDictionary *arguments) {
        CENChat *chat = nil;
        NSNumber *isPrivate = arguments[NSStringFromSelector(@selector(private))];
        NSNumber *shouldAutoConnect = arguments[NSStringFromSelector(@selector(autoConnect))];
        NSDictionary *meta = arguments[NSStringFromSelector(@selector(meta))];
        NSString *group = arguments[NSStringFromSelector(@selector(group))];
        
        if ([flags containsObject:NSStringFromSelector(@selector(create))]) {
            chat = [self createChatWithName:arguments[@"name"]
                                      group:group
                                    private:(isPrivate ? isPrivate.boolValue : NO)
                                autoConnect:(shouldAutoConnect ? shouldAutoConnect.boolValue : YES)
                                   metaData:meta];
        } else {
            chat = [self chatWithName:arguments[@"name"] private:(isPrivate ? isPrivate.boolValue : NO)];
        }
        
        return chat;
    }];
    
    return ^CENChatBuilderInterface * {
        return builder;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (CENChat *)createChatWithName:(NSString *)name
                         group:(NSString *)group
                       private:(BOOL)isPrivate
                   autoConnect:(BOOL)shouldAutoConnect
                      metaData:(NSDictionary *)meta {

    return [self.chatsManager createChatWithName:name group:group private:isPrivate autoConnect:shouldAutoConnect metaData:meta];
}

- (CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate {
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Get '%@' %@ chat.", name, isPrivate ? @"private" : @"public");
    
    return [self.chatsManager chatWithName:name private:isPrivate];
}


#pragma mark -  Chats management

- (void)createGlobalChat {
    
    [self.chatsManager createChatWithName:self.configuration.globalChannel group:CENChatGroup.system private:NO autoConnect:YES metaData:nil];
}

- (CENChat *)createDirectChatForUser:(CENUser *)user {
    
    NSString *globalChannel = self.configuration.globalChannel;
    NSString *chatName = [@[globalChannel, @"user", user.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    
    return [self createChatWithName:chatName group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
}

- (CENChat *)createFeedChatForUser:(CENUser *)user {
    
    NSString *globalChannel = self.configuration.globalChannel;
    NSString *chatName = [@[globalChannel, @"user", user.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    
    return [self createChatWithName:chatName group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
}

- (void)removeChat:(CENChat *)chat {
    
    [self.chatsManager removeChat:chat];
}


#pragma mark - Chats state

- (void)fetchRemoteStateForChat:(CENChat *)chat withCompletion:(void(^)(BOOL success, NSDictionary *meta))block {
    
    NSArray<NSDictionary *> *routes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": chat.channel } }];
    
    [self.functionsClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        NSDictionary *information = (NSDictionary *)responses.lastObject;
        NSDictionary *meta = information[CENEventData.chat][@"meta"];
        
        if (success) {
            [self handleFetchedMeta:meta forChat:chat];
        }
        
        block(!success, meta);
    }];
}

- (void)handleFetchedMeta:(NSDictionary *)meta forChat:(CENChat *)chat {
    
    [chat updateMetaWithFetchedData:meta];
}

- (void)updateChatState:(CENChat *)__unused chat withData:(NSDictionary *)data completion:(nullable dispatch_block_t)block {
    
    [self setClientState:data forChannel:self.configuration.globalChannel withCompletion:^(__unused PNClientStateUpdateStatus *status) {
        if (block) {
            block();
        }
    }];
}

- (void)pushUpdatedChatMeta:(CENChat *)chat withRepresentation:(NSDictionary *)representation {
    
    NSArray<NSDictionary *> *routes = @[@{ @"route": @"chat", @"method": @"post", @"body": @{ @"chat": representation } }];
    
    __weak __typeof__(self) weakSelf = self;
    [self.functionsClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (!success) {
            NSString *description = @"Something went wrong while making a request to authentication server.";
            NSError *error = [CENError errorFromPubNubFunctionError:responses withDescription:description];
            
            [strongSelf throwError:error forScope:@"chat" from:chat propagateFlow:CEExceptionPropagationFlow.middleware];
        }
    }];
}


#pragma mark - Chat connection

- (void)connectToChat:(CENChat *)chat withCompletion:(void(^)(NSDictionary *meta))block {
    
    [self handshakeChatAccess:chat withCompletion:^(BOOL isError, NSDictionary *meta) {
        if (isError) {
            return;
        }
        
        block(meta);
        
        void (^handshakeCompletionOnConnect)(CENMe *) = ^(CENMe *me){
            [chat handleRemoteUsersJoin:@[me]];
            
            BOOL isSynchronizationChat = [self.synchronizationSession isSynchronizationChat:chat];
            if (![chat isEqual:self.global] && ![chat isEqual:me.direct] && ![chat isEqual:me.feed] && !isSynchronizationChat) {
                [self synchronizeSessionChatJoin:chat];
            }
            
            if ([chat isEqual:me.direct] || [chat isEqual:me.feed] || isSynchronizationChat) {
                return;
            }
            
            if ([chat.group isEqualToString:CENChatGroup.custom]) {
                dispatch_queue_t delayQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), delayQueue, ^{
                    if (self.chats.count) {
                        [chat fetchParticipants];
                    }
                });
            }
        };
        
        if(self.isReady && self.me) {
            handshakeCompletionOnConnect(self.me);
        } else {
            [self handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
                handshakeCompletionOnConnect(me);
            }];
        }
    }];
}

- (void)connectChats {
    
    [self.chatsManager connectChats];
}

- (void)disconnectChats {
    
    [self.chatsManager disconnectChats];
}


#pragma mark - Participation

- (void)inviteToChat:(CENChat *)chat user:(CENUser *)user {
    
    NSArray<NSDictionary *> *routes = @[@{
        @"route": @"invite",
        @"method": @"post",
        @"body": @{ @"to": user.uuid, @"chat": [chat dictionaryRepresentation] }
    }];
    
    __weak __typeof__(self) weakSelf = self;
    [self.functionsClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (success) {
            [user.direct emitEvent:@"$.invite" withData:@{ @"channel": chat.channel }];
            
            return;
        }
        
        NSString *description = @"Something went wrong while making a request to authentication server.";
        NSError *error = [CENError errorFromPubNubFunctionError:responses withDescription:description];
        
        [strongSelf throwError:error forScope:@"auth" from:chat propagateFlow:CEExceptionPropagationFlow.middleware];
    }];
}

- (void)leaveChat:(CENChat *)chat {
    
    [self unsubscribeFromChannels:@[chat.channel]];
    
    NSDictionary *dictionaryRepresentation = [chat dictionaryRepresentation];
    NSArray<NSDictionary *> *routes = @[@{
        @"route": @"leave",
        @"method": @"post",
        @"body": @{ @"chat": dictionaryRepresentation }
    }];
    
    __weak __typeof__(self) weakSelf = self;
    [self.functionsClient callRouteSeries:routes withCompletion:^(BOOL success, NSArray *responses) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (success) {
            [chat handleLeave];
            [chat emitEvent:@"$.system.leave" withData:@{ @"subject": dictionaryRepresentation }];
            
            [self synchronizeSessionChatLeave:chat];
            
            return;
        }
        
        NSString *description = @"Something went wrong while making a request to chat server.";
        NSError *error = [CENError errorFromPubNubFunctionError:responses withDescription:description];
        
        [strongSelf throwError:error forScope:@"chat" from:chat propagateFlow:CEExceptionPropagationFlow.middleware];
    }];
}

- (void)fetchParticipantsForChat:(CENChat *)chat {
    
    BOOL shouldFetchState = [chat.channel isEqualToString:self.configuration.globalChannel];
    __weak __typeof__(self) weakSelf = self;
    
    [self fetchParticipantsForChannel:chat.channel
                            withState:shouldFetchState
                           completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
                               
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (!status) {
            NSMutableArray<CENUser *> *participants = [NSMutableArray new];
            
            for (id presenceData in result.data.uuids) {
                NSString *uuid = [presenceData isKindOfClass:[NSDictionary class]] ? presenceData[@"uuid"] : presenceData;
                NSDictionary *state = [presenceData isKindOfClass:[NSDictionary class]] ? presenceData[@"state"] : nil;
                
                [participants addObject:[strongSelf createUserWithUUID:uuid state:state]];
            }
            
            [chat handleRemoteUsersStateChange:participants];
            
            return;
        }
        
        NSError *error = [CENError errorFromPubNubStatus:status];
        
        [strongSelf throwError:error forScope:@"presence" from:chat propagateFlow:CEExceptionPropagationFlow.middleware];
    }];
}


#pragma mark - Clean up

- (void)destroyChats {
    
    [self.chatsManager destroy];
}

#pragma mark -


@end
