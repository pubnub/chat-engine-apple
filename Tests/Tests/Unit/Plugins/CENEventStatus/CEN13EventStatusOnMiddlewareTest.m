/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENEventStatusOnMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <CENChatEngine/CENEventStatusPlugin.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENEvent+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN13EventStatusOnMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEventStatusOnMiddleware *middleware;
@property (nonatomic, nullable, strong) CENEvent *event;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


@implementation CEN13EventStatusOnMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return ([name rangeOfString:@"testEvents_ShouldBeSetToWildcard"].location == NSNotFound &&
            [name rangeOfString:@"testLocation_ShouldBeSetToOn"].location == NSNotFound);
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.chat = [self publicChatWithChatEngine:self.client];
    id object = self.chat;
    
    if ([self.name rangeOfString:@"OnEventEmit"].location != NSNotFound) {
        self.event = [CENEvent eventWithName:@"message" chat:self.chat chatEngine:self.client];
        object = self.event;
    }
    
    self.middleware = [CENEventStatusOnMiddleware middlewareForObject:object withIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENEventStatusOnMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENEventStatusOnMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: Event emitted

- (void)testEventSent_ShouldNotifyOnEventEmit {
    
    NSDictionary *eventStatusData = @{ CENEventStatusData.identifier: [NSUUID UUID].UUIDString };
    NSMutableDictionary *payload = [@{ CENEventStatusData.data: eventStatusData } mutableCopy];
    NSDictionary *expectedPayload = @{ CENEventData.data: eventStatusData };

    
    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client triggerEventLocallyFrom:self.chat event:@"$.eventStatus.sent"
                                                  withParameters:@[expectedPayload] completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"$.emitted" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testEventSent_ShouldNotNotifyOnEventEmit_WhenEventStatusDataIsMissing {
    
    NSMutableDictionary *payload = [@{ } mutableCopy];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect triggerEventLocallyFrom:self.chat event:@"$.eventStatus.sent"
                                                  withParameters:[OCMArg any] completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"$.emitted" withData:payload completion:^(BOOL rejected) { }];
    }];
}


#pragma mark - Tests :: Event delivered

- (void)testEventDelivered_ShouldNotifyOnEvent {
    
    CENMe *user = [CENMe userWithUUID:[NSUUID UUID].UUIDString state:@{} chatEngine:self.client];
    NSDictionary *eventStatusData = @{ CENEventStatusData.identifier: [NSUUID UUID].UUIDString };
    NSMutableDictionary *payload = [@{
        CENEventData.sender: user,
        CENEventStatusData.data: eventStatusData
    } mutableCopy];
    
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$.eventStatus.delivered" withData:eventStatusData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"some-event" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testEventDelivered_ShouldNotNotifyOnEvent_WhenPayloadSentNotByLocalUser {
    
    CENUser *user = [CENUser userWithUUID:[NSUUID UUID].UUIDString state:@{} chatEngine:self.client];
    NSDictionary *eventStatusData = @{ CENEventStatusData.identifier: [NSUUID UUID].UUIDString };
    NSMutableDictionary *payload = [@{
        CENEventData.sender: user,
        CENEventStatusData.data: eventStatusData
    } mutableCopy];
    
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$.eventStatus.delivered" withData:eventStatusData]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"some-event" withData:payload completion:^(BOOL rejected) { }];
    }];
}

#pragma mark -


@end
