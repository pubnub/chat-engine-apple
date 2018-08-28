/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEPMiddleware (ProtectedTest)

#pragma mark - Information

@property (nonatomic, strong) NSMutableArray<NSString *> *ignoredEvents;
@property (nonatomic, strong) NSMutableArray<NSString *> *checkedEvents;

#pragma mark -


@end


@interface CEPMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) id middlewareClassMock;


#pragma mark -


@end


@implementation CEPMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.middlewareClassMock = [self mockForClass:[CEPMiddleware class]];
}


#pragma mark - Tests :: Information

- (void)testLocations_ShouldReturnListOfAllowedLocations {
    
    NSArray *expected = @[CEPMiddlewareLocation.emit, CEPMiddlewareLocation.on];
    NSArray *locations = [CEPMiddleware locations];
    
    XCTAssertNotNil(locations);
    XCTAssertEqualObjects(locations, expected);
}

- (void)testLocation_ShouldThrow {
    
    XCTAssertThrows([CEPMiddleware location]);
}

- (void)testEvents_ShouldThrow {
    
    XCTAssertThrows([CEPMiddleware events]);
}

- (void)testReplaceEventsWith_ShouldNotThrowException_WhenAccessedEvents {
    
    [CEPMiddleware replaceEventsWith:@[]];
    
    XCTAssertNoThrow([CEPMiddleware events]);
}

- (void)testReplaceEventsWith_ShouldReturnNewEvents {
    
    NSArray *expected = @[@"test.event.1", @"test.event.2"];
    
    [CEPMiddleware replaceEventsWith:expected];
    
    XCTAssertEqualObjects([CEPMiddleware events], expected);
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldReturnMiddlewareInstance_WhenAllInformationPassed {
    
    NSDictionary *configuration = @{ @"test": @"configuration" };
    NSString *identifier = @"test";
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:identifier configuration:configuration];
    
    XCTAssertNotNil(middleware);
    XCTAssertEqualObjects(middleware.identifier, identifier);
    XCTAssertEqualObjects(middleware.configuration, configuration);
}

- (void)testConstructor_ShouldReturnNil_WhenNilIdentifierPassed {
    
    NSString *identifier = nil;
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    XCTAssertNil([CEPMiddleware middlewareWithIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenEmptyIdentifierPassed {
    
    NSString *identifier = @"";
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    XCTAssertNil([CEPMiddleware middlewareWithIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenNonNSStringPassed {
    
    NSString *identifier = (id)@2010;
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    XCTAssertNil([CEPMiddleware middlewareWithIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenNonNSDictionaryPassed {
    
    NSDictionary *configuration = (id)@2010;
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(middleware);
    XCTAssertEqualObjects(middleware.configuration, @{});
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenConfigurationNotPassed {
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(middleware);
    XCTAssertEqualObjects(middleware.configuration, @{});
}


#pragma mark - Tests :: runForEvent

- (void)testRunForEvent_ShouldCallCompletionBlockWithNO {
    
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.middlewareClassMock events]).andReturn(@[]);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    [middleware runForEvent:@"event" withData:[@{} mutableCopy] completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertFalse(rejected);
    }];
    
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: registeredForEvent

- (void)testRegisteredForEvent_ShouldReturnYESForEventFromClassEvents {
    
    NSArray *events = @[@"test-event-3", @"test-event-4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertTrue([middleware registeredForEvent:@"test-event-4"]);
}

- (void)testRegisteredForEvent_ShouldReturnYESForAnyEvents_WhenClassEventsContainWildcard {
    
    NSArray *events = @[@"*"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertTrue([middleware registeredForEvent:@"test-event-4"]);
}

- (void)testRegisteredForEvent_ShouldReturnNOForEvent_WhenPassedNotInClassEvents {
    
    NSArray *events = @[@"test-event-3", @"test-event-4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertFalse([middleware registeredForEvent:@"test-event-5"]);
}

- (void)testRegisteredForEvent_ShouldReturnYESForEventPathEvent_WhenEqualToClassEvents {
    
    NSArray *events = @[@"test.event.3", @"test.event.4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertTrue([middleware registeredForEvent:@"test.event.4"]);
}

- (void)testRegisteredForEvent_ShouldReturnYESForEventPathEvent_WhenMatchClassEventWithSingleWildcard {
    
    NSArray *events = @[@"test.event.*", @"test.event.4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertTrue([middleware registeredForEvent:@"test.event.8"]);
}

- (void)testRegisteredForEvent_ShouldReturnYESForEventPathEvent_WhenMatchClassEventWithDoubleWildcard {
    
    NSArray *events = @[@"test.**", @"test.event.4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertTrue([middleware registeredForEvent:@"test.event1.816"]);
}

- (void)testRegisteredForEvent_ShouldReturnNOForEventPathEvent_WhenPathShorterThanClassEvents {
    
    NSArray *events = @[@"test.event.3", @"test.event.4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertFalse([middleware registeredForEvent:@"test.event"]);
}

- (void)testRegisteredForEvent_ShouldReturnNOForEventPathEvent_WhenPathLongerThanClassEvents {
    
    NSArray *events = @[@"test.*", @"test.event.4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    
    XCTAssertFalse([middleware registeredForEvent:@"test.event.5"]);
}

- (void)testRegisteredForEvent_ShouldStoreMatchResultsOnce_WhenCalledFewTimesForSameEvent {
    
    NSArray *events = @[@"test-event-3", @"test-event-4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    [middleware registeredForEvent:@"test-event-4"];
    [middleware registeredForEvent:@"test-event-4"];
    
    XCTAssertEqual(middleware.checkedEvents.count, 1);
}

- (void)testRegisteredForEvent_ShouldStoreInIgnoredEvents_WhenEventNotInClassEvents {
    
    NSArray *events = @[@"test-event-3", @"test-event-4"];
    
    OCMStub([self.middlewareClassMock events]).andReturn(events);
    
    CEPMiddleware *middleware = [CEPMiddleware middlewareWithIdentifier:@"test" configuration:nil];
    [middleware registeredForEvent:@"test-event-5"];
    
    XCTAssertEqual(middleware.checkedEvents.count, 1);
    XCTAssertEqual(middleware.ignoredEvents.count, 1);
}

#pragma mark -


@end
