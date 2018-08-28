/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
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


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, weak) CENChat *global;
@property (nonatomic, nullable, weak) CENChat *globalMock;


#pragma mark - Misc

- (PNPresenceChannelHereNowResult *)hereNowResultWithState:(BOOL)addState;
- (PNErrorStatus *)hereNowErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineChatsTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.synchronizeSession = [self.name rangeOfString:@"SynchronizationChat"].location != NSNotFound;
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    BOOL mockDirectFeed = ([self.name rangeOfString:@"DirectChatForUser"].location == NSNotFound &&
                           [self.name rangeOfString:@"FeedChatForUser"].location == NSNotFound);
    BOOL mockChatConnection = [self.name rangeOfString:@"ConnectToChat"].location == NSNotFound;
    
    if (mockDirectFeed) {
        OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
            .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
        OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
            .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    }
    
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);
    
    if ([self.name rangeOfString:@"FetchParticipants"].location == NSNotFound) {
        OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    }
    
    if (mockChatConnection) {
        OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
            void(^handleBlock)(NSDictionary *) = nil;
            
            [invocation getArgument:&handleBlock atIndex:3];
            handleBlock(nil);
        });
    }
    
    [self.clientMock createGlobalChat];
    
    self.global = self.client.global;
    if ([self.name rangeOfString:@"testFetchParticipantsForChat_ShouldRequestParticipantsListWithStates_WhenRequestedForGlobalChat"].location == NSNotFound) {
        self.globalMock = [self partialMockForObject:self.global];
        OCMStub([self.clientMock global]).andReturn(self.globalMock);
        OCMStub([self.clientMock.global connected]).andReturn(YES);
    }
    
    if (configuration.shouldSynchronizeSession) {
        [self.client.synchronizationSession listenEvents];
    }
}


#pragma mark - Tests :: Chat / createChatWithName

- (void)testChatCreateChatWithName_ShouldCreateChatInstance {
    
    XCTAssertNotNil(self.client.Chat().name(@"test-chat").autoConnect(NO).create());
}

- (void)testChatCreateChatWithName_ShouldCreateChatInstanceWithRandomName {
    
    CENChat *chat = self.client.Chat().autoConnect(NO).create();
    
    XCTAssertNotNil(chat.name);
    XCTAssertGreaterThan(chat.name.length, 0);
}

- (void)testChatCreateChatWithName_ShouldCreatePrivateChatInstance {
    
    CENChat *chat = self.client.Chat().name(@"test-chat").private(YES).autoConnect(NO).create();
    
    XCTAssertTrue(chat.isPrivate);
}

- (void)testChatCreateChatWithName_ShouldCreateChatInstanceWithMetaData {
    
    NSDictionary *expectedMeta = @{ @"test": @"meta" };
    CENChat *chat = self.client.Chat().name(@"test-chat").meta(expectedMeta).autoConnect(NO).create();
    
    XCTAssertNotNil(chat.meta);
    XCTAssertEqualObjects(chat.meta, expectedMeta);
}

- (void)testChatCreateChatWithName_ShouldReturnExistingChatInstance {
    
    CENChat *chat1 = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    CENChat *chat2 = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    
    XCTAssertEqual(chat2, chat1);
}


#pragma mark - Tests :: Chat / chatWithName

- (void)testChatChatWithName_ShouldFindAndReturnChatByName {
    
    CENChat *chat1 = self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    CENChat *chat2 = self.client.Chat().name(@"test-chat").get();
    
    XCTAssertNotNil(chat2);
    XCTAssertEqual(chat2, chat1);
}

- (void)testChatChatWithName_ShouldNotFindChatByName_WhenDifferentPrivacyPassed {
    
    self.client.Chat().name(@"test-chat").autoConnect(NO).create();
    
    CENChat *chat = self.client.Chat().name(@"test-chat").private(YES).get();
    
    XCTAssertNil(chat);
}


