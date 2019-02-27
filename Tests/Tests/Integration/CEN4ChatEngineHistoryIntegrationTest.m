/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENDefines.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


#pragma mark Constants

static BOOL const kCENTShouldPublishTestMessages = NO;
static NSUInteger const kCENTPublishedMessagesCount = 250;
static NSUInteger kCENTCountableNameStart = 10;
static NSInteger kCENTEnforcedNameStart = -1;


#pragma mark - Interface declaration

@interface CEN4ChatEngineHistoryIntegrationTest: CENTestCase


#pragma mark - Information

/**
 * @brief Map of test cases to global channel names which should be used with them.
 *
 * @discussion This map filled by test cases which fill up those channels with messages.
 */
@property (class, nonatomic, readonly, strong) NSMutableDictionary *globalNamesMap;

/**
 * @brief Map of message filling test cases to names of test case for which they filled chats.
 */
@property (nonatomic, readonly, strong) NSMutableDictionary *messageAddMapToTestCase;


#pragma mark - Misc

- (void)publishTestMessages;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CEN4ChatEngineHistoryIntegrationTest


#pragma mark - Information

+ (NSMutableDictionary *)globalNamesMap {
    
    static NSMutableDictionary *_sharedGlobalNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGlobalNames = [NSMutableDictionary new];
    });
    
    return _sharedGlobalNames;
}

+ (NSMutableDictionary *)namespacesMap {
    
    static NSMutableDictionary *_sharedNamespaces;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedNamespaces = [NSMutableDictionary new];
    });
    
    return _sharedNamespaces;
}


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return [self.name rangeOfString:@"AddMessagesToChat"].location == NSNotFound;
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {

    return YES;
}

- (NSString *)globalChatChannelForTestCaseWithName:(NSString *)name {
    
    NSString *globalChatChannel = [NSString stringWithFormat:@"global-%@", @(kCENTCountableNameStart)];
    NSString *caseName = [[self.name componentsSeparatedByString:@" "].lastObject
                          stringByReplacingOccurrencesOfString:@"]" withString:@""];
    
    if ([name rangeOfString:@"AddMessagesToChat"].location != NSNotFound) {
        [self class].globalNamesMap[self.messageAddMapToTestCase[caseName]] = globalChatChannel;
    } else if (kCENTShouldPublishTestMessages) {
        globalChatChannel = [self class].globalNamesMap[caseName];
    }
    
    return globalChatChannel;
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {
    
    NSDictionary *state = nil;
    
    if ([name rangeOfString:@"AddMessagesToChat"].location == NSNotFound) {
        state = @{ @"works": @YES };
    }
    
    return state;
}

- (void)setUp {
    
    [super setUp];

    
    _messageAddMapToTestCase = [NSMutableDictionary new];
    NSArray *testCaseNames = @[@"testSearch_ShouldFetch50SpecificEvents_WhenLimitAndEventNameIsSet",
                               @"testSearch_ShouldFetch200SpecificEvents_WhenLimitEventNameAndPagesIsSet",
                               @"testSearch_ShouldFetch10LatestEvents_WhenLimitAndPagesIsSet",
                               @"testSearch_ShouldNotFetchEvents_WhenUnknownSenderSpecified",
                               @"testSearch_ShouldEmitEventsInDescendingOrder_WhenSearchingForEvents",
                               @"testSearch_ShouldFetchEventsIgnoringLimit_WhenSearchingForEventsBetweenDates",
                               @"testSearch_ShouldFetchEventsLimitedByPage_WhenSearhingForEventsBetweenDates",
                               @"testSearch_ShouldFetchEventsLimitedByPageCount"];
    
    for (NSUInteger testCaseIdx = 0; testCaseIdx < testCaseNames.count; testCaseIdx++) {
        NSString *name = [@[@"testSearch_AddMessagesToChat", @"_WhenRecordingNewCassette"] componentsJoinedByString:@(testCaseIdx + 1).stringValue];
        _messageAddMapToTestCase[name] = testCaseNames[testCaseIdx];
    }
    
    if (kCENTEnforcedNameStart >= 0 && kCENTCountableNameStart < kCENTEnforcedNameStart) {
        kCENTCountableNameStart = kCENTEnforcedNameStart;
    }
    
    if ([self.name rangeOfString:@"AddMessagesToChat"].location == NSNotFound || kCENTShouldPublishTestMessages) {
        kCENTCountableNameStart++;
        [self setupChatEngineForUser:@"robot-stephen"];
    }
}

- (void)tearDown {
    
    [super tearDown];
    
    // Wait a bit more after step with message publishing.
    if ([self.name rangeOfString:@"AddMessagesToChat"].location != NSNotFound && kCENTShouldPublishTestMessages) {
        [self waitTask:@"WaitAllPublishToComplete" completionFor:4.f];
        NSLog(@"Messages addition completed!");
    }
}

- (void)testSearch_AddMessagesToChat1_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat2_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat3_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat4_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat5_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat6_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat7_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_AddMessagesToChat8_WhenRecordingNewCassette {
    
    [self publishTestMessages];
}

- (void)testSearch_ShouldFetch50SpecificEvents_WhenLimitAndEventNameIsSet {

    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block NSUInteger foundEventsCount = 0;
    NSUInteger expectedEventsCount = 50;

    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];

    CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).create();
    CENWeakify(search);
    
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search);
        
        return ^(CENEmittedEvent *emittedEvent) {
            search.removeAll(@"tester");
            
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


    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];

    CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).pages(11).create();
    CENWeakify(search);
    
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search);
        
        return ^(CENEmittedEvent *emittedEvent) {
            search.removeAll(@"tester");
            
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


    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];

    CENSearch *search = chat.search().limit(10).create();
    CENWeakify(search);
    
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search);
        
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


    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];

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


    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];

    CENSearch *search = chat.search().event(@"tester").limit(10).create();
    CENWeakify(search);
    
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search);
        
        return ^(CENEmittedEvent *emittedEvent) {
            search.removeAll(@"tester");
            
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
    
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];
    
    CENSearch *search1 = chat.search().event(@"tester").limit(100).create();
    CENWeakify(search1);
    
    [self object:search1 shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search1);
        
        return ^(CENEmittedEvent *emittedEvent) {
            search1.removeAll(@"tester");
            
            XCTAssertGreaterThan(timetokens.count, 0);
            handler();
        };
    } afterBlock:^{
        search1.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
    }];
    
    
    // Search between timetokens.
    NSNumber *end = timetokens[timetokens.count - 10];
    NSNumber *start = timetokens[10];
    // -1 because start/end search exclude message at 'end' date.
    NSUInteger expectedMessagesCount = [timetokens indexOfObject:end] - [timetokens indexOfObject:start] - 1;
    
    CENSearch *search2 = chat.search().event(@"tester").limit(10).pages(14).start(start).end(end).create();
    CENWeakify(search2);
    
    [self object:search2 shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search2);
        
        return ^(CENEmittedEvent *emittedEvent) {
            search2.removeAll(@"tester");
            
            XCTAssertEqual(messages.count - 1, expectedMessagesCount);
            XCTAssertFalse(search2.hasMore);
            handler();
        };
    } afterBlock:^{
        search2.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [messages insertObject:payload atIndex:0];
        });
    }];
}

