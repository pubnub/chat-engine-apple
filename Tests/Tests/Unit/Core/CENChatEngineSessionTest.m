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


#pragma mark Misc

- (void)stubLocalUser;
- (PNErrorStatus *)streamAuditErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSessionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (BOOL)shouldSynchronizeSessionForTestCaseWithName:(NSString *)name {
    
    return YES;
}


#pragma mark - Tests :: listenSynchronizationEvents

- (void)testListenSynchronizationEvents_ShouldRequestSynchronizationManagerHandleEvents {
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([sessionMock listenEvents]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client listenSynchronizationEvents];
    }];
}


#pragma mark - Tests :: synchronizeSession

- (void)testSynchronizeSession_ShouldRequestChatsSynchronizationFromSynchronizationManager {
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([sessionMock restore]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client synchronizeSession];
    }];
}


#pragma mark - Tests :: synchronizeSessionWithCompletion

- (void)testSynchronizeSessionWithCompletion_ShouldRequestListOfChatsForPredefinedGroups {
    
    self.usesMockedObjects = YES;
    NSString *namespace = self.client.currentConfiguration.namespace;
    
    
    [self stubLocalUser];
    
    NSString *localUserUUID = self.client.me.uuid;
    NSString *expectedGroup = [@[namespace, localUserUUID, CENChatGroup.custom] componentsJoinedByString:@"#"];
    
    id recorded = OCMExpect([self.client channelsForGroup:expectedGroup withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client synchronizeSessionWithCompletion:^(NSString *group, NSArray<NSString *> *chats) { }];
    }];
}

- (void)testSynchronizeSessionWithCompletion_ShouldCallHandlerBlock {
    
    self.usesMockedObjects = YES;
    NSString *namespace = self.client.currentConfiguration.namespace;
    NSArray *expectedChats = @[@"Chat1", @"Chat2", @"Chat3"];
    
    
    [self stubLocalUser];
    
    NSString *localUserUUID = self.client.me.uuid;
    NSString *expectedGroup = [@[namespace, localUserUUID, CENChatGroup.custom] componentsJoinedByString:@"#"];
    
    OCMStub([self.client channelsForGroup:expectedGroup withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorStatus *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(expectedChats, nil);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client synchronizeSessionWithCompletion:^(NSString *group, NSArray<NSString *> *chats) {
            XCTAssertEqualObjects(chats, expectedChats);
            handler();
        }];
    }];
}

- (void)testSynchronizeSessionWithCompletion_ShouldThrow_WhenAuditionDidFail {
    
    [self stubLocalUser];
    
    OCMExpect([self.client channelsForGroup:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorStatus *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(nil, [self streamAuditErrorStatus]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client synchronizeSessionWithCompletion:^(NSString *group, NSArray *chats) { }],
                                 NSException, kCENPNErrorDomain);
}

- (void)testSynchronizeSessionWithCompletion_ShouldEmitError_WhenAuditionDidFail {
    
    [self stubLocalUser];
    
    OCMExpect([self.client channelsForGroup:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSArray<NSString *> *, PNErrorStatus *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(nil, [self streamAuditErrorStatus]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.sync" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.data);
            handler();
        };
    } afterBlock:^{
        [self.client synchronizeSessionWithCompletion:^(NSString *group, NSArray<NSString *> *chats) { }];
    }];
}


#pragma mark - Tests :: synchronizeSessionChatJoin

- (void)testSynchronizeSessionChatJoin_ShouldRequestChatJoinUsingSynchronizationManager {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([sessionMock joinChat:expectedChat]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client synchronizeSessionChatJoin:expectedChat];
    }];
}

- (void)testSynchronizeSessionChatJoin_ShouldNotRequestChatJoinUsingSynchronizationManager_WhenSystemChatPassed {
    
    CENChat *expectedChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([[sessionMock reject] joinChat:expectedChat]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client synchronizeSessionChatJoin:expectedChat];
    }];
}

- (void)testSynchronizeSessionChatJoin_ShouldNotRequestChatJoinUsingSynchronizationManager_WhenGlobalChatPassed{
    
    self.usesMockedObjects = YES;
    CENChat *expectedChat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client global]).andReturn(expectedChat);
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([[sessionMock reject] joinChat:expectedChat]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client synchronizeSessionChatJoin:expectedChat];
    }];
}


#pragma mark - Tests :: synchronizeSessionChatLeave

- (void)testSynchronizeSessionChatLeave_ShouldRequestChatLeaveUsingSynchronizationManager {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([sessionMock leaveChat:expectedChat]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client synchronizeSessionChatLeave:expectedChat];
    }];
}

- (void)testSynchronizeSessionChatLeave_ShouldNotRequestChatLeaveUsingSynchronizationManager_WhenSystemChatPassed {
    
    CENChat *expectedChat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([[sessionMock reject] leaveChat:expectedChat]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client synchronizeSessionChatLeave:expectedChat];
    }];
}

- (void)testSynchronizeSessionChatLeave_ShouldNotRequestChatLeaveUsingSynchronizationManager_WhenGlobalChatPassed {
    
    self.usesMockedObjects = YES;
    CENChat *expectedChat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client global]).andReturn(expectedChat);
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([[sessionMock reject] leaveChat:expectedChat]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client synchronizeSessionChatLeave:expectedChat];
    }];
}


#pragma mark - Tests :: destroySession

- (void)testDestroySession_ShouldStopSynchronizationEventsHandling {
    
    id sessionMock = [self mockForObject:self.client.synchronizationSession];
    id recorded = OCMExpect([sessionMock destruct]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client destroySession];
    }];
}


#pragma mark - Tests :: synchronizationChat

- (void)testSynchronizationChat_ShouldConstructChatToListenSynchronizationEvents {
    
    NSString *expectedGroup = CENChatGroup.system;
    BOOL expectedAutoConnect = YES;
    BOOL expectedPrivate = NO;
    
    
    [self stubLocalUser];
    NSString *namespace = self.client.currentConfiguration.namespace;
    NSString *localUserUUID = self.client.me.uuid;
    NSString *expectedChat = [@[namespace, @"user", localUserUUID, @"me.", @"sync"] componentsJoinedByString:@"#"];
    
    id recorded = OCMExpect([self.client createChatWithName:expectedChat group:expectedGroup private:expectedPrivate
                                                autoConnect:expectedAutoConnect metaData:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client synchronizationChat];
    }];
}


#pragma mark - Misc

- (void)stubLocalUser {
    
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
    OCMStub([self.client pubnub]).andReturn(@"PubNub");
    OCMStub([self.client connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handleBlock(nil);
    });
    
    OCMStub([self.client me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.client]);
}

- (PNErrorStatus *)streamAuditErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNChannelsForGroupOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}


#pragma mark -


@end
