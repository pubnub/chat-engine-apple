/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENSession+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENSessionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) CENSession *session;


#pragma mark - Misc

- (NSDictionary *)synchronizationEventFor:(NSString *)chat isPrivate:(BOOL)isPrivate;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENSessionTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENChatEngine *client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    CENMe *user = [CENMe userWithUUID:@"tester" state:@{} chatEngine:client];
    self.defaultClient = [self partialMockForObject:client];
    
    OCMStub([self.defaultClient me]).andReturn(user);
    
    self.session = [CENSession sessionWithChatEngine:self.defaultClient];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [self.session destruct];
    self.session = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreate {
    
    CENSession *session = [CENSession sessionWithChatEngine:self.defaultClient];
    
    XCTAssertNotNil(session);
    XCTAssertEqual(session.chatEngine, self.defaultClient);
}

- (void)testConstructor_ShouldHaveNilChatsList_WhenSynchronizationNotPerformed {
    
    XCTAssertNil([CENSession sessionWithChatEngine:self.defaultClient].chats);
}


#pragma mark - Tests :: listenEvents

- (void)testListenEvents_ShouldRequestSynchronizationChat {
    
    OCMStub([self.defaultClient createChatWithName:[OCMArg any] group:[OCMArg any] private:NO autoConnect:YES metaData:[OCMArg any]])
        .andReturn(nil);
    OCMExpect([self.defaultClient synchronizationChat]);
    
    [self.session listenEvents];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testListenEvents_ShouldListenSynchronizationEvens {
    
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.session listenEvents];
    
    XCTAssertTrue([syncChat.eventNames containsObject:@"$.session.notify.chat.join"]);
    XCTAssertTrue([syncChat.eventNames containsObject:@"$.session.notify.chat.leave"]);
}

- (void)testListenEvents_ShouldNotifyAboutJoinToChat_WhenSynchronizationEventReceived {
    
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertNotNil(chat);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];

    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testListenEvents_ShouldNotifyAboutJoinToChat_WhenSameSynchronizationEventReceived {
    
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalledTwice = NO;
    __block BOOL handlerCalledOnce = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEvent:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        if (handlerCalledOnce) {
            handlerCalledTwice = YES;
            dispatch_semaphore_signal(semaphore);
        }
        handlerCalledOnce = YES;
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalledOnce);
    XCTAssertFalse(handlerCalledTwice);
}

- (void)testListenEvents_ShouldNotNotifyAboutJoinToChat_WhenSynchronizationEventReceivedForAlreadyExistingChat {
    
    self.defaultClient.Chat().name(@"test-chat").autoConnect(NO).create();
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertNotNil(chat);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (void)testListenEvents_ShouldNotifyAboutLeaveFromChat_WhenSynchronizationEventReceived {
    
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    NSDictionary *leavePayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEventOnce:@"$.chat.leave" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertNotNil(chat);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testListenEvents_ShouldNotNotifyAboutLeaveFromChat_WhenSynchronizationEventReceivedForUnknownChat {
    
    NSDictionary *leavePayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEventOnce:@"$.chat.leave" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertNotNil(chat);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (void)testListenEvents_ShouldNotNotifyAboutLeaveFromChat_WhenSameSynchronizationEventReceived {
    
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    NSDictionary *leavePayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalledTwice = NO;
    __block BOOL handlerCalledOnce = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEvent:@"$.chat.leave" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        if (handlerCalledOnce) {
            handlerCalledTwice = YES;
            dispatch_semaphore_signal(semaphore);
        }
        handlerCalledOnce = YES;
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalledOnce);
    XCTAssertFalse(handlerCalledTwice);
}


#pragma mark - Tests :: restore

- (void)testRestore_ShouldRequestChatsForGroups {
    
    OCMExpect([self.defaultClient synchronizeSessionChatsWithCompletion:[OCMArg any]]);
    
    [self.session restore];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testRestore_ShouldNotifyJoinEvent_WhenReceivedChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedChatName = @"test-chat";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient synchronizeSessionChatsWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSString *, NSArray<NSString *> *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:2];
        handlerBlock(CENChatGroup.custom, @[expectedChatName]);
    });
    
    [self.defaultClient handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(chat.name, expectedChatName);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.session restore];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(expectedChatName);
}


#pragma mark - Tests :: joinChat

