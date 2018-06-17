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
#import <OCMock/OCMock.h>


#pragma mark Interface declaration

@interface CENPushNotificationsPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENPushNotificationsPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
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
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    
    [CENPushNotificationsPlugin markAllNotificationAsSeenForUser:client.me withCompletion:nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark - Tests


#pragma mark -


@end
