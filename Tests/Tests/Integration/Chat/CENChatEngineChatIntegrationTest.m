/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CEDummyPlugin.h"


#pragma mark Interface declaration

@interface CENChatEngineChatIntegrationTest: CENTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *testedChatName;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineChatIntegrationTest


#pragma mark - Setup / Tear down

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateVCRConfigurationFromDefaultConfiguration:configuration];
    
    YHVPostBodyFilterBlock postBodyFilter = configuration.postBodyFilter;
    configuration.postBodyFilter = ^NSData * (NSURLRequest *request, NSData *body) {
        NSString *bodyString = [[NSString alloc] initWithData:postBodyFilter(request, body) encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
        
        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    YHVResponseBodyFilterBlock responseBodyFilter = configuration.responseBodyFilter;
    configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        NSString *bodyString = [[NSString alloc] initWithData:responseBodyFilter(request, response, data) encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
        
        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    YHVPathFilterBlock pathFilter = configuration.pathFilter;
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        return [[pathFilter(request) componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
    };
}

- (void)setUp {
    
    [super setUp];
    
    self.testedChatName = YHVVCR.cassette.isNewCassette ? [@[@"chat-tester", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"] : @"chat-tester";
    
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    [self setupChatEngineForUser:@"serhii" withSynchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testEmit_ShouldProvidePublishTimetoken_WhenChatEmitEvent {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;
    
    CENChat *chat = client.Chat().name(self.testedChatName).create();
    chat.once(@"$.connected", ^{
        chat.emit(@"test").perform().once(@"$.emitted", ^(NSDictionary *payload) {
            callbackCalled = YES;
            
            XCTAssertNotNil(payload[CENEventData.timetoken]);
            dispatch_semaphore_signal(semaphore);
        });
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testJoin_ShouldBeNotifier_WhenUserJoinToChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;

    CENChat *chat = client.Chat().name(self.testedChatName).create();
    chat.on(@"$.online.join", ^(CENUser *user) {
        if ([user.uuid isEqualToString:client.me.uuid]) {
            callbackCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testHandleEvent_ShouldBeNotifier_WhenChatConnected {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;

    CENChat *chat = client.Chat().name(self.testedChatName).create();
    chat.once(@"$.connected", ^{
        callbackCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testHandleEvent_ShouldBeNotifier_WhenMessageSent {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;

    CENChat *chat = client.Chat().name(self.testedChatName).create();
    chat.once(@"something", ^(NSDictionary *payload) {
        callbackCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.timetoken]);
        XCTAssertNotNil(payload[CENEventData.data][@"text"]);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    chat.once(@"$.connected", ^{
        chat.emit(@"something").data(@{ @"text": @"'hello world" }).perform();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelayWithNestedSemaphores * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testRegisterPlugin_ShouldAddExtension_WhenPluginRegistered {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL contextBlockCalled = NO;

    CENChat *chat = client.Chat().name(self.testedChatName).create();
    
    chat.plugin([CEDummyPlugin class]).store();
    chat.extension([CEDummyPlugin class], ^(CEDummyExtension *extension) {
        contextBlockCalled = YES;
        
        XCTAssertNotNil(extension);
        XCTAssertTrue([extension respondsToSelector:@selector(testMethodReturningParentObject)]);
        XCTAssertTrue(extension.constructWorks);
        XCTAssertEqualObjects([extension testMethodReturningParentObject], chat);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(contextBlockCalled);
}

- (void)testRegisterProtoPlugin_ShouldAddExtension_WhenProtoPluginRegistered {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    client.proto(@"Chat", [CEDummyPlugin class]).store();
    __block BOOL contextBlockCalled = NO;
    
    CENChat *chat = client.Chat().name(self.testedChatName).create();
    
    client.once(@"$.created.chat", ^(CENChat *createdChat) {
        if (![createdChat.channel isEqualToString:chat.channel]) {
            return;
        }
        
        chat.extension([CEDummyPlugin class], ^(CEDummyExtension *extension) {
            contextBlockCalled = YES;
            
            XCTAssertNotNil(extension);
            XCTAssertTrue([extension respondsToSelector:@selector(testMethodReturningParentObject)]);
            XCTAssertTrue(extension.constructWorks);
            XCTAssertEqualObjects([extension testMethodReturningParentObject], chat);
            dispatch_semaphore_signal(semaphore);
        });
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(contextBlockCalled);
}

#pragma mark -


@end
