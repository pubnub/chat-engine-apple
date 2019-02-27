/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENSearchFilterMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CENSearch+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENSearchFilterMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENSearchFilterMiddleware *middleware;
@property (nonatomic, nullable, strong) CENUser *user;


#pragma mark - Misc

- (NSMutableDictionary *)payloadForEvent:(NSString *)event fromUser:(CENUser *)user;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENSearchFilterMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    self.user = self.client.User([NSUUID UUID].UUIDString).create();
    CENSearch *search = [CENSearch searchForEvent:@"event" inChat:chat sentBy:self.user withLimit:0
                                            pages:0 count:100 start:nil end:nil chatEngine:self.client];
    NSMutableDictionary *configuration = [NSMutableDictionary new];
    
    if ([self.name rangeOfString:@"SpecificUserConfigured"].location != NSNotFound ||
        [self.name rangeOfString:@"SpecificUserAndEventConfigured"].location != NSNotFound) {
        configuration[@"sender"] = self.user.uuid;
    }
    
    if ([self.name rangeOfString:@"SpecificEventConfigured"].location != NSNotFound ||
        [self.name rangeOfString:@"SpecificUserAndEventConfigured"].location != NSNotFound) {
        configuration[@"event"]= @"test-event";
    }
    
    self.middleware = [CENSearchFilterMiddleware middlewareForObject:search withIdentifier:@"test"
                                                       configuration:configuration];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENSearchFilterMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENSearchFilterMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: Search

- (void)testSearch_ShouldReturnEventsSentBySender_WhenSpecificUserConfigured {
    
    NSMutableDictionary *payload = [self payloadForEvent:@"message" fromUser:self.user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldNotReturnEventsSentByAnotherSender_WhenSpecificUserConfigured {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSMutableDictionary *payload = [self payloadForEvent:@"message" fromUser:user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertTrue(rejected);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldReturnEventsSentAsEvent_WhenSpecificEventConfigured {
    
    NSMutableDictionary *payload = [self payloadForEvent:@"test-event" fromUser:self.user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldNotReturnEventsSentAsAnotherEvent_WhenSpecificEventConfigured {
    
    NSMutableDictionary *payload = [self payloadForEvent:@"message" fromUser:self.user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertTrue(rejected);
            handler();
        }];
    }];
    
}

- (void)testSearch_ShouldReturnEventsSentBySenderAndEvent_WhenSpecificUserAndEventConfigured {
    
    NSMutableDictionary *payload = [self payloadForEvent:@"test-event" fromUser:self.user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
            handler();
        }];
    }];
    
}

- (void)testSearch_ShouldNotReturnEventsSentByAnotherSenderAndEvent_WhenSpecificUserAndEventConfigured {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSMutableDictionary *payload = [self payloadForEvent:@"test-event" fromUser:user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"test-event" withData:payload completion:^(BOOL rejected) {
            XCTAssertTrue(rejected);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldNotReturnEventsSentBySenderAndAsAnotherEvent_WhenSpecificUserAndEventConfigured {
    
    NSMutableDictionary *payload = [self payloadForEvent:@"test-event" fromUser:self.user];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertTrue(rejected);
            handler();
        }];
    }];
}


#pragma mark - Misc

- (NSMutableDictionary *)payloadForEvent:(NSString *)event fromUser:(CENUser *)user {
    
    return [@{
        CENEventData.event: event,
        CENEventData.chat: [self publicChatWithChatEngine:self.client],
        CENEventData.sender: user.uuid,
        CENEventData.data: @{ @"text": @"Test message" }
    } mutableCopy];
}

#pragma mark -


@end