#pragma mark - Tests :: createGlobalChat

- (void)testCreateGlobalChat_ShouldCreateGlobalChat {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.client.chatsManager];
    NSString *expectedGlobalChat = self.client.currentConfiguration.globalChannel;
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([chatsManagerPartialMock createChatWithName:expectedGlobalChat group:expectedGroup private:NO autoConnect:YES metaData:nil])
        .andDo(nil);
    
    [self.client createGlobalChat];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: createDirectChatForUser

- (void)testCreateDirectChatForUser_ShouldCreateInstanceForLocalUser {
    
    NSString *globalChannel = self.clientMock.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", self.clientMock.me.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.clientMock createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:NO metaData:nil])
        .andDo(nil);
    
    [self.clientMock createDirectChatForUser:self.clientMock.me];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testCreateDirectChatForUser_ShouldCreateInstanceForRemoteUser {
    
    CENUser *user = [CENUser userWithUUID:@"remoter" state:@{} chatEngine:self.clientMock];
    NSString *globalChannel = self.clientMock.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", user.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.clientMock createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:NO metaData:nil]).andDo(nil);
    
    [self.clientMock createDirectChatForUser:user];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: createFeedChatForUser

- (void)testCreateFeedChatForUser_ShouldCreateInstanceForLocalUser {
    
    NSString *globalChannel = self.clientMock.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", self.clientMock.me.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.clientMock createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:NO metaData:nil]).andDo(nil);
    
    [self.clientMock createFeedChatForUser:self.clientMock.me];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testCreateFeedChatForUser_ShouldCreateInstanceForRemoteUser {
    
    CENUser *user = [CENUser userWithUUID:@"remoter" state:@{} chatEngine:self.clientMock];
    NSString *globalChannel = self.clientMock.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", user.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.clientMock createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:NO metaData:nil]).andDo(nil);
    
    [self.clientMock createFeedChatForUser:user];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: removeChat

- (void)testRemoveChat_ShouldRequestChatRemoval {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.client.chatsManager];
    CENChat *expectedChat = self.client.me.direct;
    
    OCMExpect([chatsManagerPartialMock removeChat:expectedChat]).andDo(nil);
    
    [self.client removeChat:expectedChat];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: fetchRemoteStateForChat

- (void)testFetchRemoteStateForChat_ShouldCallSetOfEndpoints {
    
    CENChat *expectedChat = self.client.me.direct;
    NSArray<NSDictionary *> *expectedRoutes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": expectedChat.channel } }];
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;

        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client fetchRemoteStateForChat:expectedChat withCompletion:^(BOOL isError, NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchRemoteStateForChat_ShouldUpdateChatMeta_WhenStateFetchedSuccessfully {
    
    CENChat *expectedChat = self.clientMock.global;
    NSArray<NSDictionary *> *expectedRoutes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": expectedChat.channel } }];
    NSDictionary *expectedMeta = @{ @"cloud": @[@"stored",@"meta"] };
    NSDictionary *remoteMetaData = @{ CENEventData.chat: @{ @"meta": expectedMeta } };
    id functionsClientPartialMock = [self partialMockForObject:self.clientMock.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, @[remoteMetaData]);
    });
    
    OCMExpect([self.clientMock handleFetchedMeta:expectedMeta forChat:expectedChat]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        [invocation invoke];
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock fetchRemoteStateForChat:expectedChat withCompletion:^(BOOL success, NSDictionary * _Nonnull meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
    XCTAssertEqualObjects(expectedChat.meta, expectedMeta);
}


#pragma mark - Tests :: handleFetchedMeta

- (void)testHandleFetchedMeta_ShouldRequestChatToUpdateMeta {
    
    CENChat *chat = self.client.global;
    NSDictionary *expectedMeta = @{ @"cloud": @[@"stored",@"meta"] };
    
    [self.client handleFetchedMeta:expectedMeta forChat:chat];
    
    XCTAssertEqualObjects(chat.meta, expectedMeta);
}


#pragma mark - Tests :: updateChatState

- (void)testUpdateChatState_ShouldUpdateStateOnGlobalChat {
    
    NSString *expectedChannel = self.clientMock.currentConfiguration.globalChannel;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"meta" };
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.clientMock setClientState:expectedState forChannel:expectedChannel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNClientStateUpdateStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:4];
            handlerBlock(nil);
        });
    
    [self.clientMock updateChatState:self.clientMock.me.direct withData:expectedState completion:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: pushUpdatedChatMeta

- (void)testPushUpdatedChatMeta_ShouldCallSetOfEndpoints {
    
    CENChat *expectedChat = self.client.me.direct;
    NSArray<NSDictionary *> *expectedRoutes = @[
        @{ @"route": @"chat", @"method": @"post", @"body": @{ @"chat": [expectedChat dictionaryRepresentation] } }
    ];
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client pushUpdatedChatMeta:expectedChat withRepresentation:[expectedChat dictionaryRepresentation]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertFalse(handlerCalled);
}

- (void)testPushUpdatedChatMeta_ShouldThrowEmitError_WhenUpdateUnsuccessful {
    
    CENChat *expectedChat = self.client.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client pushUpdatedChatMeta:expectedChat withRepresentation:[expectedChat dictionaryRepresentation]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testPushUpdatedChatMeta_ShouldThrowEmitError_WhenUpdateUnsuccessfulWithUnknownError {
    
    CENChat *expectedChat = self.client.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error.userInfo[NSUnderlyingErrorKey]);
        XCTAssertEqualObjects(((NSError *)error.userInfo[NSUnderlyingErrorKey]).localizedDescription, @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client pushUpdatedChatMeta:expectedChat withRepresentation:[expectedChat dictionaryRepresentation]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: connectToChat

- (void)testConnectToChat_ShouldRequestAccessRights {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotCompleteConnection_WhenAccessRightsRequesDidFail {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] synchronizeSessionChatJoin:expectedChat]);
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) {
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertFalse(handlerCalled);
}

- (void)testConnectToChat_ShouldSynchronizeJoinToChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.Chat().group(CENChatGroup.system).autoConnect(NO).create();
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([(id)self.clientMock synchronizeSessionChatJoin:expectedChat]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotSynchronizeJoinToChat_WhenItIsGlobalChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.global;
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] synchronizeSessionChatJoin:expectedChat]);
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectToChat_ShouldNotSynchronizeJoinToChat_WhenItIsDirectChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.me.direct;
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] synchronizeSessionChatJoin:expectedChat]);
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectToChat_ShouldNotSynchronizeJoinToChat_WhenItIsFeedChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.me.feed;
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] synchronizeSessionChatJoin:expectedChat]);
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectToChat_ShouldNotifyLocalUserJoin_WhenClientIsReady {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.Chat().autoConnect(NO).create();
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.online.join", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqual(user, self.clientMock.me);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotifyLocalUserJoin_WhenClientNotReadyYet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.clientMock.Chat().autoConnect(NO).create();
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.online.join", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqual(user, self.clientMock.me);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    [self.clientMock emitEventLocally:@"$.ready", self.clientMock.me, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldFetchParticipants_WhenCustomChatPassed {
    
    CENChat *expectedChat = self.clientMock.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([self.clientMock fetchParticipantsForChat:expectedChat]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotFetchParticipants_WhenDirectChatPassed {
    
    CENChat *expectedChat = self.clientMock.me.direct;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] fetchParticipantsForChat:expectedChat]);
    
    [self.clientMock connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectToChat_ShouldNotFetchParticipants_WhenFeedChatPassed {
    
    CENChat *expectedChat = self.client.me.feed;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] fetchParticipantsForChat:expectedChat]);
    
    [self.client connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectToChat_ShouldNotFetchParticipants_WhenSynchronizationChatPassed {
    
    NSString *chatsNamespace = self.client.currentConfiguration.globalChannel;
    NSString *synchronizationChatName = [@[chatsNamespace, @"user", self.client.me.uuid, @"me.", @"sync"] componentsJoinedByString:@"#"];
    CENChat *expectedChat = self.client.Chat().name(synchronizationChatName).get();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMStub([self.clientMock isReady]).andReturn(YES);
    OCMStub([self.clientMock handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([[(id)self.clientMock reject] fetchParticipantsForChat:expectedChat]);
    
    [self.client connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: connectChats

- (void)testConnectChats_ShouldRequestManagerToConnect {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.client.chatsManager];
    OCMExpect([chatsManagerPartialMock connectChats]);
    
    [self.client connectChats];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: connectChats

- (void)testDisconnectChats_ShouldRequestManagerToDisconnect {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.client.chatsManager];
    OCMExpect([chatsManagerPartialMock disconnectChats]);
    
    [self.client disconnectChats];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: inviteToChat

- (void)testInviteToChat_ShouldCallSetOfEndpoints {
    
    CENUser *expectedUser = [CENUser userWithUUID:@"invite-tester" state:@{} chatEngine:self.client];
    CENChat *expectedChat = self.client.me.direct;
    NSDictionary *expectedInviteData = @{ @"channel": expectedChat.channel };
    NSArray<NSDictionary *> *expectedRoutes = @[@{
        @"route": @"invite",
        @"method": @"post",
        @"body": @{ @"to": expectedUser.uuid, @"chat": [expectedChat dictionaryRepresentation] }
    }];
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([self.clientMock publishToChat:expectedChat eventWithName:@"$.invite" data:expectedInviteData]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client inviteToChat:expectedChat user:expectedUser];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testInviteToChat_WhenInviteUnsuccessful {
    
    CENUser *expectedUser = [CENUser userWithUUID:@"invite-tester" state:@{} chatEngine:self.client];
    CENChat *expectedChat = self.client.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    expectedChat.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client inviteToChat:expectedChat user:expectedUser];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testInviteToChat_ShouldThrowEmitError_WhenInviteUnsuccessfulWithUnknownError {
    
    CENUser *expectedUser = [CENUser userWithUUID:@"invite-tester" state:@{} chatEngine:self.client];
    CENChat *expectedChat = self.client.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error.userInfo[NSUnderlyingErrorKey]);
        XCTAssertEqualObjects(((NSError *)error.userInfo[NSUnderlyingErrorKey]).localizedDescription, @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client inviteToChat:expectedChat user:expectedUser];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: leaveChat

- (void)testLeaveChat_ShouldCallSetOfEndpoints {
    
    CENChat *expectedChat = self.client.me.direct;
    NSArray<NSDictionary *> *expectedRoutes = @[@{
        @"route": @"leave",
        @"method": @"post",
        @"body": @{ @"chat": [expectedChat dictionaryRepresentation] }
    }];
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([self.clientMock triggerEventLocallyFrom:expectedChat event:@"$.left" withParameters:@[] completion:nil])
        .andDo(^(NSInvocation *invocation) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        });
    
    [self.clientMock leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testLeaveChat_ShouldUnsubscribeFromChat {
    
    id functionsClientPartialMock = [self partialMockForObject:self.clientMock.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.client.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    OCMExpect([self.clientMock unsubscribeFromChannels:@[expectedChat.channel]]);
    
    [self.clientMock leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}

- (void)testLeaveChat_ShouldSynchronizeLeaveFromChat {
    
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.client.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([(id)self.clientMock synchronizeSessionChatLeave:expectedChat]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testLeaveChat_WhenLeaveUnsuccessful {
    
    CENChat *expectedChat = self.client.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, @[[NSError errorWithDomain:@"TestDomain" code:0 userInfo:nil]]);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testLeaveChat_ShouldThrowEmitError_WhenLeaveUnsuccessfulWithUnknownError {
    
    CENChat *expectedChat = self.client.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.client.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error.userInfo[NSUnderlyingErrorKey]);
        XCTAssertEqualObjects(((NSError *)error.userInfo[NSUnderlyingErrorKey]).localizedDescription, @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: fetchParticipantsForChat

- (void)testFetchParticipantsForChat_ShouldRequestParticipantsListWithOutStates_WhenRequestedForCustomChat {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    
    OCMExpect([self.clientMock fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]]);
    
    [self.client fetchParticipantsForChat:expectedChat];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testFetchParticipantsForChat_ShouldRequestParticipantsListWithStates_WhenRequestedForGlobalChat {
    
    CENChat *expectedChat = self.client.global;
    
    OCMExpect([self.clientMock fetchParticipantsForChannel:expectedChat.channel withState:YES completion:[OCMArg any]]);
    
    [self.client fetchParticipantsForChat:expectedChat];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testFetchParticipantsForChat_ShouldCreateUserWithState_WhenListReceived {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"user-state": @"good" };
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNPresenceChannelHereNowResult *, PNErrorStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:4];
            handlerBlock([self hereNowResultWithState:YES], nil);
        });
    
    self.client.once(@"$.online.join", ^(CENChat *chat, CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertNotNil(user);
        XCTAssertEqual(chat, expectedChat);
        XCTAssertEqualObjects(user.state, expectedState);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client fetchParticipantsForChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchParticipantsForChat_ShouldCreateUserWithOutState_WhenListReceived {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{};
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNPresenceChannelHereNowResult *, PNErrorStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:4];
            handlerBlock([self hereNowResultWithState:NO], nil);
        });
    
    self.client.once(@"$.online.join", ^(CENChat *chat, CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertNotNil(user);
        XCTAssertEqualObjects(user.state, expectedState);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client fetchParticipantsForChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchParticipantsForChat_ShouldThrowEmitError_WhenFetchDidFail {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNPresenceChannelHereNowResult *, PNErrorStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:4];
            handlerBlock(nil, [self hereNowErrorStatus]);
        });
    
    expectedChat.once(@"$.error.presence", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.client fetchParticipantsForChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Test :: chats

- (void)testChats_ShouldReturnListOfCreatedChats {
    
    XCTAssertNotNil(self.client.chats);
    XCTAssertGreaterThanOrEqual(self.client.chats.count, 2);
}


#pragma mark - Test :: global

- (void)testGlobal_ShouldReturnListOfCreatedChats {
    
    XCTAssertNotNil(self.client.global);
    XCTAssertEqualObjects(self.client.global.name, self.client.currentConfiguration.globalChannel);
    XCTAssertEqualObjects(self.client.global.group, CENChatGroup.system);
    XCTAssertFalse(self.client.global.isPrivate);
    XCTAssertFalse(self.client.global.asleep);
}


#pragma mark - Test :: destroyChats

- (void)testDestroyChats_ShouldRequestChatsManagerDestruction {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.client.chatsManager];
    
    OCMExpect([chatsManagerPartialMock destroy]);
    
    [self.client destroyChats];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Misc

- (PNPresenceChannelHereNowResult *)hereNowResultWithState:(BOOL)addState {
    
    NSMutableArray *usersData = [NSMutableArray new];
    NSString *uuid = @"remote-tester-user";
    if (addState) {
        [usersData addObject:@{ @"uuid": uuid, @"state": @{ @"user-state": @"good" } }];
    } else {
        [usersData addObject:uuid];
    }
    
    NSDictionary *serviceData = @{ @"uuids": usersData, @"occupancy": @(1) };
    
    return [PNPresenceChannelHereNowResult objectForOperation:PNHereNowForChannelOperation completedWithTask:nil processedData:serviceData
                                              processingError:nil];
}

- (PNErrorStatus *)hereNowErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNHereNowForChannelOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}

#pragma mark -


@end
