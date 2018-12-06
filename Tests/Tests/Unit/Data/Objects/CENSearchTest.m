/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENStateRestoreAugmentationPlugin.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CENSearch+Interface.h>
#import <CENChatEngine/CENSearch+Private.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENObject+Plugins.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <PubNub/PNResult+Private.h>
#import "CENTestCase.h"


@interface CENSearchTest : CENTestCase


#pragma mark - Misc

- (CENSearch *)defaultSearcher;
- (CENSearch *)searcherInChat:(CENChat *)chat;
- (CENSearch *)searcherInChat:(CENChat *)chat forEventsFrom:(CENUser *)user;
- (CENSearch *)searcherInChat:(CENChat *)chat forEvents:(NSString *)event sentFrom:(CENUser *)user;

- (PNHistoryResult *)resultFromSearcher:(CENSearch *)search withCount:(NSUInteger)count;
- (PNHistoryResult *)resultForChannel:(NSString *)channel from:(NSString *)sender
                            withCount:(NSUInteger)messagesCount start:(NSNumber *)start
                                  end:(NSNumber *)end;
- (PNErrorStatus *)historyErrorStatus;

- (NSDictionary *)payloadWithData:(id)data sentBy:(NSString *)sender toChat:(NSString *)channel;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENSearchTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return NO;
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateWithDefaults {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENSearch *search = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:0 pages:0 count:0
                                            start:nil end:nil chatEngine:self.client];
    
    
    XCTAssertNotNil(search);
    XCTAssertNotNil(search.chat);
    XCTAssertEqual(search.chat, chat);
    XCTAssertEqual(search.limit, 20);
    XCTAssertEqual(search.count, 100);
    XCTAssertEqual(search.pages, 10);
    XCTAssertTrue(search.hasMore);
    XCTAssertEqual(search.chatEngine, self.client);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringEventNamePassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    XCTAssertNil([CENSearch searchForEvent:(id)@2010 inChat:chat sentBy:nil withLimit:0 pages:0 count:0
                                     start:nil end:nil chatEngine:self.client]);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyEventNamePassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    XCTAssertNil([CENSearch searchForEvent:@"" inChat:chat sentBy:nil withLimit:0 pages:0 count:0
                                     start:nil end:nil chatEngine:self.client]);
}

- (void)testConstructor_ShouldNotCreate_WhenNonCENUserSenderPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    XCTAssertNil([CENSearch searchForEvent:nil inChat:chat sentBy:(id)@2010 withLimit:0 pages:0 count:0
                                     start:nil end:nil chatEngine:self.client]);
}


- (void)testConstructor_ShouldCreateWithPlugins_WhenSenderOrEventNamePassed {
    
    self.usesMockedObjects = YES;
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSDictionary *expectedConfiguraiton = @{ @"sender": user.uuid, @"event": @"test-event" };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMExpect([self.client registerPlugin:[CENSearchFilterPlugin class] withIdentifier:[OCMArg any]
                            configuration:expectedConfiguraiton forObject:[OCMArg any] firstInList:YES
                               completion:[OCMArg any]]).andDo(nil);
    
    [self searcherInChat:chat forEvents:@"test-event" sentFrom:user];
    
    OCMVerifyAll((id)self.client);
}


#pragma mark - Tests :: search / searchEvents

