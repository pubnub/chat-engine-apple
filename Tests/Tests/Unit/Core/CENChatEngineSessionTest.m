/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENSession+Private.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <PubNub/PNResult+Private.h>
#import "CENTestCase.h"


@interface CENChatEngineSessionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;


#pragma mark - Misc

- (PNErrorStatus *)streamAuditErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSessionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.synchronizeSession = YES;
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);
    
    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}


#pragma mark - Tests :: listenSynchronizationEvents

- (void)testListenSynchronizationEvents_ShouldRequestSynchronizationManagerHandleEvebts {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.client.synchronizationSession];
    
    OCMExpect([syncrhonizationPartialMock listenEvents]);
    
    [self.client listenSynchronizationEvents];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizeSession

- (void)testSynchronizeSession_ShouldRequestChatsSynchronizationFromSynchronizationManager {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.client.synchronizationSession];
    
    OCMExpect([syncrhonizationPartialMock restore]);
    
    [self.client synchronizeSession];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizeSessionChatsWithCompletion

- (void)testSynchronizeSessionChatsWithCompletion_ShouldRequestListOfChatsForPredefinedGroups {
    
    NSString *globalChat = self.clientMock.currentConfiguration.globalChannel;
    NSString *localUserUUID = self.clientMock.me.uuid;
    NSString *expectedCustomGroup = [@[globalChat, localUserUUID, CENChatGroup.custom] componentsJoinedByString:@"#"];
    NSString *expectedSystemGroup = [@[globalChat, localUserUUID, CENChatGroup.system] componentsJoinedByString:@"#"];
    
    OCMExpect([self.clientMock channelsForGroup:expectedCustomGroup withCompletion:[OCMArg any]]);
    OCMExpect([self.clientMock channelsForGroup:expectedSystemGroup withCompletion:[OCMArg any]]);
    
    [self.clientMock synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) { }];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testSynchronizeSessionChatsWithCompletion_ShouldCallHandlerBlock {
    
    NSString *globalChat = self.clientMock.currentConfiguration.globalChannel;
    NSString *localUserUUID = self.clientMock.me.uuid;
    NSString *expectedGroup = [@[globalChat, localUserUUID, CENChatGroup.custom] componentsJoinedByString:@"#"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray *expectedChats = @[@"Chat1", @"Chat2", @"Chat3"];
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock channelsForGroup:expectedGroup withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorStatus *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(expectedChats, nil);
    });
    
    [self.clientMock synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(chats, expectedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testSynchronizeSessionChatsWithCompletion_ShouldThrowEmitError_WhenAuditionDidFail {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.clientMock channelsForGroup:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorStatus *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(nil, [self streamAuditErrorStatus]);
    });
    
    self.clientMock.once(@"$.error.sync", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: synchronizeSessionChatJoin

- (void)testSynchronizeSessionChatJoin_ShouldRequestChatJoinUsingSynchronizationManager {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.client.synchronizationSession];
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    
    OCMExpect([syncrhonizationPartialMock joinChat:expectedChat]);
    
    [self.client synchronizeSessionChatJoin:expectedChat];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizeSessionChatLeave

- (void)testSynchronizeSessionChatLeave_ShouldRequestChatLeaveUsingSynchronizationManager {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.client.synchronizationSession];
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    
    OCMExpect([syncrhonizationPartialMock leaveChat:expectedChat]);
    
    [self.client synchronizeSessionChatLeave:expectedChat];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: destroySession

- (void)testDestroySession_ShouldStopSynchronizationEventsHandling {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.client.synchronizationSession];
    
    OCMExpect([syncrhonizationPartialMock destruct]);
    
    [self.client destroySession];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizationChat

- (void)testSynchronizationChat_ShouldConstructChatToListenSynchronizationEvents {
    
    NSString *globalChat = self.clientMock.currentConfiguration.globalChannel;
    NSString *localUserUUID = self.clientMock.me.uuid;
    NSString *expectedChat = [@[globalChat, @"user", localUserUUID, @"me.", @"sync"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    BOOL expectedPrivate = NO;
    BOOL expectedAutoConnect = YES;
    
    OCMExpect([self.clientMock createChatWithName:expectedChat group:expectedGroup private:expectedPrivate autoConnect:expectedAutoConnect
                                         metaData:[OCMArg any]]).andForwardToRealObject();
    
    XCTAssertNotNil([self.clientMock synchronizationChat]);
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Misc

- (PNErrorStatus *)streamAuditErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNChannelsForGroupOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}


#pragma mark -


@end
