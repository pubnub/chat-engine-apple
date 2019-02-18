/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENConfiguration+Private.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <PubNub/PNResult+Private.h>
#import <PubNub/PNStatus+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatEnginePubNubTest : CENTestCase


#pragma mark - Information

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

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {

    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];


    [self completeChatEngineConfiguration:self.client];
    self.defaultAuthKey = @"secret-key";

    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handleBlock(nil);
    });
    OCMStub([self.client me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.client]);

    if ([self.name rangeOfString:@"testSetupPubNubForUserWithUUID"].location == NSNotFound) {
        [self.client setupPubNubForUserWithUUID:self.client.me.uuid authorizationKey:self.defaultAuthKey];
    }
}


#pragma mark - Tests :: setupPubNubForUserWithUUID

- (void)testSetupPubNubForUserWithUUID_ShouldCreateAndConfigurePubNubClientWithRandomAuthKey_WhenNonNSStringAuthKeyPassed {
    
    NSString *expectedAuthKey = (id)@2010;
    
    
    [self.client setupPubNubForUserWithUUID:self.client.me.uuid authorizationKey:expectedAuthKey];
    
    XCTAssertNotNil(self.client.pubnub);
    XCTAssertEqualObjects(self.client.pubnub.currentConfiguration.uuid, self.client.me.uuid);
    XCTAssertNotNil(self.client.pubnub.currentConfiguration.authKey);
    XCTAssertNotEqualObjects(self.client.pubnub.currentConfiguration.authKey, expectedAuthKey);
    XCTAssertGreaterThan(self.client.pubnub.currentConfiguration.authKey.length, 0);
}

- (void)testSetupPubNubForUserWithUUID_ShouldCreateAndConfigurePubNubClientWithRandomAuthKey_WhenEmptyAuthKeyPassed {
    
    NSString *expectedAuthKey = @"";
    
    
    [self.client setupPubNubForUserWithUUID:self.client.me.uuid authorizationKey:expectedAuthKey];
    
    XCTAssertNotNil(self.client.pubnub);
    XCTAssertEqualObjects(self.client.pubnub.currentConfiguration.uuid, self.client.me.uuid);
    XCTAssertNotNil(self.client.pubnub.currentConfiguration.authKey);
    XCTAssertGreaterThan(self.client.pubnub.currentConfiguration.authKey.length, 0);
}

- (void)testSetupPubNubForUserWithUUID_ShouldCreateAndConfigurePubNubClientWithCustomAuthKey {
    
    [self.client setupPubNubForUserWithUUID:self.client.me.uuid authorizationKey:self.defaultAuthKey];
    
    XCTAssertNotNil(self.client.pubnub);
    XCTAssertEqualObjects(self.client.pubnub.currentConfiguration.uuid, self.client.me.uuid);
    XCTAssertEqualObjects(self.client.pubnub.currentConfiguration.authKey, self.defaultAuthKey);
}


#pragma mark - Tests :: changePubNubAuthorizationKey

- (void)testChangePubNubAuthorizationKey_ShouldModifyPubNubInstanceConfiguration {
    
    PubNub *existingPubNubClient = self.client.pubnub;
    NSString *expectedAuthKey = @"new-secret-key";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client changePubNubAuthorizationKey:expectedAuthKey withCompletion:^{
            XCTAssertNotNil(self.client.pubnub);
            XCTAssertNotEqual(self.client.pubnub, existingPubNubClient);
            XCTAssertNotEqualObjects(self.client.pubnub.currentConfiguration.authKey,
                                     existingPubNubClient.currentConfiguration.authKey);
            XCTAssertEqualObjects(self.client.pubnub.currentConfiguration.authKey, expectedAuthKey);
            handler();
        }];
    }];
}


#pragma mark - Tests :: connectToPubNub

