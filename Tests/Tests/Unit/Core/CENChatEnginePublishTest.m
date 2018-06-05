/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENEvent+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <PubNub/PNResult+Private.h>
#import "CENTestCase.h"


@interface CENChatEnginePublishTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, strong) NSString *localUserUUID;


#pragma mark - Misc

- (PNPublishStatus *)publishStatus;
- (PNErrorStatus *)publishErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEnginePublishTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.localUserUUID = @"tester";
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:self.localUserUUID state:@{} chatEngine:self.defaultClient]);
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: publishToChat

- (void)testPublishToChat_ShouldCreateEventEmittingInstance {
    
    id eventClassMock = [self mockForClass:[CENEvent class]];
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedEvent = @"test-event";
    
    OCMExpect([eventClassMock eventWithName:expectedEvent chat:expectedChat chatEngine:self.defaultClient]);
    OCMExpect([self.defaultClient storeTemporaryObject:[OCMArg any]]);
    
    [self.defaultClient publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    
    OCMVerify(eventClassMock);
    OCMVerify((id)self.defaultClient);
    
    [eventClassMock stopMocking];
}

- (void)testPublishToChat_ShouldCreateMessagePayload {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedSenderUUID = self.defaultClient.me.uuid;
    NSString *expectedEvent = @"test-event";
    NSNumber *expectedTimetoken = @2010;
    __block BOOL callbackCalled = NO;
    
    NSString *expectedUUIDString = @"01234567-8910-1112-1314-151617181920";
    id uuidClassMock = OCMClassMock([NSUUID class]);
    OCMStub([uuidClassMock UUID]).andReturn([[NSUUID alloc] initWithUUIDString:expectedUUIDString]);
    
    OCMStub([self.defaultClient publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:6];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
                handlerBlock(expectedTimetoken);
            });
        });
    
    [self.defaultClient publishToChat:expectedChat eventWithName:expectedEvent data:expectedData].once(@"$.emitted", ^(NSDictionary *payload) {
        callbackCalled = YES;
        
        XCTAssertEqualObjects(payload[CENEventData.data], expectedData);
        XCTAssertEqualObjects(payload[CENEventData.eventID], expectedUUIDString);
        XCTAssertEqualObjects(payload[CENEventData.event], expectedEvent);
        XCTAssertEqualObjects(payload[CENEventData.sender], expectedSenderUUID);
        XCTAssertEqualObjects(payload[CENEventData.timetoken], expectedTimetoken);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testPublishToChat_ShouldCreateMessagePayloadWithEmptyData_WhenNilPassedAsData {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test-event";
    NSDictionary *dataForPublish = nil;
    __block BOOL callbackCalled = NO;
    NSDictionary *expectedData = @{};
    
    OCMStub([self.defaultClient publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:6];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
                handlerBlock(@2010);
            });
        });
    
    [self.defaultClient publishToChat:expectedChat eventWithName:expectedEvent data:dataForPublish].once(@"$.emitted", ^(NSDictionary *payload) {
        callbackCalled = YES;
        
        XCTAssertEqualObjects(payload[CENEventData.data], expectedData);
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)));
    XCTAssertTrue(callbackCalled);
}

- (void)testPublishToChat_ShouldThrow_WhenNonNSDictionaryPayloadPassed {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    NSString *expectedEvent = @"test-event";
    NSDictionary *expectedData = (id)@2010;
    
    XCTAssertThrows([self.defaultClient publishToChat:expectedChat eventWithName:expectedEvent data:expectedData]);
}


#pragma mark - Tests :: publishStorableEvent

- (void)testPublishStorableEvent_ShouldRequestPayloadPublish {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENEvent *event = nil;
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient publishStorable:YES data:[OCMArg any] toChannel:expectedChat.channel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNErrorStatus *) = nil;
            
            [invocation getArgument:&handlerBlock atIndex:5];
            
            handlerBlock([self publishStatus]);
        });
    
    [self.defaultClient publishStorable:YES event:event toChannel:expectedChat.channel withData:expectedData completion:^(NSNumber *timetoken) {
        handlerCalled = YES;
        
        XCTAssertNotNil(timetoken);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}

- (void)testPublishStorable_ShouldThrowEmitError_WhenPublishUnsuccessful {
    
    CENChat *expectedChat = self.defaultClient.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedEvent = @"test-event";
    __block BOOL handlerCalled = NO;
    
    OCMExpect([self.defaultClient publishStorable:YES data:[OCMArg any] toChannel:expectedChat.channel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation4) {
            void(^handlerBlock)(PNErrorStatus *) = nil;
            
            [invocation4 getArgument:&handlerBlock atIndex:5];
            
            handlerBlock([self publishErrorStatus]);
        });
    
    OCMExpect([self.defaultClient throwError:[OCMArg any] forScope:@"emitter" from:[OCMArg any] propagateFlow:CEExceptionPropagationFlow.direct])
        .andDo(^(NSInvocation *invocation5) {
            handlerCalled = YES;
            
            dispatch_semaphore_signal(semaphore);
        });
    
    [self.defaultClient publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Misc

- (PNPublishStatus *)publishStatus {
    
    return [PNPublishStatus objectForOperation:PNPublishOperation completedWithTask:nil
                                 processedData:@{ @"information": @"Sent", @"status": @200, @"timetoken": @12345 }
                             processingError:nil];
}

- (PNErrorStatus *)publishErrorStatus {
    
    return [PNErrorStatus objectForOperation:PNPublishOperation completedWithTask:nil
                               processedData:@{ @"information": @"Test error", @"status": @404 }
                             processingError:nil];
}

#pragma mark -


@end
