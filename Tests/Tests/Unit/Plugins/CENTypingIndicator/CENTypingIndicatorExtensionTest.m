/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
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


@implementation CENTypingIndicatorExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.chat = [self publicChatWithChatEngine:self.client];
    
    self.extension = [CENTypingIndicatorExtension extensionWithIdentifier:@"test" configuration:nil];
    self.extension.object = self.chat;
}


#pragma mark - Tests :: startTyping

- (void)testStartTyping_ShouldEmitTypingStartEvent_WhenIsTypingNo {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$typingIndicator.startTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.extension startTyping];
    }];
}

- (void)testStartTyping_ShouldNotEmitTypingStartEvent_WhenIsTypingYes {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    OCMStub([extensionMock isTyping]).andReturn(YES);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$typingIndicator.startTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.extension startTyping];
    }];
}


#pragma mark - Tests :: stopTyping

- (void)testStopTyping_ShouldEmitTypingStopEvent_WhenIsTypingYes {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    OCMStub([extensionMock isTyping]).andReturn(YES);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$typingIndicator.stopTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.extension stopTyping];
    }];
}

- (void)testStopTyping_ShouldNotEmitTypingStopEvent_WhenIsTypingNo {
    
    id extensionMock = [self mockForObject:self.extension];
    OCMStub([extensionMock handleTypingIdleTimer:[OCMArg any]]).andDo(nil);
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$typingIndicator.stopTyping" withData:nil]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [self.extension stopTyping];
    }];
}

#pragma mark -


@end
