/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CEN7ChatEngineChatInviteIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CEN7ChatEngineChatInviteIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
}

- (void)testInvite_ShouldBeAbleToConnectTwoUsersInPrivateChat_WhenOneUserInvitedAnother {
    
    NSString *privateChatName = @"predictable-secret-channel";
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block CENChat *myPrivateChat = nil;
    NSString *expected = @"sup?";
    
    
    CENChat *privateChat = client2.Chat().name(privateChatName).create();
    [self waitForOwnOnlineOnChat:privateChat];
    
    [self object:client1.me.direct shouldHandleEvent:@"$.invite" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent1) {
            NSDictionary *payload = emittedEvent1.data;
            
            myPrivateChat = client1.Chat().name(payload[CENEventData.data][@"channel"]).autoConnect(NO).create();
            handler();
        };
    } afterBlock:^{
        privateChat.invite(client1.me);
    }];
    
    myPrivateChat.connect();
    [self waitForOwnOnlineOnChat:myPrivateChat];
    
    [self object:privateChat shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertEqualObjects(payload[CENEventData.data][@"text"], expected);
            handler();
        };
    } afterBlock:^{
        myPrivateChat.emit(@"message").data(@{ @"text": expected }).perform();
    }];
}

#pragma mark -


@end
