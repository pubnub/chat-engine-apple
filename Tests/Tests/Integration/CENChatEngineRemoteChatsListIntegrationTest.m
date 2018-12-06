/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <YAHTTPVCR/YHVCassette+Private.h>


#pragma mark Interface declaration

@interface CENChatEngineRemoteChatsListIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, assign) NSUInteger shouldConnectCallbackCallCount;
@property (nonatomic, copy) NSString *synchronizedChatName;
@property (nonatomic, strong) NSString *globalChannel;
@property (nonatomic, copy) NSString *namespace;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineRemoteChatsListIntegrationTest


#pragma mark - Setup / Tear down

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {

    [super updateVCRConfigurationFromDefaultConfiguration:configuration];

    YHVPostBodyFilterBlock postBodyFilter = configuration.postBodyFilter;
    configuration.postBodyFilter = ^NSData * (NSURLRequest *request, NSData *body) {
        NSString *bodyString = [[NSString alloc] initWithData:postBodyFilter(request, body) encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.synchronizedChatName] componentsJoinedByString:@"sync-chat"];

        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };

    YHVResponseBodyFilterBlock responseBodyFilter = configuration.responseBodyFilter;
    configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        NSString *bodyString = [[NSString alloc] initWithData:responseBodyFilter(request, response, data) encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.synchronizedChatName] componentsJoinedByString:@"sync-chat"];

        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };

    YHVPathFilterBlock pathFilter = configuration.pathFilter;
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        return [[pathFilter(request) componentsSeparatedByString:self.synchronizedChatName] componentsJoinedByString:@"sync-chat"];
    };
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (BOOL)shouldSynchronizeSessionForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    BOOL shouldConnect = YES;
    
    if ([name rangeOfString:@"testSession_ShouldBePopulated_WhenGroupRestoreCompleted"].location != NSNotFound) {
        self.shouldConnectCallbackCallCount++;
        shouldConnect = self.shouldConnectCallbackCallCount < 2;
    }
    
    return shouldConnect;
}

- (BOOL)shouldWaitOwnPresenceEventsTestCaseWithName:(NSString *)name {
    
    return NO;
}

- (BOOL)shouldWaitOwnStateChangeEventTestCaseWithName:(NSString *)name {
    
    return NO;
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

    NSString *synchronizedChatName = [@[@"sync-chat", [[NSUUID UUID].UUIDString substringToIndex:13]] componentsJoinedByString:@"-"];
    self.synchronizedChatName = YHVVCR.cassette.isNewCassette ?synchronizedChatName : @"sync-chat";

    [self setupChatEngineForUser:@"ian"];

    if ([self.name rangeOfString:@"testSession_ShouldBePopulated_WhenGroupRestoreCompleted"].location == NSNotFound) {
        [self setupChatEngineForUser:@"ian"];
    }
}

- (void)testSession_ShouldBeNotifiedOfNewChats_WhenCreatedFromSecondInstance {

    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    CENSession *session = client1.me.session;

    [self object:session shouldHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.data;

            XCTAssertTrue([chat.channel rangeOfString:self.synchronizedChatName].location != NSNotFound);
            handler();
        };
    } afterBlock:^{
        client2.Chat().name(self.synchronizedChatName).create();
    }];
}

- (void)testSession_ShouldBePopulated_WhenGroupRestoreCompleted {

    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChat *chat = client1.Chat().name(self.synchronizedChatName).autoConnect(NO).create();

    [self object:chat shouldHandleEvent:@"$.connected" afterBlock:^{
        chat.connect();
    }];

    [self setupChatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];

    [self object:client2 shouldHandleEvent:@"$.group.restored" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENSession *session = client2.me.session;
            
            // Two chats are global and newly created one.
            XCTAssertEqual(session.chats.count, 2);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"ian" usingClient:client2];
    }];
}

- (void)testSession_ShouldGetDeleteEvent_WhenUserLeaveChat {

    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    CENSession *session = client1.me.session;
    __block CENChat *chat = nil;

    [self object:session shouldHandleEvent:@"$.chat.join" afterBlock:^{
        chat = client2.Chat().name(self.synchronizedChatName).create();
    }];
    
    [self object:session shouldHandleEvent:@"$.chat.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENChat *chat = emittedEvent.data;
            
            XCTAssertTrue([chat.channel rangeOfString:self.synchronizedChatName].location != NSNotFound);
            handler();
        };
    } afterBlock:^{
        chat.leave();
    }];
}

- (void)testSession_ShouldGetDeleteEventAndNotRestored_WhenUserLeaveChat {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    CENSession *session = client1.me.session;
    
    [self object:session shouldHandleEvent:@"$.chat.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        CENChat *chat = client2.Chat().name(self.synchronizedChatName).create();
        chat.once(@"$.connected", ^(CENEmittedEvent *emittedEvent) {
            chat.leave();
        });
    }];
    
    [self object:client1 shouldHandleEvent:@"$.disconnected" afterBlock:^{
        client1.disconnect();
    }];
    
    
    [self object:session shouldHandleEvent:@"$.group.restored" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(session.chats.count, 1);
            handler();
        };
    } afterBlock:^{
        client1.reconnect();
    }];
}

#pragma mark -


@end
