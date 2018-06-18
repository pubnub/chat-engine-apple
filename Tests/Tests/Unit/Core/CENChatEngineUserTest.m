/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENMe+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"

@interface CENChatEngineUserTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSDictionary *defaultLocalUserState;
@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineUserTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.defaultLocalUserState = @{ @"tester": @"user", @"state": @"information" };
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    if ([self.name rangeOfString:@"testMe"].location == NSNotFound) {
        OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:self.defaultLocalUserState chatEngine:self.defaultClient]);
    }
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.defaultClient createGlobalChat];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: User / createUserWithUUID

- (void)testUserCreateUserWithUUID_ShouldCreateUserInstanceUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.defaultClient.usersManager];
    NSDictionary *expectedState = @{ @"test": @"user state" };
    NSString *expectedUserUUID = [NSUUID UUID].UUIDString;
    
    OCMExpect([usersManagerPartialMock createUserWithUUID:expectedUserUUID state:expectedState]).andForwardToRealObject();
    
    XCTAssertNotNil(self.defaultClient.User(expectedUserUUID).state(expectedState).create());
    
    OCMVerifyAll(usersManagerPartialMock);
}


#pragma mark - Tests :: User / userWithUUID

- (void)testUserUserWithUUID_ShouldFindInstanceUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.defaultClient.usersManager];
    NSString *expectedUserUUID = [NSUUID UUID].UUIDString;
    
    OCMExpect([usersManagerPartialMock userWithUUID:expectedUserUUID]);
    
    self.defaultClient.User(expectedUserUUID).get();
    
    OCMVerifyAll(usersManagerPartialMock);
}


#pragma mark - Tests :: updateLocalUserState

- (void)testUpdateLocalUserState_ShouldUpdateState {
    
    id localUserPartialMock = [self partialMockForObject:self.defaultClient.me];
    NSDictionary *expectedState = @{ @"test": @"user state" };
    
    OCMExpect([localUserPartialMock updateState:expectedState withCompletion:[OCMArg any]]);
    
    [self.defaultClient updateLocalUserState:expectedState withCompletion:^{ }];
    
    OCMVerifyAll(localUserPartialMock);
}


#pragma mark - Tests :: propagateLocalUserStateRefreshWithCompletion

- (void)testPropagateLocalUserStateRefreshWithCompletion_ShouldPushOnGlobalChat {
    
    id globalChatPartialMock = [self partialMockForObject:self.defaultClient.global];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([globalChatPartialMock setState:self.defaultLocalUserState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient propagateLocalUserStateRefreshWithCompletion:^{ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(globalChatPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: fetchUserState

- (void)testFetchUserState_CallSetOfEndpoints {
    
    NSString *expectedLocalUserUUID = self.defaultClient.me.uuid;
    NSArray<NSDictionary *> *expectedRoutes = @[@{ @"route": @"user_state", @"method": @"get", @"query": @{ @"user": expectedLocalUserUUID } }];
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient fetchUserState:self.defaultClient.me withCompletion:^(NSDictionary *state) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchUserState_ShouldCallHandlerWithState {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    NSDictionary *expectedState = @{ @"state": @"from PubNub Function" };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, @[expectedState]);
    });
    
    [self.defaultClient fetchUserState:self.defaultClient.me withCompletion:^(NSDictionary *state) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(state, expectedState);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.defaultClient fetchUserState:self.defaultClient.me withCompletion:^(NSDictionary *state) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchUserState_ShouldThrowEmitError_WhenStateFetchDidFail {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    self.defaultClient.once(@"$.error.getState", ^(CENUser *user, NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient fetchUserState:self.defaultClient.me withCompletion:^(NSDictionary *state) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: destroyUsers

- (void)testDestroyUsers_ShouldRemoveAllUsersUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.defaultClient.usersManager];
    
    OCMExpect([usersManagerPartialMock destroy]);
    
    [self.defaultClient destroyUsers];
    
    OCMVerify(usersManagerPartialMock);
}


#pragma mark - Tests :: users

- (void)testUsers_ShouldReturnListOfCreatedUsersUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.defaultClient.usersManager];
    
    OCMExpect([usersManagerPartialMock users]).andForwardToRealObject();
    
    XCTAssertNotNil(self.defaultClient.users);
    
    OCMVerify(usersManagerPartialMock);
}


#pragma mark - Tests :: me

- (void)testMe_ShouldReturnReferenceOnLocalUserUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.defaultClient.usersManager];
    
    OCMExpect([usersManagerPartialMock me]).andForwardToRealObject();
    
    XCTAssertNil(self.defaultClient.me);
    
    OCMVerify(usersManagerPartialMock);
}

#pragma mark -


@end
