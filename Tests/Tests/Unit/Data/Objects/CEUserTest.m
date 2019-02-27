/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUserTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSDictionary *defaultState;
@property (nonatomic, nullable, strong) NSDictionary *changedState;
@property (nonatomic, nullable, strong) NSString *defaultUUID;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUserTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];

    
    self.changedState = @{ @"changed": @"state" };
    self.defaultState = @{ @"test": @"state" };
    self.defaultUUID = @"tester";
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance_WhenRequiredParametersIsSet {
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    
    
    XCTAssertNotNil(user);
    XCTAssertNotNil(user.direct);
    XCTAssertNotNil(user.feed);
    XCTAssertEqual(user.chatEngine, self.client);
}

- (void)testConstructor_ShouldNotCreateInstance_WhenNonNSStringUUIDPassed {
    
    CENUser *user = [CENUser userWithUUID:(id)@2010 state:self.defaultState chatEngine:self.client];
    
    
    XCTAssertNil(user);
}

- (void)testConstructor_ShouldNotCreateInstance_WhenNilUUIDPassed {
    
    NSString *uuid = nil;
    CENUser *user = [CENUser userWithUUID:uuid state:self.defaultState chatEngine:self.client];
    
    
    XCTAssertNil(user);
}

- (void)testConstructor_ShouldNotCreateInstance_WhenEmptyUUIDPassed {
    
    CENUser *user = [CENUser userWithUUID:@"" state:self.defaultState chatEngine:self.client];
    
    
    XCTAssertNil(user);
}


#pragma mark - Tests :: assignState

- (void)testAssignState_ShouldUpdateStateForGlobal_WhenCalledWithNil {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };
    NSMutableDictionary *expectedState = [self.defaultState mutableCopy];
    [expectedState addEntriesFromDictionary:state];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    [user assignState:state forChat:nil];
    
    XCTAssertEqualObjects([user stateForChat:self.client.global], expectedState);
}

- (void)testAssignState_ShouldUpdateStateForSpecificChat_WhenCalledWithChat {
    
    NSDictionary *expectedState = @{ @"some": @[@"test", @"state"] };
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    [user assignState:expectedState forChat:chat];
    
    XCTAssertEqualObjects([user stateForChat:chat], expectedState);
}

- (void)testAssignState_ShouldThrow_WhenCalledWithNilAndNoGlobalIsSet {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:nilState chatEngine:self.client];
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };
    
    
    XCTAssertThrowsSpecificNamed([user assignState:state forChat:nil], NSException, kCENErrorDomain);
}


#pragma mark - Tests :: updateState

- (void)testUpdateState_ShouldCallStateAssign {
    
    self.usesMockedObjects = YES;
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:nilState chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);

    id userMock = [self mockForObject:user];
    id recorded = OCMExpect([userMock assignState:state forChat:chat]);
    [self waitForObject:userMock recordedInvocationCall:recorded afterBlock:^{
        [user updateState:state forChat:nil];
    }];
}

- (void)testUpdateState_ShouldThrow_WhenCalledWithNilAndNoGlobalIsSet {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:nilState chatEngine:self.client];
    NSDictionary *state = @{ @"some": @[@"test", @"state"] };
    
    
    XCTAssertThrowsSpecificNamed([user updateState:state forChat:nil], NSException, kCENErrorDomain);
}


#pragma mark - Tests :: restoreState / restoreStateForChat

- (void)testRestoreState_ShouldFetchStoredStateForGlobal_WhenCalledWithNil {
    
    self.usesMockedObjects = YES;
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    id userMock = [self mockForObject:user];
    id recorded = OCMExpect([userMock restoreStateForChat:chat withCompletion:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationCall:recorded afterBlock:^{
        [user restoreStateForChat:nil];
    }];
}

- (void)testRestoreState_ShouldThrow_WhenCalledWithNilAndNoGlobalIsSet {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:nilState chatEngine:self.client];

    
    XCTAssertThrowsSpecificNamed([user restoreStateForChat:nil], NSException, kCENErrorDomain);
}


#pragma mark - Tests :: fetchStoredStateWithCompletion

- (void)testFetchStoredStateWithCompletion_ShouldRequestState_WhenInitialStateNotProvided {
    
    self.usesMockedObjects = YES;
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);

    OCMExpect([self.client fetchUserState:user forChat:chat withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:3];
            handlerBlock(self.defaultState);
        });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [user restoreStateForChat:self.client.global withCompletion:^(NSDictionary *state) {
            XCTAssertEqualObjects(state, self.defaultState);
            handler();
        }];
    }];
    
    OCMVerifyAll((id)self.client);
}

- (void)testFetchStoredStateWithCompletion_ShouldNotRequestState_WhenInitialStateProvided {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    
    id falseExpect = [(id)self.client reject];
    OCMExpect([falseExpect fetchUserState:[OCMArg any] forChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(nil);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [user restoreStateForChat:self.client.global withCompletion:^(NSDictionary *state) {
            XCTAssertEqualObjects(state, self.defaultState);
            handler();
        }];
    }];
    
    OCMVerifyAll((id)self.client);
}


#pragma mark - Tests :: state

- (void)testState_ShouldNotBeEmptyForUserCreatedWithState {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedState = self.defaultState;


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    
    XCTAssertNotNil(user.state);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testState_ShouldBeEmpty_WhenModelCreatedWithNilState {
    
    self.usesMockedObjects = YES;
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedState = @{};


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    XCTAssertNotNil(user.state);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testState_ShouldThrow_WhenCalledAndNoGlobalIsSet {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:nilState chatEngine:self.client];
    
    
    XCTAssertThrowsSpecificNamed(user.state, NSException, kCENErrorDomain);
}


#pragma mark - Tests :: defaultStateChat

- (void)testDefaultStateChat_ShouldReturnGlobal {
    
    self.usesMockedObjects = YES;
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    XCTAssertEqualObjects([user defaultStateChat], self.client.global);
}


#pragma mark - Tests :: identifier

- (void)testIdentifier_ShouldReturnUUID {
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    
    
    XCTAssertEqualObjects(user.identifier, user.uuid);
}


#pragma mark - Tests :: uuid

- (void)testUUID_ShouldNotBeEmpty {
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    NSString *expectedUUID = self.defaultUUID;
    
    
    XCTAssertNotNil(user.uuid);
    XCTAssertEqualObjects(user.uuid, expectedUUID);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client global]).andReturn(chat);
    
    CENUser *user = [CENUser userWithUUID:self.defaultUUID state:self.defaultState chatEngine:self.client];
    [user updateState:self.changedState forChat:nil];
    
    NSString *description = [user description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"state set: 1 chats"].location, NSNotFound);
}

- (void)testDescription_ShouldProvideInstanceDescription_WhenStateIsNil {
    
    NSDictionary *nilState = nil;
    CENUser *user = [CENUser userWithUUID:@"stateTester" state:nilState chatEngine:self.client];
    NSString *description = [user description];
    
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"state set: 0 chats"].location, NSNotFound);
}

#pragma mark -


@end
