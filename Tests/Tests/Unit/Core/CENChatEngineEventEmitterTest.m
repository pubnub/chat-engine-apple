/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENErrorCodes.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineEventEmitterTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineEventEmitterTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [self.name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}


#pragma mark - Tests :: triggerEventLocallyFrom

- (void)testTriggerEventLocallyFrom_ShouldCallDesignatedMethod {
    
    NSString *expectedData = @"ChatEngine";
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
    
    id recorded = OCMExpect([self.client triggerEventLocallyFrom:self.client event:expectedEvent
                                                  withParameters:expectedPasrameters completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client triggerEventLocallyFrom:self.client event:expectedEvent, expectedData, nil];
    }];
}


#pragma mark - Tests :: triggerEventLocallyFromWithParameters

- (void)testTriggerEventLocallyFromWithParameters_ShouldEmitEventWithOutMiddlewareHandling_WhenNonNSDictionaryParameterPassed {
    
    self.usesMockedObjects = YES;
    CENPluginsManager *manager = self.client.pluginsManager;
    NSString *expectedData = @"ChatEngine";
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    
    
    id managerMock = [self mockForObject:manager];
    OCMExpect([[managerMock reject] runMiddlewaresAtLocation:[OCMArg any] forEvent:[OCMArg any] object:[OCMArg any]
                                                 withPayload:[OCMArg any] completion:[OCMArg any]]);
    
    id recorded = OCMExpect([self.client emitEventLocally:expectedEvent withParameters:expectedPasrameters]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client triggerEventLocallyFrom:self.client event:expectedEvent withParameters:expectedPasrameters
                                      completion:^(NSString *event, id payload, BOOL rejected) { }];
    }];
    
    OCMVerifyAll(managerMock);
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldAddReferenceOnChat_WhenEmittingObjectIsCENChat {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedData = @{ @"test": @"data" };
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client triggerEventLocallyFrom:chat event:expectedEvent withParameters:expectedPasrameters
                                  completion:^(NSString *event, NSArray<NSDictionary *> *updatedParameters, BOOL rejected) {
                                      
            XCTAssertNotNil(updatedParameters.firstObject[CENEventData.chat]);
            XCTAssertEqual(updatedParameters.firstObject[CENEventData.chat], chat);
            handler();
        }];
    }];
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldReplaceFirstParameter_WhenNSDictionaryPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedData = @{ @"test": @"data", CENEventData.chat: chat };
    NSArray *expectedPasrameters = @[expectedData, @"Hello"];
    NSDictionary *data = @{ @"test": @"data" };
    NSString *expectedEvent = @"test-event";
    NSArray *pasrameters = @[data, @"Hello"];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client triggerEventLocallyFrom:chat event:expectedEvent withParameters:pasrameters
                                  completion:^(NSString *event, NSArray<NSDictionary *> *updatedParameters, BOOL rejected) {
                                      
                XCTAssertEqualObjects(event, expectedEvent);
                XCTAssertFalse(rejected);
                XCTAssertEqualObjects(updatedParameters, expectedPasrameters);
                handler();
            }];
    }];
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldWrapFirstParameterInDictionary_WhenCENUserPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUser *user = self.client.User(@"exception-tester").create();
    NSDictionary *expectedPayload = @{ CENEventData.sender: user };
    NSString *expectedEvent = @"$.connected";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock runMiddlewaresAtLocation:@"on" forEvent:expectedEvent object:chat
                                                      withPayload:expectedPayload completion:[OCMArg any]]).andForwardToRealObject();
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client triggerEventLocallyFrom:(id)chat event:expectedEvent, user, nil];
    }];
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldReportRejection_WhenMiddlewareRejects {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedData = @{ @"test": @"data" };
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    OCMStub([managerMock runMiddlewaresAtLocation:[OCMArg any] forEvent:[OCMArg any] object:[OCMArg any] withPayload:[OCMArg any]
                                       completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, id) = [self objectForInvocation:invocation argumentAtIndex:5];
        id payload = [self objectForInvocation:invocation argumentAtIndex:4];
        block(YES, payload);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client triggerEventLocallyFrom:chat event:expectedEvent withParameters:expectedPasrameters
                                  completion:^(NSString *event, NSArray<NSDictionary *> *updatedParameters, BOOL rejected) {
                                      
            XCTAssertNil(updatedParameters.firstObject[CENEventData.chat]);
            XCTAssertTrue(rejected);
            handler();
        }];
    }];
}



#pragma mark - Tests :: throwError

- (void)testThrowError_ShouldEmitErrorByClient {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
    
    id recorded = OCMExpect([self.client emitEventLocally:@"$.error.test-error" withParameters:@[error]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client throwError:error forScope:@"test-error" from:nil propagateFlow:CEExceptionPropagationFlow.direct];
    }];
}

- (void)testThrowError_ShouldEmitErrorByObject_WhenDirectPropagationFlowUsed {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    CENUser *user = self.client.User(@"exception-tester").create();
    
    
    id userMock = [self mockForObject:user];
    id recorded = OCMExpect([userMock emitEventLocally:@"$.error.test-error" withParameters:@[error]]);
    [self waitForObject:userMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client throwError:error forScope:@"test-error" from:user propagateFlow:CEExceptionPropagationFlow.direct];
    }];
}

- (void)testThrowError_ShouldEmitErrorByObjectAndClient_WhenMiddlewarePropagationFlowUsed {
   
    self.usesMockedObjects = YES;
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    CENUser *user = self.client.User(@"exception-tester").create();
    NSArray *clientExpectedParameters = @[user, error];
    
    
    id userMock = [self mockForObject:user];
    OCMExpect([self.client emitEventLocally:@"$.error.test-error" withParameters:clientExpectedParameters]);
    OCMExpect([userMock emitEventLocally:@"$.error.test-error" withParameters:@[error]]).andForwardToRealObject();
    
    [self.client throwError:error forScope:@"test-error" from:user propagateFlow:CEExceptionPropagationFlow.middleware];
    
    OCMVerifyAll((id)self.client);
    OCMVerifyAll(userMock);
}

- (void)testThrowError_ShouldThrow_WhenClientConfiguredForExpections {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    CENUser *user = self.client.User(@"exception-tester").create();
    
    XCTAssertThrowsSpecificNamed([self.client throwError:error forScope:@"test-error" from:user
                                           propagateFlow:CEExceptionPropagationFlow.direct],
                                 NSException, error.domain);
    
}

#pragma mark -


@end
