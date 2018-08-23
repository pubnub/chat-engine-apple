/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineConnectionIntegrationTest: CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineConnectionIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [self setupChatEngineForUser:@"serhii" withSynchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testConnect_ShouldSetProperValues_WhenChatEngineConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    
    XCTAssertTrue(client.isReady);
    XCTAssertNotNil(client.pubnub);
}

- (void)testChats_ShouldContainGlobalFeedDirect_WhenChatEngineConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    NSArray<NSString *> *chatNames = [client.chats.allValues valueForKey:@"name"];
    
    XCTAssertTrue([chatNames containsObject:@"feed"]);
    XCTAssertTrue([chatNames containsObject:@"direct"]);
    XCTAssertNotNil(client.global);
}

- (void)testLocalUser_ShouldNotBeNil_WhenChatEngineConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    
    XCTAssertNotNil(client.me);
}

- (void)testHandleEvent_ShouldBeNotified_WhenNewChatCreated {
    
    NSString *chatName = @"this-is-only-a-test-1";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL handlerCalled = NO;
    
    client.on(@"$.created.chat", ^(CENChat *chat) {
        NSString *expectedChannel = [@[client.currentConfiguration.globalChannel, @"chat#public.", chatName] componentsJoinedByString:@"#"];
        if ([expectedChannel isEqualToString:chat.channel]) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    client.Chat().name(chatName).create();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatConnected {
    
    NSString *chatName = @"this-is-only-a-test-2";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL handlerCalled = NO;
    
    client.on(@"$.connected", ^(CENChat *chat) {
        if ([chat.name isEqualToString:chatName]) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    client.Chat().name(chatName).create();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatDisconnected {
    
    NSString *chatName = @"this-is-only-a-test-3";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL handlerCalled = NO;
    
    client.on(@"$.disconnected", ^(CENChat *chat) {
        if ([chat.name isEqualToString:chatName]) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    CENChat *testChat = client.Chat().name(chatName).create();
    testChat.once(@"$.connected", ^{
        testChat.leave();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
