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

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;


#pragma mark - Misc

- (PNErrorStatus *)streamAuditErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSessionTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.synchronizeSession = YES;
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: listenSynchronizationEvents

- (void)testListenSynchronizationEvents_ShouldRequestSynchronizationManagerHandleEvebts {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.defaultClient.synchronizationSession];
    
    OCMExpect([syncrhonizationPartialMock listenEvents]);
    
    [self.defaultClient listenSynchronizationEvents];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizeSession

- (void)testSynchronizeSession_ShouldRequestChatsSynchronizationFromSynchronizationManager {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.defaultClient.synchronizationSession];
    
    OCMExpect([syncrhonizationPartialMock restore]);
    
    [self.defaultClient synchronizeSession];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizeSessionChatsWithCompletion

- (void)testSynchronizeSessionChatsWithCompletion_ShouldRequestListOfChatsForPredefinedGroups {
    
    NSString *globalChat = self.defaultClient.currentConfiguration.globalChannel;
    NSString *localUserUUID = self.defaultClient.me.uuid;
    NSString *expectedCustomGroup = [@[globalChat, localUserUUID, CENChatGroup.custom] componentsJoinedByString:@"#"];
    NSString *expectedSystemGroup = [@[globalChat, localUserUUID, CENChatGroup.system] componentsJoinedByString:@"#"];
    
    OCMExpect([self.defaultClient channelsForGroup:expectedCustomGroup withCompletion:[OCMArg any]]);
    OCMExpect([self.defaultClient channelsForGroup:expectedSystemGroup withCompletion:[OCMArg any]]);
    
    [self.defaultClient synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) { }];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testSynchronizeSessionChatsWithCompletion_ShouldCallHandlerBlock {
    
    NSString *globalChat = self.defaultClient.currentConfiguration.globalChannel;
    NSString *localUserUUID = self.defaultClient.me.uuid;
    NSString *expectedGroup = [@[globalChat, localUserUUID, CENChatGroup.custom] componentsJoinedByString:@"#"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSArray *expectedChats = @[@"Chat1", @"Chat2", @"Chat3"];
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient channelsForGroup:expectedGroup withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorData *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(expectedChats, nil);
    });
    
    [self.defaultClient synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(chats, expectedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testSynchronizeSessionChatsWithCompletion_ShouldThrowEmitError_WhenAuditionDidFail {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient channelsForGroup:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorData *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(nil, [self streamAuditErrorStatus].errorData);
    });
    
    self.defaultClient.once(@"$.error.sync", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: synchronizeSessionChatJoin

- (void)testSynchronizeSessionChatJoin_ShouldRequestChatJoinUsingSynchronizationManager {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.defaultClient.synchronizationSession];
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    
    OCMExpect([syncrhonizationPartialMock joinChat:expectedChat]);
    
    [self.defaultClient synchronizeSessionChatJoin:expectedChat];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizeSessionChatLeave

- (void)testSynchronizeSessionChatLeave_ShouldRequestChatLeaveUsingSynchronizationManager {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.defaultClient.synchronizationSession];
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    
    OCMExpect([syncrhonizationPartialMock leaveChat:expectedChat]);
    
    [self.defaultClient synchronizeSessionChatLeave:expectedChat];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: destroySession

- (void)testDestroySession_ShouldStopSynchronizationEventsHandling {
    
    id syncrhonizationPartialMock = [self partialMockForObject:self.defaultClient.synchronizationSession];
    
    OCMExpect([syncrhonizationPartialMock destruct]);
    
    [self.defaultClient destroySession];
    
    OCMVerifyAll(syncrhonizationPartialMock);
}


#pragma mark - Tests :: synchronizationChat

- (void)testSynchronizationChat_ShouldConstructChatToListenSynchronizationEvents {
    
    NSString *globalChat = self.defaultClient.currentConfiguration.globalChannel;
    NSString *localUserUUID = self.defaultClient.me.uuid;
    NSString *expectedChat = [@[globalChat, @"user", localUserUUID, @"me.", @"sync"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    BOOL expectedPrivate = NO;
    BOOL expectedAutoConnect = YES;
    
    OCMExpect([self.defaultClient createChatWithName:expectedChat group:expectedGroup private:expectedPrivate autoConnect:expectedAutoConnect
                                            metaData:[OCMArg any]]).andForwardToRealObject();
    
    XCTAssertNotNil([self.defaultClient synchronizationChat]);
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Misc

- (PNErrorStatus *)streamAuditErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNChannelsForGroupOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}


#pragma mark -


@end
