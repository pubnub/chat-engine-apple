/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENEventEmitter+BuilderInterface.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENEventEmitterTest : CENTestCase

#pragma mark - Information

@property (nonatomic, nullable, strong) CENEventEmitter *emitter;

#pragma mark -


@end


@implementation CENEventEmitterTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.emitter = [CENEventEmitter new];
}

- (void)tearDown {
    
    [self.emitter destruct];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    XCTAssertNotNil([CENEventEmitter new]);
}


#pragma mark - Tests :: Property :: eventNames

- (void)testThat_EmptyEventHandlersList_WhenRegisteredHandler_ThenEventNamesListShouldContainOneEvent {
    
    NSArray<NSString *> *expected = @[@"test-event"];
    
    self.emitter.on(@"test-event", ^{});
    
    XCTAssertEqualObjects(self.emitter.eventNames, expected);
    XCTAssertEqual(self.emitter.eventNames.count, 1);
}

- (void)testThat_AfterHandlerRegistered_WhenRemovedRegisteredHandler_ThenEventNamesListShouldBeEmpty {
    
    dispatch_block_t handler = ^{};
    NSArray<NSString *> *expected = @[];
    self.emitter.on(@"test-event", handler);
    
    XCTAssertEqual(self.emitter.eventNames.count, 1);
    self.emitter.off(@"test-event", handler);
    
    XCTAssertEqualObjects(self.emitter.eventNames, expected);
}


