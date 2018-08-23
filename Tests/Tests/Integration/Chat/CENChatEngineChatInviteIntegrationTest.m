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
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayBetweenActions * NSEC_PER_SEC)));
    
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
        
        myPrivateChat.once(@"$.connected", ^{
            myPrivateChat.emit(@"message").data(@{ @"text": expected }).perform();
        });
    });
    
    CENChat *privateChat = client2.Chat().name(privateChatName).create();
    privateChat.once(@"$.connected", ^{
        privateChat.invite(client1.me);
    });
    
    privateChat.once(@"message", ^(NSDictionary *payload) {
        if (!messageReceived) {
            messageReceived = YES;
            handlerCalled = YES;
            
            XCTAssertEqualObjects(payload[CENEventData.data][@"text"], expected);
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(messageReceived);
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
