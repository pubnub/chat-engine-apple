/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CENSearch+Private.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENObject+Plugins.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <PubNub/PNResult+Private.h>
#import "CENTestCase.h"


@interface CENSearchTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, strong) CENSearch *searchStartDate3EndDate18;
@property (nonatomic, nullable, strong) CENSearch *searchLimit40Count20;
@property (nonatomic, nullable, strong) CENSearch *searchPages1Count20;
@property (nonatomic, nullable, strong) CENSearch *searchDefault;


#pragma mark - Misc

- (void)stubFetchedMessagesWithResult:(PNHistoryResult *)result errorStatus:(PNErrorStatus *)error inInvocation:(NSInvocation *)invocation;

- (PNHistoryResult *)historyResultForEvent:(NSString *)eventName sentToChannel:(NSString *)channel fromSender:(NSString *)sender
                                 withCount:(NSUInteger)messagesCount startDate:(NSNumber *)start endDate:(NSNumber *)end;
- (PNErrorStatus *)historyErrorStatus;

- (NSDictionary *)payloadForEvent:(NSString *)event withData:(id)data sentBy:(CENUser *)sender toChat:(NSString *)channel;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENSearchTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);
    
    CENChat *chat = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    self.searchStartDate3EndDate18 = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:20 pages:1 count:20 start:@3 end:@18 chatEngine:self.client];
    self.searchLimit40Count20 = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:40 pages:0 count:20 start:nil end:nil chatEngine:self.client];
    self.searchPages1Count20 = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:200 pages:1 count:20 start:nil end:nil chatEngine:self.client];
    self.searchDefault = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:0 pages:0 count:0 start:nil end:nil chatEngine:self.client];
}

- (void)tearDown {

    [self.searchStartDate3EndDate18 destruct];
    [self.searchLimit40Count20 destruct];
    [self.searchPages1Count20 destruct];
    [self.searchDefault destruct];
    self.searchStartDate3EndDate18 = nil;
    self.searchLimit40Count20 = nil;
    self.searchPages1Count20 = nil;
    self.searchDefault = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateWithDefaults {
    
    CENChat *chat = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    CENSearch *search = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:0 pages:0 count:0 start:nil end:nil chatEngine:self.client];
    
    XCTAssertNotNil(search);
    XCTAssertNotNil(search.chat);
    XCTAssertEqual(search.chat, chat);
    XCTAssertEqual(search.limit, 20);
    XCTAssertEqual(search.count, 100);
    XCTAssertEqual(search.pages, 10);
    XCTAssertTrue(search.hasMore);
    XCTAssertEqual(search.chatEngine, self.client);
}

- (void)testConstructor_ShouldNOtCreate_WhenNonNSStringEventNamePassed {
    
    CENChat *chat = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    
    XCTAssertNil([CENSearch searchForEvent:(id)@2010 inChat:chat sentBy:nil withLimit:0 pages:0 count:0 start:nil end:nil chatEngine:self.client]);
}

- (void)testConstructor_ShouldNOtCreate_WhenEmptyEventNamePassed {
    
    CENChat *chat = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    
    XCTAssertNil([CENSearch searchForEvent:@"" inChat:chat sentBy:nil withLimit:0 pages:0 count:0 start:nil end:nil chatEngine:self.client]);
}

- (void)testConstructor_ShouldNOtCreate_WhenNonCENUserSenderPassed {
    
    CENChat *chat = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    
    XCTAssertNil([CENSearch searchForEvent:nil inChat:chat sentBy:(id)@2010 withLimit:0 pages:0 count:0 start:nil end:nil chatEngine:self.client]);
}

- (void)testConstructor_ShouldCreateWithPlugins_WhenSenderOrEventNamePassed {
    
    NSDictionary *expectedPluginConfiguraiton = @{ @"sender": self.clientMock.me.uuid, @"event": @"test-event" };
    CENChat *chat = self.clientMock.Chat().name(@"test-chat").autoConnect(NO).create();
    
    OCMExpect([self.clientMock registerPlugin:[CENSearchFilterPlugin class] withIdentifier:[OCMArg any] configuration:expectedPluginConfiguraiton
                                    forObject:[OCMArg any] firstInList:YES completion:[OCMArg any]]).andDo(nil);
    
    CENSearch *search = [CENSearch searchForEvent:@"test-event" inChat:chat sentBy:self.clientMock.me withLimit:0 pages:0 count:0
                                          start:nil end:nil chatEngine:self.clientMock];
    
    OCMVerifyAll((id)self.clientMock);
    XCTAssertNotNil(search);
    XCTAssertNotNil(search.chat);
    XCTAssertEqual(search.chat, chat);
    XCTAssertEqual(search.limit, 20);
    XCTAssertEqual(search.count, 100);
    XCTAssertEqual(search.pages, 10);
}


#pragma mark - Tests :: search / searchEvents

