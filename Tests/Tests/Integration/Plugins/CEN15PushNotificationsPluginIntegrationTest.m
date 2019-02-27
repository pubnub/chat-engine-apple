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

@interface CEN15PushNotificationsPluginIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSData *defaultToken;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN15PushNotificationsPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (NSString *)filteredPublishMessageFrom:(NSString *)message {
    
    NSString *filteredMessage = [super filteredPublishMessageFrom:message];
    
    NSData *data = [filteredMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *payload = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] mutableCopy];
    
    NSMutableDictionary *cepayload = [(payload[@"pn_apns"] ?: payload[@"pn_gcm"][@"data"])[@"cepayload"] mutableCopy];
    cepayload[CENEventData.sdk] = @"objc";
    cepayload[CENEventData.eventID] = @"unique-event-id";
    
    if (payload[@"pn_apns"]) {
        NSMutableDictionary *apns = [payload[@"pn_apns"] mutableCopy];
        apns[@"cepayload"] = [cepayload copy];
        payload[@"pn_apns"] = apns;
    }
    
    if (payload[@"pn_gcm"][@"data"]) {
        NSMutableDictionary *gcm = [payload[@"pn_gcm"] mutableCopy];
        NSMutableDictionary *gcmData = [payload[@"pn_gcm"][@"data"] mutableCopy];
        gcmData[@"cepayload"] = [cepayload copy];
        gcm[@"data"] = gcmData;
        payload[@"pn_gcm"] = gcm;
    }
    
    data = [NSJSONSerialization dataWithJSONObject:payload options:(NSJSONWritingOptions)0 error:nil];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)setUp {
    
    [super setUp];
    
    self.defaultToken = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *configuration = @{
        CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns, CENPushNotificationsService.fcm]
    };
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"ian"];
    [self chatEngineForUser:@"ian"].me.plugin([CENPushNotificationsPlugin class]).configuration(configuration).store();
    
#if TARGET_OS_IOS || TARGET_OS_WATCH
    if (@available(iOS 10.0, watchOS 3.0, *)) {
        id notificationCenterMock = [self mockForObject:[UNUserNotificationCenter class]];
        OCMStub(ClassMethod([notificationCenterMock currentNotificationCenter])).andReturn(nil);
    }
#endif
}


#pragma mark - Tests :: Mark as seen

- (void)testMarkNotificationAsSeen_ShouldMarkSpecificNotificationAsSeen_WhenNSNotificationPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    NSDictionary *receivedPayload = @{
        CENEventData.chat: client1.me.direct.channel,
        CENEventData.data: @{ @"important": @"data" },
        CENEventData.event: @"$seen",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self
                                                               userInfo:@{ @"cepayload": receivedPayload }];
    NSString *expected = receivedPayload[CENEventData.eventID];
    
    
    [self object:client2.me.direct shouldHandleEvent:@"$notifications.seen"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertEqualObjects(payload[CENEventData.event], @"$notifications.seen");
            XCTAssertNotNil(payload[@"pn_apns"]);
            XCTAssertEqualObjects(payload[@"pn_apns"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
            XCTAssertNotNil(payload[@"pn_gcm"]);
            XCTAssertEqualObjects(payload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
            handler();
        };
    } afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:@[client1.me.direct] withDeviceToken:self.defaultToken
                                        completion:^(NSError *error) {
                                            
            [CENPushNotificationsPlugin markAsSeen:notification forUser:client1.me withCompletion:nil];
        }];
    }];
}

- (void)testMarkNotificationAsSeen_ShouldMarkAllNotificationAsSeen_WhenNSNotificationPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    NSString *expected = @"all";
    
    
    [self object:client2.me.direct shouldHandleEvent:@"$notifications.seen"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertEqualObjects(payload[CENEventData.event], @"$notifications.seen");
            XCTAssertNotNil(payload[@"pn_apns"]);
            XCTAssertEqualObjects(payload[@"pn_apns"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
            XCTAssertNotNil(payload[@"pn_gcm"]);
            XCTAssertEqualObjects(payload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.data][CENEventData.eventID], expected);
            handler();
        };
    } afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:@[client1.me.direct] withDeviceToken:self.defaultToken
                                        completion:^(NSError *error) {
                                            
            [CENPushNotificationsPlugin markAllAsSeenForUser:client1.me withCompletion:nil];
        }];
    }];
}

#pragma mark -


@end
