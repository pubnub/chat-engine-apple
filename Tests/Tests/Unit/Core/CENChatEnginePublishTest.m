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

@property (nonatomic, strong) NSString *localUserUUID;


#pragma mark - Misc

- (PNPublishStatus *)publishStatus;
- (PNErrorStatus *)publishErrorStatus;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEnginePublishTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    self.usesMockedObjects = YES;
    self.localUserUUID = @"tester";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
    if ([self.name rangeOfString:@"WhenMeIsMissing"].location != NSNotFound) {
        return;
    }
    
    OCMStub([self.client connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
        handleBlock(nil);
    });
    
    OCMStub([self.client me]).andReturn([CENMe userWithUUID:self.localUserUUID state:@{} chatEngine:self.client]);
}


#pragma mark - Tests :: publishToChat

- (void)testPublishToChat_ShouldCreateEventEmittingInstance {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedEvent = @"test-event";
    
    id eventMock = [self mockForObject:[CENEvent class]];
    OCMExpect([eventMock eventWithName:expectedEvent chat:expectedChat chatEngine:self.client]);
    OCMExpect([self.client storeTemporaryObject:[OCMArg any]]);
    
    [self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    
    OCMVerify(eventMock);
    OCMVerify((id)self.client);
}

- (void)testPublishToChat_ShouldCreateEventEmittingInstance_WhenNilDataPassed {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = nil;
    NSString *expectedEvent = @"test-event";
    
    id eventMock = [self mockForObject:[CENEvent class]];
    OCMExpect([eventMock eventWithName:expectedEvent chat:expectedChat chatEngine:self.client]);
    OCMExpect([self.client storeTemporaryObject:[OCMArg any]]);
    
    [self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    
    OCMVerify(eventMock);
    OCMVerify((id)self.client);
}

- (void)testPublishToChat_ShouldNotCreateEventEmittingInstance_WhenMeIsMissing {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedEvent = @"test-event";
    
    
    id eventMock = [self mockForObject:[CENEvent class]];
    OCMExpect([[eventMock reject] eventWithName:expectedEvent chat:expectedChat chatEngine:self.client]);
    OCMExpect([[(id)self.client reject] storeTemporaryObject:[OCMArg any]]);
    
    [self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    
    OCMVerify(eventMock);
    OCMVerify((id)self.client);
}

- (void)testPublishToChat_ShouldCreateMessagePayload {
    
    NSString *expectedUUIDString = @"01234567-8910-1112-1314-151617181920";
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedSenderUUID = self.client.me.uuid;
    NSString *expectedEvent = @"test-event";
    NSNumber *expectedTimetoken = @2010;
    
    
    id uuidMock = [self mockForObject:[NSUUID class]];
    OCMStub([uuidMock UUID]).andReturn([[NSUUID alloc] initWithUUIDString:expectedUUIDString]);
    
    OCMStub([self.client publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any]
                              completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = [self objectForInvocation:invocation argumentAtIndex:5];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
                handlerBlock(expectedTimetoken);
            });
        });
    
    CENEvent *event = [self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    [self object:event shouldHandleEvent:@"$.emitted" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertEqualObjects(payload[CENEventData.data], expectedData);
            XCTAssertEqualObjects(payload[CENEventData.eventID], expectedUUIDString);
            XCTAssertEqualObjects(payload[CENEventData.event], expectedEvent);
            XCTAssertEqualObjects(payload[CENEventData.sender], expectedSenderUUID);
            XCTAssertEqualObjects(payload[CENEventData.timetoken], expectedTimetoken);
            handler();
        };
    } afterBlock:^{ }];
}

- (void)testPublishToChat_ShouldCreateMessagePayloadWithEmptyData_WhenNilPassedAsData {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSString *expectedEvent = @"test-event";
    NSDictionary *dataForPublish = nil;
    NSDictionary *expectedData = @{};
    
    
    OCMStub([self.client publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any]
                              completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = [self objectForInvocation:invocation argumentAtIndex:5];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
                handlerBlock(@2010);
            });
        });
    
    CENEvent *event = [self.client publishToChat:expectedChat eventWithName:expectedEvent data:dataForPublish];
    [self object:event shouldHandleEvent:@"$.emitted" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertEqualObjects(payload[CENEventData.data], expectedData);
            handler();
        };
    } afterBlock:^{ }];
}

- (void)testPublishToChat_ShouldThrow_WhenNonNSDictionaryPayloadPassed {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSString *expectedEvent = @"test-event";
    NSDictionary *expectedData = (id)@2010;
    
    XCTAssertThrows([self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData]);
}


#pragma mark - Tests :: publishStorableEvent

- (void)testPublishStorableEvent_ShouldRequestPayloadPublish {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedEvent = @"test-event";
    CENEvent *event = nil;
    
    
    OCMStub([self.client publishStorable:YES data:[OCMArg any] toChannel:expectedChat.channel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNErrorStatus *) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock([self publishStatus]);
        });

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client publishStorable:YES event:event toChannel:expectedChat.channel withData:expectedData
                          completion:^(NSNumber *timetoken) {
            XCTAssertNotNil(timetoken);
            handler();
        }];
    } afterBlock:^{
        [self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    }];
}

- (void)testPublishStorable_ShouldThrow_WhenPublishUnsuccessful {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedEvent = @"test-event";
    
    
    OCMStub([self.client publishStorable:YES data:[OCMArg any] toChannel:expectedChat.channel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNErrorStatus *) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock([self publishErrorStatus]);
        });
    
    OCMStub([self.client runMiddlewaresAtLocation:[OCMArg any] forEvent:[OCMArg any] object:[OCMArg any] withPayload:[OCMArg any]
                                       completion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handlerBlock)(BOOL, NSMutableDictionary *) = [self objectForInvocation:invocation argumentAtIndex:5];
        handlerBlock(NO, [NSMutableDictionary new]);
    });
    
    XCTAssertThrowsSpecificNamed([self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData],
                                 NSException, kCENPNErrorDomain);
}

- (void)testPublishStorable_ShouldEmitError_WhenPublishUnsuccessful {
    
    CENChat *expectedChat = self.client.Chat().autoConnect(NO).create();
    NSDictionary *expectedData = @{ @"test": @[@"data", @"payload"] };
    NSString *expectedEvent = @"test-event";
    
    
    OCMStub([self.client publishStorable:YES data:[OCMArg any] toChannel:expectedChat.channel withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(PNErrorStatus *) = [self objectForInvocation:invocation argumentAtIndex:4];
            handlerBlock([self publishErrorStatus]);
        });
    
    id recorded = OCMExpect([self.client throwError:[OCMArg any] forScope:@"emitter" from:[OCMArg any]
                                      propagateFlow:CEExceptionPropagationFlow.direct]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client publishToChat:expectedChat eventWithName:expectedEvent data:expectedData];
    }];
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
