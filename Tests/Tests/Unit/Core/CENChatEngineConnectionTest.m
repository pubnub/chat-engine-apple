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

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineConnectionTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
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


#pragma mark - Tests :: connect / connectUser

- (void)testConnectConnectUser_ShouldAuthorizeLocalUser {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    OCMExpect([self.defaultClient authorizeLocalUserWithUUID:expectedUUID authorizationKey:expectedAuthKey completion:[OCMArg any]]);
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testConnectConnectUser_ShouldAuthorizeWithRandomAuthKey_WhenNonNSStringAuthKeyPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = (id)@2010;
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    self.defaultClient.on(@"$.connected", ^(CENChat *chat) {
        if ([chat.name isEqualToString:self.defaultClient.currentConfiguration.globalChannel]) {
            handlerCalled = YES;
            
            XCTAssertNotNil([self.defaultClient pubNubAuthKey]);
            XCTAssertGreaterThan([self.defaultClient pubNubAuthKey].length, 0);
            XCTAssertNotEqualObjects([self.defaultClient pubNubAuthKey], expectedAuthKey);
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldAuthorizeWithRandomAuthKey_WhenEmptyAuthKeyPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    self.defaultClient.on(@"$.connected", ^(CENChat *chat) {
        if ([chat.name isEqualToString:self.defaultClient.currentConfiguration.globalChannel]) {
            handlerCalled = YES;
            
            XCTAssertNotNil([self.defaultClient pubNubAuthKey]);
            XCTAssertGreaterThan([self.defaultClient pubNubAuthKey].length, 0);
            XCTAssertNotEqualObjects([self.defaultClient pubNubAuthKey], expectedAuthKey);
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldConfigurePubNubClient {
    
    NSString *expectedUUID = @"PubNub";
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient setupPubNubForUserWithUUID:expectedUUID authorizationKey:[OCMArg any]]);
    
    [self.defaultClient connectUser:expectedUUID];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testConnectConnectUser_ShouldCreateGlobalChat {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient createGlobalChat]);
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testConnectConnectUser_ShouldCreateLocalUserWithEmptyState {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient createUserWithUUID:expectedUUID state:@{}]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldCreateLocalUserWithNilState_WhenNonNSDictionaryStatePassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = (id)@2010;
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
    .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
        dispatch_block_t handlerBlock = nil;
        
        [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
        handlerBlock();
    });
    
    OCMExpect([self.defaultClient updateLocalUserState:nil withCompletion:[OCMArg any]]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient connectUser:expectedUUID withState:expectedState authKey:expectedAuthKey];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldCreateLocalUserWithNilState_WhenEmptyStatePassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{};
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
    .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
        dispatch_block_t handlerBlock = nil;
        
        [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
        handlerBlock();
    });
    
    OCMExpect([self.defaultClient updateLocalUserState:nil withCompletion:[OCMArg any]]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [self.defaultClient connectUser:expectedUUID withState:expectedState authKey:expectedAuthKey];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldUpdateLocalUserState {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient updateLocalUserState:expectedState withCompletion:[OCMArg any]]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldListenSynchronizationEevents {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    __block BOOL handlerCalled = NO;
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient listenSynchronizationEvents]).andDo(^(NSInvocation *createUserInvocation) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testConnectConnectUser_ShouldCompleteClientInitialization {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *expectedState = @{ @"test": @"state" };
    __block id globalChatPartialMock = nil;
    NSString *expectedAuthKey = @"secret";
    NSString *expectedUUID = @"PubNub";
    
    dispatch_block_t configureGlobalChatMock = ^{
        globalChatPartialMock = [self partialMockForObject:self.defaultClient.global];
        OCMExpect([globalChatPartialMock fetchParticipants]);
    };
    
    OCMStub([self.defaultClient authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *authorizeLocalUserInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [authorizeLocalUserInvocation getArgument:&handlerBlock atIndex:4];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient updateLocalUserState:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *localUserStateUpdateInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [localUserStateUpdateInvocation getArgument:&handlerBlock atIndex:3];
            handlerBlock();
        });
    
    OCMStub([self.defaultClient emitEventLocally:@"$.ready" withParameters:[OCMArg any]])
        .andDo(^(NSInvocation *localUserStateUpdateInvocation) {
            configureGlobalChatMock();
        });
    OCMExpect([self.defaultClient connectToPubNub]);
    OCMExpect([self.defaultClient synchronizeSession]);
    
    self.defaultClient.connect(expectedUUID).state(expectedState).authKey(expectedAuthKey).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    OCMVerifyAll(globalChatPartialMock);
}


#pragma mark - Tests :: reconnect / reconnectUser

- (void)testReconnectReconnectUser_ShouldReAuthorizeLocalUser {
    
    OCMExpect([self.defaultClient authorizeLocalUserWithCompletion:[OCMArg any]]);
    
    self.defaultClient.reconnect();
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testReconnectReconnectUser_ShouldReConnectChatsAndPubNub {
    
    OCMStub([self.defaultClient authorizeLocalUserWithCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *localUserStateUpdateInvocation) {
            dispatch_block_t handlerBlock = nil;
            
            [localUserStateUpdateInvocation getArgument:&handlerBlock atIndex:2];
            handlerBlock();
        });
    
    OCMExpect([self.defaultClient connectChats]);
    OCMExpect([self.defaultClient connectToPubNub]);
    
    self.defaultClient.reconnect();
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: disconnect / disconnectUser

- (void)testDisconnectDisconnectUser_ShouldDisconnectChatsAndPubNub {
    
    OCMExpect([self.defaultClient disconnectFromPubNub]);
    OCMExpect([self.defaultClient disconnectChats]);
    
    self.defaultClient.disconnect();
    
    OCMVerifyAll((id)self.defaultClient);
}

#pragma mark -


@end
