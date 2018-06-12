/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChat+BuilderInterface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENStructures.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChat (TestExtension)


#pragma mark - Information

/**
 * @brief  Stores whether \c chat currently asleep after \c disconnect and doesn't receive any new
 *         updates.
 */
@property (nonatomic, assign) BOOL asleep;


#pragma mark - Authorization and access

/**
 * @brief      Complete chat initialization for local user.
 * @discussion Chat owner may invide remote user, but he should perform handshake to complete setup.
 *
 * @param block Reference on block which called at the end of handshake process. Block pass two
 *              arguments: \c isError - whether handshake failed or not; \c response - \b PubNub
 *              Functions response.
 */
- (void)handshakeWithCompletion:(void(^)(BOOL isError, id response))block;

#pragma mark -


@end


@interface CENChatTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *privateChatRepresentation;
@property (nonatomic, strong) NSDictionary *publicChatRepresentation;
@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) CENChat *privateChat;
@property (nonatomic, strong) NSDictionary *privateChatMeta;
@property (nonatomic, nullable, strong) CENChat *publicChat;
@property (nonatomic, strong) NSDictionary *publicChatMeta;
@property (nonatomic, strong) NSString *chatNamespace;
@property (nonatomic, strong) NSString *chatName;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.throwExceptions = YES;
    CENChatEngine *client = [self chatEngineWithConfiguration:configuration];
    self.defaultClient = [self partialMockForObject:client];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    self.privateChatMeta = @{ @"chat": @"private" };
    self.publicChatMeta = @{ @"chat": @"public" };
    self.chatNamespace = @"test-group";
    self.chatName = @"test-channel";
    self.privateChatRepresentation = @{
        CENChatData.channel: [CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:YES],
        CENChatData.group: CENChatGroup.custom,
        CENChatData.private: @(YES),
        CENChatData.meta: self.privateChatMeta
    };
    self.publicChatRepresentation = @{
        CENChatData.channel: [CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:NO],
        CENChatData.group: CENChatGroup.custom,
        CENChatData.private: @(NO),
        CENChatData.meta: self.publicChatMeta
    };
    
    
    self.privateChat = [CENChat chatWithName:self.chatName namespace:self.chatNamespace group:CENChatGroup.custom private:YES
                                   metaData:self.privateChatMeta chatEngine:self.defaultClient];
    self.publicChat = [CENChat chatWithName:self.chatName namespace:self.chatNamespace group:CENChatGroup.custom private:NO
                                  metaData:self.publicChatMeta chatEngine:self.defaultClient];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [self.privateChat destruct];
    self.privateChat = nil;
    
    [self.publicChat destruct];
    self.publicChat = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreatePrivate_WhenAllRequiredDataPassed {
    
    XCTAssertNotNil(self.privateChat);
    XCTAssertTrue(self.privateChat.isPrivate);
    XCTAssertEqualObjects(self.privateChat.name, self.chatName);
    XCTAssertFalse(self.privateChat.connected);
    XCTAssertEqualObjects(self.privateChat.group, CENChatGroup.custom);
    XCTAssertNotNil(self.privateChat.users);
    XCTAssertEqual(self.privateChat.users.count, 0);
}

- (void)testConstructor_ShouldCreatePublic_WhenAllRequiredDataPassed {
    
    XCTAssertNotNil(self.publicChat);
    XCTAssertFalse(self.publicChat.isPrivate);
    XCTAssertEqualObjects(self.publicChat.name, self.chatName);
    XCTAssertFalse(self.publicChat.connected);
    XCTAssertEqualObjects(self.publicChat.group, CENChatGroup.custom);
    XCTAssertNotNil(self.publicChat.users);
    XCTAssertEqual(self.publicChat.users.count, 0);
}

- (void)testConstructor_ShouldCreateWithEmptyMeta_WhenNilMetaPassed {
    
    NSDictionary *meta = nil;
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:meta chatEngine:self.defaultClient];
    
    XCTAssertNotNil([chat dictionaryRepresentation][CENChatData.meta]);
    XCTAssertEqual(((NSDictionary *)[chat dictionaryRepresentation][CENChatData.meta]).count, 0);
}