- (void)testConnectToPubNub_ShouldSubscribeOnRequiredSetOfGroups {
    
    NSString *namespace = self.client.currentConfiguration.globalChannel;
    NSString *uuid = self.client.pubnub.currentConfiguration.uuid;
    NSArray<NSString *> *expectedGroups = @[
        [@[namespace, uuid, @"system"] componentsJoinedByString:@"#"],
        [@[namespace, uuid, @"custom"] componentsJoinedByString:@"#"]
    ];
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    OCMExpect([pubnubMock removeListener:[OCMArg any]]);
    OCMExpect([pubnubMock addListener:[OCMArg any]]);
    OCMExpect([pubnubMock subscribeToChannelGroups:expectedGroups withPresence:YES]);
    
    [self.client connectToPubNubWithCompletion:^{ }];
    
    OCMVerifyAll(pubnubMock);
}


#pragma mark - Tests :: disconnectFromPubNub

- (void)testDisconnectFromPubNub_ShouldStopListeningForRealTimeUpdates {
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock unsubscribeFromAll]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.client disconnectFromPubNub];
    }];
}


#pragma mark - Tests :: searchMessagesIn

- (void)testSearchMessagesIn_ShouldRequestHistoryUsingPubNubClient {
    
    NSString *expectedChat = self.client.me.direct.channel;
    NSNumber *expectedStart = @12345678900;
    NSUInteger expectedLimit = 26;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock historyForChannel:expectedChat start:expectedStart end:nil limit:expectedLimit reverse:NO
                                         includeTimeToken:YES withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.client searchMessagesIn:expectedChat withStart:expectedStart limit:expectedLimit
                           completion:^(PNHistoryResult *result, PNErrorStatus *status) {}];
    }];
}

- (void)testSearchMessagesIn_ShouldNotRequestHistoryUsingPubNubClient_WhenNonNSStringChatPassed {
    
    NSNumber *expectedStart = @12345678900;
    NSString *expectedChat = (id)@2010;
    NSUInteger expectedLimit = 26;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] historyForChannel:[OCMArg any] start:[OCMArg any] end:nil limit:expectedLimit
                                                           reverse:NO includeTimeToken:YES withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client searchMessagesIn:expectedChat withStart:expectedStart limit:expectedLimit
                           completion:^(PNHistoryResult *result, PNErrorStatus *status) {}];
    }];
}

- (void)testSearchMessagesIn_ShouldNotRequestHistoryUsingPubNubClient_WhenNEmptyChatPassed {
    
    NSNumber *expectedStart = @12345678900;
    NSUInteger expectedLimit = 26;
    NSString *expectedChat = @"";
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] historyForChannel:[OCMArg any] start:[OCMArg any] end:nil limit:expectedLimit
                                                           reverse:NO includeTimeToken:YES withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client searchMessagesIn:expectedChat withStart:expectedStart limit:expectedLimit
                           completion:^(PNHistoryResult *result, PNErrorStatus *status) {}];
    }];
}


#pragma mark - Tests :: fetchParticipantsForChannel

- (void)testFetchParticipantsForChannel_ShouldRequestListOfChatParticipantsUsingPubNubClient {
    
    NSString *expectedChat = self.client.me.direct.channel;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock hereNowForChannel:expectedChat withVerbosity:PNHereNowState completion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.client fetchParticipantsForChannel:expectedChat
                                      completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    }];
}

- (void)testFetchParticipantsForChannel_ShouldNotRequestListOfChatParticipantsUsingPubNubClient_WhenNonNSStringChatPassed {
    
    NSString *expectedChat = (id)@2010;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] hereNowForChannel:[OCMArg any] withVerbosity:PNHereNowState
                                                        completion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client fetchParticipantsForChannel:expectedChat
                                      completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    }];
}

- (void)testFetchParticipantsForChannel_ShouldNotRequestListOfChatParticipantsUsingPubNubClient_WhenEmptyChatPassed {
    
    NSString *expectedChat = @"";
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] hereNowForChannel:[OCMArg any] withVerbosity:PNHereNowState
                                                        completion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client fetchParticipantsForChannel:expectedChat
                                      completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) { }];
    }];
}


