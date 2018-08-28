/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENMarkdownPlugin.h>


#pragma mark Interface declaration

@interface CENMarkdownPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENMarkdownPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSDictionary *configuration = nil;
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayBetweenActions * NSEC_PER_SEC)));
    
    [self setupChatEngineWithGlobal:global forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    if ([self.name rangeOfString:@"testDefaultCondfiguration"].location == NSNotFound) {
        configuration = @{ CENMarkdownConfiguration.events: @[@"message"], CENMarkdownConfiguration.messageKey: @"text" };
    }
    
    [self chatEngineForUser:@"ian"].global.plugin([CENMarkdownPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENMarkdownPlugin class]).configuration(configuration).store();
    
    // Give some time to connect both users.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayBetweenActions * NSEC_PER_SEC)));
}

- (void)testDefaultCondfiguration_ShouldHandleMessageEventsByDefault {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client1.global.once(@"message", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.data][@"text"]);
        XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
        dispatch_semaphore_signal(semaphore);
    });
    
    client2.global.emit(@"message").data(@{ @"text": @"_Italic_ text" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultCondfiguration_ShouldHandleMessagesUnderDefaultDataKey {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client1.global.once(@"message", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.data][@"text"]);
        XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
        dispatch_semaphore_signal(semaphore);
    });
    
    client2.global.emit(@"message").data(@{ @"text": @"**Bold** text" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testMarkdownFormat_ShouldNotFormatReceivedMessage_WhenReceivedMessageWithOutMarkdownMarkup {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client1.global.once(@"message", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.data][@"text"]);
        XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSString class]]);
        dispatch_semaphore_signal(semaphore);
    });
    
    client2.global.emit(@"message").data(@{ @"text": @"Simple text" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testMarkdownFormat_ShouldFormatReceivedMessage_WhenReceivedMessageWithMarkdownMarkup {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client1.global.once(@"message", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.data][@"text"]);
        XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
        dispatch_semaphore_signal(semaphore);
    });
    
    client2.global.emit(@"message").data(@{ @"text": @"**Bold** text" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
