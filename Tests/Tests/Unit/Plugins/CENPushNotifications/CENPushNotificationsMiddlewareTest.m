/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENPushNotificationsMiddleware.h>
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import "CENTestCase.h"


@interface CENPushNotificationsMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine<PNObjectEventListener> *defaultClient;
@property (nonatomic, nullable, strong) CENPushNotificationsMiddleware *defaultMiddleware;
@property (nonatomic, nullable, strong) NSMutableDictionary *preFormattedLeavePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *preFormattedSeenPayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *defaultMessagePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *defaultInvitePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *defaultLeavePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *pluginPayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *seenPayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *userPayload;
@property (nonatomic, nullable, strong) CENChat *defaultChat;


#pragma mark - Misc

- (void)preparePreFormattedLeavePayload;
- (void)preparePreFormattedSeenPayload;
- (void)prepareMessagePayload;
- (void)prepareInvitePayload;
- (void)preparePluginPayload;
- (void)prepareLeavePayload;
- (void)prepareSeenPayload;
- (void)prepareUserPayload;

#pragma mark -


@end


@implementation CENPushNotificationsMiddlewareTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSMutableDictionary *middlewareConfiguration = [@{
        CENPushNotificationsConfiguration.events: @[@"message", @"$.invite"],
        CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns, CENPushNotificationsService.fcm]
    } mutableCopy];

    if ([self.name rangeOfString:@"BoundledChatEngineEvent"].location != NSNotFound ||
        [self.name rangeOfString:@"GenerateBySystem"].location != NSNotFound ||
        [self.name rangeOfString:@"GenerateByPlugin"].location != NSNotFound ||
        [self.name rangeOfString:@"GenerateByUser"].location != NSNotFound) {
        middlewareConfiguration[CENPushNotificationsConfiguration.formatter] = ^NSDictionary * (NSDictionary *cePayload) {
            if ([self.name rangeOfString:@"BoundledChatEngineEvent"].location == NSNotFound) {
                return self.preFormattedLeavePayload;
            }
            
            return self.preFormattedSeenPayload;
        };
    }
    
    CENConfiguration *chatEngineConfiguration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    CENChatEngine *chatEngine = [self chatEngineWithConfiguration:chatEngineConfiguration];
    self.defaultClient = [self partialMockForObject:chatEngine];
    
    self.defaultChat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:chatEngine];
    
    self.defaultMiddleware = [CENPushNotificationsMiddleware new];
    id defaultMiddlewareMock = [self partialMockForObject:self.defaultMiddleware];
    OCMStub([defaultMiddlewareMock configuration]).andReturn(middlewareConfiguration);
    
    [self prepareMessagePayload];
    [self prepareInvitePayload];
    [self prepareLeavePayload];
    [self preparePreFormattedLeavePayload];
    [self preparePreFormattedSeenPayload];
    [self preparePluginPayload];
    [self prepareSeenPayload];
    [self prepareUserPayload];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Information

- (void)testLocation_ShouldBeSetToEmit {
    
    XCTAssertEqualObjects(CENPushNotificationsMiddleware.location, CEPMiddlewareLocation.emit);
}


#pragma mark - Tests :: Default formatter

- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenMessageEventWithMessageDataKeyPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"message" withData:self.defaultMessagePayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"title"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"body"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentTitle"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentText"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"ticker"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"], @"CATEGORY_MESSAGE");
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenMessageEventWithTextDataKeyPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"message" withData:self.defaultMessagePayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"title"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"body"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentTitle"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentText"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"ticker"]);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"], @"CATEGORY_MESSAGE");
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenInviteEventPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"$.invite" withData:self.defaultInvitePayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"aps"][@"alert"][@"title"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"aps"][@"alert"][@"body"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"contentTitle"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"contentText"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"ticker"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"category"], @"CATEGORY_SOCIAL");
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenSeenEventPassed {
    
    NSString *expected = @"com.pubnub.chat-engine.notifications.seen";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"$notifications.seen" withData:self.seenPayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.seenPayload[@"pn_apns"]);
        XCTAssertEqualObjects(self.seenPayload[@"pn_apns"][@"aps"][@"category"], expected);
        XCTAssertNotNil(self.seenPayload[@"pn_apns"][@"cepayload"]);
        XCTAssertNotNil(self.seenPayload[@"pn_gcm"]);
        XCTAssertEqualObjects(self.seenPayload[@"pn_gcm"][@"data"][@"category"], expected);
        XCTAssertNotNil(self.seenPayload[@"pn_gcm"][@"data"][@"cepayload"]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Payload normalization

- (void)testPayloadNormalization_ShouldAddChatEngineEventToPayload {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"$.invite" withData:self.defaultInvitePayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"cepayload"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"cepayload"][CENEventData.chat]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"cepayload"][CENEventData.data]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"cepayload"][CENEventData.event]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"cepayload"][CENEventData.sender]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"cepayload"]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.chat]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.data]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.event]);
        XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"cepayload"][CENEventData.sender]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testPayloadNormalization_ShouldGenerateCategory_WhenEventNameGenerateBySystem {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected = @"com.pubnub.chat-engine.leave";
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"$.leave" withData:self.defaultLeavePayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.defaultLeavePayload[@"pn_apns"][@"aps"][@"category"]);
        XCTAssertEqualObjects(self.defaultLeavePayload[@"pn_apns"][@"aps"][@"category"], expected);
        XCTAssertNotNil(self.defaultLeavePayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.defaultLeavePayload[@"pn_gcm"][@"data"][@"category"], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testPayloadNormalization_ShouldGenerateCategory_WhenEventNameGenerateByPlugin {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected = @"com.pubnub.chat-engine.seen";
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"$seen" withData:self.pluginPayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.pluginPayload[@"pn_apns"][@"aps"][@"category"]);
        XCTAssertEqualObjects(self.pluginPayload[@"pn_apns"][@"aps"][@"category"], expected);
        XCTAssertNotNil(self.pluginPayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.pluginPayload[@"pn_gcm"][@"data"][@"category"], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testPayloadNormalization_ShouldGenerateCategory_WhenEventNameGenerateByUser {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expected = @"com.pubnub.chat-engine.my-event";
    __block BOOL handlerCalled =  NO;
    
    [self.defaultMiddleware runForEvent:@"my-event" withData:self.userPayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.userPayload[@"pn_apns"][@"aps"][@"category"]);
        XCTAssertEqualObjects(self.userPayload[@"pn_apns"][@"aps"][@"category"], expected);
        XCTAssertNotNil(self.userPayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.userPayload[@"pn_gcm"][@"data"][@"category"], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testPayloadNormalization_ShouldUseProvidedCategory_WhenCategoryIsPresentInNotificationBoundledChatEngineEvent {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled =  NO;
    NSString *expected = @"seen";
    
    [self.defaultMiddleware runForEvent:@"message" withData:self.defaultMessagePayload completion:^(BOOL rejected) {
        handlerCalled = YES;
        
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"category"]);
        XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"category"], expected);
        XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"]);
        XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}






#pragma mark - Misc

- (void)preparePreFormattedLeavePayload {
    
    self.preFormattedLeavePayload = [@{
        @"apns": @{ @"aps": @{ @"alert": @{ @"title": @"Hi" } }, @"cepayload": self.defaultMessagePayload },
        @"gcm": @{ @"data": @{ @"contentTitle": @"Hi", @"cepayload": self.defaultMessagePayload } }
    } mutableCopy];
}

- (void)preparePreFormattedSeenPayload {

    NSDictionary *payload = @{ CENEventData.eventID: @"1234567890" };
    self.preFormattedSeenPayload = [@{
        @"apns": @{ @"aps": @{ @"content-available": @1, @"sound": @"", @"category": @"seen" }, @"cepayload": payload },
        @"gcm": @{ @"data": @{ @"category": @"seen", @"cepayload": payload } }
    } mutableCopy];
}

- (void)prepareMessagePayload {
    
    NSString *key = [self.name rangeOfString:@"WithTextDataKey"].location != NSNotFound ? @"text" : @"message";
    NSMutableDictionary *data = [NSMutableDictionary new];
    data[key] = @"Hello there";
    
    self.defaultMessagePayload = [@{
        CENEventData.chat: self.defaultChat,
        CENEventData.data: data,
        CENEventData.event: @"message",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)prepareInvitePayload {
    
    self.defaultInvitePayload = [@{
        CENEventData.chat: self.defaultChat,
        CENEventData.data: @{ @"channel": @"secret-channel" },
        CENEventData.event: @"$.invite",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)prepareLeavePayload {
    
    self.defaultLeavePayload = [@{
        CENEventData.chat: self.defaultChat,
        CENEventData.data: @{ @"channel": @"secret-channel" },
        CENEventData.event: @"$.leave",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)preparePluginPayload {
    
    self.pluginPayload = [@{
        CENEventData.chat: self.defaultChat,
        CENEventData.data: @{ @"important": @"data" },
        CENEventData.event: @"$seen",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)prepareSeenPayload {
    
    self.seenPayload = [@{
        CENEventData.chat: self.defaultChat,
        CENEventData.data: @{ CENEventData.eventID: @"1234567890" },
        CENEventData.event: @"$notifications.seen",
        CENEventData.eventID: @"1234567891",
        CENEventData.sender: @"tester2"
    } mutableCopy];
}

- (void)prepareUserPayload {
    
    self.userPayload = [@{
        CENEventData.chat: self.defaultChat,
        CENEventData.data: @{ @"my": @"data" },
        CENEventData.event: @"my-event",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

#pragma mark -


@end
