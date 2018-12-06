/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import "CEDummyPlugin.h"


#pragma mark Constants

static BOOL const kCENTShouldPublishTestMessages = NO;
static NSUInteger const kCENTPublishedMessagesCount = 250;


#pragma mark - Interface declaration

@interface CENChatEngineHistoryIntegrationTest: CENTestCase


#pragma mark - Misc

- (void)publishTestMessages;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineHistoryIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return [self.name rangeOfString:@"testSearch_AddMessagesToChat_WhenRecordingNewCassette"].location == NSNotFound;
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {

    return YES;
}

- (NSString *)globalChatChannelForTestCaseWithName:(NSString *)name {
    
    return @"global";
}

- (NSString *)namespaceForTestCaseWithName:(NSString *)name {
    
    return @"namespace";
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {

    return @{ @"works": @YES };
}

- (void)setUp {
    
    [super setUp];


    [self setupChatEngineForUser:@"robot-stephen"];
}

- (void)testSearch_AddMessagesToChat_WhenRecordingNewCassette {
    
    if (kCENTShouldPublishTestMessages) {
        NSString *fixturesPath = @"/Volumes/Develop/Projects/Xcode/PubNub/chat-engine-apple/Tests/Tests/Fixtures";
        NSString *cassette = [NSStringFromClass([self class]) stringByAppendingPathExtension:@"bundle"];
        NSString *cassettesPath = [fixturesPath stringByAppendingPathComponent:cassette];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cassettesPath isDirectory:nil]) {
            [self publishTestMessages];
        }
    }
}

- (void)testSearch_ShouldFetch50SpecificEvents_WhenLimitAndEventNameIsSet {

    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block NSUInteger foundEventsCount = 0;
    NSUInteger expectedEventsCount = 50;
    __block CENChat *chat = nil;


    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];

    CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(foundEventsCount, expectedEventsCount);
            XCTAssertFalse(search.hasMore);
            handler();
        };
    } afterBlock:^{
        search.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            foundEventsCount++;

            XCTAssertEqualObjects(payload[CENEventData.event], @"tester");
            XCTAssertNotNil(payload[CENEventData.timetoken]);
        });
    }];
}

- (void)testSearch_ShouldFetch200SpecificEvents_WhenLimitEventNameAndPagesIsSet {

    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block NSUInteger foundEventsCount = 0;
    NSUInteger expectedEventsCount = 200;
    __block CENChat *chat = nil;


    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];

    CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).pages(11).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(foundEventsCount, expectedEventsCount);
            XCTAssertFalse(search.hasMore);
            handler();
        };
    } afterBlock:^{
        search.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            foundEventsCount++;
        });
    }];
}

- (void)testSearch_ShouldFetch10LatestEvents_WhenLimitAndPagesIsSet {

    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block BOOL handlerCalled = NO;
    __block CENChat *chat = nil;


    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];

    CENSearch *search = chat.search().limit(10).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(search.hasMore);
            XCTAssertTrue(handlerCalled);
            handler();
        };
    } afterBlock:^{
        search.search().once(@"tester", ^(CENEmittedEvent *emittedEvent) {
            handlerCalled = YES;
        });
    }];
}

- (void)testSearch_ShouldNotFetchEvents_WhenUnknownSenderSpecified {

    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block BOOL handlerCalled = NO;
    __block CENChat *chat = nil;


    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];

    CENUser *user = client.User(@"stephen").create();
    CENSearch *search = chat.search().sender(user).limit(10).pages(1).create();
    [self object:search shouldHandleEvent:@"$.search.pause" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertFalse(handlerCalled);
            handler();
        };
    } afterBlock:^{
        search.search().once(@"tester", ^(CENEmittedEvent *emittedEvent) {
            handlerCalled = YES;
        });
    }];
}

- (void)testSearch_ShouldEmitEventsInDescendingOrder_WhenSearchingForEvents {

    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block CENChat *chat = nil;


    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];

    CENSearch *search = chat.search().event(@"tester").limit(10).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertGreaterThan(timetokens.count, 0);
            XCTAssertEqual([timetokens.firstObject compare:timetokens.lastObject], NSOrderedDescending);
            XCTAssertFalse(search.hasMore);
            handler();
        };
    } afterBlock:^{
        search.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [timetokens addObject:payload[CENEventData.timetoken]];
        });
    }];
}

