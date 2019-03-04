/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/ChatEngine.h>
#import <CENChatEngine/CENDefines.h>
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CEN1ChatEngineConnectionIntegrationTest: CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN1ChatEngineConnectionIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {

    return YES;
}

- (BOOL)shouldWaitOwnOnlineStatusForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"testConnect_ShouldFail"].location == NSNotFound;
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {

    NSDictionary *state = nil;
    
    if ([name rangeOfString:@"testConnect_ShouldFail"].location == NSNotFound) {
        state = @{ @"works": @YES };
    }
    
    return state;
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

- (void)testHandleEvent_ShouldBeNotified_WhenNewChatCreated {
    
    NSString *chatName = @"this-is-only-a-test-1";
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];


    CENWeakify(client);
    [self object:client shouldHandleEvent:@"$.created.chat" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(client);
        
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.emitter;
            NSArray *channelComponents = @[client.currentConfiguration.globalChannel, @"chat#public.", chatName];
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
