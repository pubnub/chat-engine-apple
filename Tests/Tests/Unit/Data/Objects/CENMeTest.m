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
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENUser+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENMeTest : CENTestCase


#pragma mark Misc

- (CENMe *)userWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENMeTest


#pragma mark - Setup / Tear down

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
    
    self.usesMockedObjects = YES;
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{ @"test": @"state" } chatEngine:self.client];
    
    
    XCTAssertNotNil(me);
}

- (void)testConstructor_ShouldNotSetState_WhenGlobalConfigured {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client global]).andReturn(chat);
    
    CENMe *me = [self userWithUUID:@"tester" state:@{ @"test": @"state" } chatEngine:self.client];
    
    XCTAssertEqualObjects(me.state(chat), @{});
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

- (void)testUpdateState_ShouldChangeStateForGlobal_WhenCalledWithNil {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedState = @{ @"fromRemote": @YES, @"success": @YES };
    
    
    OCMStub([self.client global]).andReturn(chat);
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    
    id globalMock = [self mockForObject:chat];
    id recorded = OCMExpect([(CENChat *)globalMock setState:expectedState]);
    [self waitForObject:globalMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        me.update(expectedState, nil);
    }];
    
    XCTAssertEqualObjects(me.state(chat), expectedState);
}

- (void)testUpdateState_ShouldChangeStateForSpecificChat_WhenCalledWithChat {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSDictionary *expectedState = @{ @"fromRemote": @YES, @"success": @YES };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([(CENChat *)chatMock setState:expectedState]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        me.update(expectedState, chat);
    }];
    
    XCTAssertEqualObjects(me.state(chat), expectedState);
}

- (void)testUpdateState_ShouldThrow_WhenCalledWithNilAndNoGlobalConfigured {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSDictionary *state = @{ @"fromRemote": @YES, @"success": @YES };
    
    
    XCTAssertThrowsSpecificNamed(me.update(state, nil), NSException, kCENErrorDomain);
}


#pragma mark - Tests :: destruct

- (void)testDestruct_ShouldUnregisterObjectByClient {
    
    CENMe *me = [self userWithUUID:@"tester" state:@{} chatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client unregisterAllFromObjects:me]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
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
    
    OCMStub([chatEngine createDirectChatForUser:[OCMArg any]])
        .andReturn([self directChatForUser:uuid connectable:NO withChatEngine:chatEngine]);
    OCMStub([chatEngine createFeedChatForUser:[OCMArg any]])
        .andReturn([self feedChatForUser:uuid connectable:NO withChatEngine:chatEngine]);
    
    return [CENMe userWithUUID:uuid state:state chatEngine:chatEngine];
}

#pragma mark -


@end
