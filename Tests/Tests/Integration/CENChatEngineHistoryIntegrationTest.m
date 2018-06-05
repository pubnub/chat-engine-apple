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
    
    NSUInteger expectedEventsCount = 50;
    __block NSUInteger foundEventsCount = 0;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"History should fetch 50 'tester' events."];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).create();
        
        search.on(@"tester",^(NSDictionary *payload) {
            XCTAssertEqualObjects(payload[CENEventData.event], @"tester");
            XCTAssertNotNil(payload[CENEventData.timetoken]);
            
            foundEventsCount++;
        });
        
        search.once(@"$.search.finish", ^{
            XCTAssertFalse(search.hasMore);
            XCTAssertEqual(foundEventsCount, expectedEventsCount);
            [expectation fulfill];
        });
        
        search.search();
    });
    
    [self waitForExpectations:@[expectation] timeout:30.f];
}

- (void)testSearch_ShouldFetch200SpecificEvents_WhenLimitEventNameAndPagesIsSet {
    
    NSUInteger expectedEventsCount = 200;
    __block NSUInteger foundEventsCount = 0;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"History should fetch 200 'tester' events."];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().event(@"tester").limit(expectedEventsCount).pages(11).create();
        
        search.on(@"tester",^(NSDictionary *payload) {
            foundEventsCount++;
        });
        
        search.once(@"$.search.finish", ^{
            XCTAssertFalse(search.hasMore);
            XCTAssertEqual(foundEventsCount, expectedEventsCount);
            [expectation fulfill];
        });
        
        search.search();
    });
    
    [self waitForExpectations:@[expectation] timeout:30.f];
}

- (void)testSearch_ShouldFetch10LatestEvents_WhenLimitAndPagesIsSet {
    
    __block BOOL handlerCalledAtLeastOnce = NO;
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"History should fetch 200 'tester' evenys."];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.once(@"$.connected", ^{
        CENSearch *search = chat.search().limit(10).pages(13).create();
        
        search.once(@"tester",^(NSDictionary *payload) {
            handlerCalledAtLeastOnce = YES;
        });
        
        search.once(@"$.search.finish", ^{
            XCTAssertFalse(search.hasMore);
            XCTAssertTrue(handlerCalledAtLeastOnce);
            [expectation fulfill];
        });
         
         search.search();
    });
    
    [self waitForExpectations:@[expectation] timeout:30.f];
}

- (void)testSearch_ShouldEmitEventsInDesencdingOrder_WhenSearhingForEvents {
    
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"History should emit events in descending order."];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.on(@"$.connected", ^{
        CENSearch *search = chat.search().event(@"tester").limit(10).pages(13).create();
        
        search.on(@"tester",^(NSDictionary *payload) {
            [timetokens addObject:payload[CENEventData.timetoken]];
        });
         
        search.on(@"$.search.finish", ^{
            XCTAssertFalse(search.hasMore);
            XCTAssertEqual([timetokens.firstObject compare:timetokens.lastObject], NSOrderedDescending);
            
            [expectation fulfill];
        });
         
        search.search();
    });
    
    [self waitForExpectations:@[expectation] timeout:30.f];
}

- (void)testSearch_ShouldFetchEventsIgnoringLimit_WhenSearhingForEventsBetweenDates {
    
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"History search should ignore limit."];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.on(@"$.connected", ^{
        CENSearch *search1 = chat.search().event(@"tester").limit(100).create();
        
        search1.on(@"tester",^(NSDictionary *payload) {
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
        
        search1.on(@"$.search.finish", ^{
            NSMutableArray<NSDictionary *> *messages = [NSMutableArray new];
            NSNumber *end = timetokens[timetokens.count - 10];
            NSNumber *start = timetokens[10];
            // -1 because start/end search exclude message at 'end' date.
            NSUInteger expectedMessagesCount = [timetokens indexOfObject:end] - [timetokens indexOfObject:start] - 1;
            CENSearch *search2 = chat.search().event(@"tester").limit(10).pages(14).start(start).end(end).create();
            
            search2.on(@"tester",^(NSDictionary *payload) {
                [messages insertObject:payload atIndex:0];
            });
            
            search2.on(@"$.search.finish", ^{
                XCTAssertFalse(search2.hasMore);
                XCTAssertEqual(messages.count - 1, expectedMessagesCount);
                
                [expectation fulfill];
            });
            
            search2.search();
        });
        
        search1.search();
    });
    
    [self waitForExpectations:@[expectation] timeout:30.f];
}

- (void)testSearch_ShouldFetchEventsLimitedByPage_WhenSearhingForEventsBetweenDates {
    
    NSMutableArray<NSNumber *> *timetokens = [NSMutableArray new];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"History search should pause."];
    CENChatEngine *client = [self chatEngineForUser:@"stephen"];
    
    
    CENChat *chat = client.Chat().name(@"chat-history").create();
    chat.on(@"$.connected", ^{
        CENSearch *search1 = chat.search().event(@"tester").limit(100).create();
        
        search1.on(@"tester",^(NSDictionary *payload) {
            [timetokens insertObject:payload[CENEventData.timetoken] atIndex:0];
        });
        
        search1.on(@"$.search.finish", ^{
            NSNumber *end = timetokens[timetokens.count - 10];
            NSNumber *start = timetokens[10];
            CENSearch *search2 = chat.search().event(@"tester").limit(0).pages(1).count(10).start(start).end(end).create();
            
            search2.on(@"$.search.pause", ^{
                XCTAssertTrue(search2.hasMore);
                [expectation fulfill];
            });
            
            search2.search();
        });
        
        search1.search();
    });
    
    [self waitForExpectations:@[expectation] timeout:30.f];
}

#pragma mark -


@end
