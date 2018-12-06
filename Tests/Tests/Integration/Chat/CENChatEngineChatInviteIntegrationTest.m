/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineChatInviteIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSString *globalChannel;
@property (nonatomic, copy) NSString *namespace;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineChatInviteIntegrationTest


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
    [self setupChatEngineForUser:@"stephen"];
}

- (void)testInvite_ShouldBeAbleToConnectTwoUsersInPrivateChat_WhenOneUserInvitedAnother {
    
    NSString *privateChatName = @"predictable-secret-channel";
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block CENChat *myPrivateChat = nil;
    __block CENChat *privateChat = nil;
    NSString *expected = @"sup?";
    
    
    [self object:client1.me.direct shouldHandleEvent:@"$.invite" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent1) {
            NSDictionary *payload = emittedEvent1.data;
            
            myPrivateChat = client1.Chat().name(payload[CENEventData.data][@"channel"]).autoConnect(NO).create();
            myPrivateChat.once(@"$.connected", ^(CENEmittedEvent *emittedEvent2) {
                handler();
            });
            myPrivateChat.connect();
        };
    } afterBlock:^{
        privateChat = client2.Chat().name(privateChatName).autoConnect(NO).create();
        privateChat.once(@"$.connected", ^(CENEmittedEvent *emittedEvent) {
            privateChat.invite(client1.me);
        });
        privateChat.connect();
    }];
    
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