- (void)testSearch_ShouldFetchEventsLimitedByPage_WhenSearhingForEventsBetweenDates {
    
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];
    
    // Pull out list of event timetokens.
    CENSearch *search1 = chat.search().event(@"tester").limit(100).create();
    CENWeakify(search1);
    
    [self object:search1 shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search1);
        
        return ^(CENEmittedEvent *emittedEvent) {
            search1.removeAll(@"tester");
            
            XCTAssertGreaterThan(timetokens.count, 0);
            handler();
        };
    } afterBlock:^{
        search1.search().on(@"tester", ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
    }];
    
    // Search between timetokens.
    NSNumber *end = timetokens[timetokens.count - 10];
    NSNumber *start = timetokens[10];
    
    CENSearch *search2 = chat.search().event(@"tester").pages(1).count(10).start(start).end(end).create();
    CENWeakify(search2);
    
    [self object:search2 shouldHandleEvent:@"$.search.pause" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(search2);
        
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertTrue(search2.hasMore);
            handler();
        };
    } afterBlock:^{
        search2.search();
    }];
}

- (void)testSearch_ShouldFetchEventsLimitedByPageCount {
    
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];
    
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
    
    if (kCENTShouldPublishTestMessages) {
        NSString *cassette = [NSStringFromClass([self class]) stringByAppendingPathExtension:@"bundle"];
        NSString *cassettesPath = [self.fixturesLocation stringByAppendingPathComponent:cassette];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cassettesPath isDirectory:nil]) {
            return;
        }
    } else {
        return;
    }
    
    dispatch_semaphore_t publishSemaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"robot-stephen"];
    __block NSUInteger publishedMessagesCount = 0;
    
    // Wait for connection to test chat.
    CENChat *chat = client.Chat().name(@"chat-history").create();
    [self waitForOwnOnlineOnChat:chat];
    
    CENEventHandlerBlock (^errorHandler)(dispatch_group_t) = ^CENEventHandlerBlock (dispatch_group_t group) {
        return ^(CENEmittedEvent *event) {
            NSLog(@"Event publish failed with error: %@", event.data);
            
            dispatch_group_leave(group);
        };
    };
    
    NSLog(@"Publish %@ messages to '%@'", @(kCENTPublishedMessagesCount), chat.name);
    for (NSUInteger messageIdx = 0; messageIdx < kCENTPublishedMessagesCount; messageIdx++) {
        dispatch_group_t messagesPublishGroup = dispatch_group_create();
        dispatch_group_enter(messagesPublishGroup);
        dispatch_group_enter(messagesPublishGroup);
        
        chat.emit(@"tester").data(@{ @"works": @YES, @"count": @(messageIdx) }).perform()
            .once(@"$.emitted", ^(CENEmittedEvent *event) {
                publishedMessagesCount++;
                dispatch_group_leave(messagesPublishGroup);
            })
            .once(@"$.error.emitter", errorHandler(messagesPublishGroup));
        
        chat.emit(@"not-tester").data(@{ @"works": @NO, @"count": @(messageIdx) }).perform()
            .once(@"$.emitted", ^(CENEmittedEvent *event) {
                publishedMessagesCount++;
                dispatch_group_leave(messagesPublishGroup);
            })
            .once(@"$.error.emitter", errorHandler(messagesPublishGroup));
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_notify(messagesPublishGroup, queue, ^{
            dispatch_semaphore_signal(publishSemaphore);
        });
        
        dispatch_semaphore_wait(publishSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    }
    
    NSLog(@"%@/%@ messages has been published (2 messages with different event names)",
          @(publishedMessagesCount), @(kCENTPublishedMessagesCount * 2));
    
    chat.leave().once(@"$.disconnected", ^(CENEmittedEvent * __unused event) {
        dispatch_semaphore_signal(publishSemaphore);
    });
    
    dispatch_semaphore_wait(publishSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    [self waitTask:@"ensureWeAreDone" completionFor:0.5f];
    NSLog(@"Ready to start test");
}

#pragma mark -


@end
