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

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;
@property (nonatomic, nullable, strong) NSDictionary *defaultLocalUserState;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineUserTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.defaultLocalUserState = @{ @"tester": @"user", @"state": @"information" };
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    if ([self.name rangeOfString:@"testMe"].location == NSNotFound) {
        OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:self.defaultLocalUserState chatEngine:self.clientMock]);
    }
    
    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.client createGlobalChat];
}


#pragma mark - Tests :: User / createUserWithUUID

- (void)testUserCreateUserWithUUID_ShouldCreateUserInstanceUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.client.usersManager];
    NSDictionary *expectedState = @{ @"test": @"user state" };
    NSString *expectedUserUUID = [NSUUID UUID].UUIDString;
    
    OCMExpect([usersManagerPartialMock createUserWithUUID:expectedUserUUID state:expectedState]).andForwardToRealObject();
    
    XCTAssertNotNil(self.client.User(expectedUserUUID).state(expectedState).create());
    
    OCMVerifyAll(usersManagerPartialMock);
}


#pragma mark - Tests :: User / userWithUUID

- (void)testUserUserWithUUID_ShouldFindInstanceUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.client.usersManager];
    NSString *expectedUserUUID = [NSUUID UUID].UUIDString;
    
    OCMExpect([usersManagerPartialMock userWithUUID:expectedUserUUID]);
    
    self.client.User(expectedUserUUID).get();
    
    OCMVerifyAll(usersManagerPartialMock);
}


#pragma mark - Tests :: updateLocalUserState

- (void)testUpdateLocalUserState_ShouldUpdateState {
    
    id localUserPartialMock = [self partialMockForObject:self.client.me];
    NSDictionary *expectedState = @{ @"test": @"user state" };
    
    OCMExpect([localUserPartialMock updateState:expectedState withCompletion:[OCMArg any]]);
    
    [self.client updateLocalUserState:expectedState withCompletion:^{ }];
    
    OCMVerifyAll(localUserPartialMock);
}


#pragma mark - Tests :: propagateLocalUserStateRefreshWithCompletion

- (void)testPropagateLocalUserStateRefreshWithCompletion_ShouldPushOnGlobalChat {
    
    id globalChatPartialMock = [self partialMockForObject:self.client.global];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([globalChatPartialMock setState:self.defaultLocalUserState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client propagateLocalUserStateRefreshWithCompletion:^{ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(globalChatPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: fetchUserState

- (void)testFetchUserState_CallSetOfEndpoints {
    
    NSString *expectedLocalUserUUID = self.client.me.uuid;
    NSArray<NSDictionary *> *expectedRoutes = @[@{ @"route": @"user_state", @"method": @"get", @"query": @{ @"user": expectedLocalUserUUID } }];
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client fetchUserState:self.client.me withCompletion:^(NSDictionary *state) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchUserState_ShouldCallHandlerWithState {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    NSDictionary *expectedState = @{ @"state": @"from PubNub Function" };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, @[expectedState]);
    });
    
    [self.client fetchUserState:self.client.me withCompletion:^(NSDictionary *state) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(state, expectedState);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.client fetchUserState:self.client.me withCompletion:^(NSDictionary *state) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchUserState_ShouldThrowEmitError_WhenStateFetchDidFail {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    self.client.once(@"$.error.getState", ^(CENUser *user, NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client fetchUserState:self.client.me withCompletion:^(NSDictionary *state) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: destroyUsers

- (void)testDestroyUsers_ShouldRemoveAllUsersUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.client.usersManager];
    
    OCMExpect([usersManagerPartialMock destroy]);
    
    [self.client destroyUsers];
    
    OCMVerify(usersManagerPartialMock);
}


#pragma mark - Tests :: users

- (void)testUsers_ShouldReturnListOfCreatedUsersUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.client.usersManager];
    
    OCMExpect([usersManagerPartialMock users]).andForwardToRealObject();
    
    XCTAssertNotNil(self.client.users);
    
    OCMVerify(usersManagerPartialMock);
}


#pragma mark - Tests :: me

- (void)testMe_ShouldReturnReferenceOnLocalUserUsingUsersManager {
    
    id usersManagerPartialMock = [self partialMockForObject:self.client.usersManager];
    
    OCMExpect([usersManagerPartialMock me]).andForwardToRealObject();
    
    XCTAssertNil(self.client.me);
    
    OCMVerify(usersManagerPartialMock);
}

#pragma mark -


@end
