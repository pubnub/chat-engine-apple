/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENEventEmitter+BuilderInterface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestEventEmitter.h"
#import "CENTestCase.h"


@interface CENEventEmitterTest : CENTestCase

#pragma mark - Information

@property (nonatomic, nullable, strong) CENEventEmitter *emitter;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENEventEmitterTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.emitter = [CENEventEmitter new];
}

- (void)tearDown {
    
    [self.emitter destruct];
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    XCTAssertNotNil([CENEventEmitter new]);
}


#pragma mark - Tests :: Property :: eventNames

- (void)testThat_EmptyEventHandlersList_WhenRegisteredHandler_ThenEventNamesListShouldContainOneEvent {
    
    NSArray<NSString *> *expected = @[@"test-event"];
    
    
    self.emitter.on(@"test-event", ^(CENEmittedEvent *event) {});
    
    XCTAssertEqualObjects(self.emitter.eventNames, expected);
    XCTAssertEqual(self.emitter.eventNames.count, 1);
}

- (void)testThat_AfterHandlerRegistered_WhenRegisteredForAny_ThenEventNamesListShouldIncludeWildcard {
    
    CENEventHandlerBlock handler = ^(CENEmittedEvent *event) {};
    
    
    self.emitter.on(@"test-event", handler);
    self.emitter.onAny(handler);
    
    XCTAssertEqual(self.emitter.eventNames.count, 2);
    XCTAssertTrue([self.emitter.eventNames containsObject:@"*"]);
}