- (void)testSearch_ShouldEmitSearchStart_WhenStartedSearch {
    
    CENSearch *search = [self defaultSearcher];
    
    
    [self object:search shouldHandleEvent:@"$.search.start" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldEmitPageRequest_WhenStartedSearch {
    
    CENSearch *search = [self defaultSearcher];
    
    
    [self object:search shouldHandleEvent:@"$.search.page.request" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldEmitPageResponse_WhenFirstSearchResultRetrieved {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:0];
    NSNumber *startDate = nil;
    
    
    OCMStub([self.client searchMessagesIn:search.chat.channel withStart:startDate limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"$.search.page.response" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldEmitFetchedEvent_WhenSearchResultRetrieved {
    
    self.usesMockedObjects = YES;
    NSUInteger expectedEventsCount = 20;
    CENSearch *search = [self defaultSearcher];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:expectedEventsCount];
    __block NSUInteger fetchedEventsCount = 0;
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"test-event" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            fetchedEventsCount++;
            
            XCTAssertNotNil(payload);
            if (fetchedEventsCount == expectedEventsCount) {
                handler();
            }
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldEmitError_WhenReceivedFetchErrorStatus {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(nil, [self historyErrorStatus]);
        });
    
    [self object:search shouldHandleEvent:@"$.error.search" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.data);
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldEmitSearchFinishEvent_WhenFetchedCountIsEqualToLimit {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:20];
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldFetchMoreHistoryPages_WhenFetchedCountIsEqualToLimit {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENSearch *search = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:40 pages:0 count:20
                                            start:nil end:nil chatEngine:self.client];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:20];
    __block NSUInteger fetchedPagesCount = 0;
    NSUInteger expectedPagesCount = 2;
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"$.search.page.request" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            fetchedPagesCount++;
            
            if (fetchedPagesCount == expectedPagesCount) {
                handler();
            }
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldEmitSearchPause_WhenReachedPagesCountLimit {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENSearch *search = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:200 pages:1 count:20
                                            start:nil end:nil chatEngine:self.client];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:20];
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"$.search.pause" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertTrue(search.hasMore);
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testSearch_ShouldNotifyAboutPartOfEvents_WhenStartAndEndDateSpecified {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    PNHistoryResult *history = [self resultForChannel:chat.name from:@"tester" withCount:100 start:@1 end:@100];
    CENSearch *search = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:20 pages:1 count:20
                                            start:@3 end:@18 chatEngine:self.client];
    __block NSUInteger fetchedEventsCount = 0;
    NSUInteger expectedEventsCount = 16;
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });

    [self object:search shouldHandleEvent:@"test-event" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            fetchedEventsCount++;
            
            XCTAssertNotNil(payload);
            if (fetchedEventsCount == expectedEventsCount) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
                    if (fetchedEventsCount == expectedEventsCount) {
                        handler();
                    }
                });
            }
        };
    } afterBlock:^{
        search.search();
    }];
}


#pragma mark - Tests :: next / searchOlder

- (void)testNext_ShouldSearchMore_WhenThereIsMoreData {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENSearch *search = [CENSearch searchForEvent:nil inChat:chat sentBy:nil withLimit:200 pages:1 count:20
                                            start:nil end:nil chatEngine:self.client];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:20];
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"$.search.pause" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            [search handleEvent:@"$.search.page.request" withHandlerBlock:^(CENEmittedEvent *event) {
                handler();
            }];
            
            search.next();
        };
    } afterBlock:^{
        search.search();
    }];
}

- (void)testNext_ShouldNotSearch_WhenThereIsNoMoreData {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:20];
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    [self object:search shouldHandleEvent:@"$.search.finish" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        search.search();
    }];
    
    id searchMock = [self mockForObject:search];
    id recorded = OCMExpect([(CENSearch *)[searchMock reject] searchEvents]);
    [self waitForObject:searchMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay
             afterBlock:^{
                 search.next();
             }];
}


#pragma mark - Tests :: restoreState / restoreStateForChat

- (void)testRestoreState_ShouldRegisterUserStateResolverPlugin_WhenStateRestoreCalled {

    CENSearch *search = [self defaultSearcher].restoreState(nil);
    
    
    XCTAssertTrue(search.plugin([CENStateRestoreAugmentationPlugin class]).exists());
}

- (void)testRestoreState_ShouldUseSearchChatForStateRestore_WhenStateRestoreCalledWithNil {
    
    CENSearch *search = [self defaultSearcher];
    
    
    id searchMock = [self mockForObject:search];
    OCMExpect([searchMock restoreStateForChat:nil]).andForwardToRealObject();
    OCMExpect([searchMock defaultStateChat]).andForwardToRealObject();
    XCTAssertEqualObjects([search defaultStateChat], search.chat);
    
    search.restoreState(nil);
    
    OCMVerifyAll(searchMock);
}

- (void)testRestoreState_ShouldUseCustomChatForStateRestore_WhenStateRestoreCalledWithChat {
    
    CENSearch *search = [self defaultSearcher];
    CENChat *chat = self.client.Chat().autoConnect(NO).create();
    
    
    id searchMock = [self mockForObject:search];
    OCMExpect([searchMock restoreStateForChat:chat]).andForwardToRealObject();
    OCMExpect([[searchMock reject] defaultStateChat]).andForwardToRealObject();
    
    search.restoreState(chat);
    
    OCMVerifyAll(searchMock);
}

- (void)testRestoreState_ShouldTryRestoreState_WhenStateRestoreCalledWithNil {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:1];
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    id recorded = OCMExpect([self.client fetchUserState:[OCMArg any] forChat:search.chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        search.restoreState(nil).search();
    }];
}

