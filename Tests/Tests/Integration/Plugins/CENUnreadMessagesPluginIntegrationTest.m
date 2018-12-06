/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENUnreadMessagesPlugin.h>


#pragma mark Interface declaration

@interface CENUnreadMessagesPluginIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSString *namespace;
@property (nonatomic, strong) NSString *globalChannel;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENUnreadMessagesPluginIntegrationTest


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
    
    
    NSDictionary *configuration = nil;
    NSArray<NSString *> *eventNames = nil;
    
    if ([self.name rangeOfString:@"testConstructor_ShouldEmitUnreadEvent_WhenPluginRegisteredOnEvent"].location != NSNotFound ||
        [self.name rangeOfString:@"ShouldNotEmitUnreadEvent_WhenPluginNotRegisteredOnEvent"].location != NSNotFound) {
        eventNames = @[@"ping"];
    }
    
    if (eventNames) {
        configuration = @{ CENUnreadMessagesConfiguration.events: eventNames };
    }
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    [self chatEngineForUser:@"ian"].global.plugin([CENUnreadMessagesPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENUnreadMessagesPlugin class]).configuration(configuration).store();
}

- (void)testConstructor_ShouldEmitUnreadEventForMessageEvent_WhenNoConfigurationPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    }];
}

- (void)testConstructor_ShouldEmitUnreadEvent_WhenPluginRegisteredOnEvent {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
        
            XCTAssertNotNil(payload);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"ping").data(@{ @"text": @"Hi!" }).perform();
    }];
}

- (void)testConstructor_ShouldNotEmitUnreadEvent_WhenPluginNotRegisteredOnEvent {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldNotHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"pong").data(@{ @"text": @"Hi!" }).perform();
    }];
}

- (void)testUnreadEvent_ShouldEmitUnreadEvent_WhenMessageSentToNotActiveChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            NSNumber *count = payload[CENUnreadMessagesEvent.count];
        
            XCTAssertNotNil(payload);
            XCTAssertEqual(count.unsignedIntegerValue, 1);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    }];
}

- (void)testUnreadEvent_ShouldNotEmitUnreadEvent_WhenMessageSentToActiveChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldNotHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [CENUnreadMessagesPlugin setChat:client2.global active:YES];
        client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    }];
}

- (void)testUnreadEvent_ShouldNotEmitUnreadEvent_WhenMessageSentToChatWhichBecameNotActiveChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldNotHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [CENUnreadMessagesPlugin setChat:client2.global active:YES];
        client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    }];
    
    [self object:client2.global shouldHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [CENUnreadMessagesPlugin setChat:client2.global active:NO];
        client1.global.emit(@"message").data(@{ @"text": @"Hi there!" }).perform();
    }];
}


- (void)testFetchUnreadCount_ShouldBeGreaterThanZero_WhenMessageSentToNotActiveChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];

    
    [self object:client2.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            [CENUnreadMessagesPlugin fetchUnreadCountForChat:client2.global withCompletion:^(NSUInteger unreadCount) {
                XCTAssertGreaterThan(unreadCount, 0);
                handler();
            }];
        };
    } afterBlock:^{
        [CENUnreadMessagesPlugin setChat:client2.global active:NO];
        client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    }];
}

- (void)testFetchUnreadCount_ShouldBeEqualToZero_WhenMessageSentToActiveChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            [CENUnreadMessagesPlugin fetchUnreadCountForChat:client2.global withCompletion:^(NSUInteger unreadCount) {
                XCTAssertEqual(unreadCount, 0);
                handler();
            }];
        };
    } afterBlock:^{
        [CENUnreadMessagesPlugin setChat:client2.global active:YES];
        client1.global.emit(@"message").data(@{ @"text": @"Hi!" }).perform();
    }];
}

#pragma mark -


@end
