/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENTypingIndicatorMiddleware.h>
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


#pragma mark - Tests

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

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
    XCTAssertEqualObjects(CENTypingIndicatorPlugin.identifier, @"com.chatengine.plugin.typing-indicator");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaults_WhenNilConfigurationPassed {
    
    CENTypingIndicatorPlugin *plugin = [CENTypingIndicatorPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqual(((NSNumber *)plugin.configuration[CENTypingIndicatorConfiguration.timeout]).floatValue, 1.f);
    XCTAssertEqualObjects(plugin.configuration[CENTypingIndicatorConfiguration.events], @[@"message"]);
}

- (void)testConfiguration_ShouldNotReplaceConfiguredKeys_WhenConfigurationPassed {
    
    NSDictionary *configuration = @{
        CENTypingIndicatorConfiguration.timeout: @(26.f),
        CENTypingIndicatorConfiguration.events: @[@"ping", @"pong"]
    };
    
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


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENTypingIndicatorMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:(id)@2010];
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenCENChatInstancePassedForUnexpectedLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: setTyping

- (void)testSetTyping_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENTypingIndicatorPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:chat];
    }];
}

- (void)testSetTyping_ShouldCallExtensionMethod_WhenStartTypingIsYes {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionForObject:chat withIdentifier:@"test"
                                                                               configuration:self.plugin.configuration];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock startTyping]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:YES inChat:chat];
    }];
}

- (void)testSetTyping_ShouldCallExtensionMethod_WhenStartTypingIsNo {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionForObject:chat withIdentifier:@"test"
                                                                               configuration:self.plugin.configuration];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock stopTyping]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENTypingIndicatorPlugin setTyping:NO inChat:chat];
    }];
}


#pragma mark - Tests :: isTyping

- (void)testIsTyping_ShouldRequestExtensionWithPluginIdentifier {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENTypingIndicatorPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENTypingIndicatorPlugin isTypingInChat:chat];
    }];
}

- (void)testIsTyping_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENTypingIndicatorExtension *extension = [CENTypingIndicatorExtension extensionForObject:chat withIdentifier:@"test"
                                                                               configuration:self.plugin.configuration];


    id extensionMock = [self mockForObject:extension];

    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);

    id recorded = OCMExpect([extensionMock isTyping]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENTypingIndicatorPlugin isTypingInChat:chat];
    }];
}


#pragma mark - Tests :: checkIsTyping

- (void)testCheckIsTyping_ShouldForwardCall {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    

    id pluginMock = [self mockForObject:[CENTypingIndicatorPlugin class]];
    id recorded = OCMExpect([pluginMock isTypingInChat:chat]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENTypingIndicatorPlugin checkIsTypingInChat:chat withCompletion:^(BOOL isTyping) { }];
#pragma GCC diagnostic pop
    }];
}

#pragma mark -


@end