- (void)testConstructor_ShouldNotCreate_WhenNilNamePassed {
    
    NSString *name = nil;
    
    XCTAssertNil([CENChat chatWithName:name namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyNamePassed {
    
    NSString *name = @"";
    
    XCTAssertNil([CENChat chatWithName:name namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringNamePassed {
    
    NSString *name = (id)@2010;
    
    XCTAssertNil([CENChat chatWithName:name namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenNilNamespacePassed {
    
    NSString *nspace = nil;
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:nspace group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyNamespacePassed {
    
    NSString *nspace = @"";
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:nspace group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringNamespacePassed {
    
    NSString *nspace = (id)@2010;
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:nspace group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenNilGroupPassed {
    
    NSString *group = nil;
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:@"test" group:group private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyGroupPassed {
    
    NSString *group = @"";
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:@"test" group:group private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringGroupPassed {
    
    NSString *group = (id)@2010;
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:@"test" group:group private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenUnknownGroupPassed {
    
    NSString *group = @"PubNub";
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:@"test" group:group private:NO metaData:@{} chatEngine:self.defaultClient]);
}

- (void)testConstructor_ShouldNotCreate_WhenNonChatEngineInstancePassed {
    
    CENChatEngine *client = (id)@2010;
    
    XCTAssertNil([CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:client]);
}


#pragma mark - Tests :: objectType

- (void)testObjectType_ShouldBeChat {
    
    XCTAssertEqualObjects([CENChat objectType], CENObjectType.chat);
}


#pragma mark - Tests :: identifier

- (void)testIdentifier_ShouldBeEqualToChatChannel {
    
    XCTAssertEqualObjects(self.publicChat.identifier, self.publicChat.channel);
}


#pragma mark - Tests :: isPrivate

- (void)testIsPrivate_ShouldReturnTrue_WhenPrivateChatChannelPassed {
    
    XCTAssertTrue([CENChat isPrivate:self.privateChat.channel]);
}

- (void)testIsPrivate_ShouldReturnFalse_WhenPublicChatChannelPassed {
    
    XCTAssertFalse([CENChat isPrivate:self.publicChat.channel]);
}

- (void)testIsPrivate_ShouldReturnFalse_WhenMalformedChannelNamePassed {
    
    XCTAssertFalse([CENChat isPrivate:self.publicChat.name]);
}


#pragma mark - Tests :: objectify

- (void)testDictionaryRepresentation_ShouldCreatePrivateChatRepresentation {
    
    XCTAssertEqualObjects(self.privateChat.objectify(), self.privateChatRepresentation);
}

- (void)testDictionaryRepresentation_ShouldCreatePublicChatRepresentation {
    
    XCTAssertEqualObjects(self.publicChat.objectify(), self.publicChatRepresentation);
}


#pragma mark - Tests :: internalNameFor

- (void)testInternalNameFor_ShouldCreateChannel_WhenNameForPrivateChatPassed {
    
    NSString *expectedChannel = [@[ self.chatNamespace, @"chat", @"private.", self.chatName ] componentsJoinedByString:@"#"];
    
    XCTAssertEqualObjects([CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:YES], expectedChannel);
}
- (void)testInternalNameFor_ShouldCreateChannel_WhenNameForPublicChatPassed {
    
    NSString *expectedChannel = [@[ self.chatNamespace, @"chat", @"public.", self.chatName ] componentsJoinedByString:@"#"];
    
    XCTAssertEqualObjects([CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:NO], expectedChannel);
}

- (void)testInternalNameFor_ShouldReturnChannelname_WhenChannelNameIncludeNamespace {
    
    NSString *expectedChannel = [@[ self.chatNamespace, @"chat", @"private.", self.chatName ] componentsJoinedByString:@"#"];
    
    XCTAssertEqualObjects([CENChat internalNameFor:expectedChannel inNamespace:self.chatNamespace private:NO], expectedChannel);
}


#pragma mark - Tests :: sleep

- (void)testSleep_ShouldSleep_WhenConnectedAndNotAsleep {
    
    id privateChatPartialMock = [self partialMockForObject:self.privateChat];
    OCMStub([(CENChat *)privateChatPartialMock connected]).andReturn(YES);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [privateChatPartialMock sleep];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)));
    OCMVerify([privateChatPartialMock emitEventLocally:@"$.disconnected" withParameters:@[]]);
}

- (void)testSleep_ShouldNotSleep_WhenNotConnected {
    
    id privateChatPartialMock = [self partialMockForObject:self.privateChat];
    OCMStub([(CENChat *)privateChatPartialMock connected]).andReturn(NO);
    OCMExpect([[privateChatPartialMock reject] emitEventLocally:@"$.disconnected" withParameters:@[]]);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    XCTAssertNoThrow([privateChatPartialMock sleep]);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)));
    OCMVerifyAll(privateChatPartialMock);
}


#pragma mark - Tests :: wake

- (void)testWake_ShouldWake_WhenAsleepAndNoHandshakeError {
    
    id privateChatPartialMock = [self partialMockForObject:self.privateChat];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([(CENChat *)privateChatPartialMock asleep]).andReturn(YES);
    OCMStub([self.defaultClient handshakeChatAccess:self.privateChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        void(^handlerBlock)(BOOL,id);
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    [privateChatPartialMock wake];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)));
    OCMVerify([privateChatPartialMock emitEventLocally:@"$.connected" withParameters:@[]]);
    XCTAssertTrue(handlerCalled);
}

- (void)testWake_ShouldNotWake_WhenAsleepAndHandshakeError {
    
    id privateChatPartialMock = [self partialMockForObject:self.privateChat];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    OCMStub([(CENChat *)privateChatPartialMock asleep]).andReturn(YES);
    OCMExpect([[privateChatPartialMock reject] emitEventLocally:@"$.connected" withParameters:@[]]);
    
    OCMStub([self.defaultClient handshakeChatAccess:self.privateChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        void(^handlerBlock)(BOOL,id);
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    XCTAssertNoThrow([privateChatPartialMock wake]);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)));
    OCMVerifyAll(privateChatPartialMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testWake_ShouldNotWake_WhenNotAsleep {
    
    id privateChatPartialMock = [self partialMockForObject:self.privateChat];
    OCMStub([(CENChat *)privateChatPartialMock asleep]).andReturn(NO);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCMExpect([[(id)self.defaultClient reject] handshakeChatAccess:[OCMArg any] withCompletion:[OCMArg any]]);
    
    XCTAssertNoThrow([privateChatPartialMock wake]);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: setState

- (void)testSetState_ShouldUpdateChatState_WhenNSDictionaryStatePassed {
    
    NSDictionary *expectedState = @{ @"some": @"value" };
    
    OCMExpect([self.defaultClient updateChatState:self.privateChat withData:expectedState completion:[OCMArg any]]).andDo(nil);
    
    [self.privateChat setState:expectedState withCompletion:nil];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: handlePresenCENEvent

- (void)testHandlePresenCENEvent_ShouldEmitOnlineJoin_WhenUserJoinToChat {
    
    NSString *expectedUserUUID = @"test-user";
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.publicChat.once(@"$.online.join", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(user.uuid, expectedUserUUID);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled, @"It took too long to handle presence event.");
}

- (void)testHandlePresenCENEvent_ShouldEmitOnlineHere_WhenUserJoinAfterTimeout {
    
    NSString *expectedUserUUID = @"test-user";
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.publicChat.once(@"$.online.here", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(user.uuid, expectedUserUUID);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user]];
    [self.publicChat handleRemoteUsersDisconnect:@[user]];
    [self.publicChat handleRemoteUsersJoin:@[user]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled, @"It took too long to handle presence event.");
}

- (void)testHandlePresenCENEvent_ShouldEmitOfflineDisconnect_WhenUserTimeoutAfterJoin {
    
    NSString *expectedUserUUID = @"test-user";
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.publicChat.once(@"$.offline.disconnect", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(user.uuid, expectedUserUUID);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user]];
    [self.publicChat handleRemoteUsersDisconnect:@[user]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled, @"It took too long to handle presence event.");
}

- (void)testHandlePresenCENEvent_ShouldNotEmitOfflineDisconnect_WhenUnknownUserTimeout {
    
    NSString *expectedUserUUID = @"test-user";
    CENUser *user1 = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.defaultClient];
    CENUser *user2 = [CENUser userWithUUID:@"PubNub" state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL emittedForUnknown = NO;
    
    self.publicChat.once(@"$.offline.disconnect", ^(CENUser *user) {
        emittedForUnknown = ![user.uuid isEqualToString:expectedUserUUID];
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user1]];
    [self.publicChat handleRemoteUsersDisconnect:@[user2]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(emittedForUnknown);
}

- (void)testHandlePresenCENEvent_ShouldEmitOfflineLeave_WhenUserLeaveAfterJoin {
    
    NSString *expectedUserUUID = @"test-user";
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.publicChat.once(@"$.offline.leave", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(user.uuid, expectedUserUUID);
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user]];
    [self.publicChat handleRemoteUsersLeave:@[user]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled, @"It took too long to handle presence event.");
}

- (void)testHandlePresenCENEvent_ShouldNotEmitOfflineLeave_WhenUnknownUserLeave {
    
    NSString *expectedUserUUID = @"test-user";
    CENUser *user1 = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.defaultClient];
    CENUser *user2 = [CENUser userWithUUID:@"PubNub" state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL emittedForUnknown = NO;
    
    self.publicChat.once(@"$.offline.leave", ^(CENUser *user) {
        emittedForUnknown = ![user.uuid isEqualToString:expectedUserUUID];
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user1]];
    [self.publicChat handleRemoteUsersLeave:@[user2]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertFalse(emittedForUnknown);
}

- (void)testHandlePresenCENEvent_ShouldEmitOnlineJoinAndState_WhenUnknownUserChangeState {
    
    NSString *expectedUserUUID = @"PubNub";
    CENUser *user1 = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.defaultClient];
    CENUser *user2 = [CENUser userWithUUID:@"PubNub" state:@{} chatEngine:self.defaultClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    self.publicChat.on(@"$.online.join", ^(CENUser *user) {
        if ([user.uuid isEqualToString:expectedUserUUID]) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    [self.publicChat handleRemoteUsersJoin:@[user1]];
    [self.publicChat handleRemoteUsersStateChange:@[user2]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled, @"It took too long to handle presence event.");
}


#pragma mark - Tests :: connect

- (void)testConnect_ShouldEmitConnectedOnlinJoin_WhenHandshakeSuccessful {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    __block BOOL handlerCalled = NO;
    
    dispatch_group_enter(group);
    self.privateChat.on(@"$.connected", ^{
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    self.privateChat.on(@"$.online.join", ^(CENUser *user) {
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    
    OCMStub([self.defaultClient isReady]).andReturn(YES);
    OCMStub([self.defaultClient handshakeChatAccess:self.privateChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL,id);
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(NO, nil);
    });
    
    self.privateChat.connect();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled, @"It took too long to connect");
}


#pragma mark - Tests :: update

- (void)testUpdate_ShouldPushUpdatedState {
    
    NSDictionary *stateForUpdate = @{ @"PubNub": @"Awesome!!!" };
    NSMutableDictionary *expectedState = [NSMutableDictionary dictionaryWithDictionary:self.publicChatMeta];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [expectedState addEntriesFromDictionary:stateForUpdate];
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient pushUpdatedChatMeta:self.publicChat withRepresentation:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            handlerCalled = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                XCTAssertEqualObjects(self.publicChat.meta, expectedState);
                dispatch_semaphore_signal(semaphore);
            });
        });
    
    self.publicChat.update(stateForUpdate);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: updateMetaWithFetchedData

- (void)testUpdateMetaWithFetchedData_ShouldUseFetchedState {
    
    NSDictionary *stateForUpdate = @{ @"PubNub": @"Awesome!!!" };
    
    [self.publicChat updateMetaWithFetchedData:stateForUpdate];
    
    XCTAssertEqualObjects(self.publicChat.meta, stateForUpdate);
}

- (void)testUpdateMetaWithFetchedData_ShouldPushLocalMeta_WhenNilStatePassed {
    
    id publicChatPartialMock = [self partialMockForObject:self.publicChat];
    
    OCMExpect([publicChatPartialMock updateMeta:self.publicChatMeta]).andDo(nil);
    
    [self.publicChat updateMetaWithFetchedData:nil];
    
    OCMVerifyAll(publicChatPartialMock);
}


#pragma mark - Tests :: invite / inviteUser

- (void)testInvite_ShouldInviteRemoteUser {
    
    CENUser *user = [CENUser userWithUUID:@"chat-join-tester" state:@{} chatEngine:self.defaultClient];
    
    OCMExpect([self.defaultClient inviteToChat:self.publicChat user:user]).andDo(nil);
    
    self.publicChat.invite(user);
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: leave / leaveChat

- (void)testLeave_ShouldLeavePublicChat {

    id publicChatPartialMock = [self partialMockForObject:self.publicChat];
    id functionClientPartialMock = [self partialMockForObject:self.defaultClient.functionsClient];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENUser *userToLeave = self.defaultClient.me;
    __block BOOL handlerCalled = NO;
    
    OCMStub([functionClientPartialMock callRouteSeries:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL success, NSArray *responses) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(YES, nil);
    });
    
    OCMStub([publicChatPartialMock emitEvent:@"$.system.leave" withData:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        NSDictionary *payload = nil;
        
        [invocation getArgument:&payload atIndex:3];
        
        NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionaryWithDictionary:payload];
        mutablePayload[CENEventData.sender] = userToLeave;
        [publicChatPartialMock emitEventLocally:@"$.system.leave" withParameters:@[mutablePayload]];
    });
    
    OCMExpect([publicChatPartialMock handleRemoteUsersLeave:@[userToLeave]]).andDo(^(NSInvocation *invocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    OCMStub([self.defaultClient connectToChat:self.publicChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(NSDictionary *__nullable) = nil;
        
        [invocation getArgument:&handlerBlock atIndex:3];
        handlerBlock(nil);
    });
    
    [self.publicChat handleEventOnce:@"$.connected" withHandlerBlock:^{
        self.publicChat.leave();
    }];
    
    self.publicChat.connect();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll(publicChatPartialMock);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: fetchParticipants

- (void)testFetchParticipants_ShouldRequestChatParticipants {
    
    OCMExpect([self.defaultClient fetchParticipantsForChat:self.publicChat]).andDo(nil);
    
    self.publicChat.fetchUserUpdates();
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: search / searchEvent

- (void)testSearch_ShouldRequestChatParticipants {
    
    id publicChatPartialMock = [self partialMockForObject:self.publicChat];
    CENUser *expectedSender = self.defaultClient.me;
    NSString *expectedEvent = @"test-event";
    NSInteger expectedLimit = 123;
    NSInteger expectedPages = 45;
    NSInteger expectedCount = 67;
    NSNumber *expectedStart = @1;
    NSNumber *expectedEnd = @2;
    
    OCMStub([publicChatPartialMock hasConnected]).andReturn(YES);
    
    CENSearch *search = self.publicChat.search().event(expectedEvent).sender(expectedSender).limit(expectedLimit).pages(expectedPages)
        .count(expectedCount).start(expectedStart).end(expectedEnd).create();
    
    XCTAssertNotNil(search);
    XCTAssertEqualObjects(search.event, expectedEvent);
    XCTAssertEqual(search.sender, expectedSender);
    XCTAssertEqual(search.limit, expectedLimit);
    XCTAssertEqual(search.pages, expectedPages);
    XCTAssertEqual(search.count, expectedCount);
    XCTAssertEqual([search.start compare:expectedStart], NSOrderedSame);
    XCTAssertEqual([search.end compare:expectedEnd], NSOrderedSame);
}

- (void)testSearch_ShouldThrow_WhenNotConnected {
    
    XCTAssertThrowsSpecificNamed(self.publicChat.search().event(@"test-event").create(), NSException, kCEErrorDomain);
}


#pragma mark - Tests :: emit / emitEvent

- (void)testEmit_ShouldPushEvent {
    
    NSDictionary *expectedPayload = @{ @"test": @"data" };
    NSString *expectedEventName = @"test-event";
    
    OCMExpect([self.defaultClient publishToChat:self.publicChat eventWithName:expectedEventName data:expectedPayload]).andForwardToRealObject();
    
    XCTAssertNotNil(self.publicChat.emit(expectedEventName).data(expectedPayload).perform());
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvidePublicChatInstanceDescription {
    
    id publicChatPartialMock = [self partialMockForObject:self.publicChat];
    OCMStub([publicChatPartialMock asleep]).andReturn(YES);
    NSString *description = [self.publicChat description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"private: NO"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"asleep: YES"].location, NSNotFound);
}

- (void)testDescription_ShouldProvidePrivateChatInstanceDescription {
    
    NSString *description = [self.privateChat description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"private: YES"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"asleep: NO"].location, NSNotFound);
}

#pragma mark -


@end
