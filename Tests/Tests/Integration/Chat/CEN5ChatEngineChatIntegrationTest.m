/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CEN5ChatEngineChatIntegrationTest: CENTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *testedChatName;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CEN5ChatEngineChatIntegrationTest


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
        NSString *bodyString = [[NSString alloc] initWithData:responseBodyFilter(request, response, data)
                                                     encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
        
        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    YHVPathFilterBlock pathFilter = configuration.pathFilter;
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        return [[pathFilter(request) componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
    };
    
    YHVQueryParametersFilterBlock queryFilter = configuration.queryParametersFilter;
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        if (queryFilter) {
            queryFilter(request, queryParameters);
        }
        
        for (NSString *parameter in [queryParameters.allKeys copy]) {
            __block id value = queryParameters[parameter];
            
            if ([value isKindOfClass:[NSString class]] &&
                [(NSString *)value rangeOfString:@"chat-tester-"].location != NSNotFound) {
                
                value = [[(NSString *)value componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
            }
            
            queryParameters[parameter] = value;
        }
    };
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {
    
    return @{ @"works": @YES };
}

- (void)setUp {
    
    [super setUp];


    NSString *testedChatName = [@[@"chat-tester", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    self.testedChatName = YHVVCR.cassette.isNewCassette ? testedChatName : @"chat-tester";
    
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    [self setupChatEngineForUser:@"serhii"];
}

- (void)testEmit_ShouldProvidePublishTimetoken_WhenChatEmitEvent {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block BOOL callbackCalled = NO;
    __block CENChat *chat = nil;

    
    [self object:client shouldHandleEvent:@"$.connected" afterBlock:^{
        chat = client.Chat().name(self.testedChatName).create();
    }];

    chat.emit(@"test").perform().once(@"$.emitted", ^(CENEmittedEvent *emittedEvent) {
        NSDictionary *payload = emittedEvent.data;
        callbackCalled = YES;
        
        XCTAssertNotNil(payload[CENEventData.timetoken]);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testHandleEvent_ShoulBeNotified_WhenLocalUserBecameOnline {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    CENChat *chat = client.Chat().name(self.testedChatName).autoConnect(NO).create();
    
    
    [self object:chat shouldHandleEvent:@"$.online.*" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            XCTAssertEqualObjects(user.uuid, client.me.uuid);
            handler();
        };
    } afterBlock:^{
        chat.connect();
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    __block CENChat *chat = nil;

    
    [self object:client shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *connectedChat = emittedEvent.emitter;
            
            XCTAssertEqualObjects(connectedChat.channel, chat.channel);
            handler();
        };
    } afterBlock:^{
        chat = client.Chat().name(self.testedChatName).create();
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenMessageSent {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    CENChat *chat = client.Chat().name(self.testedChatName).autoConnect(NO).create();

    
    chat.connect();
    [self waitForOwnOnlineOnChat:chat];
    
    [self object:chat shouldHandleEvent:@"something" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.timetoken]);
            XCTAssertNotNil(payload[CENEventData.data][@"text"]);
            handler();
        };
    } afterBlock:^{
        chat.emit(@"something").data(@{ @"text": @"'hello world" }).perform();
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenMessageSentToDirect {
    
    [self setupChatEngineForUser:@"ian"];
    CENChatEngine *client1 = [self chatEngineForUser:@"serhii"];
    CENChatEngine *client2 = [self chatEngineForUser:@"ian"];
    
    
    [self object:client1.me.direct shouldHandleEvent:@"anything" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        CENUser *user = client2.User(client1.me.uuid).create();
        user.direct.emit(@"anything").data(@{ @"test": @YES }).perform();
    }];
}

- (void)testHandleEvent_ShouldBeNotified_WhenMessageSentToFeed {
    
    [self setupChatEngineForUser:@"ian"];
    CENChatEngine *client1 = [self chatEngineForUser:@"serhii"];
    CENChatEngine *client2 = [self chatEngineForUser:@"ian"];
    CENUser *user = client2.User(client1.me.uuid).create();
    
    
    user.feed.connect();
    [self waitForOwnOnlineOnChat:user.feed];
    
    [self object:user.feed shouldHandleEvent:@"anything" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.me.feed.emit(@"anything").data(@{ @"test": @YES }).perform();
    }];
}

- (void)testRegisterPlugin_ShouldAddExtension_WhenPluginRegistered {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    CENChat *chat = client.Chat().name(self.testedChatName).autoConnect(NO).create();
    __block BOOL contextBlockCalled = NO;

    
    chat.plugin([CEDummyPlugin class]).store();
    CEDummyExtension *extension = chat.extension([CEDummyPlugin class]);
    contextBlockCalled = YES;
    
    XCTAssertNotNil(extension);
    XCTAssertTrue([extension respondsToSelector:@selector(testMethodReturningParentObject)]);
    XCTAssertTrue(extension.constructWorks);
    XCTAssertEqualObjects([extension testMethodReturningParentObject], chat);
    dispatch_semaphore_signal(semaphore);
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(contextBlockCalled);
}

- (void)testRegisterProtoPlugin_ShouldAddExtension_WhenProtoPluginRegistered {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    client.proto(@"Chat", [CEDummyPlugin class]).store();
    __block BOOL contextBlockCalled = NO;
    
    
    CENChat *chat = client.Chat().name(self.testedChatName).autoConnect(NO).create();
    
    client.once(@"$.created.chat", ^(CENEmittedEvent *emittedEvent) {
        CENChat *createdChat = emittedEvent.emitter;
        
        if (![createdChat.channel isEqualToString:chat.channel]) {
            return;
        }
        
        CEDummyExtension *extension = chat.extension([CEDummyPlugin class]);
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

#pragma mark -


@end
