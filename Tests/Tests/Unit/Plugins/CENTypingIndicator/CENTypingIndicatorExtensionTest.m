/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENTypingIndicatorExtension.h>
#import <CENChatEngine/CENTypingIndicatorPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENTypingIndicatorExtension (TestExtension)


#pragma mark - Handler

/**
 * @brief Handle idle timer.
 *
 * @param timer Timer which triggered this callback.
 */
- (void)handleTypingIdleTimer:(NSTimer *)timer;

@end


@interface CENTypingIndicatorExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENTypingIndicatorExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;


#pragma mark -


@end


#pragma mark - Tests

@implementation CENTypingIndicatorExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.chat = [self publicChatWithChatEngine:self.client];
    
    NSDictionary *configuration = @{ CENTypingIndicatorConfiguration.timeout: @(0.5f) };
    self.extension = [CENTypingIndicatorExtension extensionForObject:self.chat withIdentifier:@"test"
                                                       configuration:configuration];
}


#pragma mark - Tests :: startTyping

- (void)testStartTyping_ShouldEmitTypingStartEvent_WhenIsTypingNo {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$typingIndicator.startTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension startTyping];
    }];
}

- (void)testStartTyping_ShouldNotEmitTypingStartEvent_WhenIsTypingYes {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    OCMStub([extensionMock isTyping]).andReturn(YES);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$typingIndicator.startTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension startTyping];
    }];
}


#pragma mark - Tests :: stopTyping

- (void)testStopTyping_ShouldStopRunningTimer {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMExpect([[extensionMock reject] handleTypingIdleTimer:[OCMArg any]]);
    
    [self.extension startTyping];
    [self.extension stopTyping];
    
    [self waitTask:@"waitingIdleTimer" completionFor:1.f];
    
    OCMVerifyAll(extensionMock);
}

- (void)testStopTyping_ShouldEmitTypingStopEvent_WhenIsTypingYes {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    OCMStub([extensionMock isTyping]).andReturn(YES);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$typingIndicator.stopTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension stopTyping];
    }];
}

- (void)testStopTyping_ShouldEmitTypingStopEvent_WhenTimerFires {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMExpect([extensionMock stopTyping]);
    
    [self.extension startTyping];
    [self waitTask:@"waitingIdleTimer" completionFor:1.f];
    
    OCMVerifyAll(extensionMock);
}

- (void)testStopTyping_ShouldNotEmitTypingStopEvent_WhenIsTypingNo {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$typingIndicator.stopTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension stopTyping];
    }];
}

#pragma mark -


@end
