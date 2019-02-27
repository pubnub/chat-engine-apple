/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatEngineAuthorizationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineAuthorizationTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {

    return ([name rangeOfString:@"testAuthorizeLocalUserWithUUID"].location == NSNotFound &&
            [name rangeOfString:@"testHandshakeChatAccess_ShouldEmitError_WhenPubNubClientNotReady"].location == NSNotFound);
}

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"GlobalChatEnabled"].location != NSNotFound;
}

- (BOOL)shouldEnableMetaForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"MetaSynchronizationEnabled"].location != NSNotFound;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (void)setUp {

    [super setUp];


    if ([self hasMockedObjectsInTestCaseWithName:self.name]) {
        [self completeChatEngineConfiguration:self.client];
    }
}


#pragma mark - Tests :: reauthorize / reauthorizeUserWithKey

- (void)testReauthorize_ShouldUseRandomAuthorizationKey_WhenAuthorizationKeyIsNil {

    CENChat *chat = [self publicChatWithChatEngine:self.client];

    
    XCTAssertTrue([self isObjectMocked:self.client]);
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    OCMStub([self.client global]).andReturn(chat);

    id recorded = OCMExpect([self.client changePubNubAuthorizationKey:[OCMArg any] withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(nil);
    }];
}

- (void)testReauthorize_ShouldUseNSNumberAuthorizationKey {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSNumber *authorizationKey = @2010;


    XCTAssertTrue([self isObjectMocked:self.client]);
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    OCMStub([self.client global]).andReturn(chat);

    id recorded = OCMExpect([self.client changePubNubAuthorizationKey:authorizationKey.stringValue withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
    }];
}

- (void)testReauthorize_ShouldDisconnectLocalUser {

    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client changePubNubAuthorizationKey:authorizationKey withCompletion:[OCMArg any]]).andDo(nil);
    
    id recorded = OCMExpect([self.client disconnectUser]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
    }];
}

- (void)testReauthorize_ShouldChangePubNubConfiguration {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    OCMStub([self.client global]).andReturn(chat);

    id recorded = OCMExpect([self.client changePubNubAuthorizationKey:authorizationKey withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
    }];
}

- (void)testReauthorize_ShouldChangePubNubConfiguration_WhenGlobalDisconnect {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    id chatMock = [self mockForObject:chat];
    OCMExpect([chatMock handleEventOnce:@"$.disconnected" withHandlerBlock:[OCMArg any]]).andForwardToRealObject();
    
    OCMStub([self.client global]).andReturn(chat);
    
    id recorded = OCMExpect([self.client changePubNubAuthorizationKey:authorizationKey withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
        [self.client.global emitEventLocally:@"$.disconnected", nil];
    }];
    
    OCMVerifyAll(chatMock);
}

- (void)testReauthorize_ShouldNotChangePubNubConfiguration_WhenGlobalNotDisconnected {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    id chatMock = [self mockForObject:chat];
    OCMExpect([chatMock handleEventOnce:@"$.disconnected" withHandlerBlock:[OCMArg any]]).andForwardToRealObject();
    
    OCMStub([self.client global]).andReturn(chat);
    
    id recorded = OCMExpect([[(id)self.client reject] changePubNubAuthorizationKey:authorizationKey withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
    }];
    
    OCMVerifyAll(chatMock);
}

- (void)testReauthorize_ShouldUpdateFunctionsManagerConfiguration {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *uuid = [self.client pubNubUUID];
    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    OCMStub([self.client global]).andReturn(chat);

    OCMStub([self.client reconnectUser]).andDo(nil);
    OCMStub([self.client changePubNubAuthorizationKey:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
            block();
        });

    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock setWithNamespace:[OCMArg any] userUUID:uuid userAuth:authorizationKey]);
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
    }];
}

- (void)testReauthorize_ShouldReconnectUser {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    OCMStub([self.client global]).andReturn(chat);

    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock setWithNamespace:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    
    OCMStub([self.client changePubNubAuthorizationKey:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
            block();
        });
    
    id recorded = OCMExpect([self.client reconnectUser]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.reauthorize(authorizationKey);
    }];
}


#pragma mark - Tests :: authorizeLocalUserWithCompletion

- (void)testAuthorizeLocalUserWithCompletion_ShouldRequestAuthorizationWithLocalUserData {

    NSString *uuid = [self.client pubNubUUID];
    NSString *authorizationKey = @"PubNub";


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubNubAuthKey]).andReturn(authorizationKey);
    
    id recorded = OCMExpect([self.client authorizeLocalUserWithUUID:uuid authorizationKey:authorizationKey
                                                         completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [self.client authorizeLocalUserWithCompletion:^{ }];
    }];
}


#pragma mark - Tests :: authorizeLocalUserWithUUID

- (void)testAuthorizeLocalUserWithUUID_ShouldConfigureFunctionsClient {
    
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *authorizationKey = @"PubNub";

    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(nil);
    
    id recorded = OCMExpect([clientMock setWithNamespace:[OCMArg any] userUUID:uuid userAuth:authorizationKey]);
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        [self.client authorizeLocalUserWithUUID:uuid authorizationKey:authorizationKey completion:^{ }];
    }];
}

- (void)testAuthorizeLocalUserWithUUID_ShouldCallSetOfEndpoints {
    
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *authorizationKey = @"PubNub";
    NSArray *routes = @[
        @{ @"route": @"bootstrap", @"method": @"post" },
        @{ @"route": @"user_read", @"method": @"post" },
        @{ @"route": @"user_write", @"method": @"post" },
        @{ @"route": @"group", @"method": @"post" }
    ];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock setWithNamespace:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    
    id recorded = OCMExpect([clientMock callRouteSeries:routes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        [self.client authorizeLocalUserWithUUID:uuid authorizationKey:authorizationKey completion:^{ }];
    }];
}

