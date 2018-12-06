/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENChat+Private.h"
#import "CENStructures.h"
#import "CENErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENChatEngine (PubNubProtected) <PNObjectEventListener>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENChatEngine (PubNub)


#pragma mark - Information

- (NSString *)pubNubUUID {
    
    return self.pubNubConfiguration.uuid;
}

- (NSString *)pubNubAuthKey {
    
    return self.pubNubConfiguration.authKey;
}


#pragma mark - Configuration

- (void)setupPubNubForUserWithUUID:(NSString *)uuid authorizationKey:(NSString *)authorizationKey {
    
    if (![authorizationKey isKindOfClass:[NSString class]] || !authorizationKey.length) {
        authorizationKey = nil;
    }
    
    self.pubNubConfiguration.uuid = uuid;
    self.pubNubConfiguration.authKey = authorizationKey ?: [[NSUUID UUID] UUIDString];
    
    self.pubnub = [PubNub clientWithConfiguration:self.pubNubConfiguration
                                    callbackQueue:self.pubNubCallbackQueue];
}

- (void)changePubNubAuthorizationKey:(NSString *)authorizationKey
                      withCompletion:(dispatch_block_t)block {
    
    PNConfiguration *configuration = [self.pubNubConfiguration copy];
    configuration.authKey = authorizationKey ?: [[NSUUID UUID] UUIDString];
    
    [self.pubnub copyWithConfiguration:configuration completion:^(PubNub *client) {
        self.pubNubConfiguration = [configuration copy];
        self.pubnub = client;
        
        block();
    }];
}


#pragma mark - Connection

- (void)connectToPubNubWithCompletion:(dispatch_block_t)completion {
    
    NSString *uuid = self.pubnub.currentConfiguration.uuid;
    NSArray<NSString *> *channelGroups = @[
        [@[self.configuration.namespace, uuid, @"rooms"] componentsJoinedByString:@"#"],
        [@[self.configuration.namespace, uuid, @"system"] componentsJoinedByString:@"#"],
        [@[self.configuration.namespace, uuid, @"custom"] componentsJoinedByString:@"#"]
    ];
    
    [self.pubnub removeListener:self];
    [self.pubnub addListener:self];
    
    self.pubNubSubscribeCompletion = completion;
    [self.pubnub subscribeToChannelGroups:channelGroups withPresence:YES];
}

- (void)disconnectFromPubNub {

    [self.pubnub unsubscribeFromAll];
}


#pragma mark - History

- (void)searchMessagesIn:(NSString *)channel
               withStart:(NSNumber *)date
                   limit:(NSUInteger)limit
              completion:(PNHistoryCompletionBlock)block {
    
    if (![channel isKindOfClass:[NSString class]] || !channel.length) {
        return;
    }
    
    [self.pubnub historyForChannel:channel
                             start:date
                               end:nil
                             limit:limit
                           reverse:NO
                  includeTimeToken:YES
                    withCompletion:block];
}


#pragma mark - State

- (void)fetchParticipantsForChannel:(NSString *)channel completion:(PNHereNowCompletionBlock)block {
    
    if (![channel isKindOfClass:[NSString class]] || !channel.length) {
        return;
    }
    
    [self.pubnub hereNowForChannel:channel withVerbosity:PNHereNowState completion:block];
}

- (void)setClientState:(NSDictionary *)state
            forChannel:(NSString *)channel
        withCompletion:(PNSetStateCompletionBlock)block {
    
    if (![state isKindOfClass:[NSDictionary class]] ||
        ![channel isKindOfClass:[NSString class]] || !channel.length) {
        
        return;
    }
    
    [self.pubnub setState:state forUUID:[self pubNubUUID] onChannel:channel withCompletion:block];
}


#pragma mark - Publishing

