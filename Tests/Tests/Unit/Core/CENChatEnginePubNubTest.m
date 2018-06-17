/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENConfiguration+Private.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatsManager.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <PubNub/PNResult+Private.h>
#import <PubNub/PNStatus+Private.h>
#import "CENTestCase.h"


@interface CENChatEnginePubNubTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine<PNObjectEventListener> *defaultClient;
@property (nonatomic, nullable, strong) NSString *defaultAuthKey;


#pragma mark - Misc

- (PNSubscribeStatus *)statusWithOperation:(PNOperationType)operation category:(PNStatusCategory)category;
- (PNMessageResult *)messageResultForChat:(CENChat *)chat withData:(NSDictionary *)data;
- (PNPresenceEventResult *)presenceResultForChat:(CENChat *)chat;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEnginePubNubTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.defaultAuthKey = @"secret-key";
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
    .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
    .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    if ([self.name rangeOfString:@"testSetupPubNubForUserWithUUID"].location == NSNotFound) {
        [self.defaultClient setupPubNubForUserWithUUID:self.defaultClient.me.uuid authorizationKey:self.defaultAuthKey];
    }
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: setupPubNubForUserWithUUID

- (void)testSetupPubNubForUserWithUUID_ShouldCreateAndConfigurePubNubClientWithRandomAuthKey_WhenNonNSStringAuthKeyPassed {
    
    NSString *expectedAuthKey = (id)@2010;
    
    [self.defaultClient setupPubNubForUserWithUUID:self.defaultClient.me.uuid authorizationKey:expectedAuthKey];
    
    XCTAssertNotNil(self.defaultClient.pubnub);
    XCTAssertEqualObjects(self.defaultClient.pubnub.currentConfiguration.uuid, self.defaultClient.me.uuid);
    XCTAssertNotNil(self.defaultClient.pubnub.currentConfiguration.authKey);
    XCTAssertNotEqualObjects(self.defaultClient.pubnub.currentConfiguration.authKey, expectedAuthKey);
    XCTAssertGreaterThan(self.defaultClient.pubnub.currentConfiguration.authKey.length, 0);
}

- (void)testSetupPubNubForUserWithUUID_ShouldCreateAndConfigurePubNubClientWithRandomAuthKey_WhenEmptyAuthKeyPassed {
    
    NSString *expectedAuthKey = nil;
    
    [self.defaultClient setupPubNubForUserWithUUID:self.defaultClient.me.uuid authorizationKey:expectedAuthKey];
    
    XCTAssertNotNil(self.defaultClient.pubnub);
    XCTAssertEqualObjects(self.defaultClient.pubnub.currentConfiguration.uuid, self.defaultClient.me.uuid);
    XCTAssertNotNil(self.defaultClient.pubnub.currentConfiguration.authKey);
    XCTAssertGreaterThan(self.defaultClient.pubnub.currentConfiguration.authKey.length, 0);
}

- (void)testSetupPubNubForUserWithUUID_ShouldCreateAndConfigurePubNubClientWithCustomAuthKey {
    
    [self.defaultClient setupPubNubForUserWithUUID:self.defaultClient.me.uuid authorizationKey:self.defaultAuthKey];
    
    XCTAssertNotNil(self.defaultClient.pubnub);
    XCTAssertEqualObjects(self.defaultClient.pubnub.currentConfiguration.uuid, self.defaultClient.me.uuid);
    XCTAssertEqualObjects(self.defaultClient.pubnub.currentConfiguration.authKey, self.defaultAuthKey);
}


#pragma mark - Tests :: changePubNubAuthorizationKey

