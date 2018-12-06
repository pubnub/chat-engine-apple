/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENTypingIndicatorExtension.h>
#import <CENChatEngine/CENTypingIndicatorPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>


@interface CENTypingIndicatorPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENTypingIndicatorPlugin *plugin;

#pragma mark -


@end


@implementation CENTypingIndicatorPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.plugin = [CENTypingIndicatorPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENTypingIndicatorPlugin.identifier, @"com.chatengine.plugin.typing-indicator");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaultTimeout_WhenNilConfigurationPassed {
    
    CENTypingIndicatorPlugin *plugin = [CENTypingIndicatorPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqual(((NSNumber *)plugin.configuration[CENTypingIndicatorConfiguration.timeout]).floatValue, 1.f);
}

- (void)testConfiguration_ShouldNotReplaceConfiguredKeys_WhenConfigurationPassed {
    
    NSDictionary *configuration = @{ CENTypingIndicatorConfiguration.timeout: @(26.f) };
    
    CENTypingIndicatorPlugin *plugin = [CENTypingIndicatorPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENTypingIndicatorConfiguration.timeout],
                          configuration[CENTypingIndicatorConfiguration.timeout]);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    Class extensionClass = [self.plugin extensionClassFor:chat];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENTypingIndicatorExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: setTyping

- (void)testSetTyping_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENTypingIndicatorPlugin.identifier context:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:chat];
    }];
}

- (void)testSetTyping_ShouldCallExtensionMethod_WhenStartTypingIsYes {
    
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionWithIdentifier:@"test"
                                                                                    configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENTypingIndicatorExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([extensionMock startTyping]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:chat];
    }];
}

- (void)testSetTyping_ShouldCallExtensionMethod_WhenStartTypingIsNo {
    
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionWithIdentifier:@"test"
                                                                                    configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENTypingIndicatorExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([extensionMock stopTyping]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:NO inChat:chat];
    }];
}


#pragma mark - Tests :: checkIsTyping

- (void)testCheckIsTyping_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENTypingIndicatorPlugin.identifier context:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENTypingIndicatorPlugin checkIsTypingInChat:chat withCompletion:^(BOOL isTyping) { }];
    }];
}

- (void)testCheckIsTyping_ShouldCallExtensionMethod {
    
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionWithIdentifier:@"test"
                                                                                    configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENTypingIndicatorExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([extensionMock isTyping]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENTypingIndicatorPlugin checkIsTypingInChat:chat withCompletion:^(BOOL isTyping) { }];
    }];
}

#pragma mark -


@end
