/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENEventStatusEmitMiddleware.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <CENChatEngine/CENEventStatusPlugin.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN13EventStatusEmitMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEventStatusEmitMiddleware *middleware;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


#pragma mark - Tests

@implementation CEN13EventStatusEmitMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return ([name rangeOfString:@"testEventCreated_ShouldNotifyOnEmit_WhenNewEventIsEmitting"].location != NSNotFound ||
            [name rangeOfString:@"testEventCreated_ShouldNotNotifyOnEmit_WhenPayloadAlreadyHasEventStatusData"].location != NSNotFound);
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.chat = [self publicChatWithChatEngine:self.client];
    self.middleware = [CENEventStatusEmitMiddleware middlewareForObject:self.chat withIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENEventStatusEmitMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENEventStatusEmitMiddleware.location, CEPMiddlewareLocation.emit);
}


#pragma mark - Tests :: Event emitting

- (void)testEventCreated_ShouldAddEventStatusInformation {
    
    NSMutableDictionary *payload = [@{ CENEventData.eventID: [NSUUID UUID].UUIDString } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) {
            XCTAssertNotNil(payload[CENEventStatusData.data]);
            XCTAssertNotNil(payload[CENEventStatusData.data][CENEventStatusData.identifier]);
            handler();
        }];
    }];
}

- (void)testEventCreated_ShouldNotifyOnEmit_WhenNewEventIsEmitting {
    
    NSMutableDictionary *payload = [@{ CENEventData.eventID: [NSUUID UUID].UUIDString } mutableCopy];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client triggerEventLocallyFrom:self.chat event:@"$.eventStatus.created"
                                                  withParameters:[OCMArg any] completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testEventCreated_ShouldNotReplaceEventStatusInformation_WhenPayloadAlreadyHasIt {
    
    NSDictionary *eventStatusData = @{ CENEventStatusData.identifier: [NSUUID UUID].UUIDString };
    NSMutableDictionary *payload = [@{ CENEventStatusData.data: eventStatusData } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload[CENEventStatusData.data], eventStatusData);
            handler();
        }];
    }];
}

- (void)testEventCreated_ShouldNotNotifyOnEmit_WhenPayloadAlreadyHasEventStatusData {
    
    NSDictionary *eventStatusData = @{ CENEventStatusData.identifier: [NSUUID UUID].UUIDString };
    NSMutableDictionary *payload = [@{ CENEventStatusData.data: eventStatusData } mutableCopy];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect triggerEventLocallyFrom:self.chat event:@"$.eventStatus.created"
                                                  withParameters:[OCMArg any] completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) { }];
    }];
}

#pragma mark -


@end