#pragma mark - Tests :: Property :: on

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithSameName_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    self.emitter.on(@"test-event", ^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithDifferentFromRegistered_ThenHandlerNotCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerNotCalled = YES;
    self.emitter.on(@"test-event1", ^{
        handlerNotCalled = NO;
    });
    
    [self.emitter emitEventLocally:@"test-event2", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerNotCalled);
}

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithSingleData_ThenReceiveData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected = @"1";
    self.emitter.on(@"test.event", ^(id parameter1) {
        XCTAssertEqualObjects(parameter1, expected);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expected, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
}

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithFourData_ThenReceiveData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected1 = @"1";
    NSString *expected2 = @"2";
    NSString *expected3 = @"3";
    NSString *expected4 = @"4";
    self.emitter.on(@"test.event", ^(id parameter1, id parameter2, id parameter3, id parameter4) {
        XCTAssertEqualObjects(parameter1, expected1);
        XCTAssertEqualObjects(parameter2, expected2);
        XCTAssertEqualObjects(parameter3, expected3);
        XCTAssertEqualObjects(parameter4, expected4);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expected1, expected2, expected3, expected4, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
}

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithFiveData_ThenReceiveData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected1 = @"1";
    NSString *expected2 = @"2";
    NSString *expected3 = @"3";
    NSString *expected4 = @"4";
    NSString *expected5 = @"5";
    self.emitter.on(@"test.event", ^(id parameter1, id parameter2, id parameter3, id parameter4, id parameter5) {
        XCTAssertEqualObjects(parameter1, expected1);
        XCTAssertEqualObjects(parameter2, expected2);
        XCTAssertEqualObjects(parameter3, expected3);
        XCTAssertEqualObjects(parameter4, expected4);
        XCTAssertEqualObjects(parameter5, expected5);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expected1, expected2, expected3, expected4, expected5, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
}

- (void)testThat_HandlerRegisteredOnEventWithSingleWildcard_WhenEmittedEventWithOneSubstitution_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    self.emitter.on(@"test.*", ^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerNotCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerNotCalled = YES;
    self.emitter.on(@"test.*", ^{
        handlerNotCalled = NO;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerNotCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleWildcard_WhenEmittedEventWithData_ThenReceiveConcreteEventNameAndData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test.event";
    NSString *expectedValue = @"1";
    self.emitter.on(@"test.*", ^(NSString *event, id parameter) {
        XCTAssertEqualObjects(event, expectedEvent);
        XCTAssertEqualObjects(parameter, expectedValue);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expectedValue, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
}

- (void)testThat_HandlerRegisteredOnEventWithMultipleWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    self.emitter.on(@"test.**", ^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleAndMultipleWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1Called = NO;
    __block BOOL handler2Called = NO;
    self.emitter.on(@"test.**", ^{
        handler1Called = YES;
    });
    self.emitter.on(@"test.event.*", ^{
        handler2Called = YES;
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(handler1Called);
    XCTAssertTrue(handler2Called);
}


#pragma mark - Tests :: Property :: onAny / wildcard

- (void)testThat_HandlerRegisteredOnWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    self.emitter.on(@"*", ^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredWithAny_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    self.emitter.onAny(^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnWildcard_WhenEmittedEventWithData_ThenReceiveConcreteEventNameSenderAndData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test.event";
    NSString *expectedValue = @"1";
    self.emitter.onAny(^(NSString *event, id parameter) {
        XCTAssertEqualObjects(event, expectedEvent);
        XCTAssertEqualObjects(parameter, expectedValue);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expectedValue, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
}

- (void)testThat_HandlerRegisteredOnWildcard_WhenEmittedEventWithDataWhichIncludeEmitter_ThenReceiveDataWithOnlyOneEmitterReferenceInIt {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test.event";
    NSString *expectedValue = @"1";
    self.emitter.onAny(^(NSString *event, id emittedBy, id parameter) {
        XCTAssertEqualObjects(event, expectedEvent);
        XCTAssertEqualObjects(emittedBy, self.emitter);
        XCTAssertEqualObjects(parameter, expectedValue);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", self.emitter, expectedValue, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
}


#pragma mark - Tests :: Property :: once

- (void)testThat_RegisteredHandler_WhenEmittedEvent_ThenHandlerCalledAndRemovedFromObserversList {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray<NSString *> *expected = @[];
    __block BOOL calledOnce = NO;
    __block BOOL calledTwice = NO;
    self.emitter.once(@"test-event", ^{
        if (calledOnce) {
            calledTwice = YES;
        }
        
        calledOnce = YES;
    });
    
    [self.emitter emitEventLocally:@"test-event", nil];
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertEqualObjects(self.emitter.eventNames, expected);
    XCTAssertFalse(calledTwice);
    XCTAssertTrue(calledOnce);
}


#pragma mark - Tests :: Property :: off

- (void)testThat_RegisteredHandler_WhenHandlerRemoved_ThenHandlerRemovedFromObserversList {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray<NSString *> *expected = @[];
    __block BOOL calledOnce = NO;
    __block BOOL calledTwice = NO;
    dispatch_block_t handler = ^{
        if (calledOnce) {
            calledTwice = YES;
        }
        
        calledOnce = YES;
    };
    self.emitter.on(@"test-event", handler);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.off(@"test-event", handler);
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertEqualObjects(self.emitter.eventNames, expected);
    XCTAssertFalse(calledTwice);
    XCTAssertTrue(calledOnce);
}

- (void)testThat_RegisteredTwoHandlers_WhenOneHandlerRemoved_ThenAnotherHandlerShouldStayInList {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray<NSString *> *expected = @[@"test-event"];
    __block BOOL handler1CalledOnce = NO;
    __block BOOL handler1CalledTwice = NO;
    __block BOOL handler2CalledOnce = NO;
    __block BOOL handler2CalledTwice = NO;
    dispatch_block_t handler1 = ^{
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    dispatch_block_t handler2 = ^{
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
        }
        
        handler2CalledOnce = YES;
    };
    
    self.emitter.on(@"test-event", handler1);
    self.emitter.on(@"test-event", handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.off(@"test-event", handler1);
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertEqualObjects(self.emitter.eventNames, expected);
    XCTAssertTrue(handler1CalledOnce);
    XCTAssertFalse(handler1CalledTwice);
    XCTAssertTrue(handler2CalledOnce);
    XCTAssertTrue(handler2CalledTwice);
}


#pragma mark - Tests :: Property :: offAny

- (void)testThat_RegisteredTwoHandlersOnWildcardEvents_WhenOneHandlerRemoved_ThenAnotherHandlerShouldStayInList {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1CalledOnce = NO;
    __block BOOL handler1CalledTwice = NO;
    __block BOOL handler2CalledOnce = NO;
    __block BOOL handler2CalledTwice = NO;
    dispatch_block_t handler1 = ^{
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    dispatch_block_t handler2 = ^{
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
        }
        
        handler2CalledOnce = YES;
    };
    self.emitter.onAny(handler1);
    self.emitter.onAny(handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.offAny(handler1);
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(handler1CalledOnce);
    XCTAssertFalse(handler1CalledTwice);
    XCTAssertTrue(handler2CalledOnce);
    XCTAssertTrue(handler2CalledTwice);
}


#pragma mark - Tests :: Property :: removeAll

- (void)testThat_RegisteredTwoHandlersForSameEvent_WhenEventRemoveAllListeners_ThenEventsListShouldBeEmpty {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1CalledOnce = NO;
    __block BOOL handler1CalledTwice = NO;
    __block BOOL handler2CalledOnce = NO;
    __block BOOL handler2CalledTwice = NO;
    dispatch_block_t handler1 = ^{
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    dispatch_block_t handler2 = ^{
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
        }
        
        handler2CalledOnce = YES;
    };
    self.emitter.on(@"test-event", handler1);
    self.emitter.on(@"test-event", handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.removeAll(@"test-event");
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(handler1CalledOnce);
    XCTAssertFalse(handler1CalledTwice);
    XCTAssertTrue(handler2CalledOnce);
    XCTAssertFalse(handler2CalledTwice);
}

- (void)testThat_RegisteredTwoHandlersForWildcardEvent_WhenEventRemoveAllListeners_ThenEventsListShouldBeEmpty {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1CalledOnce = NO;
    __block BOOL handler1CalledTwice = NO;
    __block BOOL handler2CalledOnce = NO;
    __block BOOL handler2CalledTwice = NO;
    dispatch_block_t handler1 = ^{
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    dispatch_block_t handler2 = ^{
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
        }
        
        handler2CalledOnce = YES;
    };
    self.emitter.on(@"*", handler1);
    self.emitter.on(@"*", handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.removeAll(@"*");
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(handler1CalledOnce);
    XCTAssertFalse(handler1CalledTwice);
    XCTAssertTrue(handler2CalledOnce);
    XCTAssertFalse(handler2CalledTwice);
}




- (void)testThat_RegisteredTwoHandlersForEventWithPath_WhenEventRemoveAllListenersWithPartialEvent_ThenEventsListShouldBeEmpty {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1Called = NO;
    __block BOOL handler2Called = NO;
    dispatch_block_t handler1 = ^{
        handler1Called = YES;
    };
    dispatch_block_t handler2 = ^{
        handler2Called = YES;
    };
    self.emitter.on(@"test.event1", handler1);
    self.emitter.on(@"test.event2", handler2);
    
    [self.emitter emitEventLocally:@"test.event1", nil];
    self.emitter.removeAll(@"test.*");
    [self.emitter emitEventLocally:@"test.event2", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(handler1Called);
    XCTAssertFalse(handler2Called);
}

- (void)testThat_RegisteredTwoHandlersForEventWithPath_WhenEventRemoveAllListenersWithMultiPartialEvent_ThenEventsListShouldBeEmpty {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1Called = NO;
    __block BOOL handler2Called = NO;
    dispatch_block_t handler1 = ^{
        handler1Called = YES;
    };
    dispatch_block_t handler2 = ^{
        handler2Called = YES;
    };
    self.emitter.on(@"test.*", handler1);
    self.emitter.on(@"test.event.2", handler2);
    
    [self.emitter emitEventLocally:@"test.event1", nil];
    self.emitter.removeAll(@"test.*");
    self.emitter.removeAll(@"test.**");
    [self.emitter emitEventLocally:@"test.event.2", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(handler1Called);
    XCTAssertFalse(handler2Called);
}



#pragma mark -


@end
