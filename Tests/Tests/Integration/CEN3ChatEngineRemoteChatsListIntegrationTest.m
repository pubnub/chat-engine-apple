/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <YAHTTPVCR/YHVCassette+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENDefines.h>
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CEN3ChatEngineRemoteChatsListIntegrationTest : CENTestCase


#pragma mark - Informationog


@property (nonatomic, assign) NSUInteger shouldConnectCallbackCallCount;
@property (nonatomic, copy) NSString *synchronizedChatName;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CEN3ChatEngineRemoteChatsListIntegrationTest


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
    
    YHVQueryParametersFilterBlock queryFilter = configuration.queryParametersFilter;
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        if (queryFilter) {
            queryFilter(request, queryParameters);
        }
        
        for (NSString *parameter in [queryParameters.allKeys copy]) {
            __block id value = queryParameters[parameter];
            
            if ([value isKindOfClass:[NSString class]] &&
                [(NSString *)value rangeOfString:@"sync-chat-"].location != NSNotFound) {
                
                value = [[(NSString *)value componentsSeparatedByString:self.synchronizedChatName] componentsJoinedByString:@"sync-chat"];
            }
            
            queryParameters[parameter] = value;
        }
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

- (BOOL)shouldWaitOwnOnlineStatusForTestCaseWithName:(NSString *)name {
    
    return NO;
}

- (void)setUp {

    [super setUp];

    NSString *synchronizedChatName = [@[@"sync-chat", [[NSUUID UUID].UUIDString substringToIndex:13]] componentsJoinedByString:@"-"];
    self.synchronizedChatName = YHVVCR.cassette.isNewCassette ? synchronizedChatName : @"sync-chat";

    [self setupChatEngineForUser:@"ian"];

    if ([self.name rangeOfString:@"testSession_ShouldBePopulated_WhenGroupRestoreCompleted"].location == NSNotFound) {
        [self setupChatEngineForUser:@"ian"];
    }
}

- (void)testSession_ShouldBeNotifiedOfNewChats_WhenCreatedFromSecondInstance {

    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    CENSession *session = client1.me.session;
    __block CENChat *chat = nil;

    [self object:session shouldHandleEvent:@"$.chat.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            chat = emittedEvent.data;

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
    
    chat.connect();
    [self waitForOwnOnlineOnChat:chat];

    [self setupChatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    CENWeakify(client2);
    
    [self object:client2 shouldHandleEvent:@"$.group.restored" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(client2);
        
        return ^(CENEmittedEvent *emittedEvent) {
            CENSession *session = client2.me.session;
            
            // Two chats are global and newly created one.
            XCTAssertEqual(session.chats.count, 1);
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
    
    CENChat *chat = client2.Chat().name(self.synchronizedChatName).create();
    [self waitForOwnOnlineOnChat:chat];
    
    [self object:session shouldHandleEvent:@"$.chat.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        chat.leave();
    }];
    
    [self waitTask:@"waitABitAfterDisconnection" completionFor:2.5f];
    
    [self object:client1 shouldHandleEvent:@"$.disconnected" afterBlock:^{
        client1.disconnect();
    }];
    
    [self object:session shouldHandleEvent:@"$.group.restored" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(session.chats.count, 0);
            handler();
        };
    } afterBlock:^{
        client1.reconnect();
    }];
}

#pragma mark -


@end