- (void)testChangePubNubAuthorizationKey_ShouldModifyPubNubInstanCENConfiguration {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    PubNub *existingPubNubClient = self.defaultClient.pubnub;
    NSString *expectedAuthKey = @"new-secret-key";
    __block BOOL handlerCalled = NO;
    
    [self.defaultClient changePubNubAuthorizationKey:expectedAuthKey withCompletion:^{
        handlerCalled = YES;
        
        XCTAssertNotEqual(self.defaultClient.pubnub, existingPubNubClient);
        XCTAssertNotEqualObjects(self.defaultClient.pubnub.currentConfiguration.authKey, existingPubNubClient.currentConfiguration.authKey);
        XCTAssertEqualObjects(self.defaultClient.pubnub.currentConfiguration.authKey, expectedAuthKey);
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: connectToPubNub

- (void)testConnectToPubNub_ShouldSubscribeOnRequiredSetOfGroups {
    
    NSString *globalChat = self.defaultClient.currentConfiguration.globalChannel;
    NSString *uuid = self.defaultClient.pubnub.currentConfiguration.uuid;
    NSArray<NSString *> *expectedGroups = @[
        [@[globalChat, uuid, @"rooms"] componentsJoinedByString:@"#"],
        [@[globalChat, uuid, @"system"] componentsJoinedByString:@"#"],
        [@[globalChat, uuid, @"custom"] componentsJoinedByString:@"#"]
    ];
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    
    OCMExpect([pubNubPartialMock removeListener:[OCMArg any]]);
    OCMExpect([pubNubPartialMock addListener:[OCMArg any]]);
    OCMExpect([pubNubPartialMock subscribeToChannelGroups:expectedGroups withPresence:YES]);
    
    [self.defaultClient connectToPubNub];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: disconnectFromPubNub

- (void)testDisconnectFromPubNub_ShouldStopListeningForRealTimeUpdates {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    
    OCMExpect([pubNubPartialMock unsubscribeFromAll]);
    
    [self.defaultClient disconnectFromPubNub];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: searchMessagesIn

- (void)testSearchMessagesIn_ShouldRequestHistoryUsingPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    NSNumber *expectedStart = @12345678900;
    NSUInteger expectedLimit = 26;
    
    OCMExpect([pubNubPartialMock historyForChannel:expectedChat start:expectedStart end:nil limit:expectedLimit reverse:NO includeTimeToken:YES
                                    withCompletion:[OCMArg any]]);
    
    [self.defaultClient searchMessagesIn:expectedChat withStart:expectedStart limit:expectedLimit
                              completion:^(PNHistoryResult *result, PNErrorStatus *status) {}];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testSearchMessagesIn_ShouldNotRequestHistoryUsingPubNubClient_WhenNonNSStringChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSNumber *expectedStart = @12345678900;
    NSString *expectedChat = (id)@2010;
    NSUInteger expectedLimit = 26;
    
    OCMExpect([[pubNubPartialMock reject] historyForChannel:[OCMArg any] start:[OCMArg any] end:nil limit:expectedLimit reverse:NO
                                           includeTimeToken:YES withCompletion:[OCMArg any]]);
    
    [self.defaultClient searchMessagesIn:expectedChat withStart:expectedStart limit:expectedLimit
                              completion:^(PNHistoryResult *result, PNErrorStatus *status) {}];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testSearchMessagesIn_ShouldNotRequestHistoryUsingPubNubClient_WhenNEmptyChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSNumber *expectedStart = @12345678900;
    NSUInteger expectedLimit = 26;
    NSString *expectedChat = @"";
    
    OCMExpect([[pubNubPartialMock reject] historyForChannel:[OCMArg any] start:[OCMArg any] end:nil limit:expectedLimit reverse:NO
                                           includeTimeToken:YES withCompletion:[OCMArg any]]);
    
    [self.defaultClient searchMessagesIn:expectedChat withStart:expectedStart limit:expectedLimit
                              completion:^(PNHistoryResult *result, PNErrorStatus *status) {}];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: fetchParticipantsForChannel

- (void)testFetchParticipantsForChannel_ShouldRequestListOfChatParticipantsWithStateUsingPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    BOOL expectedStateFetch = YES;
    
    OCMExpect([pubNubPartialMock hereNowForChannel:expectedChat withVerbosity:PNHereNowState completion:[OCMArg any]]);
    
    [self.defaultClient fetchParticipantsForChannel:expectedChat withState:expectedStateFetch
                                         completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testFetchParticipantsForChannel_ShouldRequestListOfChatParticipantsWithOutStateUsingPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    BOOL expectedStateFetch = NO;
    
    OCMExpect([pubNubPartialMock hereNowForChannel:expectedChat withVerbosity:PNHereNowUUID completion:[OCMArg any]]);
    
    [self.defaultClient fetchParticipantsForChannel:expectedChat withState:expectedStateFetch
                                         completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testFetchParticipantsForChannel_ShouldNotRequestListOfChatParticipantsWithStateUsingPubNubClient_WhenNonNSStringChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = (id)@2010;
    BOOL expectedStateFetch = YES;
    
    OCMExpect([[pubNubPartialMock reject] hereNowForChannel:[OCMArg any] withVerbosity:PNHereNowState completion:[OCMArg any]]);
    
    [self.defaultClient fetchParticipantsForChannel:expectedChat withState:expectedStateFetch
                                         completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testFetchParticipantsForChannel_ShouldNotRequestListOfChatParticipantsWithStateUsingPubNubClient_WhenEmptyChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    BOOL expectedStateFetch = YES;
    NSString *expectedChat = @"";
    
    OCMExpect([[pubNubPartialMock reject] hereNowForChannel:[OCMArg any] withVerbosity:PNHereNowState completion:[OCMArg any]]);
    
    [self.defaultClient fetchParticipantsForChannel:expectedChat withState:expectedStateFetch
                                         completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: setClientState

- (void)testSetClientState_ShouldRequestChatStateUpdateUsingPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSDictionary *expectedState = @{ @"updated": @[@"chat", @"state"] };
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    NSString *expectedUUID = [self.defaultClient pubNubUUID];

    OCMExpect([pubNubPartialMock setState:expectedState forUUID:expectedUUID onChannel:expectedChat withCompletion:[OCMArg any]]);
    
    [self.defaultClient setClientState:expectedState forChannel:expectedChat withCompletion:^(PNClientStateUpdateStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testSetClientState_ShouldNotRequestChatStateUpdateUsingPubNubClient_WhenNonNSDictionaryStatePassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    NSDictionary *expectedState = (id)@2010;
    
    OCMExpect([[pubNubPartialMock reject] setState:[OCMArg any] forUUID:[OCMArg any] onChannel:[OCMArg any] withCompletion:[OCMArg any]]);
    
    [self.defaultClient setClientState:expectedState forChannel:expectedChat withCompletion:^(PNClientStateUpdateStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testSetClientState_ShouldNotRequestChatStateUpdateUsingPubNubClient_WhenNonNSStringChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSDictionary *expectedState = @{ @"updated": @[@"chat", @"state"] };
    NSString *expectedChat = (id)@2010;
    
    OCMExpect([[pubNubPartialMock reject] setState:[OCMArg any] forUUID:[OCMArg any] onChannel:[OCMArg any] withCompletion:[OCMArg any]]);
    
    [self.defaultClient setClientState:expectedState forChannel:expectedChat withCompletion:^(PNClientStateUpdateStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testSetClientState_ShouldNotRequestChatStateUpdateUsingPubNubClient_WhenEmptyChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSDictionary *expectedState = @{ @"updated": @[@"chat", @"state"] };
    NSString *expectedChat = @"";
    
    OCMExpect([[pubNubPartialMock reject] setState:[OCMArg any] forUUID:[OCMArg any] onChannel:[OCMArg any] withCompletion:[OCMArg any]]);
    
    [self.defaultClient setClientState:expectedState forChannel:expectedChat withCompletion:^(PNClientStateUpdateStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: unsubscribeFromChannels

- (void)testUnsubscribeFromChannels_ShouldRequestUnsubscriptionFromSetOfChatsUsinPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSArray<NSString *> *expectedChats = @[@"Chat1", @"Chat2", @"Chat3"];
    
    OCMExpect([pubNubPartialMock unsubscribeFromChannels:expectedChats withPresence:YES]);
    
    [self.defaultClient unsubscribeFromChannels:expectedChats];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: publishStorable

- (void)testPublishStorable_ShouldRequestDataPublishUsingPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSDictionary *expectedData = @{ @"data": @[@"for", @"publish"] };
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    BOOL expectedStoreInHistory = YES;
    
    OCMExpect([pubNubPartialMock publish:[OCMArg any] toChannel:[OCMArg any] storeInHistory:expectedStoreInHistory withCompletion:[OCMArg any]]);
    
    [self.defaultClient publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                         withCompletion:^(PNPublishStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenNonNSDictionaryDataPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    NSDictionary *expectedData = (id)@2010;
    BOOL expectedStoreInHistory = YES;
    
    OCMExpect([[pubNubPartialMock reject] publish:[OCMArg any] toChannel:[OCMArg any] storeInHistory:expectedStoreInHistory
                                   withCompletion:[OCMArg any]]);
    
    [self.defaultClient publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                         withCompletion:^(PNPublishStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenEmptyDataPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSString *expectedChat = self.defaultClient.me.direct.channel;
    BOOL expectedStoreInHistory = YES;
    NSDictionary *expectedData = @{};
    
    OCMExpect([[pubNubPartialMock reject] publish:[OCMArg any] toChannel:[OCMArg any] storeInHistory:expectedStoreInHistory
                                   withCompletion:[OCMArg any]]);
    
    [self.defaultClient publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                         withCompletion:^(PNPublishStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenNonNSStringChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSDictionary *expectedData = @{ @"data": @[@"for", @"publish"] };
    NSString *expectedChat = (id)@2010;
    BOOL expectedStoreInHistory = YES;
    
    OCMExpect([[pubNubPartialMock reject] publish:[OCMArg any] toChannel:[OCMArg any] storeInHistory:expectedStoreInHistory
                                   withCompletion:[OCMArg any]]);
    
    [self.defaultClient publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                         withCompletion:^(PNPublishStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenEmptyChatPassed {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSDictionary *expectedData = @{ @"data": @[@"for", @"publish"] };
    BOOL expectedStoreInHistory = YES;
    NSString *expectedChat = @"";
    
    OCMExpect([[pubNubPartialMock reject] publish:[OCMArg any] toChannel:[OCMArg any] storeInHistory:expectedStoreInHistory
                                   withCompletion:[OCMArg any]]);
    
    [self.defaultClient publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                         withCompletion:^(PNPublishStatus *status) { }];
    
    OCMVerifyAll(pubNubPartialMock);
}


#pragma mark - Tests :: channelsForGroup

- (void)testChannelsForGroup_ShouldRequestGroupChatsListUsingPubNubClient {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedGroup = @"chats-group";
    __block BOOL handlerCalled = NO;
    
    OCMExpect([pubNubPartialMock channelsForGroup:expectedGroup withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        void(^handlerBlock)(PNChannelGroupChannelsResult *, PNErrorStatus *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(nil, nil);
    });
    
    [self.defaultClient channelsForGroup:expectedGroup withCompletion:^(NSArray<NSString *> *chats, PNErrorStatus *errorStatus) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(pubNubPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: clientDidReceiveStatus

- (void)testClientDidReceiveStatus_ShouldEmitEventOnUnexpectedDisconnect {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNUnexpectedDisconnectCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.down.offline", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnNetworkIssue {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNNetworkIssuesCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.down.issue", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnAccessDenied {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNAccessDeniedCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.down.denied", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnTLSUntrusted {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNTLSUntrustedCertificateCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.down.tlsuntrusted", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnBadRequest {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNBadRequestCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.down.badrequest", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnConnection {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNConnectedCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.up.connected", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnReconnection {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNReconnectedCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.network.up.reconnected", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(self.defaultClient.connectedToPubNub);
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnConnection_WhenConnectedStateIsSetToYes {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNConnectedCategory];
    
    OCMExpect([[(id)self.defaultClient reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    
    OCMStub([self.defaultClient connectedToPubNub]).andReturn(YES);
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnDisconnection_WhenPubNubClientNotSubscribedToAnyObjects {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNUnsubscribeOperation category:PNDisconnectedCategory];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;

    self.defaultClient.once(@"$.network.down.disconnected", ^(id status) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnDisconnection_WhenPubNubClientSubscribedToChannels {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNUnsubscribeOperation category:PNDisconnectedCategory];
    NSArray<NSString *> *expectedObjects = @[@"Channel1", @"Channel2", @"Channel3"];
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    
    OCMStub([pubNubPartialMock channels]).andReturn(expectedObjects);
    
    OCMExpect([[(id)self.defaultClient reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnDisconnection_WhenPubNubClientSubscribedToRresenceChannels {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNUnsubscribeOperation category:PNDisconnectedCategory];
    NSArray<NSString *> *expectedObjects = @[@"Object1-pnpres", @"Object2-pnpres", @"Object3-pnpres"];
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    
    OCMStub([pubNubPartialMock presenceChannels]).andReturn(expectedObjects);
    
    OCMExpect([[(id)self.defaultClient reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnDisconnection_WhenPubNubClientSubscribedToChannelGroups {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNUnsubscribeOperation category:PNDisconnectedCategory];
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    NSArray<NSString *> *expectedObjects = @[@"Group1", @"Group2", @"Group3"];
    
    OCMStub([pubNubPartialMock channelGroups]).andReturn(expectedObjects);
    
    OCMExpect([[(id)self.defaultClient reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnBadRequest_WhenUnsupportedStatusPassed {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNTimeoutCategory];
    
    OCMExpect([[(id)self.defaultClient reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveStatus:expectedStatus];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: clientDidReceiveMessage

- (void)testClientDidReceiveMessage_ShouldForwardToTargetChat {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    CENChat *expectedChat = self.defaultClient.me.direct;
    NSDictionary *receivedData = @{ @"received": @"data" };
    NSDictionary *expectedData = @{ @"received": @"data", @"timetoken": @123456 };
    PNMessageResult *result = [self messageResultForChat:expectedChat withData:receivedData];
    
    OCMExpect([chatsManagerPartialMock handleChat:expectedChat message:expectedData]);
    
    [self.defaultClient client:self.defaultClient.pubnub didReceiveMessage:result];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: clientDidReceivePresenCENEvent

- (void)testClientDidReceivePresenCENEvent_ShouldForwardToTargetChat {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    CENChat *expectedChat = self.defaultClient.me.direct;
    PNPresenceEventResult *result = [self presenceResultForChat:expectedChat];
    
    OCMExpect([chatsManagerPartialMock handleChat:expectedChat presenceEvent:result.data]);
    
    [self.defaultClient client:self.defaultClient.pubnub didReceivePresenceEvent:result];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: destroyPubNub

- (void)testDestroyPubNub_ShouldStopRealTimeUpdatesListening {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    
    OCMExpect([pubNubPartialMock removeListener:[OCMArg any]]);
    OCMExpect([self.defaultClient disconnectFromPubNub]);
    
    [self.defaultClient destroyPubNub];
    
    OCMVerifyAll(pubNubPartialMock);
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: pubNubUUID

- (void)testPubNubUUID_ShouldRetruenUUIDUsedForConfiguration {
    
    XCTAssertNotNil([self.defaultClient pubNubUUID]);
    XCTAssertEqualObjects([self.defaultClient pubNubUUID], self.defaultClient.me.uuid);
}


#pragma mark - Tests :: pubNubAuthKey

- (void)testPubNubAuthKey_ShouldRetruenUUIDUsedForConfiguration {
    
    XCTAssertNotNil([self.defaultClient pubNubAuthKey]);
    XCTAssertEqualObjects([self.defaultClient pubNubAuthKey], self.defaultAuthKey);
}


#pragma mark - Misc

- (PNSubscribeStatus *)statusWithOperation:(PNOperationType)operation category:(PNStatusCategory)category {
    
    return [PNSubscribeStatus statusForOperation:operation category:category withProcessingError:nil];
}

- (PNMessageResult *)messageResultForChat:(CENChat *)chat withData:(NSDictionary *)data {
    
    return [PNMessageResult objectForOperation:PNSubscribeOperation completedWithTask:nil
                                 processedData:@{ @"message": data, @"channel": chat.channel, @"timetoken": @123456 }
                               processingError:nil];
}

- (PNPresenceEventResult *)presenceResultForChat:(CENChat *)chat {
    
    return [PNPresenceEventResult objectForOperation:PNSubscribeOperation completedWithTask:nil
                                       processedData:@{
                                           @"presenceEvent": @"join",
                                           @"channel": chat.channel,
                                           @"presence": @{
                                               @"timetoken": @123456,
                                               @"uuid": @"PubNub"
                                           } }
                                     processingError:nil];
}

#pragma mark -


@end
