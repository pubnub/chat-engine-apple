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
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"

@interface CENChatEngineUserTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSDictionary *defaultLocalUserState;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineUserTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    self.defaultLocalUserState = @{ @"tester": @"user", @"state": @"information" };
}


#pragma mark - Tests :: User / createUserWithUUID

- (void)testUserCreateUserWithUUID_ShouldCreateUserInstanceUsingUsersManager {
    
    NSDictionary *expectedState = @{ @"test": @"user state" };
    NSString *expectedUserUUID = [NSUUID UUID].UUIDString;
    
    
    id managerMock = [self mockForObject:self.client.usersManager];
    id recorded = OCMExpect([managerMock createUserWithUUID:expectedUserUUID state:expectedState]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.User(expectedUserUUID).state(expectedState).create();
    }];
}


#pragma mark - Tests :: User / userWithUUID

- (void)testUserUserWithUUID_ShouldFindInstanceUsingUsersManager {
    
    NSString *expectedUserUUID = [NSUUID UUID].UUIDString;
    
    
    self.client.User(expectedUserUUID).create();
    
    id managerMock = [self mockForObject:self.client.usersManager];
    id recorded = OCMExpect([managerMock userWithUUID:expectedUserUUID]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.User(expectedUserUUID).get();
    }];
}


#pragma mark - Tests :: fetchUserState

- (void)testFetchUserState_CallSetOfEndpoints {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSArray<NSDictionary *> *expectedRoutes = @[@{
        @"route": @"user_state",
        @"method": @"get",
        @"query": @{ @"user": user.uuid, @"channel": chat.channel }
    }];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client fetchUserState:user forChat:chat withCompletion:^(NSDictionary *state) { }];
    }];
}

- (void)testFetchUserState_ShouldCallHandlerWithState {
    
    NSDictionary *expectedState = @{ @"state": @"from PubNub Function" };
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(YES, @[expectedState]);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client fetchUserState:user forChat:chat withCompletion:^(NSDictionary *state) {
            XCTAssertEqualObjects(state, expectedState);
            handler();
        }];
    }];
}

- (void)testFetchUserState_ShouldThrow_WhenStateFetchDidFail {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client fetchUserState:user forChat:chat withCompletion:^(NSDictionary *state) { }],
                                 NSException, kCENPNFunctionErrorDomain);
}

- (void)testFetchUserState_ShouldEmitError_WhenStateFetchDidFail {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.restoreState.network"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.data);
            handler();
        };
    } afterBlock:^{
        [self.client fetchUserState:user forChat:chat withCompletion:^(NSDictionary *state) { }];
    }];
}


#pragma mark - Tests :: destroyUsers

- (void)testDestroyUsers_ShouldRemoveAllUsersUsingUsersManager {
    
    id managerMock = [self mockForObject:self.client.usersManager];
    id recorded = OCMExpect([managerMock destroy]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client destroyUsers];
    }];
}


#pragma mark - Tests :: users

- (void)testUsers_ShouldReturnListOfCreatedUsersUsingUsersManager {
    
    id managerMock = [self mockForObject:self.client.usersManager];
    OCMExpect([managerMock users]).andForwardToRealObject();
    
    XCTAssertNotNil(self.client.users);
    
    OCMVerify(managerMock);
}


#pragma mark - Tests :: me

- (void)testMe_ShouldReturnReferenceOnLocalUserUsingUsersManager {
    
    id managerMock = [self mockForObject:self.client.usersManager];
    OCMExpect([managerMock me]).andForwardToRealObject();
    
    XCTAssertNil(self.client.me);
    
    OCMVerify(managerMock);
}

#pragma mark -


@end