- (void)testThat_AfterHandlerRegistered_WhenRemovedRegisteredHandler_ThenEventNamesListShouldBeEmpty {
    
    CENEventHandlerBlock handler = ^(CENEmittedEvent *event) {};
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
    
    
    self.emitter.on(@"test-event", ^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithDifferentFromRegistered_ThenHandlerNotCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerNotCalled = YES;
    
    
    self.emitter.on(@"test-event1", ^(CENEmittedEvent *event) {
        handlerNotCalled = NO;
    });
    
    [self.emitter emitEventLocally:@"test-event2", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerNotCalled);
}

- (void)testThat_HandlerRegisteredOnConcreteEvent_WhenEmittedEventWithSingleData_ThenReceiveData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    NSString *expected = @"1";
    
    
    self.emitter.on(@"test.event", ^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(event.data, expected);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expected, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleWildcard_WhenEmittedEventWithOneSubstitution_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    
    self.emitter.on(@"test.*", ^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerNotCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerNotCalled = YES;
    
    
    self.emitter.on(@"test.*", ^(CENEmittedEvent *event) {
        handlerNotCalled = NO;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerNotCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleWildcard_WhenEmittedEventWithData_ThenReceiveConcreteEventNameAndData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test.event";
    __block BOOL handlerCalled = NO;
    NSString *expectedValue = @"1";
    
    
    self.emitter.on(@"test.*", ^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(event.event, expectedEvent);
        XCTAssertEqualObjects(event.data, expectedValue);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expectedValue, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithMultipleWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    
    self.emitter.on(@"test.**", ^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnEventWithSingleAndMultipleWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1Called = NO;
    __block BOOL handler2Called = NO;
    
    
    self.emitter.on(@"test.**", ^(CENEmittedEvent *event) {
        handler1Called = YES;
        
        if (handler2Called) {
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    self.emitter.on(@"test.event.*", ^(CENEmittedEvent *event) {
        handler2Called = YES;
        
        if (handler1Called) {
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handler1Called);
    XCTAssertTrue(handler2Called);
}

- (void)testThat_EmitterForwarded_WhenEventEmittedByEmitterSubclass {
    
    CENTestEventEmitter *globalEmitter = [CENTestEventEmitter new];
    NSArray *data = @[@"ChatEngine", @"Test"];
    NSString *event = @"test-event";
    
    
    [self object:globalEmitter shouldHandleEvent:event withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqualObjects(emittedEvent.event, event);
            XCTAssertEqualObjects(emittedEvent.emitter, self.emitter);
            XCTAssertEqualObjects(emittedEvent.data, data);
            handler();
        };
    } afterBlock:^{
        [globalEmitter emitEventLocally:event withParameters:@[self.emitter, data]];
    }];
}


#pragma mark - Tests :: Property :: onAny / wildcard

- (void)testThat_HandlerRegisteredOnWildcard_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    
    self.emitter.on(@"*", ^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredWithAny_WhenEmittedEventWithMultipleSubstitutions_ThenHandlerCalled {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.emitter.onAny(^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event.sent", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnWildcard_WhenEmittedEventWithData_ThenReceiveConcreteEventNameSenderAndData {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test.event";
    __block BOOL handlerCalled = NO;
    NSString *expectedValue = @"1";
    
    
    self.emitter.onAny(^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(event.event, expectedEvent);
        XCTAssertEqualObjects(event.data, expectedValue);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expectedValue, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testThat_HandlerRegisteredOnWildcard_WhenEmittedEventWithDataWhichIncludeEmitter_ThenReceiveDataWithOnlyOneEmitterReferenceInIt {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test.event";
    __block BOOL handlerCalled = NO;
    NSString *expectedValue = @"1";
    
    
    self.emitter.onAny(^(CENEmittedEvent *event) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(event.event, expectedEvent);
        XCTAssertEqualObjects(event.data, expectedValue);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.emitter emitEventLocally:@"test.event", expectedValue, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Property :: once

- (void)testThat_RegisteredHandler_WhenEmittedEvent_ThenHandlerCalledAndRemovedFromObserversList {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray<NSString *> *expected = @[];
    __block BOOL calledOnce = NO;
    __block BOOL calledTwice = NO;
    
    
    self.emitter.once(@"test-event", ^(CENEmittedEvent *event) {
        if (calledOnce) {
            calledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        calledOnce = YES;
    });
    
    [self.emitter emitEventLocally:@"test-event", nil];
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
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
    
    CENEventHandlerBlock handler = ^(CENEmittedEvent *event) {
        if (calledOnce) {
            calledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        calledOnce = YES;
    };
    
    
    self.emitter.on(@"test-event", handler);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.off(@"test-event", handler);
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
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
    
    CENEventHandlerBlock handler1 = ^(CENEmittedEvent *event) {
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    
    CENEventHandlerBlock handler2 = ^(CENEmittedEvent *event) {
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        handler2CalledOnce = YES;
    };
    
    
    self.emitter.on(@"test-event", handler1);
    self.emitter.on(@"test-event", handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.off(@"test-event", handler1);
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
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
    
    CENEventHandlerBlock handler1 = ^(CENEmittedEvent *event) {
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    
    CENEventHandlerBlock handler2 = ^(CENEmittedEvent *event) {
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        handler2CalledOnce = YES;
    };
    
    
    self.emitter.onAny(handler1);
    self.emitter.onAny(handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.offAny(handler1);
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
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
    
    CENEventHandlerBlock handler1 = ^(CENEmittedEvent *event) {
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    
    CENEventHandlerBlock handler2 = ^(CENEmittedEvent *event) {
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        handler2CalledOnce = YES;
    };
    
    
    self.emitter.on(@"test-event", handler1);
    self.emitter.on(@"test-event", handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.removeAll(@"test-event");
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
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
    
    CENEventHandlerBlock handler1 = ^(CENEmittedEvent *event) {
        if (handler1CalledOnce) {
            handler1CalledTwice = YES;
        }
        
        handler1CalledOnce = YES;
    };
    
    CENEventHandlerBlock handler2 = ^(CENEmittedEvent *event) {
        if (handler2CalledOnce) {
            handler2CalledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        handler2CalledOnce = YES;
    };
    
    
    self.emitter.on(@"*", handler1);
    self.emitter.on(@"*", handler2);
    
    [self.emitter emitEventLocally:@"test-event", nil];
    self.emitter.removeAll(@"*");
    [self.emitter emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handler1CalledOnce);
    XCTAssertFalse(handler1CalledTwice);
    XCTAssertTrue(handler2CalledOnce);
    XCTAssertFalse(handler2CalledTwice);
}

- (void)testThat_RegisteredTwoHandlersForEventWithPath_WhenEventRemoveAllListenersWithPartialEvent_ThenEventsListShouldBeEmpty {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1Called = NO;
    __block BOOL handler2Called = NO;
    
    CENEventHandlerBlock handler1 = ^(CENEmittedEvent *event) {
        handler1Called = YES;
    };
    
    CENEventHandlerBlock handler2 = ^(CENEmittedEvent *event) {
        handler2Called = YES;
        
        dispatch_semaphore_signal(semaphore);
    };
    
    
    self.emitter.on(@"test.event1", handler1);
    self.emitter.on(@"test.event2", handler2);
    
    [self.emitter emitEventLocally:@"test.event1", nil];
    self.emitter.removeAll(@"test.*");
    [self.emitter emitEventLocally:@"test.event2", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handler1Called);
    XCTAssertFalse(handler2Called);
}

- (void)testThat_RegisteredTwoHandlersForEventWithPath_WhenEventRemoveAllListenersWithMultiPartialEvent_ThenEventsListShouldBeEmpty {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handler1Called = NO;
    __block BOOL handler2Called = NO;
    
    CENEventHandlerBlock handler1 = ^(CENEmittedEvent *event) {
        handler1Called = YES;
    };
    
    CENEventHandlerBlock handler2 = ^(CENEmittedEvent *event) {
        handler2Called = YES;
        
        dispatch_semaphore_signal(semaphore);
    };
    
    
    self.emitter.on(@"test.*", handler1);
    self.emitter.on(@"test.event.2", handler2);
    
    [self.emitter emitEventLocally:@"test.event1", nil];
    self.emitter.removeAll(@"test.*");
    self.emitter.removeAll(@"test.**");
    [self.emitter emitEventLocally:@"test.event.2", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handler1Called);
    XCTAssertFalse(handler2Called);
}



#pragma mark -


@end
