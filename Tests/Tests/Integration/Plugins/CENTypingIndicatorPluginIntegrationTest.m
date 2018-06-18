/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENTypingIndicatorPlugin.h>


#pragma mark Interface declaration

@interface CENTypingIndicatorPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENTypingIndicatorPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSTimeInterval timeout = 2.f;
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    [self setupChatEngineWithGlobal:global forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    if ([self.name rangeOfString:@"ShouldNotSendStartTypingEvent_WhenAlreadyCalledHelperMethod"].location == NSNotFound &&
        [self.name rangeOfString:@"ShouldSendStopTypingEvent_WhenCalledHelperMethod"].location == NSNotFound) {
        timeout = 60.f;
    }
    
    NSDictionary *configuration = @{ CENTypingIndicatorConfiguration.timeout: @(timeout) };
    [self chatEngineForUser:@"ian"].global.plugin([CENTypingIndicatorPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENTypingIndicatorPlugin class]).configuration(configuration).store();
}

- (void)testStartTyping_ShouldSendStartTypingEvent_WhenCalledHelperMethod {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.on(@"$typingIndicator.startTyping", ^(NSDictionary *payload) {
        NSString *sender = ((CENUser *)payload[CENEventData.sender]).uuid;
        handlerCalled = YES;
        
        XCTAssertNotEqual([sender rangeOfString:@"ian"].location, NSNotFound);
        dispatch_semaphore_signal(semaphore);
    });

    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)));
    [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testStartTyping_ShouldNotSendStartTypingEvent_WhenAlreadyCalledHelperMethod {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalledTwice = NO;
    
    
    client2.global.once(@"$typingIndicator.startTyping", ^(NSDictionary *payload) {
        [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
        
        client2.global.once(@"$typingIndicator.startTyping", ^(NSDictionary *payload) {
            handlerCalledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        });
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.f * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalledTwice);
}

- (void)teststopTyping_ShouldSendStopTypingEvent_WhenCalledHelperMethod {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.once(@"$typingIndicator.startTyping", ^(NSDictionary *payload) {
        [CENTypingIndicatorPlugin setTyping:NO inChat:client1.global];
        
        client2.global.once(@"$typingIndicator.stopTyping", ^(NSDictionary *payload) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        });
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    [CENTypingIndicatorPlugin setTyping:YES inChat:client1.global];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