- (void)testAuthorizeLocalUserWithUUID_ShouldCallBlock_WhenAuthorizationSuccess {
    
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *authorizationKey = @"PubNub";
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock setWithNamespace:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client authorizeLocalUserWithUUID:uuid authorizationKey:authorizationKey completion:handler];
    }];
}

- (void)testAuthorizeLocalUserWithUUID_ShouldThrow_WhenAuthorizationDidFail {
    
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *authorizationKey = @"PubNub";
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock setWithNamespace:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(NO, @[error]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client authorizeLocalUserWithUUID:uuid authorizationKey:authorizationKey
                                                              completion:^{}],
                                 NSException, kCENPNFunctionErrorDomain);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldEmitError_WhenAuthorizationDidFail {
    
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSString *authorizationKey = @"PubNub";
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[error]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.auth"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
        return ^(CENEmittedEvent *emittedEvent) {
            NSError *emittedError = emittedEvent.data;
            
            XCTAssertNotNil(emittedError);
            XCTAssertEqualObjects(emittedError.userInfo[NSUnderlyingErrorKey], error);
            handler();
        };
    } afterBlock:^{
        [self.client authorizeLocalUserWithUUID:uuid authorizationKey:authorizationKey completion:^{}];
    }];
}


#pragma mark - Tests :: handshakeChatAccess

- (void)testHandshakeChatAccess_ShouldCallSetOfEndpoints {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *representation = [chat dictionaryRepresentation];
    NSArray *routes = @[
        @{ @"route": @"grant", @"method": @"post", @"body": @{ @"chat": representation } },
        @{ @"route": @"join", @"method": @"post", @"body": @{ @"chat": representation } },
    ];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock callRouteSeries:routes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}

- (void)testHandshakeChatAccess_ShouldCallBlock_WhenHandshakeSuccess {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client handshakeChatAccess:chat withCompletion:handler];
    }];
}

- (void)testHandshakeChatAccess_ShouldCallBlock_WhenMetaSynchronizationEnabledSuccess {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client handshakeChatAccess:chat withCompletion:handler];
    }];
}

- (void)testHandshakeChatAccess_ShouldNotCallBlock_WhenHandshakeSuccessAndMetaSynchronizationEnabledNotCompleted {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    OCMStub([self.client fetchMetaForChat:chat withCompletion:[OCMArg any]]).andDo(nil);
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client handshakeChatAccess:chat withCompletion:handler];
    }];
}

- (void)testHandshakeChatAccess_ShouldRequestMetaForChat_WhenMetaSynchronizationEnabled {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id recorded = OCMExpect([self.client fetchMetaForChat:chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}

- (void)testHandshakeChatAccess_ShouldNotRequestMetaForChat_WhenSystemChatPassedAndMetaSynchronizationEnabledNotCompleted {

    CENChat *chat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id recorded = OCMExpect([[(id)self.client reject] fetchMetaForChat:chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}

- (void)testHandshakeChatAccess_ShouldNotRequestMetaForChat_WhenGlobalChatPassedAndMetaSynchronizationEnabledNotCompleted {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    OCMStub([self.client global]).andReturn(chat);
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id recorded = OCMExpect([[(id)self.client reject] fetchMetaForChat:chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}

- (void)testHandshakeChatAccess_ShouldThrow_WhenPubNubClientNotReady {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];

    
    XCTAssertThrowsSpecificNamed([self.client handshakeChatAccess:chat withCompletion:^{ }], NSException,
                                 kCENErrorDomain);
}

- (void)testHandshakeChatAccess_ShouldEmitError_WhenPubNubClientNotReady {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];

    
    [self object:self.client shouldHandleEvent:@"$.error.auth"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedEvent.data);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            handler();
        };
    } afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}

- (void)testHandshakeChatAccess_ShouldThrow_WhenHandshakeDidFail {

    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(NO, @[error]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client handshakeChatAccess:chat withCompletion:^{ }], NSException,
                                 kCENPNFunctionErrorDomain);
}

- (void)testHandshakeChatAccess_ShouldEmitError_WhenHandshakeDidFail {

    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(NO, @[error]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.auth"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *emittedError = emittedEvent.data;
            
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedError);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            XCTAssertEqualObjects(emittedError.userInfo[NSUnderlyingErrorKey], error);
            handler();
        };
    } afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}



- (void)testHandshakeChatAccess_ShouldThrow_WhenMetaSynchronizationEnabledDidFail {

    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    __block BOOL shouldReturnError = NO;


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        BOOL reportSuccess = !shouldReturnError;
        NSArray *response = !shouldReturnError ? @[] : @[error];
        shouldReturnError = YES;
        block(reportSuccess, response);
    });
    
    XCTAssertThrowsSpecificNamed([self.client handshakeChatAccess:chat withCompletion:^{ }], NSException,
                                 kCENPNFunctionErrorDomain);
}

- (void)testHandshakeChatAccess_ShouldEmitError_WhenMetaSynchronizationEnabledDidFail {

    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    __block BOOL shouldReturnError = NO;


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        BOOL reportSuccess = !shouldReturnError;
        NSArray *response = !shouldReturnError ? @[] : @[error];
        shouldReturnError = YES;
        block(reportSuccess, response);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.auth"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *emittedError = emittedEvent.data;
            
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedError);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            XCTAssertEqualObjects(emittedError.userInfo[NSUnderlyingErrorKey], error);
            handler();
        };
    } afterBlock:^{
        [self.client handshakeChatAccess:chat withCompletion:^{ }];
    }];
}

#pragma mark -


@end