- (void)testSearch_ShouldEmitSearchStart_WhenStartedSearch {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.searchDefault handleEventOnce:@"$.search.start" withHandlerBlock:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldEmitPageRequest_WhenStartedSearch {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.searchDefault handleEventOnce:@"$.search.page.request" withHandlerBlock:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldEmitPageResponse_WhenFirstSearchResultRetrieved {
    
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:0
                                                 startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    NSNumber *referenceDate = nil;
    
    OCMStub([self.clientMock searchMessagesIn:self.searchDefault.chat.channel withStart:referenceDate limit:self.searchDefault.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    
    [self.searchDefault handleEventOnce:@"$.search.page.response" withHandlerBlock:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldEmitFetchedEvent_WhenSearchResultRetrieved {
    
    NSUInteger expectedEventsCount = 20;
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester"
                                                 withCount:expectedEventsCount startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSUInteger fetchedEventsCount = 0;
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchDefault.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchDefault handleEvent:@"test-event" withHandlerBlock:^(NSDictionary *payload) {
        fetchedEventsCount++;
        handlerCalled = YES;
        
        XCTAssertNotNil(payload);
        if (fetchedEventsCount == expectedEventsCount) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
    XCTAssertEqual(fetchedEventsCount, expectedEventsCount);
}

- (void)testSearch_ShouldEmitError_WhenReceivedFetchErrorStatus {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchDefault.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:nil errorStatus:[self historyErrorStatus] inInvocation:invocation];
        });
    
    [self.searchDefault handleEventOnce:@"$.error.search" withHandlerBlock:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldEmitSearchFinishEvent_WhenFetchedCountIsEqualToLimit {
    
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:20
                                                 startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchDefault.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchDefault handleEventOnce:@"$.search.finish" withHandlerBlock:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFetchMoreHistoryPages_WhenFetchedCountIsEqualToLimit {
    
    NSUInteger expectedPagesCount = 2;
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:20
                                                 startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSUInteger fetchedPagesCount = 0;
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchLimit40Count20.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchLimit40Count20 handleEvent:@"$.search.page.request" withHandlerBlock:^{
        fetchedPagesCount++;
        handlerCalled = YES;
        
        if (fetchedPagesCount == expectedPagesCount) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    self.searchLimit40Count20.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
    XCTAssertEqual(fetchedPagesCount, expectedPagesCount);
}

- (void)testSearch_ShouldEmitSearchPause_WhenReachedPagesCountLimit {
    
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:20
                                                 startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchPages1Count20.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchPages1Count20 handleEvent:@"$.search.pause" withHandlerBlock:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    self.searchPages1Count20.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
    XCTAssertTrue(self.searchPages1Count20.hasMore);
}

- (void)testSearch_ShouldNotifyAboutPartOfEvents_WhenStartAndEndDateSpecified {
    
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:100
                                                 startDate:@1 endDate:@100];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSUInteger fetchedEventsCount = 0;
    NSUInteger expectedEventsCount = 18;
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchStartDate3EndDate18.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchStartDate3EndDate18 handleEvent:@"test-event" withHandlerBlock:^{
        handlerCalled = YES;
        fetchedEventsCount++;
        
        if (fetchedEventsCount == expectedEventsCount) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    self.searchStartDate3EndDate18.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
    XCTAssertEqual(fetchedEventsCount, expectedEventsCount);
}


#pragma mark - Tests :: next / searchOlder

- (void)testNext_ShouldSearchMore_WhenThereIsMoreData {
    
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:20
                                                 startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchPages1Count20.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchPages1Count20 handleEvent:@"$.search.pause" withHandlerBlock:^{
        [self.searchPages1Count20 handleEvent:@"$.search.page.request" withHandlerBlock:^{
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }];
        self.searchPages1Count20.next();
    }];
    
    self.searchPages1Count20.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testNext_ShouldNotSearch_WhenThereIsNoMoreData {
    
    PNHistoryResult *history = [self historyResultForEvent:@"test-event" sentToChannel:@"test-chat" fromSender:@"tester" withCount:20
                                                 startDate:@1 endDate:@2];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:self.searchDefault.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            [self stubFetchedMessagesWithResult:history errorStatus:nil inInvocation:invocation];
        });
    
    [self.searchDefault handleEventOnce:@"$.search.finish" withHandlerBlock:^{
        [self.searchDefault handleEventOnce:@"$.search.finish" withHandlerBlock:^{
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }];
        
        self.searchDefault.next();
    }];
    
    self.searchDefault.search();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    NSString *description = [self.searchDefault description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}


#pragma mark - Misc

- (void)stubFetchedMessagesWithResult:(PNHistoryResult *)result errorStatus:(PNErrorStatus *)error inInvocation:(NSInvocation *)invocation {

    void(^handlerBlock)(PNHistoryResult *result, PNErrorStatus *status);

    [invocation getArgument:&handlerBlock atIndex:5];
    handlerBlock(result, error);
}

- (PNHistoryResult *)historyResultForEvent:(NSString *)eventName sentToChannel:(NSString *)channel fromSender:(NSString *)sender
                                 withCount:(NSUInteger)messagesCount startDate:(NSNumber *)start endDate:(NSNumber *)end {
    
    CENUser *senderUser = [CENUser userWithUUID:sender state:@{} chatEngine:self.client];
    NSMutableArray<NSDictionary *> *messages = [NSMutableArray new];
    for (NSUInteger idx = 0; idx < messagesCount; idx++) {
        NSDictionary *event = [self payloadForEvent:eventName withData:[NSString stringWithFormat:@"Message #%@", @(idx)] sentBy:senderUser
                                             toChat:channel];
        [messages addObject:@{ @"timetoken": @(idx + 1), @"message": event }];
    }
    
    NSDictionary *serviceData = @{ @"start": start, @"end": end, @"messages": messages };
    
    return [PNHistoryResult objectForOperation:PNHistoryOperation completedWithTask:nil processedData:serviceData processingError:nil];;
}

- (PNErrorStatus *)historyErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNHistoryOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}

- (NSDictionary *)payloadForEvent:(NSString *)event withData:(id)data sentBy:(CENUser *)sender toChat:(NSString *)channel {
    
    return @{
        CENEventData.data: data,
        CENEventData.sender: sender,
        CENEventData.chat: channel,
        CENEventData.event: event,
        CENEventData.eventID: @"1234567890",
        CENEventData.sdk: @"objc/1.0"
    };
}

#pragma mark -


@end
