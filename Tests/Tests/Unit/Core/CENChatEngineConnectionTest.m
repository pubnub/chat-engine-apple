/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+UserInterface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineConnectionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineConnectionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}


#pragma mark - Tests :: connect / connectUser

- (void)testConnectUser_ShouldAuthorizeLocalUser {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    OCMExpect([self.clientMock authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey completion:[OCMArg any]]);
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectUser_ShouldAuthorizeWithRandomAuthKey_WhenNonNSStringAuthKeyPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = (id)@2010;
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock global]).andReturn(nil);
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    self.clientMock.on(@"$.connected", ^(CENChat *chat) {
        if ([chat.name isEqualToString:self.clientMock.currentConfiguration.globalChannel]) {
            handlerCalled = YES;
            
            XCTAssertNotNil([self.clientMock pubNubAuthKey]);
            XCTAssertGreaterThan([self.clientMock pubNubAuthKey].length, 0);
            XCTAssertNotEqualObjects([self.clientMock pubNubAuthKey], expectedAuthKey);
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldAuthorizeWithRandomAuthKey_WhenEmptyAuthKeyPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock global]).andReturn(nil);
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    self.clientMock.on(@"$.connected", ^(CENChat *chat) {
        if ([chat.name isEqualToString:self.clientMock.currentConfiguration.globalChannel]) {
            handlerCalled = YES;
            
            XCTAssertNotNil([self.clientMock pubNubAuthKey]);
            XCTAssertGreaterThan([self.clientMock pubNubAuthKey].length, 0);
            XCTAssertNotEqualObjects([self.clientMock pubNubAuthKey], expectedAuthKey);
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldConfigurePubNubClient {
    
    NSString *expectedUUID = @"PubNub";
    
    OCMStub([self.clientMock global]).andReturn(nil);
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock setupPubNubForUserWithUUID:expectedUUID authorizationKey:[OCMArg any]]);
    
    [self.clientMock connectUser:expectedUUID];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectUser_ShouldCreateGlobalChat {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock createGlobalChat]);
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testConnectUser_ShouldCreateLocalUserWithEmptyState {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock createUserWithUUID:expectedUUID state:@{}]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldCreateLocalUserWithNilState_WhenNonNSDictionaryStatePassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = (id)@2010;
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
    .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
        dispatch_block_t handlerBlock = nil;
        
        [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
        handlerBlock();
    });
    
    OCMExpect([self.clientMock updateLocalUserState:nil withCompletion:[OCMArg any]]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock connectUser:expectedUUID withState:expectedState authKey:expectedAuthKey];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldCreateLocalUserWithNilState_WhenEmptyStatePassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{};
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
    .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
        dispatch_block_t handlerBlock = nil;
        
        [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
        handlerBlock();
    });
    
    OCMExpect([self.clientMock updateLocalUserState:nil withCompletion:[OCMArg any]]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.clientMock connectUser:expectedUUID withState:expectedState authKey:expectedAuthKey];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldUpdateLocalUserState {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock updateLocalUserState:expectedState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldListenSynchronizationEevents {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.clientMock connectToPubNub]).andDo(nil);
    OCMStub([self.clientMock synchronizeSession]).andDo(nil);
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMStub([self.clientMock updateLocalUserState:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
            dispatch_block_t handlerBlock = nil;
            
            [invocation getArgument:&handlerBlock atIndex:3];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock listenSynchronizationEvents]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    [self.clientMock.global emitEventLocally:@"$.connected", nil];
    [self.clientMock.me.direct emitEventLocally:@"$.connected", nil];
    [self.clientMock.me.feed emitEventLocally:@"$.connected", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectUser_ShouldCompleteClientInitialization {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    __block id globalChatPartialMock = nil;
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    dispatch_block_t configureGlobalChatMock = ^{
        globalChatPartialMock = [self partialMockForObject:self.clientMock.global];
        OCMExpect([globalChatPartialMock fetchParticipants]);
    };
    
    OCMStub([self.clientMock authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock updateLocalUserState:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *localUserStateUpdateInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [localUserStateUpdateInvocation getArgument:&handlerBlock atIndex:3];
            handlerBlock();
        });
    
    OCMStub([self.clientMock emitEventLocally:@"$.ready" withParameters:[OCMArg any]])
        .andDo(^(NSInvocation *localUserStateUpdateInvocation) {
            configureGlobalChatMock();
        });
    OCMExpect([self.clientMock connectToPubNub]);
    OCMExpect([self.clientMock synchronizeSession]).andDo(^(NSInvocation *invocation) {
        dispatch_semaphore_signal(semaphore);
    });
    
    self.clientMock.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
    OCMVerifyAll(globalChatPartialMock);
}


#pragma mark - Tests :: reconnect / reconnectUser

- (void)testReconnectUser_ShouldReAuthorizeLocalUser {
    
    OCMExpect([self.clientMock authorizeLocalUserWithCompletion:[OCMArg any]]);
    
    self.clientMock.reconnect();
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testReconnectUser_ShouldReConnectChatsAndPubNub {
    
    OCMStub([self.clientMock authorizeLocalUserWithCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *localUserStateUpdateInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [localUserStateUpdateInvocation getArgument:&handlerBlock atIndex:2];
            handlerBlock();
        });
    
    OCMExpect([self.clientMock connectChats]);
    OCMExpect([self.clientMock connectToPubNub]);
    
    self.clientMock.reconnect();
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: disconnect / disconnectUser

- (void)testDisconnectUser_ShouldDisconnectChatsAndPubNub {
    
    OCMExpect([self.clientMock disconnectFromPubNub]);
    OCMExpect([self.clientMock disconnectChats]);
    
    self.clientMock.disconnect();
    
    OCMVerifyAll((id)self.clientMock);
}

#pragma mark -


@end