-(void)testJoinChat_ShouldEmitSynchronizationEvent_WhenPassedChatIsNotInSynchronizedChatsList {
    
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    CENChat *chat = [CENChat chatWithName:@"test-chat" namespace:self.defaultClient.currentConfiguration.globalChannel group:CENChatGroup.custom
                                private:NO metaData:@{} chatEngine:self.defaultClient];
    NSDictionary *expectedData = @{ @"subject": [chat dictionaryRepresentation] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    id chatPartialMock = [self partialMockForObject:syncChat];
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    OCMExpect([chatPartialMock emitEvent:@"$.session.notify.chat.join" withData:expectedData]).andDo(^(NSInvocation *invocation) {
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.session listenEvents];
    [self.session joinChat:chat];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(chatPartialMock);
}

-(void)testJoinChat_ShouldNotEmitSynchronizationEvent_WhenPassedChatAlreadyInSynchronizedChatsList {
    
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    CENChat *chat = [CENChat chatWithName:@"test-chat" namespace:self.defaultClient.currentConfiguration.globalChannel group:CENChatGroup.custom
                                private:NO metaData:@{} chatEngine:self.defaultClient];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    id chatPartialMock = [self partialMockForObject:syncChat];
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    OCMExpect([[chatPartialMock reject] emitEvent:@"$.session.notify.chat.join" withData:[OCMArg any]]);
    
    [self.defaultClient handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chatJoined) {
        [self.session joinChat:chat];
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(chatPartialMock);
}


#pragma mark - Tests :: leaveChat

-(void)testLeaveChat_ShouldEmitSynchronizationEvent_WhenPassedChatInSynchronizedChatsList {
    
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    CENChat *chat = [CENChat chatWithName:@"test-chat" namespace:self.defaultClient.currentConfiguration.globalChannel group:CENChatGroup.custom
                                private:NO metaData:@{} chatEngine:self.defaultClient];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    NSDictionary *expectedData = @{ @"subject": [chat dictionaryRepresentation] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    id chatPartialMock = [self partialMockForObject:syncChat];
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    OCMExpect([chatPartialMock emitEvent:@"$.session.notify.chat.leave" withData:expectedData]).andDo(^(NSInvocation *invocation) {
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chatJoined) {
        [self.session leaveChat:chat];
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(chatPartialMock);
}

-(void)testLeaveChat_ShouldEmitSynchronizationEvent_WhenPassedChatNotInSynchronizedChatsList {
    
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    CENChat *chat = [CENChat chatWithName:@"test-chat" namespace:self.defaultClient.currentConfiguration.globalChannel group:CENChatGroup.custom
                                private:NO metaData:@{} chatEngine:self.defaultClient];
    NSDictionary *expectedData = @{ @"subject": [chat dictionaryRepresentation] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    id chatPartialMock = [self partialMockForObject:syncChat];
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    OCMExpect([chatPartialMock emitEvent:@"$.session.notify.chat.leave" withData:expectedData]).andDo(^(NSInvocation *invocation) {
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.session listenEvents];
    [self.session leaveChat:chat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(chatPartialMock);
}


#pragma mark - Tests :: chats

- (void)testChats_ShouldBeEmpty_WhenNoSynchronizationHasBeenDone {
    
    XCTAssertEqual(self.session.chats.count, 0);
}

- (void)testChats_ShouldContainChats_WhenSynchronizationEventReceived {
    
    CENChat *syncChat = [self.defaultClient createChatWithName:@"test-sync" group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient synchronizationChat]).andReturn(syncChat);
    
    [self.defaultClient handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENSession *session, CENChat *chatJoined) {
        handlerCalled = YES;
        
        XCTAssertEqual(session.chats.count, 1);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.session listenEvents];
    [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    NSString *description = [self.session description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}

- (void)testDescription_ShouldIncludeChatsAndGroupInformation {
    
    OCMStub([self.defaultClient synchronizeSessionChatsWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSString *, NSArray<NSString *> *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:2];
        handlerBlock(CENChatGroup.custom, @[@"test-chat"]);
    });
    
    [self.session restore];
    NSString *description = [self.session description];
    
    XCTAssertTrue([description rangeOfString:CENChatGroup.custom].location != NSNotFound);
}


#pragma mark - Misc

- (NSDictionary *)synchronizationEventFor:(NSString *)chat isPrivate:(BOOL)isPrivate {
    
    return @{
        CENEventData.data: @{
            @"subject": @{
                CENChatData.channel: [@[@"chat-engine#chat#public.", chat] componentsJoinedByString:@"#"],
                CENChatData.private:@(isPrivate),
                CENChatData.group:CENChatGroup.custom
            }
        }
    };
}

#pragma mark -


@end
