/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPNFunctionClient.h>
#import <CENChatEngine/CENSession+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChatsManager.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <PubNub/PNResult+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineChatsTest : CENTestCase


#pragma mark - Misc

- (PNPresenceChannelHereNowResult *)hereNowResult;
- (PNErrorStatus *)errorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineChatsTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}


#pragma mark - Tests :: Chat

- (void)testChat_ShouldReturnBuilder {
    
    XCTAssertTrue([self.client.Chat() isKindOfClass:[CENChatBuilderInterface class]]);
}


#pragma mark - Tests :: Chat / createChatWithName

- (void)testChatCreateChatWithName_ShouldCreateChatWithDefaultsUsingChatsManager {
    
    BOOL expectedAutoConnect = YES;
    BOOL expectedPrivate = NO;
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock createGlobalChat:NO withName:nil group:nil private:expectedPrivate
                                              autoConnect:expectedAutoConnect metaData:nil]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.Chat().create();
    }];
}

- (void)testChatCreateChatWithName_ShouldCreateCustomPrivateChatUsingChatsManager {
    
    NSString *name = @"test-chat";
    NSDictionary *meta = nil;
    BOOL autoConnect = NO;
    BOOL isPrivate = YES;
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock createGlobalChat:NO withName:name group:nil private:isPrivate autoConnect:autoConnect
                                                 metaData:meta]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.Chat().name(name).private(isPrivate).autoConnect(autoConnect).create();
    }];
    
    recorded = OCMExpect([managerMock createGlobalChat:NO withName:name group:nil private:isPrivate autoConnect:autoConnect
                                              metaData:meta]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client createChatWithName:name private:isPrivate autoConnect:autoConnect metaData:meta];
    }];
}

#pragma mark - Tests :: Chat / chatWithName

- (void)testChatChatWithName_ShouldSearchChatUsingChatsManager {
    
    NSString *name = @"test-chat";
    BOOL isPrivate = YES;
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock chatWithName:name private:isPrivate]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        self.client.Chat().name(name).private(isPrivate).get();
    }];
}


#pragma mark - Tests :: createGlobalChat

- (void)testCreateGlobalChat_ShouldCreateGlobalChatWithDefaultsUsingChatsManager {
    
    NSString *name = @"global";
    NSString *group = CENChatGroup.custom;
    BOOL autoConnect = YES;
    BOOL isPrivate = NO;
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock createGlobalChat:YES withName:name group:group private:isPrivate autoConnect:autoConnect
                                                 metaData:nil]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client createGlobalChatWithChannel:nil];
    }];
}

- (void)testCreateGlobalChat_ShouldCreateCustomGlobalChatUsingChatsManager {
    
    NSString *name = @"global-test";
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock createGlobalChat:YES withName:name group:CENChatGroup.custom private:NO autoConnect:YES
                                                 metaData:nil]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client createGlobalChatWithChannel:name];
    }];
}


#pragma mark - Tests :: createDirectChatForUser

- (void)testCreateDirectChatForUser_ShouldCreateChatUsingChatsManager {
    
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSString *namespace = self.client.configuration.namespace;
    NSString *name = [@[namespace, @"user", user.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    NSString *group = CENChatGroup.system;
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock createGlobalChat:NO withName:name group:group private:NO autoConnect:NO metaData:nil]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client createDirectChatForUser:user];
    }];
}


#pragma mark - Tests :: createFeedChatForUser

- (void)testCreateFeedChatForUser_ShouldCreateChatUsingChatsManager {
    
    CENUser *user = [CENUser userWithUUID:@"remoter" state:@{} chatEngine:self.client];
    NSString *namespace = self.client.configuration.namespace;
    NSString *name = [@[namespace, @"user", user.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    NSString *group = CENChatGroup.system;
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock createGlobalChat:NO withName:name group:group private:NO autoConnect:NO metaData:nil]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client createFeedChatForUser:user];
    }];
}


#pragma mark - Tests :: removeChat

- (void)testRemoveChat_ShouldRequestChatRemovalUsingChatsManager {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock removeChat:chat]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client removeChat:chat];
    }];
}


#pragma mark - Tests :: fetchRemoteStateForChat

- (void)testFetchRemoteStateForChat_ShouldCallSetOfEndpoints {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSArray<NSDictionary *> *routes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": chat.channel } }];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock callRouteSeries:routes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client fetchMetaForChat:chat withCompletion:^(BOOL success, NSArray * responses) { }];
    }];
}

