/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPushNotificationsMiddleware.h>
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <OCMock/OCMock.h>
#import <objc/runtime.h>
#import "CENTestCase.h"


@interface CENPushNotificationsMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENPushNotificationsMiddleware *middleware;
@property (nonatomic, nullable, strong) NSMutableDictionary *preFormattedLeavePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *preFormattedSeenPayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *defaultMessagePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *defaultInvitePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *defaultLeavePayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *pluginPayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *seenPayload;
@property (nonatomic, nullable, strong) NSMutableDictionary *userPayload;
@property (nonatomic, nullable, strong) CENChat *chat;


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

- (BOOL)shouldSetupVCR {
    
    return NO;
}

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
    
    if ([self.name rangeOfString:@"PushNotificationsDebugEnabled"].location != NSNotFound) {
        middlewareConfiguration[CENPushNotificationsConfiguration.debug] = @YES;
    }
    
    self.middleware = [CENPushNotificationsMiddleware new];
    id middlewareMock = [self mockForObject:self.middleware];
    OCMStub([middlewareMock configuration]).andReturn(middlewareConfiguration);
    
    self.chat = self.client.Chat().name(@"test").autoConnect(NO).create();
    
    [self prepareMessagePayload];
    [self prepareInvitePayload];
    [self prepareLeavePayload];
    [self preparePreFormattedLeavePayload];
    [self preparePreFormattedSeenPayload];
    [self preparePluginPayload];
    [self prepareSeenPayload];
    [self prepareUserPayload];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldContainList {
    
    // Restore previous implementation if has been replaced.
    if ([CENPushNotificationsMiddleware respondsToSelector:NSSelectorFromString(@"cen_orig_events")]) {
        SEL eventsCurrentGetter = NSSelectorFromString(@"events");
        SEL eventsOriginalGetter = NSSelectorFromString(@"cen_orig_events");
        
        Method originalMethod = class_getClassMethod([CENPushNotificationsMiddleware class], eventsOriginalGetter);
        Method currentMethod = class_getClassMethod([CENPushNotificationsMiddleware class], eventsCurrentGetter);
        method_exchangeImplementations(originalMethod, currentMethod);
    }
    
    XCTAssertGreaterThanOrEqual(CENPushNotificationsMiddleware.events.count, 1);
}

- (void)testLocation_ShouldBeSetToEmit {
    
    XCTAssertEqualObjects(CENPushNotificationsMiddleware.location, CEPMiddlewareLocation.emit);
}


#pragma mark - Tests :: Default formatter

- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenMessageEventWithMessageDataKeyPassed {

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:self.defaultMessagePayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"title"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"body"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentTitle"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentText"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"ticker"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"], @"CATEGORY_MESSAGE");
            handler();
        }];
    }];
    
}

- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenMessageEventWithTextDataKeyPassed {
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:self.defaultMessagePayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"title"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"alert"][@"body"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentTitle"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"contentText"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"ticker"]);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"], @"CATEGORY_MESSAGE");
            handler();
        }];
    }];
}

- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenInviteEventPassed {
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$.invite" withData:self.defaultInvitePayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"aps"][@"alert"][@"title"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_apns"][@"aps"][@"alert"][@"body"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"contentTitle"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"contentText"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"ticker"]);
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.defaultInvitePayload[@"pn_gcm"][@"data"][@"category"], @"CATEGORY_SOCIAL");
            handler();
        }];
    }];
}


- (void)testDefaultFormatter_ShouldCreateServicesPayload_WhenSeenEventPassed {
    
    NSString *expected = @"com.pubnub.chat-engine.notifications.seen";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$notifications.seen" withData:self.seenPayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.seenPayload[@"pn_apns"]);
            XCTAssertEqualObjects(self.seenPayload[@"pn_apns"][@"aps"][@"category"], expected);
            XCTAssertNotNil(self.seenPayload[@"pn_apns"][@"cepayload"]);
            XCTAssertNotNil(self.seenPayload[@"pn_gcm"]);
            XCTAssertEqualObjects(self.seenPayload[@"pn_gcm"][@"data"][@"category"], expected);
            XCTAssertNotNil(self.seenPayload[@"pn_gcm"][@"data"][@"cepayload"]);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Payload normalization

- (void)testPayloadNormalization_ShouldAddChatEngineEventToPayload {
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$.invite" withData:self.defaultInvitePayload completion:^(BOOL rejected) {
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
            handler();
        }];
    }];
}

