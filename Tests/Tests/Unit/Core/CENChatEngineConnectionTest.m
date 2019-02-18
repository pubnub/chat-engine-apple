/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatEngineConnectionTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineConnectionTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {

    return [name rangeOfString:@"ShouldThrow"].location == NSNotFound;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"GlobalChatEnabled"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];


    if ([self hasMockedObjectsInTestCaseWithName:self.name]) {
        [self completeChatEngineConfiguration:self.client];
    }
}


#pragma mark - Tests :: connect / connectUser

- (void)testConnectUser_ShouldCallWithEmptyStateAndRandomAuthKey {
    
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client connectUser:expectedUUID withState:nil authKey:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [self.client connectUser:expectedUUID];
    }];
}

- (void)testConnectUser_ShouldAuthorize_WhenNSStringAuthKeyPassed {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey
                                                         completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldAuthorize_WhenNSNumberAuthKeyPassed {
    
    NSNumber *expectedAuthKey = @2010;
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey.stringValue
                                                         completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldConfigurePubNubClient {
    
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]]).andDo(nil);
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client setupPubNubForUserWithUUID:expectedUUID authorizationKey:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).perform();
    }];
}

- (void)testConnectUser_ShouldReconnect_WhenPubNubInstanceExists {
    
    NSString *expectedAuthKey = (id)[NSArray new];
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id recorded = OCMExpect([[(id)self.client reject] authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any]
                                                                      completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldConnectToGlobalChatFirst {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client createGlobalChatWithChannel:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldCreateLocalUser_WhenGlobalChatConnected {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client createUserWithUUID:expectedUUID state:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
        OCMStub([self.client pubnub]).andReturn(nil);
    }];
}

- (void)testConnectUser_ShouldCreateLocalUserWithEmptyState_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = [NSUUID UUID].UUIDString;


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]]).andDo(nil);
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client createUserWithUUID:expectedUUID state:@{}]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldConnectToPubNub_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client connectToPubNubWithCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldListenSynchronizationEvents_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client listenSynchronizationEvents]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldSynchronizeSession_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client synchronizeSession]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldEmitReadyEvent_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    XCTAssertTrue([self isObjectMocked:self.client]);
    
    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client emitEventLocally:@"$.ready" withParameters:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldUpdateLocalUserState_WhenAuthorizationCompleted {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    XCTAssertTrue([self isObjectMocked:self.client]);
    OCMStub([self.client global]).andReturn(chat);
    
    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id chatMock = [self mockForObject:chat];
    
    id recorded = OCMExpect([(CENChat *)chatMock setState:expectedState]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).state(expectedState).perform();
        chat.connect();
    }];
    
    [chat destruct];
}


#pragma mark - Tests :: reconnect / reconnectUser

- (void)testReconnectUser_ShouldReAuthorizeLocalUser {

    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client authorizeLocalUserWithCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reconnect();
    }];
}

- (void)testReconnectUser_ShouldReConnectChatsAndPubNub {

    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    
    OCMExpect([self.client connectChats]);
    OCMExpect([self.client connectToPubNubWithCompletion:[OCMArg any]]);
    
    self.client.reconnect();
    
    OCMVerifyAll((id)self.client);
}

- (void)testReconnectUser_ShouldReSynchronizeSession {

    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    
    id recorded = OCMExpect([self.client synchronizeSession]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reconnect();
    }];
}


#pragma mark - Tests :: disconnect / disconnectUser

- (void)testDisconnectUser_ShouldDisconnectChatsAndPubNub {

    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMExpect([self.client disconnectFromPubNub]);
    OCMExpect([self.client disconnectChats]);
    
    self.client.disconnect();
    
    OCMVerifyAll((id)self.client);
}

#pragma mark -


@end
