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

@property (nonatomic, nullable, weak) CENChatEngine *clientWithMeta;
@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineAuthorizationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.enableMeta = YES;
    self.clientWithMeta = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    configuration.enableMeta = NO;
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.clientWithMeta createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientWithMeta.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.clientWithMeta createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientWithMeta.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.clientWithMeta me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientWithMeta]);
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    OCMStub([self.clientWithMeta connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.clientWithMeta createGlobalChat];
    [self.defaultClient createGlobalChat];
}

- (void)tearDown {
    
    [self.clientWithMeta destroy];
    self.clientWithMeta = nil;
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: reauthorize / reauthorizeUserWithKey

- (void)testReauthorize_ShouldChangePubNubClientConfiguration {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedAuthorizationKey = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient changePubNubAuthorizationKey:expectedAuthorizationKey withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            handlerCalled = YES;
        
            dispatch_semaphore_signal(semaphore);
        });
    
    self.defaultClient.global.once(@"$.connected", ^{
        self.defaultClient.reauthorize(expectedAuthorizationKey);
    });
    
    self.defaultClient.global.connect();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testReauthorize_ShouldChangeFunctionsClientConfiguration {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    NSString *globalChat = self.defaultClient.currentConfiguration.globalChannel;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *userUUID = [self.defaultClient pubNubUUID];
    NSString *expectedAuthorizationKey = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient changePubNubAuthorizationKey:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t handlerBlock = nil;
            
            [invocation getArgument:&handlerBlock atIndex:3];
            handlerBlock();
        });
    OCMStub([self.defaultClient reconnectUser]).andDo(nil);
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:globalChat userUUID:userUUID userAuth:expectedAuthorizationKey])
        .andDo(^(NSInvocation *invocation) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        });
    
    self.defaultClient.global.once(@"$.connected", ^{
        self.defaultClient.reauthorize(expectedAuthorizationKey);
    });
    
    self.defaultClient.global.connect();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: authorizeLocalUserWithCompletion

- (void)testAuthorizeLocalUserWithCompletion_ShouldRequestAuthorizationWithLocalUserData {
    
    NSString *expectedUUID = [self.defaultClient pubNubUUID];
    NSString *expectedAuthKey = @"secret-auth-key";
    
    OCMStub([self.defaultClient pubNubAuthKey]).andReturn(expectedAuthKey);
    
    OCMExpect([self.defaultClient authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey completion:[OCMArg any]]).andDo(nil);
    
    [self.defaultClient authorizeLocalUserWithCompletion:^{ }];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: authorizeLocalUserWithUUID

- (void)testAuthorizeLocalUserWithUUID_ShouldConfigureFunctionsClientAndCallSetOfEndpoints {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    NSString *expectedGlobalChat = self.defaultClient.currentConfiguration.globalChannel;
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
    
    [self.defaultClient authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey completion:^{}];
    
    OCMVerifyAll((id)functionsClientPartialMock);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldCallBlockOnSuccess {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    [self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldThrowEmitErrorOnFailure {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    self.defaultClient.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:^{ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testAuthorizeLocalUserWithUUID_ShouldThrowEmitErrorOnUnknownFailure {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock setDefaultDataWithGlobalChat:[OCMArg any] userUUID:[OCMArg any] userAuth:[OCMArg any]]).andDo(nil);
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    self.defaultClient.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error.userInfo[NSUnderlyingErrorKey]);
        XCTAssertEqualObjects(((NSError *)error.userInfo[NSUnderlyingErrorKey]).localizedDescription, @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:^{ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}



#pragma mark - Tests :: handshakeChatAccess

- (void)testHandshakeChatAccess_ShouldCallSetOfEndpoints {
    
    NSDictionary *dictionaryRepresentation = [self.defaultClient.me.direct dictionaryRepresentation];
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    PubNub *client = [PubNub clientWithConfiguration:self.defaultClient.pubNubConfiguration];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray<NSDictionary *> *expectedRoutes = @[
        @{ @"route": @"grant", @"method": @"post",  @"body": @{ @"chat": dictionaryRepresentation } },
        @{ @"route": @"join", @"method": @"post",  @"body": @{ @"chat": dictionaryRepresentation } },
    ];
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient pubnub]).andReturn(client);
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient handshakeChatAccess:self.defaultClient.me.direct withCompletion:^(BOOL error, NSDictionary * _Nonnull meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testHandshakeChatAccess_ShouldCallBlockOnSuccess {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    PubNub *client = [PubNub clientWithConfiguration:self.defaultClient.pubNubConfiguration];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMStub([self.defaultClient pubnub]).andReturn(client);
    [self.defaultClient handshakeChatAccess:self.defaultClient.me.direct withCompletion:^(BOOL error, NSDictionary * _Nonnull meta) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testHandshakeChatAccess_ShouldThrowEmitError_WhenPubNubInstanceNotSet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient handshakeChatAccess:self.defaultClient.me.direct withCompletion:^(BOOL error, NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testHandshakeChatAccess_ShouldRequestMetaWhenConfigured {
    
    __block id functionsClientPartialMock = [self partialMockForObject:self.clientWithMeta.functionsClient];
    PubNub *pubNub = [PubNub clientWithConfiguration:self.clientWithMeta.pubNubConfiguration];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientWithMeta pubnub]).andReturn(pubNub);
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;

        [invocation getArgument:&handlerBlock atIndex:3];
        [functionsClientPartialMock stopMocking];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([self.clientWithMeta fetchRemoteStateForChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *baseInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientWithMeta handshakeChatAccess:self.clientWithMeta.me.direct withCompletion:^(BOOL error, NSDictionary * _Nonnull meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientWithMeta);
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
