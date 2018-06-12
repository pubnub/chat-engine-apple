/**
 * @author Serhii Mamontov
 * @version 0.9.13
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
#import "CENChat+Interface.h"
#import "CENChat+Private.h"
#import "CENUser+Private.h"
#import "CENStructures.h"
#import "CENErrorCodes.h"
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
    
    return [self.chatsManager chatWithName:name private:isPrivate];
}


#pragma mark -  Chats management

- (void)createGlobalChat {
    
    [self.chatsManager createChatWithName:self.configuration.globalChannel group:CENChatGroup.system private:NO autoConnect:YES metaData:nil];
}

- (CENChat *)createDirectChatForUser:(CENUser *)user {
    
    NSString *globalChannel = self.configuration.globalChannel;
    NSString *chatName = [@[globalChannel, @"user", user.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    
    
    return [self createChatWithName:chatName group:CENChatGroup.system private:NO autoConnect:[user isKindOfClass:[CENMe class]] metaData:nil];
}

- (CENChat *)createFeedChatForUser:(CENUser *)user {
    
    NSString *globalChannel = self.configuration.globalChannel;
    NSString *chatName = [@[globalChannel, @"user", user.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    
    return [self createChatWithName:chatName group:CENChatGroup.system private:NO autoConnect:[user isKindOfClass:[CENMe class]] metaData:nil];
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
            id errorInformation = responses.firstObject ?: @"Unknown error";
            NSString *description = @"Something went wrong while making a request to authentication server.";
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description, NSUnderlyingErrorKey: errorInformation };
            NSError *error = [NSError errorWithDomain:kCEPNFunctionErrorDomain code:kCEPNAuthorizationError userInfo:userInfo];
            
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
        
        [self synchronizeSessionChatJoin:chat];
        
        if(self.isReady && self.me) {
            [chat handleRemoteUsersJoin:@[self.me]];
        } else {
            [self handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
                [chat handleRemoteUsersJoin:@[me]];
            }];
        }
        
        if ([chat.group isEqualToString:CENChatGroup.custom] && ![chat.channel isEqualToString:self.configuration.globalChannel]) {
            [chat fetchParticipants];
            
            // We may miss updates, so call this again 5 seconds later.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [chat fetchParticipants];
            });
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
        
        id errorInformation = responses.firstObject ?: @"Unknown error";
        NSString *description = @"Something went wrong while making a request to authentication server.";
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description, NSUnderlyingErrorKey: errorInformation };
        NSError *error = [NSError errorWithDomain:kCEPNFunctionErrorDomain code:kCEPNAuthorizationError userInfo:userInfo];
        
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
        
        id errorInformation = responses.firstObject ?: @"Unknown error";
        NSString *description = @"Something went wrong while making a request to chat server.";
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description, NSUnderlyingErrorKey: errorInformation };
        NSError *error = [NSError errorWithDomain:kCEPNFunctionErrorDomain code:kCEPNAPresenceLeaveError userInfo:userInfo];
        
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
        
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: status.errorData.information };
        NSError *error = [NSError errorWithDomain:kCEPNErrorDomain code:kCEChannelPresenceAuditError userInfo:errorInformation];
        
        [strongSelf throwError:error forScope:@"presence" from:chat propagateFlow:CEExceptionPropagationFlow.middleware];
    }];
}


#pragma mark - Clean up

- (void)destroyChats {
    
    [self.chatsManager destroy];
}

#pragma mark -


@end
