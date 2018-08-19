/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPPlugablePropertyStorage+Private.h>
#import <CENChatEngine/CENPushNotificationsExtension.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENEvent+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENPushNotificationsExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, strong) CENEvent *event;
@property (nonatomic, nullable, weak) CENEvent *eventMock;

@property (nonatomic, nullable, strong) CENPushNotificationsExtension *extension;
@property (nonatomic, nullable, weak) CENPushNotificationsExtension *extensionMock;
@property (nonatomic, nullable, strong) NSMutableDictionary *extensionStorage;


#pragma mark -


@end


@implementation CENPushNotificationsExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.extensionStorage = [NSMutableDictionary new];
    self.extension = [CENPushNotificationsExtension extensionWithIdentifier:@"test" configuration:nil];
    self.extension.storage = self.extensionStorage;
    self.extensionMock = [self partialMockForObject:self.extension];
    
    CENConfiguration *clientConfiguration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = [self chatEngineWithConfiguration:clientConfiguration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);
    
    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.clientMock createGlobalChat];
    
    self.event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    self.eventMock = [self partialMockForObject:self.event];
    
    OCMStub([self.clientMock publishToChat:[OCMArg any] eventWithName:[OCMArg any] data:[OCMArg any]]).andReturn(self.event);
}


#pragma mark - Tests :: markNotificationAsSeen

- (void)testMarkNotificationAsSeen_ShouldCallCompletionBlock_WhenUpdateEmitted {
    
    NSDictionary *userInfo = @{ @"cepayload": @{ CENEventData.event: @"message", CENEventData.eventID: [NSUUID UUID].UUIDString } };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:userInfo];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markNotificationAsSeen:notification withCompletion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNil(error);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.eventMock emitEventLocally:@"$.emitted" withParameters:@[@{ @"event": @"published" }]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testMarkNotificationAsSeen_ShouldCallCompletionBlock_WhenEventIsMissing {
    
    NSDictionary *userInfo = @{ @"cepayload": @{ CENEventData.eventID: [NSUUID UUID].UUIDString } };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:userInfo];
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markNotificationAsSeen:notification withCompletion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNil(error);
    }];
    
    XCTAssertTrue(handlerCalled);
}

- (void)testMarkNotificationAsSeen_ShouldNotCallCompletionBlock_WhenCalledForOwnEvent {
    
    NSDictionary *userInfo = @{ @"cepayload": @{ CENEventData.event: @"$notifications.seen", CENEventData.eventID: [NSUUID UUID].UUIDString } };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:userInfo];
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markNotificationAsSeen:notification withCompletion:^(NSError *error) {
        handlerCalled = YES;
    }];
    
    XCTAssertFalse(handlerCalled);
}

- (void)testMarkNotificationAsSeen_ShouldNotCallCompletionBlock_WhenEventNameIsEmpty {
    
    NSDictionary *userInfo = @{ @"cepayload": @{ CENEventData.event: @"", CENEventData.eventID: [NSUUID UUID].UUIDString } };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:userInfo];
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markNotificationAsSeen:notification withCompletion:^(NSError *error) {
        handlerCalled = YES;
    }];
    
    XCTAssertFalse(handlerCalled);
}

- (void)testMarkNotificationAsSeen_ShouldCallCompletionBlockWithError_WhenUpdateEmitErrored {
    
    NSDictionary *userInfo = @{ @"cepayload": @{ CENEventData.event: @"message", CENEventData.eventID: [NSUUID UUID].UUIDString } };
    NSNotification *notification = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:userInfo];
    NSError *expected = [NSError errorWithDomain:NSURLErrorDomain code:1000 userInfo:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markNotificationAsSeen:notification withCompletion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.eventMock emitEventLocally:@"$.error.emitter" withParameters:@[expected]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: markAllNotificationAsSeenWithCompletion

- (void)testMarkAllNotificationAsSeenWithCompletion_ShouldCallCompletionBlock_WhenUpdateEmitted {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markAllNotificationAsSeenWithCompletion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNil(error);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.eventMock emitEventLocally:@"$.emitted" withParameters:@[@{ @"event": @"published" }]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testMarkAllNotificationAsSeenWithCompletion_ShouldCallCompletionBlockWithError_WhenUpdateEmitErrored {
    
    NSError *expected = [NSError errorWithDomain:NSURLErrorDomain code:1000 userInfo:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.extension.object = self.client.me;
    __block BOOL handlerCalled = NO;
    
    [self.extension markAllNotificationAsSeenWithCompletion:^(NSError *error) {
        handlerCalled = YES;
        
        XCTAssertNotNil(error);
        dispatch_semaphore_signal(semaphore);
    }];
    
    [self.eventMock emitEventLocally:@"$.error.emitter" withParameters:@[expected]];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}



#pragma mark - Tests :: Destructor

- (void)testOnCreate_ShouldSubscribeFromEvents {
    
    NSString *expectedEvent = @"$.created.chat";
    self.extension.object = self.client.me;
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
}

- (void)testOnDestruct_ShouldUnsubscribeFromEvents {
    
    NSString *expectedEvent = @"$.created.chat";
    self.extension.object = self.client.me;
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onDestruct];
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
}

#pragma mark -



#pragma mark -


@end