- (void)testPayloadNormalization_ShouldAddDebugFlag_WhenPushNotificationsDebugEnabled {
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$.invite" withData:self.defaultInvitePayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.defaultInvitePayload[@"pn_debug"]);
            XCTAssertTrue(((NSNumber *)self.defaultInvitePayload[@"pn_debug"]).boolValue);
            handler();
        }];
    }];
}

- (void)testPayloadNormalization_ShouldGenerateCategory_WhenEventNameGenerateBySystem {
    
    NSString *expected = @"com.pubnub.chat-engine.leave";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$.leave" withData:self.defaultLeavePayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.defaultLeavePayload[@"pn_apns"][@"aps"][@"category"]);
            XCTAssertEqualObjects(self.defaultLeavePayload[@"pn_apns"][@"aps"][@"category"], expected);
            XCTAssertNotNil(self.defaultLeavePayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.defaultLeavePayload[@"pn_gcm"][@"data"][@"category"], expected);
            handler();
        }];
    }];
}

- (void)testPayloadNormalization_ShouldGenerateCategory_WhenEventNameGenerateByPlugin {
    
    NSString *expected = @"com.pubnub.chat-engine.seen";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$seen" withData:self.pluginPayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.pluginPayload[@"pn_apns"][@"aps"][@"category"]);
            XCTAssertEqualObjects(self.pluginPayload[@"pn_apns"][@"aps"][@"category"], expected);
            XCTAssertNotNil(self.pluginPayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.pluginPayload[@"pn_gcm"][@"data"][@"category"], expected);
            handler();
        }];
    }];
}

- (void)testPayloadNormalization_ShouldGenerateCategory_WhenEventNameGenerateByUser {
    
    NSString *expected = @"com.pubnub.chat-engine.my-event";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"my-event" withData:self.userPayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.userPayload[@"pn_apns"][@"aps"][@"category"]);
            XCTAssertEqualObjects(self.userPayload[@"pn_apns"][@"aps"][@"category"], expected);
            XCTAssertNotNil(self.userPayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.userPayload[@"pn_gcm"][@"data"][@"category"], expected);
            handler();
        }];
    }];
}

- (void)testPayloadNormalization_ShouldUseProvidedCategory_WhenCategoryIsPresentInNotificationBoundledChatEngineEvent {
    
    NSString *expected = @"seen";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:self.defaultMessagePayload completion:^(BOOL rejected) {
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"category"]);
            XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_apns"][@"aps"][@"category"], expected);
            XCTAssertNotNil(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"]);
            XCTAssertEqualObjects(self.defaultMessagePayload[@"pn_gcm"][@"data"][@"category"], expected);
            handler();
        }];
    }];
}

- (void)testPayloadNormalization_ShouldNotChangePayload_WhenFormatterDoesntCreateDefaultPayload {
    
    NSMutableDictionary *expectedPayload = [self.userPayload mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"my-event" withData:self.userPayload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(self.userPayload, expectedPayload);
            handler();
        }];
    }];
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
        CENEventData.chat: self.chat,
        CENEventData.data: data,
        CENEventData.event: @"message",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)prepareInvitePayload {
    
    self.defaultInvitePayload = [@{
        CENEventData.chat: self.chat,
        CENEventData.data: @{ @"channel": @"secret-channel" },
        CENEventData.event: @"$.invite",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)prepareLeavePayload {
    
    self.defaultLeavePayload = [@{
        CENEventData.chat: self.chat,
        CENEventData.data: @{ @"channel": @"secret-channel" },
        CENEventData.event: @"$.leave",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)preparePluginPayload {
    
    self.pluginPayload = [@{
        CENEventData.chat: self.chat,
        CENEventData.data: @{ @"important": @"data" },
        CENEventData.event: @"$seen",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}

- (void)prepareSeenPayload {
    
    self.seenPayload = [@{
        CENEventData.chat: self.chat,
        CENEventData.data: @{ CENEventData.eventID: @"1234567890" },
        CENEventData.event: @"$notifications.seen",
        CENEventData.eventID: @"1234567891",
        CENEventData.sender: @"tester2"
    } mutableCopy];
}

- (void)prepareUserPayload {
    
    self.userPayload = [@{
        CENEventData.chat: self.chat,
        CENEventData.data: @{ @"my": @"data" },
        CENEventData.event: @"my-event",
        CENEventData.eventID: @"1234567890",
        CENEventData.sender: @"tester"
    } mutableCopy];
}
 
#pragma mark -


@end