- (void)testSearch_ShouldFetchEventsIgnoringLimit_WhenSearchingForEventsBetweenDates {
    
    NSMutableArray<NSDictionary *> *messages = [NSMutableArray new];
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block CENChat *chat = nil;
    
    
    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];
    
    CENSearch *search = chat.search().event(@"tester").limit(100).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertGreaterThan(timetokens.count, 0);
            handler();
        };
    } afterBlock:^{
        search.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
    }];
    
    // Search between timetokens.
    NSNumber *end = timetokens[timetokens.count - 10];
    NSNumber *start = timetokens[10];
    // -1 because start/end search exclude message at 'end' date.
    NSUInteger expectedMessagesCount = [timetokens indexOfObject:end] - [timetokens indexOfObject:start] - 1;
    
    search = chat.search().event(@"tester").limit(10).pages(14).start(start).end(end).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(messages.count - 1, expectedMessagesCount);
            XCTAssertFalse(search.hasMore);
            handler();
        };
    } afterBlock:^{
        search.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [messages insertObject:payload atIndex:0];
        });
    }];
}

- (void)testSearch_ShouldFetchEventsLimitedByPage_WhenSearhingForEventsBetweenDates {
    
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block CENChat *chat = nil;
    
    
    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];
    
    // Pull out list of event timetokens.
    CENSearch *search = chat.search().event(@"tester").limit(100).create();
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertGreaterThan(timetokens.count, 0);
            handler();
        };
    } afterBlock:^{
        search.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
    }];
    
    // Search between timetokens.
    NSNumber *end = timetokens[timetokens.count - 10];
    NSNumber *start = timetokens[10];
    
    search = chat.search().event(@"tester").pages(1).count(10).start(start).end(end).create();
    [self object:search shouldHandleEvent:@"$.search.pause" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertTrue(search.hasMore);
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldFetchEventsLimitedByPageCount {
    
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block CENChat *chat = nil;
    
    
    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];
    
    CENSearch *search = chat.search().event(@"tester").count(10).pages(1).create();
    [self object:search shouldHandleEvent:@"$.search.pause" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}


#pragma mark - Misc

- (void)publishTestMessages {
    
    dispatch_semaphore_t publishSemaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    dispatch_group_t messagePublishGroup = dispatch_group_create();
    __block CENChat *chat = nil;
    
    // Wait for connection to test chat.
    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(@"chat-history").create();
    }];
    
    CENEventHandlerBlock errorHandler = ^(CENEmittedEvent *event) {
        NSLog(@"Event publish failed with error: %@", event.data);
        
        dispatch_group_leave(messagePublishGroup);
    };
    
    NSLog(@"Publish %@ messages to '%@'", @(kCENTPublishedMessagesCount), chat.name);
    for (NSUInteger messageIdx = 0; messageIdx < kCENTPublishedMessagesCount; messageIdx++) {
        dispatch_group_enter(messagePublishGroup);
        dispatch_group_enter(messagePublishGroup);
        
        chat.emit(@"tester").data(@{ @"works": @YES, @"count": @(messageIdx) }).perform()
            .once(@"$.emitted", ^(CENEmittedEvent *event) {
                dispatch_group_leave(messagePublishGroup);
            })
            .once(@"$.error.emitter", errorHandler);
        
        chat.emit(@"not-tester").data(@{ @"works": @NO, @"count": @(messageIdx) }).perform()
            .once(@"$.emitted", ^(CENEmittedEvent *event) {
                dispatch_group_leave(messagePublishGroup);
            })
            .once(@"$.error.emitter", errorHandler);
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_notify(messagePublishGroup, queue, ^{
        NSLog(@"%@ messages has been published.", @(kCENTPublishedMessagesCount));
        
        chat.leave().once(@"$.disconnected", ^(CENEmittedEvent * __unused event) {
            dispatch_semaphore_signal(publishSemaphore);
        });
    });
    
    dispatch_semaphore_wait(publishSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    NSLog(@"Ready to start test");
}

#pragma mark -


@end
