/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPNFunctionClient.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChatsManager.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <PubNub/PNResult+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineChatsTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;


#pragma mark - Misc

- (PNPresenceChannelHereNowResult *)hereNowResultWithState:(BOOL)addState;
- (PNErrorStatus *)hereNowErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineChatsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    BOOL mockDirectFeed = ([self.name rangeOfString:@"DirectChatForUser"].location == NSNotFound &&
                           [self.name rangeOfString:@"FeedChatForUser"].location == NSNotFound);
    BOOL mockChatConnection = [self.name rangeOfString:@"ConnectToChat"].location == NSNotFound;
    
    if (mockDirectFeed) {
        OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
            .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
        OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
            .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    }
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    if (mockChatConnection) {
        OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
            void(^handleBlock)(NSDictionary *) = nil;
            
            [invocation getArgument:&handleBlock atIndex:3];
            handleBlock(nil);
        });
    }
    
    [self.defaultClient createGlobalChat];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Chat / createChatWithName

- (void)testChatCreateChatWithName_ShouldCreateChatInstance {
    
    XCTAssertNotNil(self.defaultClient.Chat().name(@"test-chat").autoConnect(NO).create());
}

- (void)testChatCreateChatWithName_ShouldCreateChatInstanceWithRandomName {
    
    CENChat *chat = self.defaultClient.Chat().autoConnect(NO).create();
    
    XCTAssertNotNil(chat.name);
    XCTAssertGreaterThan(chat.name.length, 0);
}

- (void)testChatCreateChatWithName_ShouldCreatePrivateChatInstance {
    
    CENChat *chat = self.defaultClient.Chat().name(@"test-chat").private(YES).autoConnect(NO).create();
    
    XCTAssertTrue(chat.isPrivate);
}

- (void)testChatCreateChatWithName_ShouldCreateChatInstanceWithMetaData {
    
    NSDictionary *expectedMeta = @{ @"test": @"meta" };
    CENChat *chat = self.defaultClient.Chat().name(@"test-chat").meta(expectedMeta).autoConnect(NO).create();
    
    XCTAssertNotNil(chat.meta);
    XCTAssertEqualObjects(chat.meta, expectedMeta);
}

- (void)testChatCreateChatWithName_ShouldReturnExistingChatInstance {
    
    CENChat *chat1 = self.defaultClient.Chat().name(@"test-chat").autoConnect(NO).create();
    
    CENChat *chat2 = self.defaultClient.Chat().name(@"test-chat").autoConnect(NO).create();
    
    XCTAssertEqual(chat2, chat1);
}


#pragma mark - Tests :: Chat / chatWithName

- (void)testChatChatWithName_ShouldFindAndReturnChatByName {
    
    CENChat *chat1 = self.defaultClient.Chat().name(@"test-chat").autoConnect(NO).create();
    
    CENChat *chat2 = self.defaultClient.Chat().name(@"test-chat").get();
    
    XCTAssertNotNil(chat2);
    XCTAssertEqual(chat2, chat1);
}

- (void)testChatChatWithName_ShouldNotFindChatByName_WhenDifferentPrivacyPassed {
    
    self.defaultClient.Chat().name(@"test-chat").autoConnect(NO).create();
    
    CENChat *chat = self.defaultClient.Chat().name(@"test-chat").private(YES).get();
    
    XCTAssertNil(chat);
}


#pragma mark - Tests :: createGlobalChat

