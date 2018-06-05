/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineChatInviteIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineChatInviteIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    [self setupChatEngineWithGlobal:global forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testInvite_ShouldBeAbleToConnectTwoUsersInPrivateChat_WhenOneUserInvitedAnother {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *privateChatName = @"predictable-secret-channel";
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block BOOL messageReceived = NO;
    __block BOOL handlerCalled = NO;
    NSString *expected = @"sup?";
    
    client1.me.direct.once(@"$.invite", ^(NSDictionary *payload) {
        CENChat *myPrivateChat = client1.Chat().name(payload[CENEventData.data][@"channel"]).create();
        myPrivateChat.on(@"$.connected", ^{
            myPrivateChat.emit(@"message").data(@{ @"text": expected }).perform();
        });
    });
    
    CENChat *privateChat = client2.Chat().name(privateChatName).create();
    privateChat.on(@"$.connected", ^{
        privateChat.invite(client1.me);
    });
    
    privateChat.on(@"message", ^(NSDictionary *payload) {
        if (!messageReceived) {
            messageReceived = YES;
            handlerCalled = YES;
            
            XCTAssertEqualObjects(payload[CENEventData.data][@"text"], expected);
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