- (void)publishStorable:(BOOL)shouldStoreInHistory
                   data:(NSDictionary *)data
              toChannel:(NSString *)channel
         withCompletion:(PNPublishCompletionBlock)block {
    
    if (![data isKindOfClass:[NSDictionary class]] || !data.count ||
        ![channel isKindOfClass:[NSString class]] || !channel.length) {
        
        return;
    }
    
    [self.pubnub publish:data
               toChannel:channel
          storeInHistory:shouldStoreInHistory
          withCompletion:block];
}


#pragma mark - Stream controller

- (void)channelsForGroup:(NSString *)group
          withCompletion:(void(^)(NSArray<NSString *> *chats, PNErrorStatus *status))block {
    
    [self.pubnub channelsForGroup:group
                   withCompletion:^(PNChannelGroupChannelsResult * result, PNErrorStatus * status) {
                       
        block(result.data.channels, status);
    }];
}


#pragma mark - Handlers

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    BOOL shouldHandleStatusChange = YES;
    if (status.operation == PNUnsubscribeOperation) {
        shouldHandleStatusChange = ![client channelGroups].count;
    } else {
        BOOL isConnectedCategory = (status.category == PNConnectedCategory ||
                                    status.category == PNReconnectedCategory);

        if (status.operation == PNSubscribeOperation && isConnectedCategory) {
            shouldHandleStatusChange = !self.connectedToPubNub;
            self.connectedToPubNub = YES;
        }
    }
    
    if (status.category == PNUnexpectedDisconnectCategory ||
        status.category == PNNetworkIssuesCategory ||
        status.category == PNAccessDeniedCategory ||
        status.category == PNTLSUntrustedCertificateCategory ||
        status.category == PNBadRequestCategory) {
        
        self.connectedToPubNub = NO;
    }
    
    if (self.pubNubSubscribeCompletion) {
        self.pubNubSubscribeCompletion();
        
        self.pubNubSubscribeCompletion = nil;
    }
    
    NSString *category = [self connectionCategories][@(status.category)];
    if (shouldHandleStatusChange && category) {
        [self emitEventLocally:[@[@"$", @"network", category] componentsJoinedByString:@"."],
                               status, nil];
    }
}

- (void)client:(PubNub *)__unused client didReceiveMessage:(PNMessageResult *)message {
    
    BOOL isPrivate = [CENChat isPrivate:message.data.channel];
    CENChat *chat = [self.chatsManager chatWithName:message.data.channel private:isPrivate];
    NSMutableDictionary *messageWithTimetoken = [message.data.message mutableCopy];
    messageWithTimetoken[CENEventData.timetoken] = message.data.timetoken;
    
    [self.chatsManager handleChat:chat message:messageWithTimetoken];
}

- (void)client:(PubNub *)__unused client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    BOOL isPrivate = [CENChat isPrivate:event.data.channel];
    CENChat *chat = [self.chatsManager chatWithName:event.data.channel private:isPrivate];
    
    if (![chat.group isEqualToString:CENChatGroup.system]) {
        [self.chatsManager handleChat:chat presenceEvent:event.data];
    }
}


#pragma mark - Clean up

- (void)destroyPubNub {
    
    [self.pubnub removeListener:self];
    [self disconnectFromPubNub];
}


#pragma mark - Misc

- (NSDictionary *)connectionCategories {
    
    static NSDictionary *categories;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        categories = @{
            @(PNUnexpectedDisconnectCategory): @"down.offline",
            @(PNDecryptionErrorCategory): @"down.decryption",
            @(PNNetworkIssuesCategory): @"down.issue",
            @(PNAccessDeniedCategory): @"down.denied",
            @(PNDisconnectedCategory): @"down.disconnected",
            @(PNTLSUntrustedCertificateCategory): @"down.tlsuntrusted",
            @(PNBadRequestCategory): @"down.badrequest",
            @(PNConnectedCategory): @"up.connected",
            @(PNReconnectedCategory): @"up.reconnected"
        };
    });
    
    return categories;
}

#pragma mark -


@end
