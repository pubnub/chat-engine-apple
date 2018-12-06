/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineConnectionTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineConnectionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"GlobalChatEngabled"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
}


#pragma mark - Tests :: connect / connectUser

- (void)testConnectUser_ShouldForwardToNewImplementation {
    
    NSString *expectedUUID = @"PubNub";
    
    
    id recorded = OCMExpect([self.client connectUser:expectedUUID withAuthKey:nil globalChannel:nil]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.client connectUser:expectedUUID];
#pragma clang diagnostic pop
    }];
}

- (void)testConnectUserWithState_ShouldForwardToNewImplementation {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    id recorded = OCMExpect([self.client connectUser:expectedUUID withAuthKey:expectedAuthKey globalChannel:nil]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.client connectUser:expectedUUID withState:@{ @"test": @"state" } authKey:expectedAuthKey];
#pragma clang diagnostic pop
    }];
}

- (void)testConnectUser_ShouldAuthorize_WhenNSStringAuthKeyPassed {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    id recorded = OCMExpect([self.client authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey
                                                         completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldAuthorize_WhenNSNumberAuthKeyPassed {
    
    NSNumber *expectedAuthKey = @2010;
    NSString *expectedUUID = @"PubNub";
    
    
    id recorded = OCMExpect([self.client authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey.stringValue
                                                         completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldThrow_WhenUnsupportedAuthKeyPassed {
    
    NSString *expectedAuthKey = (id)[NSArray new];
    NSString *expectedUUID = @"PubNub";
    
    
    XCTAssertThrowsSpecificNamed([self.client connectUser:expectedUUID withAuthKey:expectedAuthKey globalChannel:nil],
                                 NSException, kCENErrorDomain);
}

- (void)testConnectUser_ShouldConfigurePubNubClient {
    
    NSString *expectedUUID = @"PubNub";
    
    
    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]]).andDo(nil);
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client setupPubNubForUserWithUUID:expectedUUID authorizationKey:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectUser:expectedUUID withAuthKey:nil globalChannel:nil];
    }];
}

- (void)testConnectUser_ShouldReconnect_WhenPubNubInstanceExists {
    
    NSString *expectedAuthKey = (id)[NSArray new];
    NSString *expectedUUID = @"PubNub";
    
    
    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id recorded = OCMExpect([[(id)self.client reject] authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any]
                                                                      completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldConnectToGlobalChatFirst_WhenGlobalChatEngabled {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client createGlobalChatWithChannel:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldCreateLocalUser_WhenGlobalChatEngabledAndConnected {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client createUserWithUUID:[OCMArg any] state:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldNotConnectToGlobalChat_WhenGlobalChatDisabled {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]]).andDo(nil);
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([[(id)self.client reject] createGlobalChatWithChannel:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldCreateLocalUserWithEmptyState_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = [NSUUID UUID].UUIDString;
    
    
    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]]).andDo(nil);
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client createUserWithUUID:expectedUUID state:@{}]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldConnectToPubNub_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client connectToPubNubWithCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldListenSynchronizationEevents_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client listenSynchronizationEvents]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldSynchronizeSession_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client synchronizeSession]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}

- (void)testConnectUser_ShouldEmitReadyEvent_WhenAuthorizationCompleted {
    
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    
    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    [self stubChatConnection];
    
    id recorded = OCMExpect([self.client emitEventLocally:@"$.ready" withParameters:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.connect(expectedUUID).authKey(expectedAuthKey).perform();
    }];
}


#pragma mark - Tests :: reconnect / reconnectUser

- (void)testReconnectUser_ShouldReAuthorizeLocalUser {
    
    id recorded = OCMExpect([self.client authorizeLocalUserWithCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.reconnect();
    }];
}

- (void)testReconnectUser_ShouldReConnectChatsAndPubNub {
    
    [self stubUserAuthorization];
    
    OCMExpect([self.client connectChats]);
    OCMExpect([self.client connectToPubNubWithCompletion:[OCMArg any]]);
    
    self.client.reconnect();
    
    OCMVerifyAll((id)self.client);
}

- (void)testReconnectUser_ShouldReSynchronizeSession {
    
    [self stubUserAuthorization];
    [self stubPubNubSubscribe];
    
    id recorded = OCMExpect([self.client synchronizeSession]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.reconnect();
    }];
}


#pragma mark - Tests :: disconnect / disconnectUser

- (void)testDisconnectUser_ShouldDisconnectChatsAndPubNub {
    
    OCMExpect([self.client disconnectFromPubNub]);
    OCMExpect([self.client disconnectChats]);
    
    self.client.disconnect();
    
    OCMVerifyAll((id)self.client);
}

#pragma mark -


@end
