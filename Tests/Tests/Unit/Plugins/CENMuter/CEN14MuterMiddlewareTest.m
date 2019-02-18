/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENMuterMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENMuterExtension.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN14MuterMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENMuterMiddleware *middleware;

#pragma mark -


@end


#pragma mark - Tests

@implementation CEN14MuterMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];

    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    self.middleware = [CENMuterMiddleware middlewareForObject:chat withIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENMuterMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENMuterMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: Muted user events

- (void)testMutedUser_ShouldNotRejectEvent_WhenUserNotMuted {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    
    
    id userMock = [self mockForObject:user];
    OCMStub([userMock restoreStateForChat:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(@{});
        });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
            handler();
        }];
    }];
}

- (void)testMutedUser_ShouldRejectEvent_WhenUserMuted {

    CENChat *chat = (CENChat *)self.middleware.object;
    CENMuterExtension *extension = [CENMuterExtension extensionForObject:chat withIdentifier:@"test" configuration:nil];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    __block BOOL handledOnce = NO;
    [extension onCreate];
    
    
    id userMock = [self mockForObject:user];
    OCMStub([userMock restoreStateForChat:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(@{});
        });
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extension);
    
    [extension muteUser:user];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            if (!handledOnce) {
                handledOnce = YES;
                
                XCTAssertTrue(rejected);
                handler();
            }
        }];
    }];
}

- (void)testMutedUser_ShouldEmitRejectionEvent_WhenMutedUserSendMessage {

    CENChat *chat = (CENChat *)self.middleware.object;
    CENMuterExtension *extension = [CENMuterExtension extensionForObject:chat withIdentifier:@"test" configuration:nil];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    [extension onCreate];
    
    
    id userMock = [self mockForObject:user];
    OCMStub([userMock restoreStateForChat:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(@{});
        });
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extension);
    
    [extension muteUser:user];
    [self object:chat shouldHandleEvent:@"$muter.eventRejected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *event) {
            XCTAssertEqualObjects(event.data, payload);
            handler();
        };
    } afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {}];
    }];
}

- (void)testMutedUser_ShouldNotRejectEvent_WhenOwnEventPassed {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"$muter.eventRejected",
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    
    
    
    id userMock = [self mockForObject:user];
    OCMStub([userMock restoreStateForChat:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(@{});
        });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"$muter.eventRejected" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
            handler();
        }];
    }];
}

#pragma mark -


@end