- (void)testCreateGlobalChat_ShouldCreateGlobalChat {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    NSString *expectedGlobalChat = self.defaultClient.currentConfiguration.globalChannel;
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([chatsManagerPartialMock createChatWithName:expectedGlobalChat group:expectedGroup private:NO autoConnect:YES metaData:nil])
        .andDo(nil);
    
    [self.defaultClient createGlobalChat];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: createDirectChatForUser

- (void)testCreateDirectChatForUser_ShouldCreateInstanceForLocalUser {
    
    NSString *globalChannel = self.defaultClient.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", self.defaultClient.me.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.defaultClient createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:YES metaData:nil])
        .andDo(nil);
    
    [self.defaultClient createDirectChatForUser:self.defaultClient.me];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testCreateDirectChatForUser_ShouldCreateInstanceForRemoteUser {
    
    CENUser *user = [CENUser userWithUUID:@"remoter" state:@{} chatEngine:self.defaultClient];
    NSString *globalChannel = self.defaultClient.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", user.uuid, @"write.", @"direct"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.defaultClient createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:NO metaData:nil]).andDo(nil);
    
    [self.defaultClient createDirectChatForUser:user];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: createFeedChatForUser

- (void)testCreateFeedChatForUser_ShouldCreateInstanceForLocalUser {
    
    NSString *globalChannel = self.defaultClient.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", self.defaultClient.me.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.defaultClient createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:YES metaData:nil]).andDo(nil);
    
    [self.defaultClient createFeedChatForUser:self.defaultClient.me];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testCreateFeedChatForUser_ShouldCreateInstanceForRemoteUser {
    
    CENUser *user = [CENUser userWithUUID:@"remoter" state:@{} chatEngine:self.defaultClient];
    NSString *globalChannel = self.defaultClient.configuration.globalChannel;
    NSString *expectedChatName = [@[globalChannel, @"user", user.uuid, @"read.", @"feed"] componentsJoinedByString:@"#"];
    NSString *expectedGroup = CENChatGroup.system;
    
    OCMExpect([self.defaultClient createChatWithName:expectedChatName group:expectedGroup private:NO autoConnect:NO metaData:nil]).andDo(nil);
    
    [self.defaultClient createFeedChatForUser:user];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: removeChat

- (void)testRemoveChat_ShouldRequestChatRemoval {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    CENChat *expectedChat = self.defaultClient.me.direct;
    
    OCMExpect([chatsManagerPartialMock removeChat:expectedChat]).andDo(nil);
    
    [self.defaultClient removeChat:expectedChat];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: fetchRemoteStateForChat

- (void)testFetchRemoteStateForChat_ShouldCallSetOfEndpoints {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    NSArray<NSDictionary *> *expectedRoutes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": expectedChat.channel } }];
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    [self.defaultClient fetchRemoteStateForChat:expectedChat withCompletion:^(BOOL isError, NSDictionary *meta) {
        handlerCalled = YES;
        
        XCTAssertFalse(isError);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchRemoteStateForChat_ShouldUpdateChatMeta_WhenStateFetchedSuccessfully {
    
    CENChat *expectedChat = self.defaultClient.global;
    NSArray<NSDictionary *> *expectedRoutes = @[@{ @"route": @"chat", @"method": @"get", @"query": @{ @"channel": expectedChat.channel } }];
    NSDictionary *expectedMeta = @{ @"cloud": @[@"stored",@"meta"] };
    NSDictionary *remoteMetaData = @{ CENEventData.chat: @{ @"meta": expectedMeta } };
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMStub([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, @[remoteMetaData]);
    });
    
    OCMExpect([self.defaultClient handleFetchedMeta:expectedMeta forChat:expectedChat]).andForwardToRealObject();
    
    [self.defaultClient fetchRemoteStateForChat:expectedChat withCompletion:^(BOOL success, NSDictionary * _Nonnull meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertEqualObjects(expectedChat.meta, expectedMeta);
}


#pragma mark - Tests :: handleFetchedMeta

- (void)testHandleFetchedMeta_ShouldRequestChatToUpdateMeta {
    
    CENChat *chat = self.defaultClient.global;
    NSDictionary *expectedMeta = @{ @"cloud": @[@"stored",@"meta"] };
    
    [self.defaultClient handleFetchedMeta:expectedMeta forChat:chat];
    
    XCTAssertEqualObjects(chat.meta, expectedMeta);
}


#pragma mark - Tests :: updateChatState

- (void)testUpdateChatState_ShouldUpdateStateOnGlobalChat {
    
    NSString *expectedChannel = self.defaultClient.currentConfiguration.globalChannel;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"meta" };
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient setClientState:expectedState forChannel:expectedChannel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNClientStateUpdateStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:4];
            handlerBlock(nil);
        });
    
    [self.defaultClient updateChatState:self.defaultClient.me.direct withData:expectedState completion:^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: pushUpdatedChatMeta

- (void)testPushUpdatedChatMeta_ShouldCallSetOfEndpoints {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    NSArray<NSDictionary *> *expectedRoutes = @[
        @{ @"route": @"chat", @"method": @"post", @"body": @{ @"chat": [expectedChat dictionaryRepresentation] } }
    ];
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
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
    
    [self.defaultClient pushUpdatedChatMeta:expectedChat withRepresentation:[expectedChat dictionaryRepresentation]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    XCTAssertFalse(handlerCalled);
}

- (void)testPushUpdatedChatMeta_ShouldThrowEmitError_WhenUpdateUnsuccessful {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
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
    
    [self.defaultClient pushUpdatedChatMeta:expectedChat withRepresentation:[expectedChat dictionaryRepresentation]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testPushUpdatedChatMeta_ShouldThrowEmitError_WhenUpdateUnsuccessfulWithUnknownError {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient pushUpdatedChatMeta:expectedChat withRepresentation:[expectedChat dictionaryRepresentation]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}



#pragma mark - Tests :: connectToChat

- (void)testConnectToChat_ShouldRequestAccessRights {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.defaultClient.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    [self.defaultClient connectToChat:expectedChat withCompletion:^(NSDictionary *meta){
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotCompleteConnection_WhenAccessRightsRequesDidFail {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.defaultClient.me.direct;
    
    OCMStub([self.defaultClient handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([[(id)self.defaultClient reject] synchronizeSessionChatJoin:expectedChat]);
    
    [self.defaultClient connectToChat:expectedChat withCompletion:^(NSDictionary *meta){ }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testConnectToChat_ShouldSynchronizeJoinToChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.defaultClient.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([(id)self.defaultClient synchronizeSessionChatJoin:expectedChat]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotifyLocalUserJoin_WhenClientIsReady {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient isReady]).andReturn(YES);
    OCMStub([self.defaultClient handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.online.join", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqual(user, self.defaultClient.me);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldNotifyLocalUserJoin_WhenClientNotReadyYet {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.online.join", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqual(user, self.defaultClient.me);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    [self.defaultClient emitEventLocally:@"$.ready", self.defaultClient.me, nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectToChat_ShouldFetchParticipants {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    id chatPartialMock = [self partialMockForObject:expectedChat];
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient handshakeChatAccess:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    OCMExpect([chatPartialMock fetchParticipants]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient connectToChat:expectedChat withCompletion:^(NSDictionary *meta) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: connectChats

- (void)testConnectChats_ShouldRequestManagerToConnect {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    OCMExpect([chatsManagerPartialMock connectChats]);
    
    [self.defaultClient connectChats];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: connectChats

- (void)testDisconnectChats_ShouldRequestManagerToDisconnect {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    OCMExpect([chatsManagerPartialMock disconnectChats]);
    
    [self.defaultClient disconnectChats];
    
    OCMVerifyAll(chatsManagerPartialMock);
}


#pragma mark - Tests :: inviteToChat

- (void)testInviteToChat_ShouldCallSetOfEndpoints {
    
    CENUser *expectedUser = [CENUser userWithUUID:@"invite-tester" state:@{} chatEngine:self.defaultClient];
    CENChat *expectedChat = self.defaultClient.me.direct;
    NSDictionary *expectedInviteData = @{ @"channel": expectedChat.channel };
    NSArray<NSDictionary *> *expectedRoutes = @[@{
        @"route": @"invite",
        @"method": @"post",
        @"body": @{ @"to": expectedUser.uuid, @"chat": [expectedChat dictionaryRepresentation] }
    }];
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([chatPartialMock emitEvent:@"$.invite" withData:expectedInviteData]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient inviteToChat:expectedChat user:expectedUser];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    OCMVerifyAll(chatPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testInviteToChat_WhenInviteUnsuccessful {
    
    CENUser *expectedUser = [CENUser userWithUUID:@"invite-tester" state:@{} chatEngine:self.defaultClient];
    CENChat *expectedChat = self.defaultClient.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
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
    
    [self.defaultClient inviteToChat:expectedChat user:expectedUser];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testInviteToChat_ShouldThrowEmitError_WhenInviteUnsuccessfulWithUnknownError {
    
    CENUser *expectedUser = [CENUser userWithUUID:@"invite-tester" state:@{} chatEngine:self.defaultClient];
    CENChat *expectedChat = self.defaultClient.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.error.auth", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient inviteToChat:expectedChat user:expectedUser];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: leaveChat

- (void)testLeaveChat_ShouldCallSetOfEndpoints {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    NSArray<NSDictionary *> *expectedRoutes = @[@{
        @"route": @"leave",
        @"method": @"post",
        @"body": @{ @"chat": [expectedChat dictionaryRepresentation] }
    }];
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:expectedRoutes withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([chatPartialMock handleLeave]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(functionsClientPartialMock);
    OCMVerifyAll(chatPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testLeaveChat_ShouldUnsubscribeFromChat {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    
    OCMExpect([self.defaultClient unsubscribeFromChannels:@[expectedChat.channel]]);
    
    [self.defaultClient leaveChat:expectedChat];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testLeaveChat_ShouldSynchronizeLeaveFromChat {
    
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChat *expectedChat = self.defaultClient.me.direct;
    __block BOOL handlerCalled = NO;
    
    OCMExpect([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMExpect([(id)self.defaultClient synchronizeSessionChatLeave:expectedChat]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testLeaveChat_WhenLeaveUnsuccessful {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
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
    
    [self.defaultClient leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testLeaveChat_ShouldThrowEmitError_WhenLeaveUnsuccessfulWithUnknownError {
    
    CENChat *expectedChat = self.defaultClient.me.direct;
    id functionsClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionsClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSArray *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    expectedChat.once(@"$.error.chat", ^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], @"Unknown error");
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient leaveChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: fetchParticipantsForChat

- (void)testFetchParticipantsForChat_ShouldRequestParticipantsListWithStates_WhenRequestedForGlobalChat {
    
    CENChat *expectedChat = self.defaultClient.global;
    
    OCMExpect([self.defaultClient fetchParticipantsForChannel:expectedChat.channel withState:YES completion:[OCMArg any]]);
    
    [self.defaultClient fetchParticipantsForChat:expectedChat];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testFetchParticipantsForChat_ShouldRequestParticipantsListWithOutStates_WhenRequestedForCustomChat {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    
    OCMExpect([self.defaultClient fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]]);
    
    [self.defaultClient fetchParticipantsForChat:expectedChat];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testFetchParticipantsForChat_ShouldCreateUserWithState_WhenListReceived {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"user-state": @"good" };
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNPresenceChannelHereNowResult *, PNErrorStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:4];
            handlerBlock([self hereNowResultWithState:YES], nil);
        });
    
    self.defaultClient.once(@"$.online.join", ^(CENChat *chat, CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertNotNil(user);
        XCTAssertEqual(chat, expectedChat);
        XCTAssertEqualObjects(user.state, expectedState);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient fetchParticipantsForChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchParticipantsForChat_ShouldCreateUserWithOutState_WhenListReceived {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{};
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]])
    .andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(PNPresenceChannelHereNowResult *, PNErrorStatus *) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:4];
        handlerBlock([self hereNowResultWithState:NO], nil);
    });
    
    self.defaultClient.once(@"$.online.join", ^(CENChat *chat, CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertNotNil(user);
        XCTAssertEqualObjects(user.state, expectedState);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient fetchParticipantsForChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchParticipantsForChat_ShouldThrowEmitError_WhenFetchDidFail {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient fetchParticipantsForChannel:expectedChat.channel withState:NO completion:[OCMArg any]])
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
    
    [self.defaultClient fetchParticipantsForChat:expectedChat];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Test :: chats

- (void)testChats_ShouldReturnListOfCreatedChats {
    
    XCTAssertNotNil(self.defaultClient.chats);
    XCTAssertGreaterThanOrEqual(self.defaultClient.chats.count, 2);
}


#pragma mark - Test :: global

- (void)testGlobal_ShouldReturnListOfCreatedChats {
    
    XCTAssertNotNil(self.defaultClient.global);
    XCTAssertEqualObjects(self.defaultClient.global.name, self.defaultClient.currentConfiguration.globalChannel);
    XCTAssertEqualObjects(self.defaultClient.global.group, CENChatGroup.system);
    XCTAssertFalse(self.defaultClient.global.isPrivate);
    XCTAssertFalse(self.defaultClient.global.asleep);
}


#pragma mark - Test :: destroyChats

- (void)testDestroyChats_ShouldRequestChatsManagerDestruction {
    
    id chatsManagerPartialMock = [self partialMockForObject:self.defaultClient.chatsManager];
    
    OCMExpect([chatsManagerPartialMock destroy]);
    
    [self.defaultClient destroyChats];
    
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
