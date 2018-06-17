/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#if TARGET_OS_IOS || TARGET_OS_WATCH
#import <UserNotifications/UserNotifications.h>
#endif
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CENPushNotificationsMiddleware.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>


#pragma mark Interface declaration

@interface CENPushNotificationsPluginIntegrationTest : CENTestCase

#pragma mark - Information

@property (nonatomic, nullable, strong) NSData *defaultToken;


#pragma mark - Misc

- (PNErrorStatus *)errorStatusForOperation:(PNOperationType)operation forChannels:(NSArray<NSString *> *)channels;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENPushNotificationsPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.defaultToken = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *configuration = @{
        CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns, CENPushNotificationsService.fcm]
    };
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    [self chatEngineForUser:@"ian"].me.plugin([CENPushNotificationsPlugin class]).configuration(configuration).store();
    
#if TARGET_OS_IOS || TARGET_OS_WATCH
    if (@available(iOS 10.0, watchOS 3.0, *)) {
        id notificationCenterMock = OCMClassMock([UNUserNotificationCenter class]);
        OCMStub(ClassMethod([notificationCenterMock currentNotificationCenter])).andReturn(nil);
    }
#endif
}


#pragma mark - Tests :: Enable push notifications

- (void)testEnablePushNotifications_ShouldEnableNotificationsOnChats_WhenSmallListHasBeenPassed {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSArray<CENChat *> *expectedChats = @[client.global, client.me.direct, client.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock addPushNotificationsOnChannels:expectedChannels withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testEnablePushNotifications_ShouldEnableNotificationsOnChats_WhenLargeListHasBeenPassed {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSMutableArray<CENChat *> *expectedChats = [NSMutableArray new];
    for (NSUInteger count = 0; count < 200; count++) {
        [expectedChats addObjectsFromArray:@[client.global, client.me.direct, client.me.feed]];
    }
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    OCMExpect([pubNubPartialMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testEnablePushNotifications_ShouldHandleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSArray<CENChat *> *expectedChats = @[client.global, client.me.direct, client.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    NSArray<CENChat *> *expectedFailedChats = @[client.me.feed];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
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
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSMutableArray<CENChat *> *expectedChats = [NSMutableArray new];
    for (NSUInteger count = 0; count < 400; count++) {
        CENChat *chat = [client createChatWithName:[NSUUID UUID].UUIDString group:nil private:NO autoConnect:NO metaData:nil];
        [expectedChats addObject:chat];
    }
    NSArray<CENChat *> *expectedFailedChats = @[expectedChats[0], expectedChats[1]];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalledOnce = NO;
    __block BOOL handlerCalledTwice = NO;
    __block BOOL failedOnce = NO;
    
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
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
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSArray<CENChat *> *expectedChats = @[client.global, client.me.direct, client.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock removePushNotificationsFromChannels:expectedChannels withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testDisablePushNotifications_ShouldEnableNotificationsOnChats_WhenLargeListHasBeenPassed {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSMutableArray<CENChat *> *expectedChats = [NSMutableArray new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    for (NSUInteger count = 0; count < 200; count++) {
        [expectedChats addObjectsFromArray:@[client.global, client.me.direct, client.me.feed]];
    }
    
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    OCMExpect([pubNubPartialMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testDisablePushNotifications_ShouldHandleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSArray<CENChat *> *expectedChats = @[client.global, client.me.direct, client.me.feed];
    NSArray<NSString *> *expectedChannels = [expectedChats valueForKey:@"channel"];
    NSArray<CENChat *> *expectedFailedChats = @[client.me.direct];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
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
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    OCMExpect([pubNubPartialMock removeAllPushNotificationsFromDeviceWithPushToken:self.defaultToken andCompletion:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:client.me withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    OCMVerifyAll(pubNubPartialMock);
}

- (void)testDisableAllPushNotifications_ShouldHandleErrorAndReportFailedChats_WhenPubNubServiceReturnError {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSArray<CENChat *> *expectedFailedChats = @[client.me.direct, client.me.feed];
    NSArray<NSString *> *expectedFailedChannels = [expectedFailedChats valueForKey:@"channel"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    id pubNubPartialMock = [self partialMockForObject:client.pubnub];
    OCMStub([pubNubPartialMock removeAllPushNotificationsFromDeviceWithPushToken:self.defaultToken andCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(PNAcknowledgmentStatus *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        PNErrorStatus *errorStatus = [self errorStatusForOperation:PNRemoveAllPushNotificationsOperation forChannels:expectedFailedChannels];
        block((PNAcknowledgmentStatus *)errorStatus);
    });
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:client.me withDeviceToken:self.defaultToken completion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
        XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], expectedFailedChats);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Mark as seen

- (void)testMarkNotificationAsSeen_ShouldMarkSpecificNotificationAsSeen_WhenNSNotificationPassed {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSDictionary *receivedPayload = @{
        CENEventData.chat: client.me.direct.channel,
        CENEventData.data: @{ @"important": @"data" },
        CENEventData.event: @"$seen",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:@{ @"cepayload": receivedPayload }];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected = receivedPayload[CENEventData.eventID];
    __block BOOL handlerCalled = NO;
    
    [client.me.direct handleEventOnce:@"$notifications.seen" withHandlerBlock:^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(payload[CENEventData.event], @"$notifications.seen");
        XCTAssertNotNil(payload[@"pn_apns"]);
        XCTAssertEqualObjects(payload[@"pn_apns"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
        XCTAssertNotNil(payload[@"pn_gcm"]);
        XCTAssertEqualObjects(payload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    
    [CENPushNotificationsPlugin markNotificationAsSeen:notification forUser:client.me withCompletion:nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testMarkNotificationAsSeen_ShouldMarkAllNotificationAsSeen_WhenNSNotificationPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    NSString *expected = @"all";
    
    [client.me.direct handleEventOnce:@"$notifications.seen" withHandlerBlock:^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertEqualObjects(payload[CENEventData.event], @"$notifications.seen");
        XCTAssertNotNil(payload[@"pn_apns"]);
        XCTAssertEqualObjects(payload[@"pn_apns"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
        XCTAssertNotNil(payload[@"pn_gcm"]);
        XCTAssertEqualObjects(payload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5f * NSEC_PER_SEC)));
    
    [CENPushNotificationsPlugin markAllNotificationAsSeenForUser:client.me withCompletion:nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Misc

- (PNErrorStatus *)errorStatusForOperation:(PNOperationType)operation forChannels:(NSArray<NSString *> *)channels {
    
    NSDictionary *processedData = @{ @"information": @"Access denied", @"status": @403, @"channels": channels };
    
    return [PNErrorStatus objectForOperation:operation completedWithTask:nil processedData:processedData processingError:nil];
}

#pragma mark -


@end