#pragma mark - Tests :: setClientState

- (void)testSetClientState_ShouldRequestChatStateUpdateUsingPubNubClient {
    
    NSDictionary *expectedState = @{ @"updated": @[@"chat", @"state"] };
    NSString *expectedChat = self.client.me.direct.channel;
    NSString *expectedUUID = [self.client pubNubUUID];
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock setState:expectedState forUUID:expectedUUID onChannel:expectedChat
                                  withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.client setClientState:expectedState forChannel:expectedChat
                     withCompletion:^(PNClientStateUpdateStatus *status) { }];
    }];
}

- (void)testSetClientState_ShouldNotRequestChatStateUpdateUsingPubNubClient_WhenNonNSDictionaryStatePassed {
    
    NSString *expectedChat = self.client.me.direct.channel;
    NSDictionary *expectedState = (id)@2010;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] setState:[OCMArg any] forUUID:[OCMArg any] onChannel:[OCMArg any]
                                           withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client setClientState:expectedState forChannel:expectedChat
                     withCompletion:^(PNClientStateUpdateStatus *status) { }];
    }];
}

- (void)testSetClientState_ShouldNotRequestChatStateUpdateUsingPubNubClient_WhenNonNSStringChatPassed {
    
    NSDictionary *expectedState = @{ @"updated": @[@"chat", @"state"] };
    NSString *expectedChat = (id)@2010;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] setState:[OCMArg any] forUUID:[OCMArg any] onChannel:[OCMArg any]
                                           withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client setClientState:expectedState forChannel:expectedChat
                     withCompletion:^(PNClientStateUpdateStatus *status) { }];
    }];
}

- (void)testSetClientState_ShouldNotRequestChatStateUpdateUsingPubNubClient_WhenEmptyChatPassed {
    
    NSDictionary *expectedState = @{ @"updated": @[@"chat", @"state"] };
    NSString *expectedChat = @"";
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] setState:[OCMArg any] forUUID:[OCMArg any] onChannel:[OCMArg any]
                                           withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client setClientState:expectedState forChannel:expectedChat
                     withCompletion:^(PNClientStateUpdateStatus *status) { }];
    }];
}


#pragma mark - Tests :: publishStorable

- (void)testPublishStorable_ShouldRequestDataPublishUsingPubNubClient {
    
    NSDictionary *expectedData = @{ @"data": @[@"for", @"publish"] };
    NSString *expectedChat = self.client.me.direct.channel;
    BOOL expectedStoreInHistory = YES;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock publish:[OCMArg any] toChannel:[OCMArg any]
                                 storeInHistory:expectedStoreInHistory withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.client publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                      withCompletion:^(PNPublishStatus *status) { }];
    }];
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenNonNSDictionaryDataPassed {
    
    NSString *expectedChat = self.client.me.direct.channel;
    NSDictionary *expectedData = (id)@2010;
    BOOL expectedStoreInHistory = YES;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] publish:[OCMArg any] toChannel:[OCMArg any]
                                          storeInHistory:expectedStoreInHistory withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                      withCompletion:^(PNPublishStatus *status) { }];
    }];
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenEmptyDataPassed {
    
    NSString *expectedChat = self.client.me.direct.channel;
    BOOL expectedStoreInHistory = YES;
    NSDictionary *expectedData = @{};
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] publish:[OCMArg any] toChannel:[OCMArg any]
                                          storeInHistory:expectedStoreInHistory withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                      withCompletion:^(PNPublishStatus *status) { }];
    }];
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenNonNSStringChatPassed {
    
    NSDictionary *expectedData = @{ @"data": @[@"for", @"publish"] };
    NSString *expectedChat = (id)@2010;
    BOOL expectedStoreInHistory = YES;
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] publish:[OCMArg any] toChannel:[OCMArg any]
                                          storeInHistory:expectedStoreInHistory withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                      withCompletion:^(PNPublishStatus *status) { }];
    }];
}