- (void)testFetchRemoteStateForChat_ShouldUpdateChatMeta_WhenStateFetchedSuccessfully {
    
    NSDictionary *metaData = @{ CENEventData.chat: @{ @"meta": @{ @"cloud": @[@"stored",@"meta"] } } };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(YES, @[metaData]);
    });
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock updateMetaWithFetchedData:metaData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client fetchMetaForChat:chat withCompletion:^(BOOL success, NSArray * responses) { }];
    }];
}

- (void)testFetchRemoteStateForChat_ShouldNotUpdateChatMeta_WhenStateFetchedDidFail {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil]]);
    });
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([[chatMock reject] updateMetaWithFetchedData:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client fetchMetaForChat:chat withCompletion:^(BOOL success, NSArray * responses) { }];
    }];
}

#pragma mark - Tests :: pushUpdatedChatMeta

- (void)testPushUpdatedChatMeta_ShouldCallSetOfEndpoints {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *representation = [chat dictionaryRepresentation];
    NSArray<NSDictionary *> *routes = @[@{ @"route": @"chat", @"method": @"post", @"body": @{ @"chat": representation } }];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock callRouteSeries:routes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client pushUpdatedChatMeta:chat withRepresentation:representation];
    }];
}

- (void)testPushUpdatedChatMeta_ShouldThrow_WhenStatePushDidFail {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *representation = [chat dictionaryRepresentation];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil]]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client pushUpdatedChatMeta:chat withRepresentation:representation], NSException,
                                 kCENPNFunctionErrorDomain);
}

- (void)testPushUpdatedChatMeta_ShouldEmitError_WhenStatePushDidFail {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *representation = [chat dictionaryRepresentation];
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[error]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.meta" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSError *emittedError = emittedEvent.data;
            
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedError);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            XCTAssertEqualObjects(emittedError.userInfo[NSUnderlyingErrorKey], error);
            handler();
        };
    } afterBlock:^{
        [self.client pushUpdatedChatMeta:chat withRepresentation:representation];
    }];
}


#pragma mark - Tests :: updateChatState

- (void)testUpdateChatState_ShouldUpdateStateOnChat {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *state = @{ @"test": @"state" };
    
    
    id recorded = OCMExpect([self.client setClientState:state forChannel:chat.channel withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client updateChatState:chat withData:state completion:^(NSError *error) { }];
    }];
}

- (void)testUpdateChatState_ShouldCallCompletionBlock {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *state = @{ @"test": @"state" };
    
    
    OCMStub([self.client setClientState:[OCMArg any] forChannel:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSetStateCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:3];
            PNClientStateUpdateStatus *status = nil;
            block(status);
        });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client updateChatState:chat withData:state completion:^(NSError *error) {
            handler();
        }];
    }];
}

- (void)testUpdateChatState_ShouldCallCompletionBlockWithError_WhenUpdateDidFail {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *state = @{ @"test": @"state" };
    
    
    OCMStub([self.client setClientState:[OCMArg any] forChannel:[OCMArg any] withCompletion:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        PNSetStateCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:3];
        block((id)[self errorStatus]);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client updateChatState:chat withData:state completion:^(NSError *error) {
            XCTAssertNotNil(error);
            handler();
        }];
    }];
}


#pragma mark - Tests :: connectToChat

- (void)testConnectToChat_ShouldRequestAccessRights {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectToChat:chat withCompletion:^{ }];
    }];
}

- (void)testConnectToChat_ShouldWaitForLocalUser_WhenClientNotReady {
    
    self.usesMockedObjects = YES;
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client isReady]).andReturn(NO);
    OCMStub([self.client me]).andReturn(user);
    [self stubChatHandshake];
    
    id recorded = OCMExpect([self.client handleEventOnce:@"$.ready" withHandlerBlock:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectToChat:chat withCompletion:^{ }];
    }];
}

- (void)testConnectToChat_ShouldWaitForLocalUser_WhenMeNotSet {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client isReady]).andReturn(YES);
    [self stubChatHandshake];
    
    id recorded = OCMExpect([self.client handleEventOnce:@"$.ready" withHandlerBlock:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectToChat:chat withCompletion:^{ }];
    }];
}

