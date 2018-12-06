/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
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


#pragma mark - Misc

- (NSDictionary *)synchronizationEventFor:(NSString *)chat isPrivate:(BOOL)isPrivate;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENSessionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreate {
    
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    XCTAssertNotNil(session);
    XCTAssertEqual(session.chatEngine, self.client);
}

- (void)testConstructor_ShouldHaveNilChatsList_WhenSynchronizationNotPerformed {
    
    XCTAssertNil([CENSession sessionWithChatEngine:self.client].chats);
}


#pragma mark - Tests :: listenEvents

- (void)testListenEvents_ShouldRequestSynchronizationChat {
    
    self.usesMockedObjects = YES;
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMExpect([self.client synchronizationChat]).andDo(nil);
    
    [session listenEvents];
    
    OCMVerifyAll((id)self.client);
}

- (void)testListenEvents_ShouldListenSynchronizationEvens {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [session listenEvents];
    
    XCTAssertTrue([syncChat.eventNames containsObject:@"$.session.notify.chat.join"]);
    XCTAssertTrue([syncChat.eventNames containsObject:@"$.session.notify.chat.leave"]);
}

- (void)testListenEvents_ShouldNotifyAboutJoinToChat_WhenSynchronizationEventReceived {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:self.client shouldHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.data);
            handler();
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    }];
}

- (void)testListenEvents_ShouldNotNotifyAboutJoinToChat_WhenSameSynchronizationEventReceived {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    __block BOOL handlerCalled = NO;
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:self.client shouldNotHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            if (handlerCalled) {
                handler();
            }
            
            handlerCalled = YES;
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    }];
}

- (void)testListenEvents_ShouldNotNotifyAboutJoinToChat_WhenSynchronizationEventReceivedForAlreadyExistingChat {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *joinPayload = [self synchronizationEventFor:chat.name isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:self.client shouldNotHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    }];
}

- (void)testListenEvents_ShouldNotifyAboutLeaveFromChat_WhenSynchronizationEventReceived {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *leavePayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:session shouldHandleEvent:@"$.chat.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.data);
            handler();
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
        [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    }];
}

- (void)testListenEvents_ShouldNotNotifyAboutLeaveFromChat_WhenSynchronizationEventReceivedForUnknownChat {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *leavePayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:self.client shouldNotHandleEvent:@"$.chat.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.data);
            handler();
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    }];
}

- (void)testListenEvents_ShouldNotNotifyAboutLeaveFromChat_WhenSameSynchronizationEventReceived {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *leavePayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    __block BOOL handlerCalled = NO;
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:self.client shouldNotHandleEvent:@"$.chat.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            if (handlerCalled) {
                handler();
            }
            
            handlerCalled = YES;
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
        [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
        [syncChat emitEventLocally:@"$.session.notify.chat.leave", leavePayload, nil];
    }];
}


#pragma mark - Tests :: restore

- (void)testRestore_ShouldRequestChatsForGroups {
    
    self.usesMockedObjects = YES;
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client synchronizeSessionWithCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [session restore];
    }];
}

- (void)testRestore_ShouldNotifyJoinEvent_WhenReceivedChat {
    
    self.usesMockedObjects = YES;
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    NSString *expectedChatName = @"test-chat";
    
    
    OCMStub([self.client synchronizeSessionWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSString *, NSArray<NSString *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        handlerBlock(CENChatGroup.custom, @[expectedChatName]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.data;
            
            XCTAssertEqualObjects(chat.name, expectedChatName);
            handler();
        };
    } afterBlock:^{
        [session restore];
    }];
}


#pragma mark - Tests :: joinChat

-(void)testJoinChat_ShouldEmitSynchronizationEvent_WhenPassedChatIsNotInSynchronizedChatsList {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedData = @{ @"subject": [chat dictionaryRepresentation] };
    [self.client removeChat:chat];

    
    id chatMock = [self mockForObject:syncChat];
    OCMStub([self.client synchronizationChat]).andReturn(chatMock);
    
    id recorded = OCMExpect([chatMock emitEvent:@"$.session.notify.chat.join" withData:expectedData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [session listenEvents];
        [session joinChat:chat];
    }];
}

    -(void)testJoinChat_ShouldNotEmitSynchronizationEvent_WhenPassedChatAlreadyInSynchronizedChatsList {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *joinPayload = [self synchronizationEventFor:chat.name isPrivate:NO];
    
    
    id chatMock = [self mockForObject:syncChat];
    OCMStub([self.client synchronizationChat]).andReturn(chatMock);
    
    [self object:self.client shouldNotHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    }];
    
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$.session.notify.chat.join" withData:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [session joinChat:chat];
    }];
}


