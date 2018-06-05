/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineChatMetaIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineChatMetaIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [self setupChatEngineWithGlobal:@"global" forUser:@"ian" synchronization:NO meta:YES state:@{ @"works": @YES }];
}

- (void)testMeta_ShouldUpdateChatMeta_WhenChatCreatedWithMeta {
    
    NSString *chatName = [@[@"chat-tester", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSDictionary *expected = @{ @"works": @YES };
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(chatName).meta(expected).create();
    chat.on(@"$.connected", ^{
        handlerCalled = YES;
        
        XCTAssertEqualObjects(chat.meta, expected);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
