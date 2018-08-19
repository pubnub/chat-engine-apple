/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENUnreadMessagesPlugin.h>


#pragma mark Interface declaration

@interface CENUnreadMessagesPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENUnreadMessagesPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSDictionary *configuration = nil;
    NSArray<NSString *> *eventNames = nil;
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayBetweenActions * NSEC_PER_SEC)));
        
    [self setupChatEngineWithGlobal:global forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    if ([self.name rangeOfString:@"testConstructor_ShouldEmitUnreadEvent_WhenPluginRegisteredOnEvent"].location != NSNotFound ||
        [self.name rangeOfString:@"ShouldNotEmitUnreadEvent_WhenPluginNotRegisteredOnEvent"].location != NSNotFound) {
        eventNames = @[@"ping"];
    }
    
    if (eventNames) {
        configuration = @{ CENUnreadMessagesConfiguration.events: eventNames };
    }
    
    [self chatEngineForUser:@"ian"].global.plugin([CENUnreadMessagesPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENUnreadMessagesPlugin class]).configuration(configuration).store();
    
    // Give some time to connect both users.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayBetweenActions * NSEC_PER_SEC)));
}

- (void)testConstructor_ShouldEmitUnreadEventForMessageEvent_WhenNoConfigurationPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.once(@"$unread", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertNotNil(payload);
        dispatch_semaphore_signal(semaphore);
    });
    
    client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testConstructor_ShouldEmitUnreadEvent_WhenPluginRegisteredOnEvent {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.once(@"$unread", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        XCTAssertNotNil(payload);
        dispatch_semaphore_signal(semaphore);
    });
    
    client1.global.emit(@"ping").data(@{ @"text": @"Hi!" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testConstructor_ShouldNotEmitUnreadEvent_WhenPluginNotRegisteredOnEvent {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.once(@"$unread", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    client1.global.emit(@"pong").data(@{ @"text": @"Hi!" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (void)testUnreadEvent_ShouldEmitUnreadEvent_WhenMessageSentToNotActiveChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.once(@"$unread", ^(NSDictionary *payload) {
        NSNumber *count = payload[CENUnreadMessagesEvent.count];
        handlerCalled = YES;
        
        XCTAssertNotNil(payload);
        XCTAssertEqual(count.unsignedIntegerValue, 1);
        dispatch_semaphore_signal(semaphore);
    });
    
    client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testUnreadEvent_ShouldNotEmitUnreadEvent_WhenMessageSentToActiveChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
    
    client2.global.once(@"$unread", ^(NSDictionary *payload) {
        handlerCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    [CENUnreadMessagesPlugin setChat:client2.global active:YES];
    client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (void)testUnreadEvent_ShouldNotEmitUnreadEvent_WhenMessageSentToChatWhichBecameNotActiveChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalledOnce = NO;
    __block BOOL handlerCalledTwice = NO;
    
    client2.global.on(@"$unread", ^(NSDictionary *payload) {
        if(handlerCalledOnce) {
            handlerCalledTwice = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
        
        if (!handlerCalledOnce) {
        }
        
        handlerCalledOnce = YES;
    });
    
    [CENUnreadMessagesPlugin setChat:client2.global active:YES];
    client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    
    client2.global.once(@"message", ^(NSDictionary *payload) {
        [CENUnreadMessagesPlugin setChat:client2.global active:NO];
        client1.global.emit(@"message").data(@{ @"text": @"Hi there!" }).perform();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalledOnce);
    XCTAssertFalse(handlerCalledTwice);
}


- (void)testFetchUnreadCount_ShouldBeGreaterThanZero_WhenMessageSentToNotActiveChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;

    void(^countVerifyBlock)(NSDictionary *) = ^(NSDictionary *payload) {
        [CENUnreadMessagesPlugin fetchUnreadCountForChat:client2.global withCompletion:^(NSUInteger unreadCount) {
            handlerCalled = YES;
            
            XCTAssertGreaterThan(unreadCount, 0);
            dispatch_semaphore_signal(semaphore);
        }];
    };
    
    if (YHVVCR.cassette.isNewCassette) {
        client2.global.once(@"message", countVerifyBlock);
    }
    
    [CENUnreadMessagesPlugin setChat:client2.global active:NO];
    client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    
    if (!YHVVCR.cassette.isNewCassette) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
        countVerifyBlock(nil);
    }
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testFetchUnreadCount_ShouldBeEqualToZero_WhenMessageSentToActiveChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL handlerCalled = NO;
   
    void(^countVerifyBlock)(NSDictionary *) = ^(NSDictionary *payload) {
        [CENUnreadMessagesPlugin fetchUnreadCountForChat:client2.global withCompletion:^(NSUInteger unreadCount) {
            handlerCalled = YES;
            
            XCTAssertEqual(unreadCount, 0);
            dispatch_semaphore_signal(semaphore);
        }];
    };
    
    if (YHVVCR.cassette.isNewCassette) {
        client2.global.once(@"message", countVerifyBlock);
    }
    
    [CENUnreadMessagesPlugin setChat:client2.global active:YES];
    client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    
    if (!YHVVCR.cassette.isNewCassette) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
        countVerifyBlock(nil);
    }
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