- (void)testConnectToChat_ShouldSynchronize_WhenClientIsReady {
    
    self.usesMockedObjects = YES;
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client isReady]).andReturn(YES);
    OCMStub([self.client me]).andReturn(user);
    [self stubChatHandshake];
    
    id recorded = OCMExpect([self.client synchronizeSessionChatJoin:chat]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectToChat:chat withCompletion:^{ }];
    }];
}

- (void)testConnectToChat_ShouldSynchronize_WhenEmittedReady {
    
    self.usesMockedObjects = YES;
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client isReady]).andReturn(YES);
    [self stubChatHandshake];
    
    id recorded = OCMExpect([self.client synchronizeSessionChatJoin:chat]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectToChat:chat withCompletion:^{ }];
        [self.client emitEventLocally:@"$.ready", user, nil];
    }];
}


#pragma mark - Tests :: connectChats

- (void)testConnectChats_ShouldRequestManagerToConnect {
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock connectChats]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client connectChats];
    }];
}


#pragma mark - Tests :: disconnectChats

- (void)testDisconnectChats_ShouldRequestManagerToDisconnect {
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock disconnectChats]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client disconnectChats];
    }];
}


#pragma mark - Tests :: inviteToChat

- (void)testInviteToChat_ShouldCallSetOfEndpoints {
    
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSArray<NSDictionary *> *routes = @[@{
        @"route": @"invite",
        @"method": @"post",
        @"body": @{ @"to": user.uuid, @"chat": [chat dictionaryRepresentation] }
    }];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock callRouteSeries:routes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client inviteToChat:chat user:user];
    }];
}

- (void)testInviteToChat_ShouldEmitInviteEvent_WhenHandshakeForUserSuccessful {
    
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *inviteData = @{ @"channel": chat.channel };
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id chatMock = [self mockForObject:user.direct];
    id recorded = OCMExpect([chatMock emitEvent:@"$.invite" withData:inviteData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client inviteToChat:chat user:user];
    }];
}

- (void)testInviteToChat_ShouldThrow_WhenHandshakeForUserUnsuccessful {
    
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(NO, @[error]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client inviteToChat:chat user:user], NSException, kCENPNFunctionErrorDomain);
}

- (void)testInviteToChat_ShouldEmitError_WhenHandshakeForUserUnsuccessful {
    
    CENUser *user = [CENUser userWithUUID:@"tester" state:@{} chatEngine:self.client];
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handlerBlock(NO, @[error]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.invite" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSError *emittedError = emittedEvent.data;
            
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedError);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            XCTAssertEqualObjects(emittedError.userInfo[NSUnderlyingErrorKey], error);
            handler();
        };
    } afterBlock:^{
        [self.client inviteToChat:chat user:user];
    }];
}

#pragma mark - Tests :: leaveChat

- (void)testLeaveChat_ShouldCallSetOfEndpoints {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSArray<NSDictionary *> *routes = @[@{
        @"route": @"leave",
        @"method": @"post",
        @"body": @{ @"chat": [chat dictionaryRepresentation] }
    }];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([clientMock callRouteSeries:routes withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client leaveChat:chat];
    }];
}

- (void)testLeaveChat_ShouldEmitDisconnect_WhenLeaveSuccessful {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock emitEventLocally:@"$.disconnected" withParameters:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client leaveChat:chat];
    }];
}

- (void)testLeaveChat_ShouldEmitLeaveForRemoteUsers_WhenLeaveSuccessful {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *data = @{ @"subject": [chat dictionaryRepresentation] };
    NSString *event = @"$.system.leave";
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock emitEvent:event withData:data]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client leaveChat:chat];
    }];
}

- (void)testLeaveChat_ShouldSynchronizeLeaveFromChat_WhenLeaveSuccessful {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(YES, @[]);
    });
    
    id recorded = OCMExpect([self.client synchronizeSessionChatLeave:chat]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client leaveChat:chat];
    }];
}

- (void)testLeaveChat_ShouldNotLeave_WhenSystemChatPassed {
    
    CENChat *chat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([[clientMock reject] callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client leaveChat:chat];
    }];
}

- (void)testLeaveChat_ShouldNotLeave_WhenGlobalChatPassed {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatFromGroup:CENChatGroup.system withChatEngine:self.client];
    
    
    OCMStub([self.client global]).andReturn(chat);
    
    id clientMock = [self mockForObject:self.client.functionClient];
    id recorded = OCMExpect([[clientMock reject] callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]);
    [self waitForObject:clientMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.client leaveChat:chat];
    }];
}

