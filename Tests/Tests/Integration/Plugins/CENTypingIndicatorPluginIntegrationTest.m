/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENTypingIndicatorPlugin.h>


#pragma mark Interface declaration

@interface CENTypingIndicatorPluginIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSString *namespace;
@property (nonatomic, strong) NSString *globalChannel;


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENTypingIndicatorPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (NSString *)globalChatChannelForTestCaseWithName:(NSString *)name {
    
    NSString *channel = [super globalChatChannelForTestCaseWithName:name];
    
    if (!self.globalChannel) {
        self.globalChannel = channel;
    }
    
    return self.globalChannel ?: channel;
}

- (NSString *)namespaceForTestCaseWithName:(NSString *)name {
    
    NSString *namespace = [super namespaceForTestCaseWithName:name];
    
    if (!self.namespace) {
        self.namespace = namespace;
    }
    
    return self.namespace ?: namespace;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSTimeInterval timeout = 2.f;
    
    if ([self.name rangeOfString:@"ShouldNotSendStartTypingEvent_WhenAlreadyCalledHelperMethod"].location == NSNotFound &&
        [self.name rangeOfString:@"ShouldSendStopTypingEvent_WhenCalledHelperMethod"].location == NSNotFound) {
        timeout = 60.f;
    }
    
    if ([self.name rangeOfString:@"teststopTyping_ShouldSendStopTypingEvent_WhenReachTimeoutInterval"].location != NSNotFound) {
        timeout = 1.f;
    }
    
    NSDictionary *configuration = @{ CENTypingIndicatorConfiguration.timeout: @(timeout) };
    
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
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [CENTypingIndicatorPlugin checkIsTypingInChat:client1.global withCompletion:^(BOOL isTyping) {
            XCTAssertTrue(isTyping);
            handler();
        }];
    }];
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

- (void)teststopTyping_ShouldSendStopTypingEvent_WhenCalledHelperMethod {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.startTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    }];
    
    [self object:client2.global shouldHandleEvent:@"$typingIndicator.stopTyping" afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:NO inChat:client1.global];
    }];
}

#pragma mark -


@end
