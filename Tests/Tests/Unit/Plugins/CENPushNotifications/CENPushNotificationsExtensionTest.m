/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPushNotificationsExtension.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENPushNotificationsExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine<PNObjectEventListener> *defaultClient;
@property (nonatomic, nullable, strong) NSData *defaultToken;


#pragma mark - Misc

- (PNErrorStatus *)errorStatusForOperation:(PNOperationType)operation forChannels:(NSArray<NSString *> *)channels;

#pragma mark -


@end


@implementation CENPushNotificationsExtensionTest


#pragma mark - Setup / Tear down

-(void)setUp {
    
    [super setUp];
    
    self.defaultToken = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    [self.defaultClient setupPubNubForUserWithUUID:@"tester" authorizationKey:@"tester-auth"];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient global]).andReturn(self.defaultClient.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    id mePartialMock = [self partialMockForObject:self.defaultClient.me];
    id extensionPartialMock = [self partialMockForObject:extension];
    
    OCMStub([extensionPartialMock object]).andReturn(self.defaultClient.me);
    OCMStub([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENPushNotificationsExtension *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        block(extension);
    });
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Enable push notifications

- (void)testEnablePushNotifications_ShouldEnableNotificationsOnChats_WhenSmallListHasBeenPassed {
    
    NSArray<CENChat *> *expectedChats = @[self.defaultClient.global, self.defaultClient.me.direct, self.defaultClient.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock addPushNotificationsOnChannels:expectedChannels withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testEnablePushNotifications_ShouldEnableNotificationsOnChats_WhenLargeListHasBeenPassed {
    
    NSMutableArray<CENChat *> *expectedChats = [NSMutableArray new];
    for (NSUInteger count = 0; count < 200; count++) {
        [expectedChats addObjectsFromArray:@[self.defaultClient.global, self.defaultClient.me.direct, self.defaultClient.me.feed]];
    }
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    OCMExpect([pubNubPartialMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testEnablePushNotifications_ShouldHandleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    NSArray<CENChat *> *expectedChats = @[self.defaultClient.global, self.defaultClient.me.direct, self.defaultClient.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    NSArray<CENChat *> *expectedFailedChats = @[self.defaultClient.me.feed];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    OCMStub([pubNubPartialMock addPushNotificationsOnChannels:expectedChannels withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(PNAcknowledgmentStatus *) = nil;
        [invocation getArgument:&block atIndex:4];
        
        PNErrorStatus *errorStatus = [self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation forChannels:expectedFailedChannels];
        block((PNAcknowledgmentStatus *)errorStatus);
    });
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
        XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], expectedFailedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testEnablePushNotifications_ShouldHandleMultipleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    NSMutableArray<CENChat *> *expectedChats = [NSMutableArray new];
    for (NSUInteger count = 0; count < 500; count++) {
        CENChat *chat = [self.defaultClient createChatWithName:[NSUUID UUID].UUIDString group:nil private:NO autoConnect:NO metaData:nil];
        [expectedChats addObject:chat];
    }
    NSArray<CENChat *> *expectedFailedChats = @[expectedChats[0], expectedChats[1]];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalledOnce = NO;
    __block BOOL handlerCalledTwice = NO;
    __block BOOL failedOnce = NO;
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    OCMStub([pubNubPartialMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(PNAcknowledgmentStatus *) = nil;
        [invocation getArgument:&block atIndex:4];
        
        PNErrorStatus *errorStatus = nil;
        if (!failedOnce) {
            failedOnce = YES;
            errorStatus = [self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation forChannels:@[expectedFailedChannels.firstObject]];
        } else {
            errorStatus = [self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation forChannels:@[expectedFailedChannels.lastObject]];
        }
        block((PNAcknowledgmentStatus *)errorStatus);
    });
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:^(NSError *error) {
        if (handlerCalledOnce) {
            handlerCalledTwice = YES;
        }
        handlerCalledOnce = YES;
        
        XCTAssertNotNil(error);
        XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
        XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], expectedFailedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2000.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalledOnce);
    XCTAssertFalse(handlerCalledTwice);
}


#pragma mark - Tests :: Disable push notifications

- (void)testDisablePushNotifications_ShouldEnableNotificationsOnChats_WhenSmallListHasBeenPassed {
    
    NSArray<CENChat *> *expectedChats = @[self.defaultClient.global, self.defaultClient.me.direct, self.defaultClient.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock removePushNotificationsFromChannels:expectedChannels withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testDisablePushNotifications_ShouldEnableNotificationsOnChats_WhenLargeListHasBeenPassed {
    
    NSMutableArray<CENChat *> *expectedChats = [NSMutableArray new];
    for (NSUInteger count = 0; count < 200; count++) {
        [expectedChats addObjectsFromArray:@[self.defaultClient.global, self.defaultClient.me.direct, self.defaultClient.me.feed]];
    }
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    OCMExpect([pubNubPartialMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testDisablePushNotifications_ShouldHandleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    NSArray<CENChat *> *expectedChats = @[self.defaultClient.global, self.defaultClient.me.direct, self.defaultClient.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    NSArray<CENChat *> *expectedFailedChats = @[self.defaultClient.me.direct];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    OCMStub([pubNubPartialMock removePushNotificationsFromChannels:expectedChannels withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(PNAcknowledgmentStatus *) = nil;
        [invocation getArgument:&block atIndex:4];
        
        PNErrorStatus *errorStatus = [self errorStatusForOperation:PNRemovePushNotificationsFromChannelsOperation forChannels:expectedFailedChannels];
        block((PNAcknowledgmentStatus *)errorStatus);
    });
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
        XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], expectedFailedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Disable all push notifications

- (void)testDisableAllPushNotifications_ShouldEnableNotificationsOnChats {
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock removeAllPushNotificationsFromDeviceWithPushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:self.defaultClient.me withDeviceToken:self.defaultToken completion:completionHandler];
    
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testDisableAllPushNotifications_ShouldHandleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    NSArray<CENChat *> *expectedFailedChats = @[self.defaultClient.me.direct, self.defaultClient.me.feed];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    id pubNubPartialMock = [self partialMockForObject:self.defaultClient.pubnub];
    OCMStub([pubNubPartialMock removeAllPushNotificationsFromDeviceWithPushToken:self.defaultToken andCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(PNAcknowledgmentStatus *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        PNErrorStatus *errorStatus = [self errorStatusForOperation:PNRemoveAllPushNotificationsOperation forChannels:expectedFailedChannels];
        block((PNAcknowledgmentStatus *)errorStatus);
    });
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:self.defaultClient.me withDeviceToken:self.defaultToken completion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
        XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], expectedFailedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Misc

- (PNErrorStatus *)errorStatusForOperation:(PNOperationType)operation forChannels:(NSArray<NSString *> *)channels {
    
    NSDictionary *processedData = @{ @"information": @"Access denied", @"status": @403, @"channels": channels };
    
    return [PNErrorStatus objectForOperation:operation completedWithTask:nil processedData:processedData processingError:nil];
}

#pragma mark -


@end
