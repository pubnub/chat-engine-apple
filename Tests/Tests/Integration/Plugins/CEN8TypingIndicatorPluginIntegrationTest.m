/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENTypingIndicatorPlugin.h>
#import <CENChatEngine/CENChatEngine+Private.h>


#pragma mark Interface declaration

@interface CEN8TypingIndicatorPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN8TypingIndicatorPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSMutableDictionary *configuration = [NSMutableDictionary new];
    NSTimeInterval timeout = 2.f;
    
    if ([self.name rangeOfString:@"ShouldNotSendStartTypingEvent_WhenAlreadyCalledHelperMethod"].location == NSNotFound &&
        [self.name rangeOfString:@"ShouldSendStopTypingEvent_WhenCalledHelperMethod"].location == NSNotFound) {
        timeout = 60.f;
    }
    
    if ([self.name rangeOfString:@"teststopTyping_ShouldSendStopTypingEvent_WhenReachTimeoutInterval"].location != NSNotFound) {
        timeout = 1.f;
    }
    
    if ([self.name rangeOfString:@"UserSendKnownEventToChat"].location != NSNotFound) {
        configuration[CENTypingIndicatorConfiguration.events] = @[@"ping"];
        timeout = 60.f;
    }
    
    if ([self.name rangeOfString:@"UserSendUnknownEventToChat"].location != NSNotFound) {
        configuration[CENTypingIndicatorConfiguration.events] = @[@"pong"];
        timeout = 60.f;
    }
    
    configuration[CENTypingIndicatorConfiguration.timeout] = @(timeout);
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    [self chatEngineForUser:@"ian"].global.plugin([CENTypingIndicatorPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENTypingIndicatorPlugin class]).configuration(configuration).store();
}

- (void)testStartTyping_ShouldSendStartTypingEvent_WhenCalledHelperMethod {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.startTyping"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            NSString *sender = ((CENUser *)payload[CENEventData.sender]).uuid;
            
            XCTAssertNotEqual([sender rangeOfString:@"ian"].location, NSNotFound);
            handler();
        };
    } afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];

    XCTAssertTrue([CENTypingIndicatorPlugin isTypingInChat:client1.global]);
}

- (void)testStartTyping_ShouldNotSendStartTypingEvent_WhenAlreadyCalledHelperMethod {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.startTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];
    
    [self object:client2.global shouldNotHandleEvent:@"$typingIndicator.startTyping"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];
}

- (void)testStopTyping_ShouldSendStopTypingEvent_WhenCalledHelperMethod {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.startTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.stopTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:NO inChat:client1.global];
    }];
}

- (void)testStopTyping_ShouldSendStopTypingEvent_WhenUserSendKnownEventToChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.startTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.stopTyping" afterBlock:^{
        client1.global.emit(@"ping").data(@{ @"test": @"ping" }).perform();
    }];
}

- (void)testStopTyping_ShouldNotSendStopTypingEvent_WhenUserSendUnknownEventToChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.startTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];
    
    [self object:client2.global shouldNotHandleEvent:@"$typingIndicator.stopTyping"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         
        return ^(CENEmittedEvent *event) {
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"ping").data(@{ @"test": @"ping" }).perform();
    }];
}

#pragma mark -


@end