- (void)testPublishStorable_ShouldNotRequestDataPublishUsingPubNubClient_WhenEmptyChatPassed {
    
    NSDictionary *expectedData = @{ @"data": @[@"for", @"publish"] };
    BOOL expectedStoreInHistory = YES;
    NSString *expectedChat = @"";
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] publish:[OCMArg any] toChannel:[OCMArg any]
                                          storeInHistory:expectedStoreInHistory withCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client publishStorable:expectedStoreInHistory data:expectedData toChannel:expectedChat
                      withCompletion:^(PNPublishStatus *status) { }];
    }];
}


#pragma mark - Tests :: channelsForGroup

- (void)testChannelsForGroup_ShouldRequestGroupChatsListUsingPubNubClient {
    
    NSString *expectedGroup = @"chats-group";
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    OCMExpect([pubnubMock channelsForGroup:expectedGroup withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        void(^handlerBlock)(PNChannelGroupChannelsResult *, PNErrorStatus *) = [self objectForInvocation:invocation
                                                                                         argumentAtIndex:2];
        handlerBlock(nil, nil);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client channelsForGroup:expectedGroup withCompletion:^(NSArray<NSString *> *chats, PNErrorStatus *errorStatus) {
            handler();
        }];
    }];
}


#pragma mark - Tests :: clientDidReceiveStatus

- (void)testClientDidReceiveStatus_ShouldCallSubscribeCompletionBlock {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNUnexpectedDisconnectCategory];
    __block BOOL handlerCalled = NO;
    self.client.pubNubSubscribeCompletion = ^{
        handlerCalled = YES;
    };
    
    
    [self object:self.client shouldHandleEvent:@"$.network.down.offline"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
         return ^(CENEmittedEvent *emittedEvent) {
             XCTAssertTrue(handlerCalled);
             XCTAssertNil(self.client.pubNubSubscribeCompletion);
             handler();
         };
     } afterBlock:^{
         [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
     }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnUnexpectedDisconnect {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNUnexpectedDisconnectCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.down.offline"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnNetworkIssue {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNNetworkIssuesCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.down.issue"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnAccessDenied {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNAccessDeniedCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.down.denied"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnTLSUntrusted {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation
                                                         category:PNTLSUntrustedCertificateCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.down.tlsuntrusted"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnBadRequest {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNBadRequestCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.down.badrequest"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnConnection {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNConnectedCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.up.connected"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertTrue(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnReconnection {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNReconnectedCategory];
    
    
    [self object:self.client shouldHandleEvent:@"$.network.up.reconnected"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertTrue(self.client.connectedToPubNub);
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnConnection_WhenConnectedStateIsSetToYes {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNConnectedCategory];
    
    
    OCMStub([self.client connectedToPubNub]).andReturn(YES);
    
    [self waitTask:@"waitObjectsCreateEVents" completionFor:self.delayedCheck];
    
    id recorded = OCMExpect([[(id)self.client reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
    
    OCMStub([self.client chatsManager]).andReturn(nil);
}

- (void)testClientDidReceiveStatus_ShouldEmitEventOnDisconnection_WhenPubNubClientNotSubscribedToAnyObjects {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNUnsubscribeOperation category:PNDisconnectedCategory];
    

    [self object:self.client shouldHandleEvent:@"$.network.down.disconnected"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnDisconnection_WhenPubNubClientSubscribedToChannelGroups {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNUnsubscribeOperation category:PNDisconnectedCategory];
    
    NSArray<NSString *> *expectedObjects = @[@"Group1", @"Group2", @"Group3"];
    
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    OCMStub([pubnubMock channelGroups]).andReturn(expectedObjects);
    
    [self waitTask:@"waitObjectsCreateEVents" completionFor:self.delayedCheck];
    
    id recorded = OCMExpect([[(id)self.client reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
    
    OCMStub([self.client chatsManager]).andReturn(nil);
}

- (void)testClientDidReceiveStatus_ShouldNotEmitEventOnBadRequest_WhenUnsupportedStatusPassed {
    
    PNSubscribeStatus *expectedStatus = [self statusWithOperation:PNSubscribeOperation category:PNTimeoutCategory];
    
    
    [self waitTask:@"waitObjectsCreateEVents" completionFor:self.delayedCheck];
    
    id recorded = OCMExpect([[(id)self.client reject] emitEventLocally:[OCMArg any] withParameters:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveStatus:expectedStatus];
    }];
    
    OCMStub([self.client chatsManager]).andReturn(nil);
}


#pragma mark - Tests :: clientDidReceiveMessage

- (void)testClientDidReceiveMessage_ShouldForwardToTargetChat {

    NSString *eventID = [NSUUID UUID].UUIDString;
    CENChat *expectedChat = self.client.me.direct;
    NSDictionary *receivedData = @{ @"received": @"data", @"eid": eventID };
    NSDictionary *expectedData = @{ @"received": @"data", @"eid": eventID, @"timetoken": @123456 };
    PNMessageResult *result = [self messageResultForChat:expectedChat withData:receivedData];


    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock handleChat:expectedChat message:expectedData]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveMessage:result];
    }];
}

- (void)testClientDidReceiveMessage_ShouldAddEventIDFromTimetoken {

    CENChat *expectedChat = self.client.me.direct;
    NSDictionary *receivedData = @{ @"received": @"data" };
    NSDictionary *expectedData = @{ @"received": @"data", @"eid": @"123456", @"timetoken": @123456 };
    PNMessageResult *result = [self messageResultForChat:expectedChat withData:receivedData];


    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock handleChat:expectedChat message:expectedData]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceiveMessage:result];
    }];
}


#pragma mark - Tests :: clientDidReceivePresenceEvent

- (void)testClientDidReceivePresenceEvent_ShouldForwardToTargetChat {
    
    CENChat *expectedChat = [self privateChatWithChatEngine:self.client];
    PNPresenceEventResult *result = [self presenceResultForChat:expectedChat];
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock handleChat:expectedChat presenceEvent:result.data]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceivePresenceEvent:result];
    }];
}

