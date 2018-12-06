/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENUser+Private.h>


#pragma mark Interface declaration

@interface CENChatEngineUserStateIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSString *namespace;
@property (nonatomic, strong) NSString *globalChannel;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineUserStateIntegrationTest


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
    
    [self setupChatEngineForUser:@"ian"];
    
    if ([self.name rangeOfString:@"testState_ShouldGetStateUpdate_WhenUserChangeHisState"].location != NSNotFound) {
        [self setupChatEngineForUser:@"stephen"];
    }
}

- (void)testState_ShouldGetPreviouslyState_WhenUserJoinBecomeOnline {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChat *chat1 = client1.Chat().name(@"state-autorestore-chat").autoConnect(NO).create();
    
    
    [self object:chat1 shouldHandleEvent:@"$.online.*" afterBlock:^{
        chat1.connect();
    }];
    
    [self object:chat1 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            if ([user.uuid isEqualToString:client1.me.uuid]) {
                handler();
            }
        };
    } afterBlock:^{
        chat1.setState(@{ @"oldState": @YES });
    }];
    
    client1.disconnect();
    
    [self setupChatEngineForUser:@"serhii"];
    CENChatEngine *client2 = [self chatEngineForUser:@"serhii"];
    CENChat *chat2 = client2.Chat().name(chat1.name).autoConnect(NO).create().restoreState(nil);
    
    [self object:chat2 shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        chat2.connect();
    }];
    
    [self object:chat2 shouldHandleEvent:@"$.online.*" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            if ([user.uuid isEqualToString:client1.me.uuid]) {
                XCTAssertEqualObjects(user.state(chat2), @{ @"oldState": @YES });
                handler();
            }
        };
    } afterBlock:^{
        client1.reconnect();
    }];
}

- (void)testState_ShouldGetUserState_WhenUserOffline {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChat *chat1 = client1.Chat().name(@"offline-state-chat").autoConnect(NO).create();
    
    
    [self object:chat1 shouldHandleEvent:@"$.online.*" afterBlock:^{
        chat1.connect();
    }];
    
    [self object:chat1 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        chat1.setState(@{ @"oldState": @YES });
    }];
    
    [self setupChatEngineForUser:@"serhii"];
    CENChatEngine *client2 = [self chatEngineForUser:@"serhii"];
    CENChat *chat2 = client2.Chat().name(chat1.name).autoConnect(NO).create();
    
    
    [self object:chat2 shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = client2.User(client1.me.uuid).create();
            
            [user restoreStateForChat:chat2 withCompletion:^(NSDictionary *state) {
                XCTAssertEqualObjects(state, @{ @"oldState": @YES });
                handler();
            }];
        };
    } afterBlock:^{
        chat2.connect();
    }];
}

- (void)testState_ShouldGetStateUpdate_WhenUserChangeHisState {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            if ([user.uuid isEqualToString:client1.me.uuid]) {
                XCTAssertNotNil(user.state(nil)[@"newParameter"]);
                XCTAssertTrue(((NSNumber *)user.state(nil)[@"newParameter"]).boolValue);
                handler();
            }
        };
    } afterBlock:^{
        client1.me.update(@{ @"newParameter": @YES }, nil);
    }];
}

#pragma mark -


@end