#pragma mark - Tests :: leaveChat

-(void)testLeaveChat_ShouldEmitSynchronizationEvent_WhenPassedChatInSynchronizedChatsList {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *joinPayload = [self synchronizationEventFor:chat.name isPrivate:NO];
    NSDictionary *expectedData = @{ @"subject": [chat dictionaryRepresentation] };
    [self.client removeChat:chat];
    
    
    id chatMock = [self mockForObject:syncChat];
    OCMStub([self.client synchronizationChat]).andReturn(chatMock);
    
    id recorded = OCMExpect([chatMock emitEvent:@"$.session.notify.chat.leave" withData:expectedData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client handleEventOnce:@"$.chat.join" withHandlerBlock:^(CENEmittedEvent *event) {
            CENSession *session = event.emitter;
            
            [session leaveChat:chat];
        }];
        
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    }];
}

-(void)testLeaveChat_ShouldEmitSynchronizationEvent_WhenPassedChatNotInSynchronizedChatsList {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *expectedData = @{ @"subject": [chat dictionaryRepresentation] };
    [self.client removeChat:chat];
    
    
    id chatMock = [self mockForObject:syncChat];
    OCMStub([self.client synchronizationChat]).andReturn(chatMock);
    
    id recorded = OCMExpect([chatMock emitEvent:@"$.session.notify.chat.leave" withData:expectedData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [session listenEvents];
        [session leaveChat:chat];
    }];
}


#pragma mark - Tests :: chats

- (void)testChats_ShouldBeEmpty_WhenNoSynchronizationHasBeenDone {
    
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    XCTAssertEqual(session.chats.count, 0);
}

- (void)testChats_ShouldContainChats_WhenSynchronizationEventReceived {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    NSDictionary *joinPayload = [self synchronizationEventFor:@"test-chat" isPrivate:NO];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    OCMStub([self.client synchronizationChat]).andReturn(syncChat);
    
    [self object:self.client shouldHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqualObjects(emittedEvent.emitter, session);
            XCTAssertEqual(session.chats.count, 1);
            handler();
        };
    } afterBlock:^{
        [session listenEvents];
        [syncChat emitEventLocally:@"$.session.notify.chat.join", joinPayload, nil];
    }];
}


#pragma mark - Tests :: destruct

- (void)testDestruct_ShouldCleanUpUsedResources {
    
    self.usesMockedObjects = YES;
    CENChat *syncChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:syncChat];
    OCMStub([self.client synchronizationChat]).andReturn(chatMock);
    
    id recorded = OCMExpect([chatMock destruct]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [session listenEvents];
        [session destruct];
    }];
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    NSString *description = [session description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}

- (void)testDescription_ShouldIncludeChatsAndGroupInformation {
    
    self.usesMockedObjects = YES;
    CENSession *session = [CENSession sessionWithChatEngine:self.client];
    
    OCMStub([self.client synchronizeSessionWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSString *, NSArray<NSString *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        handlerBlock(CENChatGroup.custom, @[@"test-chat"]);
    });
    
    [session restore];
    NSString *description = [session description];
    
    XCTAssertTrue([description rangeOfString:CENChatGroup.custom].location != NSNotFound);
}

#pragma mark - Misc

- (NSDictionary *)synchronizationEventFor:(NSString *)chat isPrivate:(BOOL)isPrivate {
    
    NSString *namespace = [self namespaceForTestCaseWithName:self.name];
    
    return @{
        CENEventData.data: @{
            @"subject": @{
                CENChatData.channel: [@[namespace, @"chat#public.", chat] componentsJoinedByString:@"#"],
                CENChatData.private:@(isPrivate),
                CENChatData.group:CENChatGroup.custom
            }
        }
    };
}

#pragma mark -


@end
