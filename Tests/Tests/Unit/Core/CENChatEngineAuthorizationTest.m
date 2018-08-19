/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPNFunctionClient.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineAuthorizationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineAuthorizationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.enableMeta = [self.name rangeOfString:@"testHandshakeChatAccess_ShouldRequestMetaWhenConfigured"].location != NSNotFound;
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];

    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);

    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;

        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.clientMock createGlobalChat];
    id partialGlobalChatMock = [self partialMockForObject:self.client.global];
    OCMStub([self.clientMock global]).andReturn(partialGlobalChatMock);
    OCMStub([self.clientMock.global connected]).andReturn(YES);
}


#pragma mark - Tests :: reauthorize / reauthorizeUserWithKey

- (void)testReauthorize_ShouldChangePubNubClientConfiguration {

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedAuthorizationKey = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.clientMock changePubNubAuthorizationKey:expectedAuthorizationKey withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            handlerCalled = YES;
        
            dispatch_semaphore_signal(semaphore);
        });

    self.clientMock.reauthorize(expectedAuthorizationKey);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testReauthorize_ShouldChangeFunctionsClientConfiguration {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    NSString *globalChat = self.client.currentConfiguration.globalChannel;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *userUUID = [self.client pubNubUUID];
    NSString *expectedAuthorizationKey = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock reconnectUser]).andDo(nil);
    OCMExpect([self.clientMock changePubNubAuthorizationKey:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t handlerBlock = nil;
            
            [invocation getArgument:&handlerBlock atIndex:3];
            handlerBlock();
        });
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:globalChat userUUID:userUUID userAuth:expectedAuthorizationKey])
        .andDo(^(NSInvocation *invocation) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        });
    
    self.clientMock.global.once(@"$.connected", ^{
        self.clientMock.reauthorize(expectedAuthorizationKey);
    });
    
    self.clientMock.global.connect();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: authorizeLocalUserWithCompletion

- (void)testAuthorizeLocalUserWithCompletion_ShouldRequestAuthorizationWithLocalUserData {
    
    NSString *expectedUUID = [self.client pubNubUUID];
    NSString *expectedAuthKey = @"secret-auth-key";
    
    OCMStub([self.clientMock pubNubAuthKey]).andReturn(expectedAuthKey);
    
    OCMExpect([self.clientMock authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey completion:[OCMArg any]]).andDo(nil);
    
    [self.clientMock authorizeLocalUserWithCompletion:^{ }];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: authorizeLocalUserWithUUID

- (void)testAuthorizeLocalUserWithUUID_ShouldConfigureFunctionsClientAndCallSetOfEndpoints {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    NSString *expectedGlobalChat = self.client.currentConfiguration.globalChannel;
    NSString *expectedAuthKey = @"secret-auth-key";
     NSArray<NSDictionary *> *expectedRoutes = @[
        @{ @"route": @"bootstrap", @"method": @"post" },
        @{ @"route": @"user_read", @"method": @"post" },
        @{ @"route": @"user_write", @"method": @"post" },
        @{ @"route": @"group", @"method": @"post" }
    ];
    NSString *expectedUUID = @"test-user";
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:expectedGlobalChat userUUID:expectedUUID userAuth:expectedAuthKey]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(nil);
    
    [self.client authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey completion:^{}];
    
    OCMVerifyAll((id)functionsClientPartialMock);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldCallBlockOnSuccess {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    [self.client authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldThrowEmitErrorOnFailure {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    self.client.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:^{ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldThrowEmitErrorOnUnknownFailure {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    self.client.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error.userInfo[NSUnderlyingErrorKey]);
        XCTAssertEqualObjects(((NSError *)error.userInfo[NSUnderlyingErrorKey]).localizedDescription, @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:^{ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: handshakeChatAccess

- (void)testHandshakeChatAccess_ShouldCallSetOfEndpoints {
    
    NSDictionary *dictionaryRepresentation = [self.client.me.direct dictionaryRepresentation];
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    PubNub *client = [PubNub clientWithConfiguration:self.client.pubNubConfiguration];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray<NSDictionary *> *expectedRoutes = @[
        @{ @"route": @"grant", @"method": @"post",  @"body": @{ @"chat": dictionaryRepresentation } },
        @{ @"route": @"join", @"method": @"post",  @"body": @{ @"chat": dictionaryRepresentation } },
    ];
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock pubnub]).andReturn(client);
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock handshakeChatAccess:self.client.me.direct withCompletion:^(BOOL error, NSDictionary * _Nonnull meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testHandshakeChatAccess_ShouldCallBlockOnSuccess {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    PubNub *client = [PubNub clientWithConfiguration:self.client.pubNubConfiguration];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock pubnub]).andReturn(client);
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    [self.clientMock handshakeChatAccess:self.client.me.direct withCompletion:^(BOOL error, NSDictionary * _Nonnull meta) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testHandshakeChatAccess_ShouldThrowEmitError_WhenPubNubInstanceNotSet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.client.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client handshakeChatAccess:self.client.me.direct withCompletion:^(BOOL error, NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testHandshakeChatAccess_ShouldRequestMetaWhenConfigured {
    
    __block id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    PubNub *pubNub = [PubNub clientWithConfiguration:self.client.pubNubConfiguration];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock pubnub]).andReturn(pubNub);
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;

        [invocation getArgument:&handlerBlock atIndex:3];
        [functionsClientPartialMock stopMocking];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([self.clientMock fetchRemoteStateForChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *baseInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock handshakeChatAccess:self.client.me.direct withCompletion:^(BOOL error, NSDictionary * _Nonnull meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