- (void)testRestoreState_ShouldTryRestoreState_WhenStateRestoreCalledCalledWithChat {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    PNHistoryResult *history = [self resultFromSearcher:search withCount:1];
    CENChat *chat = self.client.Chat().autoConnect(NO).create();
    
    
    OCMStub([self.client searchMessagesIn:[OCMArg any] withStart:[OCMArg any] limit:search.count completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(id, id) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock(history, nil);
        });
    
    id recorded = OCMExpect([self.client fetchUserState:[OCMArg any] forChat:chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        search.restoreState(chat).search();
    }];
}


#pragma mark - Tests :: augmentation

- (void)testAugmentation_ShouldReplaceChatNameWithCENChatInstance {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    NSDictionary *event = @{
        CENEventData.sender: @"tester",
        CENEventData.chat: search.chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"message",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    
    [self object:search shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.chat]);
            XCTAssertTrue([payload[CENEventData.chat] isKindOfClass:[CENChat class]]);
            XCTAssertEqualObjects(((CENChat *)payload[CENEventData.chat]).channel, search.chat.channel);
            
            handler();
        };
    } afterBlock:^{
        [self.client triggerEventLocallyFrom:search event:@"message", event, nil];
    }];
}

- (void)testAugmentation_ShouldReplaceSenderUUIDWithCENUserInstance {
    
    self.usesMockedObjects = YES;
    CENSearch *search = [self defaultSearcher];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    NSDictionary *event = @{
        CENEventData.sender: user.uuid,
        CENEventData.chat: search.chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"message",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    
    [self object:search shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.sender]);
            XCTAssertTrue([payload[CENEventData.sender] isKindOfClass:[CENUser class]]);
            XCTAssertEqualObjects(((CENUser *)payload[CENEventData.sender]).uuid, user.uuid);
            
            handler();
        };
    } afterBlock:^{
        [self.client triggerEventLocallyFrom:search event:@"message", event, nil];
    }];
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    CENSearch *search = [self defaultSearcher];
    NSString *description = [search description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}

#pragma mark - Misc

- (CENSearch *)defaultSearcher {
    
    return [self searcherInChat:nil];
}

- (CENSearch *)searcherInChat:(CENChat *)chat {
    
    return [self searcherInChat:chat forEventsFrom:nil];
}

- (CENSearch *)searcherInChat:(CENChat *)chat forEventsFrom:(CENUser *)user {
    
    return [self searcherInChat:chat forEvents:nil sentFrom:user];
}

- (CENSearch *)searcherInChat:(CENChat *)chat forEvents:(NSString *)event sentFrom:(CENUser *)user {
    
    return [CENSearch searchForEvent:event inChat:(chat ?: [self publicChatWithChatEngine:self.client]) sentBy:user
                           withLimit:0 pages:0 count:0 start:nil end:nil chatEngine:self.client];
}

- (PNHistoryResult *)resultFromSearcher:(CENSearch *)search withCount:(NSUInteger)count {
    
    return [self resultForChannel:search.chat.name from:search.sender.uuid ?: @"tester"
                        withCount:count start:(search.start ?: @1) end:(search.end ?: @2)];
}

- (PNHistoryResult *)resultForChannel:(NSString *)channel from:(NSString *)sender
                            withCount:(NSUInteger)messagesCount start:(NSNumber *)start
                                  end:(NSNumber *)end {
    
    NSMutableArray<NSDictionary *> *messages = [NSMutableArray new];
    
    for (NSUInteger idx = 0; idx < messagesCount; idx++) {
        NSString *data = [NSString stringWithFormat:@"Message #%@", @(idx)];
        NSDictionary *event = [self payloadWithData:data sentBy:sender toChat:channel];
        [messages addObject:@{ @"timetoken": @(idx + 1), @"message": event }];
    }
    
    NSDictionary *serviceData = @{ @"start": start, @"end": end, @"messages": messages };
    
    return [PNHistoryResult objectForOperation:PNHistoryOperation completedWithTask:nil
                                 processedData:serviceData processingError:nil];
}

- (PNErrorStatus *)historyErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNHistoryOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}

- (NSDictionary *)payloadWithData:(id)data sentBy:(NSString *)sender toChat:(NSString *)channel {
    
    return @{
        CENEventData.data: data,
        CENEventData.sender: sender,
        CENEventData.chat: channel,
        CENEventData.event: @"test-event",
        CENEventData.eventID: [NSUUID UUID].UUIDString,
        CENEventData.sdk: @"objc/1.0"
    };
}

#pragma mark -


@end