- (void)testLeaveChat_ShouldThrow_WhenLeaveDidFail {
    
    self.usesMockedObjects = YES;
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(NO, @[error]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client leaveChat:chat], NSException, kCENPNFunctionErrorDomain);
}

- (void)testLeaveChat_ShouldEmitError_WhenLeaveDidFail {
    
    self.usesMockedObjects = YES;
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id clientMock = [self mockForObject:self.client.functionClient];
    OCMStub([clientMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(BOOL, NSArray *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(NO, @[error]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSError *emittedError = emittedEvent.data;
            
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedError);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            XCTAssertEqualObjects(emittedError.userInfo[NSUnderlyingErrorKey], error);
            handler();
        };
    } afterBlock:^{
        [self.client leaveChat:chat];
    }];
}


#pragma mark - Tests :: fetchParticipantsForChat

- (void)testFetchParticipantsForChat_ShouldRequestParticipantsList {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client fetchParticipantsForChannel:chat.channel completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client fetchParticipantsForChat:chat];
    }];
}

- (void)testFetchParticipantsForChat_ShouldCreateUserWithState_WhenListReceived {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    PNPresenceChannelHereNowResult *result = [self hereNowResult];
    NSDictionary *userData = result.data.uuids[0];
    
    
    OCMStub([self.client fetchParticipantsForChannel:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNHereNowCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:2];
        block(result, nil);
    });
    
    OCMExpect([self.client createUserWithUUID:userData[@"uuid"] state:userData[@"state"]]).andForwardToRealObject();
    
    [self.client fetchParticipantsForChat:chat];
    
    OCMVerify(self.client);
}

- (void)testFetchParticipantsForChat_ShouldHandleOnlineUsersRefresh_WhenListReceived {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    PNPresenceChannelHereNowResult *result = [self hereNowResult];
    NSDictionary *states = @{ result.data.uuids[0][@"uuid"]: result.data.uuids[0][@"state"] };
    
    
    OCMStub([self.client fetchParticipantsForChannel:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNHereNowCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:2];
        block(result, nil);
    });
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock handleRemoteUsers:[OCMArg any] stateChange:states]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client fetchParticipantsForChat:chat];
    }];
    
    OCMVerify(self.client);
}

- (void)testFetchParticipantsForChat_ShouldThrow_WhenFetchDidFail {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client fetchParticipantsForChannel:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNHereNowCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:2];
        block(nil, [self errorStatus]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client fetchParticipantsForChat:chat], NSException, kCENPNErrorDomain);
}

- (void)testFetchParticipantsForChat_ShouldEmitError_WhenFetchDidFail {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    OCMStub([self.client fetchParticipantsForChannel:[OCMArg any] completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        PNHereNowCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:2];
        block(nil, [self errorStatus]);
    });
    
    [self object:self.client shouldHandleEvent:@"$.error.presence" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertNotNil(emittedEvent.emitter);
            XCTAssertNotNil(emittedEvent.data);
            XCTAssertEqualObjects(emittedEvent.emitter, chat);
            handler();
        };
    } afterBlock:^{
        [self.client fetchParticipantsForChat:chat];
    }];
}


#pragma mark - Test :: chats

- (void)testChats_ShouldRequestListOfChatsUsingChatsManager {
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock chats]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client chats];
    }];
}

#pragma mark - Test :: global

- (void)testGlobal_ShouldRequestGlobalChatUsingChatsManager {
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock global]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client global];
    }];
}


#pragma mark - Test :: destroyChats

- (void)testDestroyChats_ShouldRequestChatsManagerDestruction {
    
    id managerMock = [self mockForObject:self.client.chatsManager];
    id recorded = OCMExpect([managerMock destroy]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client destroyChats];
    }];
}


#pragma mark - Misc

- (PNPresenceChannelHereNowResult *)hereNowResult {
    
    NSArray *usersData = @[@{ @"uuid": [NSUUID UUID].UUIDString, @"state": @{ @"user-state": @"good" } }];
    NSDictionary *serviceData = @{ @"uuids": usersData, @"occupancy": @(1) };
    
    return [PNPresenceChannelHereNowResult objectForOperation:PNHereNowForChannelOperation completedWithTask:nil
                                                processedData:serviceData processingError:nil];
}

- (PNErrorStatus *)errorStatus {
    
    return [PNErrorStatus objectForOperation:PNHereNowForChannelOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}

#pragma mark -


@end
