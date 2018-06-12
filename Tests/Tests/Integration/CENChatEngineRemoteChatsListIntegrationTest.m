/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineRemoteChatsListIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineRemoteChatsListIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:YES meta:YES state:@{ @"works": @YES }];
    
    if ([self.name rangeOfString:@"testSession_ShouldBePopulated_WhenGroupRestoreCompleted"].location == NSNotFound) {
        [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:YES meta:YES state:@{ @"works": @NO }];
    }
}

- (void)testSession_ShouldBeNotifiedOfNewChats_WhenCreatedFromSecondInstance {
    
    NSString *chatName = [@[@"sync-chat", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client1.me.session.on(@"$.chat.join", ^(CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertTrue([chat.channel rangeOfString:chatName].location != NSNotFound);
        dispatch_semaphore_signal(semaphore);
    });
    
    client2.Chat().name(chatName).create();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSession_ShouldBePopulated_WhenGroupRestoreCompleted {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client.me.session.once(@"$.group.restored", ^(NSString *group) {
        handlerCalled = YES;
    
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSession_ShouldGetDeleteEvent_WhenUserLeaveChat {
    
    NSString *chatName = [@[@"sync-chat", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client1.me.session.on(@"$.chat.leave", ^(CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertTrue([chat.channel rangeOfString:chatName].location != NSNotFound);
        dispatch_semaphore_signal(semaphore);
    });
    
    CENChat *chat = client2.Chat().name(chatName).create().on(@"$.connected", ^{
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    
    chat.leave();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
