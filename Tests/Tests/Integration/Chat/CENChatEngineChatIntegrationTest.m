/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CEDummyPlugin.h"


#pragma mark Interface declaration

@interface CENChatEngineChatIntegrationTest: CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineChatIntegrationTest

- (void)setUp {
    
    [super setUp];
    
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    [self setupChatEngineForUser:@"serhii" withSynchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testEmit_ShouldProvidePublishTimetoken_WhenChatEmitEvent {
    
    NSString *chatName = [@[@"chat-tester", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;
    
    CENChat *chat = client.Chat().name(chatName).create();
    chat.emit(@"test").perform().once(@"$.emitted", ^(NSDictionary *payload) {
        callbackCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.timetoken]);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testJoin_ShouldBeNotifier_WhenUserJoinToChat {
    
    NSString *chatName = [@[@"chat-tester", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;
    
    CENChat *chat = client.Chat().name(chatName).create();
    chat.once(@"$.online.join", ^(CENUser *user) {
        if ([user.uuid isEqualToString:client.me.uuid]) {
            callbackCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testHandleEvent_ShouldBeNotifier_WhenChatConnected {
    
    NSString *chatName = [@[@"chat-tester", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;
    
    CENChat *chat = client.Chat().name(chatName).create();
    chat.once(@"$.connected", ^{
        callbackCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testHandleEvent_ShouldBeNotifier_WhenMessageSent {
    
    NSString *chatName = [@[@"chat-tester", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;

    CENChat *chat = client.Chat().name(chatName).create();
    chat.once(@"something", ^(NSDictionary *payload) {
        callbackCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.timetoken]);
        XCTAssertNotNil(payload[CENEventData.data][@"text"]);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    chat.emit(@"something").data(@{ @"text": @"'hello world" }).perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testRegisterPlugin_ShouldAddExtension_WhenPluginRegistered {
    
    NSString *chatName = [@[@"chat-tester", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    CENChat *chat = client.Chat().name(chatName).create();
    __block BOOL contextBlockCalled = NO;
    
    chat.plugin([CEDummyPlugin class]).store();
    chat.extension([CEDummyPlugin class], ^(CEDummyExtension *extension) {
        contextBlockCalled = YES;
        
        XCTAssertNotNil(extension);
        XCTAssertTrue([extension respondsToSelector:@selector(testMethodReturningParentObject)]);
        XCTAssertTrue(extension.constructWorks);
        XCTAssertEqualObjects([extension testMethodReturningParentObject], chat);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(contextBlockCalled);
}

- (void)testRegisterProtoPlugin_ShouldAddExtension_WhenProtoPluginRegistered {
    
    NSString *chatName = [@[@"chat-tester", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    client.proto(@"Chat", [CEDummyPlugin class]).store();
    __block BOOL contextBlockCalled = NO;
    
    CENChat *chat = client.Chat().name(chatName).create();
    chat.extension([CEDummyPlugin class], ^(CEDummyExtension *extension) {
        contextBlockCalled = YES;
        
        XCTAssertNotNil(extension);
        XCTAssertTrue([extension respondsToSelector:@selector(testMethodReturningParentObject)]);
        XCTAssertTrue(extension.constructWorks);
        XCTAssertEqualObjects([extension testMethodReturningParentObject], chat);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)));
    XCTAssertTrue(contextBlockCalled);
}

#pragma mark -


@end
