/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENDefines.h>
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CEN2ChatEngineUserStateIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CEN2ChatEngineUserStateIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
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
    
    
    chat1.connect();
    [self waitForOwnOnlineOnChat:chat1];
    
    [self object:client1 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            if ([user.uuid isEqualToString:client1.me.uuid]) {
                handler();
            }
        };
    } afterBlock:^{
        client1.me.update(@{ @"oldState": @YES });
    }];
    
    client1.disconnect();
    
    [self setupChatEngineForUser:@"serhii"];
    CENChatEngine *client2 = [self chatEngineForUser:@"serhii"];
    CENChat *chat2 = client2.Chat().name(chat1.name).autoConnect(NO).create();
    
    chat2.connect();
    [self waitForOwnOnlineOnChat:chat2];
    
    [self object:client2.global shouldHandleEvent:@"$.online.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            if ([user.uuid isEqualToString:client1.me.uuid]) {
                XCTAssertEqualObjects(user.state, @{ @"oldState": @YES });
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
    
    
    chat1.connect();
    [self waitForOwnOnlineOnChat:chat1];
    
    [self object:client1 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.me.update(@{ @"oldState": @YES });
    }];
    
    [self setupChatEngineForUser:@"serhii"];
    CENChatEngine *client2 = [self chatEngineForUser:@"serhii"];
    CENChat *chat2 = client2.Chat().name(chat1.name).autoConnect(NO).create();
    
    chat2.connect();
    [self waitForOwnOnlineOnChat:chat2];
    
    CENUser *user = client2.User(client1.me.uuid).create();
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [user restoreStateForChat:client2.global withCompletion:^(NSDictionary *state) {
            XCTAssertEqualObjects(state, @{ @"oldState": @YES });
            handler();
        }];
    }];
}

- (void)testState_ShouldGetStateUpdate_WhenUserChangeHisState {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            if ([user.uuid isEqualToString:client1.me.uuid]) {
                XCTAssertNotNil(user.state[@"newParameter"]);
                XCTAssertTrue(((NSNumber *)user.state[@"newParameter"]).boolValue);
                handler();
            }
        };
    } afterBlock:^{
        client1.me.update(@{ @"newParameter": @YES });
    }];
}

#pragma mark -


@end