- (void)testClientDidReceivePresenceEvent_ShouldNotForwardToTargetChat_WhenCalledOnSystemChat {
    
    CENChat *expectedChat = self.client.me.direct;
    PNPresenceEventResult *result = [self presenceResultForChat:expectedChat];
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([[managerMock reject] handleChat:expectedChat presenceEvent:result.data]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [(id<PNObjectEventListener>)self.client client:self.client.pubnub didReceivePresenceEvent:result];
    }];
}


#pragma mark - Tests :: destroyPubNub

- (void)testDestroyPubNub_ShouldStopRealTimeUpdatesListening {
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    OCMExpect([pubnubMock removeListener:[OCMArg any]]);
    OCMExpect([self.client disconnectFromPubNub]);
    
    [self.client destroyPubNub];
    
    OCMVerifyAll(pubnubMock);
    OCMVerifyAll((id)self.client);
}


#pragma mark - Tests :: pubNubUUID

- (void)testPubNubUUID_ShouldReturnUUIDUsedForConfiguration {
    
    XCTAssertNotNil([self.client pubNubUUID]);
    XCTAssertEqualObjects([self.client pubNubUUID], self.client.me.uuid);
}


#pragma mark - Tests :: pubNubAuthKey

- (void)testPubNubAuthKey_ShouldReturnUUIDUsedForConfiguration {
    
    XCTAssertNotNil([self.client pubNubAuthKey]);
    XCTAssertEqualObjects([self.client pubNubAuthKey], self.defaultAuthKey);
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
                                           @"presence": @{ @"timetoken": @123456, @"uuid": @"PubNub" }
                                       }
                                     processingError:nil];
}

#pragma mark -


@end
