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


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, weak) CENChatEngine *throwableClient;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineEventEmitterTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.throwExceptions = YES;
    self.throwableClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    configuration.throwExceptions = NO;
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.throwableClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.defaultClient createGlobalChat];
}

- (void)tearDown {
    
    [self.throwableClient destroy];
    self.throwableClient = nil;
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: triggerEventLocallyFrom

- (void)testTriggerEventLocallyFrom_ShouldCallDesignatedMethod {
    
    NSString *expectedData = @"ChatEngine";
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    
    OCMExpect([self.defaultClient triggerEventLocallyFrom:self.defaultClient event:expectedEvent withParameters:expectedPasrameters
                                               completion:[OCMArg any]]);
    
    [self.defaultClient triggerEventLocallyFrom:self.defaultClient event:expectedEvent, expectedData, nil];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: triggerEventLocallyFromWithParameters

- (void)testTriggerEventLocallyFromWithParameters_ShouldEmitEventWithOutMiddlewareHandling_WhenNonNSDictionaryParameterPassed {
    
    NSString *expectedData = @"ChatEngine";
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient emitEventLocally:expectedEvent withParameters:expectedPasrameters]);
    
    [self.defaultClient triggerEventLocallyFrom:self.defaultClient event:expectedEvent withParameters:expectedPasrameters
                                     completion:^(NSString *event, id payload, BOOL rejected) {
        handlerCalled = YES;
    }];
    
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldAddReferenceOnChat_WhenEmittingObjectIsCENChat {
    
    CENChat *chat = self.defaultClient.global;
    NSDictionary *expectedData = @{ @"test": @"data" };
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    __block BOOL handlerCalled = NO;
    
    [self.defaultClient triggerEventLocallyFrom:chat event:expectedEvent withParameters:expectedPasrameters
                                     completion:^(NSString *event, NSArray<NSDictionary *> *updatedParameters, BOOL rejected) {
                                         
        handlerCalled = YES;
                                         
        XCTAssertNotNil(updatedParameters.firstObject[CENEventData.chat]);
        XCTAssertEqual(updatedParameters.firstObject[CENEventData.chat], chat);
    }];
    
    XCTAssertTrue(handlerCalled);
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldReplaceFirstParameter_WhenNSDictionaryPassed {
    
    CENChat *chat = self.defaultClient.global;
    NSDictionary *expectedData = @{ @"test": @"data", CENEventData.chat: chat };
    NSArray *expectedPasrameters = @[expectedData, @"Hello"];
    NSDictionary *data = @{ @"test": @"data" };
    NSString *expectedEvent = @"test-event";
    NSArray *pasrameters = @[data, @"Hello"];
    __block BOOL handlerCalled = NO;
    
    [self.defaultClient triggerEventLocallyFrom:chat event:expectedEvent withParameters:pasrameters
                                     completion:^(NSString *event, NSArray<NSDictionary *> *updatedParameters, BOOL rejected) {
                                         
        handlerCalled = YES;
                                         
        XCTAssertEqualObjects(event, expectedEvent);
        XCTAssertFalse(rejected);
        XCTAssertEqualObjects(updatedParameters, expectedPasrameters);
    }];
    
    XCTAssertTrue(handlerCalled);
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldFetchUser_WhenUserUUIDPassed {
    
    NSDictionary *expectedData = @{ @"test": @"data", CENEventData.sender: @"tester-user" };
    CENUser *user = self.defaultClient.User(@"remoter").create();
    id userPartialMock = [self partialMockForObject:user];
    NSArray *expectedPasrameters = @[expectedData];
    CENChat *chat = self.defaultClient.global;
    NSString *expectedEvent = @"test-event";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient createUserWithUUID:[OCMArg any] state:[OCMArg any]]).andReturn(userPartialMock);
    
    OCMStub([userPartialMock fetchStoredStateWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *storedStatFetchInvocation) {
        void(^handlerBlock)(NSDictionary *) = nil;
        
        [storedStatFetchInvocation getArgument:&handlerBlock atIndex:2];
        handlerBlock(nil);
    });
    
    [self.defaultClient triggerEventLocallyFrom:chat event:expectedEvent withParameters:expectedPasrameters
                                     completion:^(NSString *event, NSArray<NSDictionary *> *updatedParameters, BOOL rejected) {
                                         
        handlerCalled = YES;

        XCTAssertNotNil(updatedParameters.firstObject[CENEventData.sender]);
        XCTAssertTrue([updatedParameters.firstObject[CENEventData.sender] isKindOfClass:[CENUser class]]);
        XCTAssertEqual(updatedParameters.firstObject[CENEventData.sender], userPartialMock);
    }];
    
    XCTAssertTrue(handlerCalled);
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldNotAddReferenceOnChat_WhenEmittingObjectIsNotCENChat {
    
    CENUser *user = self.defaultClient.User(@"tester-user").create();
    NSDictionary *expectedData = @{ @"test": @"data" };
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    __block BOOL handlerCalled = NO;

    [self.defaultClient triggerEventLocallyFrom:user event:expectedEvent withParameters:expectedPasrameters
                                     completion:^(NSString *event, id updatedParameters, BOOL rejected) {
                                         
        handlerCalled = YES;
        XCTAssertEqualObjects(updatedParameters, expectedPasrameters);
    }];
    
    XCTAssertTrue(handlerCalled);
}

- (void)testTriggerEventLocallyFromWithParameters_ShouldHandleMiddlewareRejection {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *user = self.defaultClient.User(@"tester-user").create();
    NSDictionary *expectedData = @{ @"test": @"data" };
    NSArray *expectedPasrameters = @[expectedData];
    NSString *expectedEvent = @"test-event";
    __block BOOL handlerCalled = NO;
    
    OCMStub([pluginsManagerPartialMock runMiddlewaresAtLocation:[OCMArg any] forEvent:expectedEvent object:user withPayload:[OCMArg any]
                                                     completion:[OCMArg any]])
        .andDo(^(NSInvocation *middlewareInvocation) {
            void(^handlerBlock)(BOOL) = nil;
            
            [middlewareInvocation getArgument:&handlerBlock atIndex:6];
            handlerBlock(YES);
        });
    
    [self.defaultClient triggerEventLocallyFrom:user event:expectedEvent withParameters:expectedPasrameters
                                     completion:^(NSString *event, id updatedParameters, BOOL rejected) {
                                         
        handlerCalled = YES;
                                         
        XCTAssertEqualObjects(event, expectedEvent);
        XCTAssertTrue(rejected);
        XCTAssertNil(updatedParameters);
    }];
    
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: throwError

- (void)testThrowError_ShouldEmitErrorByClient {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    
    OCMExpect([self.defaultClient emitEventLocally:@"$.error.test-error" withParameters:@[error]]);
    
    [self.defaultClient throwError:error forScope:@"test-error" from:nil propagateFlow:CEExceptionPropagationFlow.direct];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testThrowError_ShouldEmitErrorByObject_WhenDirectPropagationFlowUsed {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    CENUser *user = self.defaultClient.User(@"exception-tester").create();
    id userPartialMock = [self partialMockForObject:user];
    
    OCMExpect([userPartialMock emitEventLocally:@"$.error.test-error" withParameters:@[error]]);
    
    [self.defaultClient throwError:error forScope:@"test-error" from:user propagateFlow:CEExceptionPropagationFlow.direct];
    
    OCMVerifyAll(userPartialMock);
}

- (void)testThrowError_ShouldEmitErrorByObjectAndClient_WhenMiddlewarePropagationFlowUsed {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    CENUser *user = self.defaultClient.User(@"exception-tester").create();
    id userPartialMock = [self partialMockForObject:user];
    NSArray *clientExpectedParameters = @[user, error];
    
    OCMExpect([self.defaultClient emitEventLocally:@"$.error.test-error" withParameters:clientExpectedParameters]);
    OCMExpect([userPartialMock emitEventLocally:@"$.error.test-error" withParameters:@[error]]).andForwardToRealObject();
    
    [self.defaultClient throwError:error forScope:@"test-error" from:user propagateFlow:CEExceptionPropagationFlow.middleware];
    
    OCMVerifyAll((id)self.defaultClient);
    OCMVerifyAll(userPartialMock);
}

- (void)testThrowError_ShouldThrow_WhenClientConfiguredForExpections {
    
    NSError *error = [NSError errorWithDomain:kCENErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"TestError" }];
    CENUser *user = self.defaultClient.User(@"exception-tester").create();
    
    XCTAssertThrowsSpecificNamed([self.throwableClient throwError:error forScope:@"test-error" from:user propagateFlow:CEExceptionPropagationFlow.direct],
                                 NSException, error.domain);
    
}

#pragma mark -


@end
