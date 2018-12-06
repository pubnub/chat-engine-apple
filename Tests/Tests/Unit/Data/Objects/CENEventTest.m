/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENEvent+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENEventTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENEventTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    
    XCTAssertNotNil(event);
}


#pragma mark - Tests :: publish

- (void)testPublish_ShouldPublishPayload {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    NSDictionary *expectedData = @{ @"test": @"data", CENEventData.event: @"test-event" };
    NSDictionary *dataForPublish = @{ @"test": @"data" };
    
    
    id recorded = OCMExpect([self.client publishStorable:YES event:event toChannel:event.channel
                                                withData:expectedData completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [event publish:[dataForPublish mutableCopy]];
    }];
}

- (void)testPublish_ShouldAddChatAfterPublish {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    NSMutableDictionary *dataForPublish = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"data" }];
    
    
    OCMStub([self.client publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = [self objectForInvocation:invocation argumentAtIndex:5];
            handlerBlock(@1234567890);
        });
    
    [self object:event shouldHandleEvent:@"$.emitted" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSMutableDictionary *publishedPayload = emittedEvent.data;
            
            XCTAssertNotNil(publishedPayload[CENEventData.chat]);
            XCTAssertEqualObjects(publishedPayload[CENEventData.chat], chat);
            handler();
        };
    } afterBlock:^{
        [event publish:dataForPublish];
    }];
}

- (void)testPublish_ShouldAddEventPublishTimetoken {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    NSMutableDictionary *dataForPublish = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"data" }];
    NSNumber *expectedTimetoken = @1234567890;
    
    
    OCMStub([self.client publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = [self objectForInvocation:invocation argumentAtIndex:5];
            handlerBlock(expectedTimetoken);
        });
    
    [self object:event shouldHandleEvent:@"$.emitted" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSMutableDictionary *publishedPayload = emittedEvent.data;
            
            XCTAssertNotNil(publishedPayload[CENEventData.timetoken]);
            XCTAssertEqual([(NSNumber *)publishedPayload[CENEventData.timetoken] compare:expectedTimetoken], NSOrderedSame);
            handler();
        };
    } afterBlock:^{
        [event publish:dataForPublish];
    }];
}

- (void)testPublish_ShouldPublishWithOutStoringInHistory_WhenSystemEventPublished {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"$.system.something" chat:chat chatEngine:self.client];
    NSMutableDictionary *dataForPublish = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"data" }];
    
    
    id recorded = OCMExpect([self.client publishStorable:NO event:event toChannel:event.channel
                                                withData:[OCMArg any] completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [event publish:dataForPublish];
    }];
}

- (void)testPublish_ShouldEmitEvent_WhenPublishCompleted {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    NSMutableDictionary *dataForPublish = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"data" }];
    NSNumber *expectedTimetoken = @1234567890;
    
    
    OCMStub([self.client publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSNumber *) = [self objectForInvocation:invocation argumentAtIndex:5];
            handlerBlock(expectedTimetoken);
        });
    
    [self object:event shouldHandleEvent:@"$.emitted" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [event publish:dataForPublish];
    }];
}


#pragma mark - Tests :: objectType

- (void)testObjectType_ShouldReturnEventType {
    
    XCTAssertEqualObjects([[CENEvent class] objectType], CENObjectType.event);
}


#pragma mark - Tests :: channel

- (void)testChannel_ShouldEqualToChannelOfChatPassedToConstructor {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    
    
    XCTAssertEqualObjects(event.channel, chat.channel);
}


#pragma mark - Tests :: event

- (void)testEvent_ShouldEqualToEventPassedToConstructor {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    
    
    XCTAssertEqualObjects(event.event, @"test-event");
}


#pragma mark - Tests :: chat

- (void)testChat_ShouldEqualToChatPassedToConstructor {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    
    
    XCTAssertEqual(event.chat, chat);
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvideInstanceDescription {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEvent *event = [CENEvent eventWithName:@"test-event" chat:chat chatEngine:self.client];
    
    
    NSString *description = [event description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
}

#pragma mark -


@end
