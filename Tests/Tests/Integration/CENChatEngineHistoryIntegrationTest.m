/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import "CEDummyPlugin.h"


#pragma mark Interface declaration

@interface CENChatEngineHistoryIntegrationTest: CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineHistoryIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [self setupChatEngineWithGlobal:@"global" forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testSearch_ShouldFetch50SpecificEvents_WhenLimitAndEventNameIsSet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block NSUInteger foundEventsCount = 0;
    NSUInteger expectedEventsCount = 50;
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).create();
        
        search.on(@"tester",^(NSDictionary *payload) {
            XCTAssertEqualObjects(payload[CENEventData.event], @"tester");
            XCTAssertNotNil(payload[CENEventData.timetoken]);
            
            foundEventsCount++;
        });
        
        search.once(@"$.search.finish", ^{
            handlerCalled = YES;
            
            XCTAssertFalse(search.hasMore);
            dispatch_semaphore_signal(semaphore);
        });
        
        search.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertEqual(foundEventsCount, expectedEventsCount);
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFetch200SpecificEvents_WhenLimitEventNameAndPagesIsSet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block NSUInteger foundEventsCount = 0;
    NSUInteger expectedEventsCount = 200;
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).pages(11).create();
        
        search.on(@"tester",^(NSDictionary *payload) {
            foundEventsCount++;
        });
        
        search.once(@"$.search.finish", ^{
            handlerCalled = YES;
            
            XCTAssertFalse(search.hasMore);
            dispatch_semaphore_signal(semaphore);
        });
        
        search.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertEqual(foundEventsCount, expectedEventsCount);
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFetch10LatestEvents_WhenLimitAndPagesIsSet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalledAtLeastOnce = NO;
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().limit(10).pages(13).create();
        
        search.once(@"tester",^(NSDictionary *payload) {
            handlerCalledAtLeastOnce = YES;
        });
        
        search.once(@"$.search.finish", ^{
            handlerCalled = YES;
            
            XCTAssertFalse(search.hasMore);
            dispatch_semaphore_signal(semaphore);
        });
        
         search.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalledAtLeastOnce);
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldNotFetchEvents_WhenUnknownSenderSpecified {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalledAtLeastOnce = NO;
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().sender(client.me).limit(10).pages(1).create();
        
        search.once(@"tester",^(NSDictionary *payload) {
            handlerCalledAtLeastOnce = YES;
        });
        
        search.once(@"$.search.pause", ^{
            handlerCalled = YES;
            dispatch_semaphore_signal(semaphore);
        });
        
         search.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalledAtLeastOnce);
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldEmitEventsInDesencdingOrder_WhenSearhingForEvents {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().event(@"tester").limit(10).pages(13).create();
        
        search.on(@"tester",^(NSDictionary *payload) {
            [timetokens addObject:payload[CENEventData.timetoken]];
        });
         
        search.once(@"$.search.finish", ^{
            handlerCalled = YES;
            
            XCTAssertFalse(search.hasMore);
            dispatch_semaphore_signal(semaphore);
        });
        
        search.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertEqual([timetokens.firstObject compare:timetokens.lastObject], NSOrderedDescending);
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFetchEventsIgnoringLimit_WhenSearhingForEventsBetweenDates {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray<NSDictionary *> *messages = [NSMutableArray new];
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block NSUInteger expectedMessagesCount = 0;
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search1 = chat.search().event(@"tester").limit(100).create();
        
        search1.on(@"tester",^(NSDictionary *payload) {
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
        
        search1.once(@"$.search.finish", ^{
            NSNumber *end = timetokens[timetokens.count - 10];
            NSNumber *start = timetokens[10];
            // -1 because start/end search exclude message at 'end' date.
            expectedMessagesCount = [timetokens indexOfObject:end] - [timetokens indexOfObject:start] - 1;
            CENSearch *search2 = chat.search().event(@"tester").limit(10).pages(14).start(start).end(end).create();
            
            search2.on(@"tester",^(NSDictionary *payload) {
                [messages insertObject:payload atIndex:0];
            });
            
            search2.once(@"$.search.finish", ^{
                handlerCalled = YES;
                
                XCTAssertFalse(search2.hasMore);
                dispatch_semaphore_signal(semaphore);
            });
            
            search2.search();
        });
        
        search1.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertEqual(messages.count - 1, expectedMessagesCount);
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFetchEventsLimitedByPage_WhenSearhingForEventsBetweenDates {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search1 = chat.search().event(@"tester").limit(100).create();
        
        search1.on(@"tester",^(NSDictionary *payload) {
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
        
        search1.once(@"$.search.finish", ^{
            NSNumber *end = timetokens[timetokens.count - 10];
            NSNumber *start = timetokens[10];
            CENSearch *search2 = chat.search().event(@"tester").limit(0).pages(1).count(10).start(start).end(end).create();
            
            search2.once(@"$.search.pause", ^{
                handlerCalled = YES;
                
                XCTAssertTrue(search2.hasMore);
                dispatch_semaphore_signal(semaphore);
            });
            
            search2.search();
        });
        
        search1.search();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
