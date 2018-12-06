/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUnreadMessagesExtension.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENUnreadMessagesPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENEventEmitter.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUnreadMessagesExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENUnreadMessagesExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


@implementation CENUnreadMessagesExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
    self.chat = [self publicChatWithChatEngine:self.client];
    
    [self stubUserAuthorization];
    
    NSDictionary *configuration = @{ CENUnreadMessagesConfiguration.events: @[@"$unread-test", @"$read-test"] };
    self.extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test" configuration:configuration];
    self.extension.object = self.chat;
}


#pragma mark - Tests :: Constructor / Destructor

- (void)testOnCreate_ShouldSubscribeOnEvents {
    
    NSArray<NSString *> *expectedEvents = self.extension.configuration[CENUnreadMessagesConfiguration.events];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test"
                                                                                  configuration:self.extension.configuration];
    extension.object = chat;
    
    [extension onCreate];
    
    XCTAssertTrue([chat.eventNames containsObject:expectedEvents.firstObject]);
    XCTAssertTrue([chat.eventNames containsObject:expectedEvents.lastObject]);
}

- (void)testOnDestruct_ShouldUnsubscribeFromEvents {
    
    NSArray<NSString *> *expectedEvents = self.extension.configuration[CENUnreadMessagesConfiguration.events];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test"
                                                                                  configuration:self.extension.configuration];
    extension.object = chat;
    
    [extension onCreate];
    
    XCTAssertTrue([chat.eventNames containsObject:expectedEvents.firstObject]);
    XCTAssertTrue([chat.eventNames containsObject:expectedEvents.lastObject]);
    
    [extension onDestruct];
    
    XCTAssertFalse([chat.eventNames containsObject:expectedEvents.firstObject]);
    XCTAssertFalse([chat.eventNames containsObject:expectedEvents.lastObject]);
}


#pragma mark - Tests :: Active / Inactive

- (void)testActive_ShouldResetUnreadCount_WhenReceivedEvents {
    
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    
    
    [self.extension onCreate];
    
    [self object:self.chat shouldHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *event) {
            NSDictionary *eventPayload = event.data;
            
            XCTAssertEqualObjects(eventPayload[CENUnreadMessagesEvent.count], @1);
            XCTAssertEqual(self.extension.unreadCount, 1);
            
            [self.extension active];
            
            XCTAssertEqual(self.extension.unreadCount, 0);
            handler();
        };
    } afterBlock:^{
        [self.chat emitEventLocally:@"$unread-test",
         @{ CENEventData.chat: self.chat, CENEventData.sender: user, CENEventData.data: @{} }, nil];
    }];
}


#pragma mark - Tests :: handleEvent

- (void)testHandleEvent_ShouldUpdateUnreadCount_WhenChatIsInactive {
    
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    
    
    [self.extension onCreate];
    [self.extension inactive];
    
    [self object:self.chat shouldHandleEvent:@"$unread" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *event) {
            NSDictionary *eventPayload = event.data;
            
            XCTAssertEqualObjects(eventPayload[CENUnreadMessagesEvent.count], @1);
            handler();
        };
    } afterBlock:^{
        [self.chat emitEventLocally:@"$unread-test",
         @{ CENEventData.chat: self.chat, CENEventData.sender: user, CENEventData.data: @{} }, nil];
    }];
}

- (void)testHandleEvent_ShouldNotUpdateUnreadCount_WhenChatIsActive {
    
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    
    
    [self.extension onCreate];
    [self.extension active];
    
    [self object:self.chat shouldNotHandleEvent:@"$unread" withinInterval:self.falseTestCompletionDelay
     withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
         return ^(CENEmittedEvent *event) {
             handler();
         };
    } afterBlock:^{
        [self.chat emitEventLocally:@"$unread-test",
         @{ CENEventData.chat: self.chat, CENEventData.sender: user, CENEventData.data: @{} }, nil];
    }];
}

#pragma mark -


@end
