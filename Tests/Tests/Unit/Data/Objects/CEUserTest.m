/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENUserTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSDictionary *defaultState;
@property (nonatomic, nullable, strong) NSDictionary *changedState;
@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) NSString *defaultUUID;
@property (nonatomic, nullable, strong) CENUser *user;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUserTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENChatEngine *client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    self.defaultClient = [self partialMockForObject:client];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    
    self.changedState = @{ @"changed": @"state" };
    self.defaultState = @{ @"test": @"state" };
    self.defaultUUID = @"tester";
    self.user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.defaultClient];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [self.user destruct];
    self.user = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance_WhenRequiredParametersIsSet {
    
    XCTAssertNotNil(self.user);
    XCTAssertNotNil(self.user.direct);
    XCTAssertNotNil(self.user.feed);
    XCTAssertEqual(self.user.chatEngine, self.defaultClient);
}

- (void)testConstructor_ShouldNotCreateInstance_WhenNonNSStringUUIDPassed {
    
    XCTAssertNil([CENUser userWithUUID:(id)@2010 state:self.defaultState chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreateInstance_WhenNilUUIDPassed {
    
    NSString *uuid = nil;
    
    XCTAssertNil([CENUser userWithUUID:uuid state:self.defaultState chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreateInstance_WhenEmptyUUIDPassed {
    
    XCTAssertNil([CENUser userWithUUID:@"" state:self.defaultState chatEngine:self.defaultClient]);
}


#pragma mark - Tests :: assignState

- (void)testAssignState_ShouldCallStateUpdate {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    id userPartialMock = [self partialMockForObject:self.user];
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };
    
    OCMExpect([userPartialMock updateState:state]).andForwardToRealObject();
    
    [self.user assignState:state];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(userPartialMock);
}


#pragma mark - Tests :: updateState

- (void)testUpdateState_ShouldUpdateState {
    
    NSMutableDictionary *expectedState = [self.defaultState mutableCopy];
    [expectedState addEntriesFromDictionary:@{ @"some": @[@"test", @"state"] }];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };
    
    [self.user updateState:state];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertEqualObjects(self.user.state, expectedState);
}

- (void)testUpdateState_ShouldEmitStateEvent_WhenResultingStateDifferentFromOld {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };
    __block BOOL handlerCalled = NO;
    
    [self.defaultClient handleEvent:@"$.state" withHandlerBlock:^(CENUser *user) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.user updateState:state];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testUpdateState_ShouldNotEmitStateEvent_WhenUpdatedStateSameAsOld {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultClient handleEvent:@"$.state" withHandlerBlock:^(CENUser *user) {
        handlerCalled = YES;
    }];
    
    [self.user updateState:self.defaultState];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}


#pragma mark - Tests :: fetchStoredStateWithCompletion

- (void)testFetchStoredStateWithCompletion_ShouldRequestState_WhenInitialStateNotProvided {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMExpect([self.defaultClient fetchUserState:user withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(self.defaultState);
    });
    
    [user fetchStoredStateWithCompletion:^(NSDictionary *state) {
        XCTAssertEqualObjects(state, self.defaultState);
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testFetchStoredStateWithCompletion_ShouldNotRequestState_WhenInitialStateProvided {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMExpect([[(id)self.defaultClient reject] fetchUserState:self.user withCompletion:[OCMArg any]]).andDo(nil);
    
    [self.user fetchStoredStateWithCompletion:^(NSDictionary *state) {
        XCTAssertEqualObjects(state, self.defaultState);
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: state

- (void)testState_ShouldNotBeEmpty_WhenModelCreatedWithState {
    
    NSDictionary *expectedState = self.defaultState;
    
    XCTAssertNotNil(self.user.state);
    XCTAssertEqualObjects(self.user.state, expectedState);
}

- (void)testState_ShouldBeEmpty_WhenModelCreatedWithNilState {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.defaultClient];
    NSDictionary *expectedState = @{};
    
    XCTAssertNotNil(user.state);
    XCTAssertEqualObjects(user.state, expectedState);
}


#pragma mark - Tests :: uuid

- (void)testUUID_ShouldNotBeEmpty {
    
    NSString *expectedUUID = self.defaultUUID;
    
    XCTAssertNotNil(self.user.uuid);
    XCTAssertEqualObjects(self.user.uuid, expectedUUID);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *description = nil;
    __block BOOL handlerCalled = NO;
    
    self.defaultClient.once(@"$.state", ^(CENUser *user) {
        handlerCalled = YES;
        
        description = [self.user description];
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.user updateState:self.changedState];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"state set: YES"].location, NSNotFound);
    XCTAssertTrue(handlerCalled);
}

- (void)testDescription_ShouldProvideInstanceDescription_WhenStateIsNil {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.defaultClient];
    NSString *description = [user description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"state set: NO"].location, NSNotFound);
}

#pragma mark -


@end
