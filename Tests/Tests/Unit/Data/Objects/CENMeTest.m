/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENMe+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENMeTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) CENMe *meWithOutState;
@property (nonatomic, nullable, strong) CENMe *meWithState;
@property (nonatomic, nullable, strong) CENChat *global;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENMeTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENChatEngine *client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    self.defaultClient = [self partialMockForObject:client];
    
    self.global = [self partialMockForObject:self.defaultClient.Chat().name(@"global").autoConnect(NO).create()];
    
    OCMStub([self.defaultClient global]).andReturn(self.global);
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    
    self.meWithState = [CENMe userWithUUID:@"tester1" state:@{ @"test": @"state" } chatEngine:self.defaultClient];
    self.meWithOutState = [CENMe userWithUUID:@"tester2" state:@{} chatEngine:self.defaultClient];
    
    OCMStub([self.defaultClient me]).andReturn(self.meWithOutState);
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [self.global destruct];
    self.global = nil;
    
    [self.meWithOutState destruct];
    [self.meWithState destruct];
    self.meWithOutState = nil;
    self.meWithState = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: session

- (void)testSession_ShouldRetrieveReferenceFromChatEngine {
    
    id expected = @{};
    OCMExpect([self.defaultClient synchronizationSession]).andReturn(expected);
    
    XCTAssertEqualObjects(self.defaultClient.me.session, expected);
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: assignState

- (void)testAssignTest_ShouldChangeStateLocally {
    
    NSDictionary *expectedState = @{ @"test": @"state", @"success": @YES };
    id mePartialMock = [self partialMockForObject:self.meWithState];
    NSDictionary *state = @{ @"success": @YES };
    
    OCMExpect([[mePartialMock reject] fetchStoredStateWithCompletion:[OCMArg any]]);
    
    [self.meWithState assignState:state];
    
    OCMVerifyAll(mePartialMock);
    XCTAssertEqualObjects(self.meWithState.state, expectedState);
}


#pragma mark - Tests :: updateState

- (void)testUpdateState_ShouldChangeState {
    
    NSDictionary *expectedState = @{ @"fromRemote": @YES, @"success": @YES };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *state = @{ @"success": @YES };
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient fetchUserState:self.meWithOutState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(@{ @"fromRemote": @YES });
    });
    
    [self.defaultClient handleEvent:@"$.state" withHandlerBlock:^(CENMe *me) {
        handlerCalled = YES;
        
        XCTAssertEqual(me, self.meWithOutState);
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.meWithOutState.update(state);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
    XCTAssertEqualObjects(self.meWithOutState.state, expectedState);
}

- (void)testUpdateState_ShouldPropagateStateToRemoteUsers {
    
    NSDictionary *expectedState = @{ @"fromRemote": @YES, @"success": @YES };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *state = @{ @"success": @YES };
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient fetchUserState:self.meWithOutState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(@{ @"fromRemote": @YES });
    });
    
    OCMExpect([self.global setState:expectedState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.meWithOutState.update(state);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.global);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    NSString *description = [self.meWithState description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}


#pragma mark -


@end
