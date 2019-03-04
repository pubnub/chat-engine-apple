/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENMeTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENChat *direct;
@property (nonatomic, nullable, strong) CENChat *feed;


#pragma mark - Misc

- (CENMe *)userWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENMeTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {

    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"WhenGlobalConfigured"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    
    if ([self hasMockedObjectsInTestCaseWithName:self.name]) {
        [self completeChatEngineConfiguration:self.client];
    }
}

- (void)tearDown {
    
    [self.direct destruct];
    [self.feed destruct];
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{ @"test": @"state" } chatEngine:self.client];
    
    
    XCTAssertNotNil(me);
}

- (void)testConstructor_ShouldNotSetState {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client global]).andReturn(chat);
    
    CENMe *me = [self userWithUUID:@"tester" state:@{ @"test": @"state" } chatEngine:self.client];
    
    XCTAssertEqualObjects(me.state, @{});
}

#pragma mark - Tests :: session

- (void)testSession_ShouldRetrieveReferenceFromChatEngine {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{ @"test": @"state" } chatEngine:self.client];
    id expected = @{};
    
    
    OCMExpect([self.client synchronizationSession]).andReturn(expected);
    OCMStub([self.client me]).andReturn(me);
    
    XCTAssertEqualObjects(self.client.me.session, expected);
    
    OCMVerifyAll((id)self.client);
}


#pragma mark - Tests :: updateState

- (void)testUpdateState_ShouldChangeStateForGlobal {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedState = @{ @"fromRemote": @YES, @"success": @YES };
    
    
    OCMStub([self.client global]).andReturn(chat);
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    
    id globalMock = [self mockForObject:chat];
    id recorded = OCMExpect([(CENChat *)globalMock setState:expectedState]);
    [self waitForObject:globalMock recordedInvocationCall:recorded afterBlock:^{
        me.update(expectedState);
    }];
    
    XCTAssertEqualObjects(me.state, expectedState);
}

- (void)testUpdateState_ShouldThrow_WhenCalledWithNilAndNoGlobalConfigured {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSDictionary *state = @{ @"fromRemote": @YES, @"success": @YES };
    
    
    XCTAssertThrowsSpecificNamed(me.update(state), NSException, kCENErrorDomain);
}


#pragma mark - Tests :: destruct

- (void)testDestruct_ShouldUnregisterObjectByClient {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client unregisterAllFromObjects:me]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [me destruct];
    }];
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSString *description = [me description];
    
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}


#pragma mark - Misc

- (CENMe *)userWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine {

    XCTAssertTrue([self isObjectMocked:self.client]);

    self.direct = [self directChatForUser:uuid connectable:NO withChatEngine:chatEngine];
    self.feed = [self feedChatForUser:uuid connectable:NO withChatEngine:chatEngine];
    
    OCMStub([chatEngine createDirectChatForUser:[OCMArg any]]).andReturn(self.direct);
    OCMStub([chatEngine createFeedChatForUser:[OCMArg any]]).andReturn(self.feed);
    
    return [CENMe userWithUUID:uuid state:state chatEngine:chatEngine];
}

#pragma mark -


@end
