/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENTypingIndicatorMiddleware.h>
#import <CENChatEngine/CENTypingIndicatorExtension.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN8TypingIndicatorMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENTypingIndicatorMiddleware *middleware;
@property (nonatomic, nullable, strong) id middlewareMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CEN8TypingIndicatorMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.middleware = [CENTypingIndicatorMiddleware new];
    self.middlewareMock = [self mockForObject:self.middleware];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENTypingIndicatorMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToEmit {
    
    XCTAssertEqualObjects(CENTypingIndicatorMiddleware.location, CEPMiddlewareLocation.emit);
}


#pragma mark - Tests :: Auto-stop

- (void)testAutoStop_ShouldEmitTypingStop_WhenMessageEmittedOnChat {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionForObject:chat withIdentifier:@"test"
                                                                               configuration:nil];
    NSMutableDictionary *payload = [@{ CENEventData.chat: chat } mutableCopy];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock stopTyping]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

#pragma mark -


@end
