/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <YAHTTPVCR/YHVCassette+Private.h>


#pragma mark Interface declaration

@interface CENChatEngineRemoteChatsListIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *synchronizedChatName;


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

- (void)setUp {
    
    [super setUp];
    
    self.synchronizedChatName = YHVVCR.cassette.isNewCassette ? [@[@"sync-chat", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"] : @"sync-chat";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSString *global = YHVVCR.cassette.isNewCassette ? [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"] : @"test";
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:YES meta:YES state:@{ @"works": @YES }];
    
    if ([self.name rangeOfString:@"testSession_ShouldBePopulated_WhenGroupRestoreCompleted"].location == NSNotFound) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayBetweenActions * NSEC_PER_SEC)));
        
        [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:YES meta:YES state:@{ @"works": @NO }];
    }
}

- (void)testSession_ShouldBeNotifiedOfNewChats_WhenCreatedFromSecondInstance {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client1.me.session.once(@"$.chat.join", ^(CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertTrue([chat.channel rangeOfString:self.synchronizedChatName].location != NSNotFound);
        if (!YHVVCR.cassette.isNewCassette) {
            dispatch_semaphore_signal(semaphore);
        }
    });

    client2.Chat().name(self.synchronizedChatName).create();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
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
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSession_ShouldGetDeleteEvent_WhenUserLeaveChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client1.me.session.once(@"$.chat.leave", ^(CENChat *chat) {
        handlerCalled = YES;
        
        XCTAssertTrue([chat.channel rangeOfString:self.synchronizedChatName].location != NSNotFound);
        
        if (!YHVVCR.cassette.isNewCassette) {
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    CENChat *chat = client2.Chat().name(self.synchronizedChatName).create();
    chat.once(@"$.connected", ^{
        chat.leave();
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
