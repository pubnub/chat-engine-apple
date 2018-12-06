/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineConnectionIntegrationTest: CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineConnectionIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {

    return YES;
}

- (NSString *)namespaceForTestCaseWithName:(NSString *)name {
    
    NSString *namespace = [super namespaceForTestCaseWithName:name];
    NSArray *components = nil;
    
    if ([name rangeOfString:@"ChatPublicNamespace"].location != NSNotFound) {
        components = @[namespace, @"chat#public"];
    } else if ([name rangeOfString:@"ChatPrivateNamespace"].location != NSNotFound) {
        components = @[namespace, @"chat#private"];
    } else if ([name rangeOfString:@"UserUUIDReadNamespace"].location != NSNotFound) {
        components = @[namespace, @"user", @"serhii", @"read"];
    } else if ([name rangeOfString:@"UserUUIDWriteNamespace"].location != NSNotFound) {
        components = @[namespace, @"user", @"serhii", @"write"];
    } else if ([name rangeOfString:@"UUIDRoomsNamespace"].location != NSNotFound) {
        components = @[namespace, @"serhii", @"rooms"];
    } else if ([name rangeOfString:@"UUIDRoomsPresenceNamespace"].location != NSNotFound) {
        components = @[namespace, @"serhii", @"rooms-pnpres"];
    } else if ([name rangeOfString:@"UUIDSystemNamespace"].location != NSNotFound) {
        components = @[namespace, @"serhii", @"system"];
    } else if ([name rangeOfString:@"UUIDSystemPresenceNamespace"].location != NSNotFound) {
        components = @[namespace, @"serhii", @"system-pnpres"];
    } else if ([name rangeOfString:@"UUIDCustomNamespace"].location != NSNotFound) {
        components = @[namespace, @"serhii", @"custom"];
    } else if ([name rangeOfString:@"UUIDCustomPresenceNamespace"].location != NSNotFound) {
        components = @[namespace, @"serhii", @"custom-pnpres"];
    }
    
    return components ? [components componentsJoinedByString:@"#"] : namespace;
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {

    return @{ @"works": @YES };
}

- (void)setUp {
    
    [super setUp];

    if ([self.name rangeOfString:@"testConnect_ShouldFail"].location == NSNotFound) {
        [self setupChatEngineForUser:@"serhii"];
    }
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

- (void)testConnect_ShouldFail_WhenChatPublicNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {

            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenChatPrivateNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {

            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUserUUIDReadNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUserUUIDWriteNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUUIDRoomsNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUUIDRoomsPresenceNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUUIDSystemNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUUIDSystemPresenceNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUUIDCustomNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testConnect_ShouldFail_WhenUUIDCustomPresenceNamespaceUsed {
    
    CENChatEngine *client = [self createChatEngineForUser:@"serhii"];
    
    [self object:client shouldHandleEvent:@"$.error.connect.handshake"
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

        return ^(CENEmittedEvent *emittedEvent) {
            NSError *error = ((NSError *)emittedEvent.data).userInfo[NSUnderlyingErrorKey];
            
            XCTAssertNotNil(error);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"serhii" usingClient:client];
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenNewChatCreated {
    
    NSString *chatName = @"this-is-only-a-test-1";
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];


    [self object:client shouldHandleEvent:@"$.created.chat" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.emitter;
            NSArray *channelComponents = @[client.currentConfiguration.namespace, @"chat#public.", chatName];
            NSString *expectedChannel = [channelComponents componentsJoinedByString:@"#"];

            XCTAssertEqualObjects(expectedChannel, chat.channel);
            handler();
        };
    } afterBlock:^{
        client.Chat().name(chatName).create();
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatConnected {
    
    NSString *chatName = @"this-is-only-a-test-2";
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];


    [self object:client shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.emitter;

            XCTAssertEqualObjects(chat.name, chatName);
            handler();
        };
    } afterBlock:^{
        client.Chat().name(chatName).create();
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatDisconnected {
    
    NSString *chatName = @"this-is-only-a-test-3";
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];


    [self object:client shouldHandleEvent:@"$.disconnected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.emitter;

            XCTAssertEqualObjects(chat.name, chatName);
            handler();
        };
    } afterBlock:^{
        CENChat *testChat = client.Chat().name(chatName).create();

        testChat.once(@"$.connected", ^(CENEmittedEvent *emittedEvent) {
            testChat.leave();
        });
    }];
}

#pragma mark -


@end
