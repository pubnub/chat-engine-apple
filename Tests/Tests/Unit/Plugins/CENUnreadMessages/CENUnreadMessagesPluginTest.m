/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUnreadMessagesExtension.h>
#import <CENChatEngine/CENUnreadMessagesPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUnreadMessagesPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENUnreadMessagesPlugin *plugin;

#pragma mark -

@end


@implementation CENUnreadMessagesPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    self.plugin = [CENUnreadMessagesPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENUnreadMessagesPlugin.identifier, @"com.chatengine.plugin.unread-messages");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaults_WhenNilConfigurationPassed {
    
    CENUnreadMessagesPlugin *plugin = [CENUnreadMessagesPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENUnreadMessagesConfiguration.events], @[@"message"]);
}

- (void)testConfiguration_ShouldNotReplaceConfiguredKeys_WhenConfigurationPassed {
    
    NSDictionary *configuration = @{ CENUnreadMessagesConfiguration.events: @[@"$.invite", @"ping", @"pong"] };
    
    CENUnreadMessagesPlugin *plugin = [CENUnreadMessagesPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENUnreadMessagesConfiguration.events],
                          configuration[CENUnreadMessagesConfiguration.events]);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:[self publicChatWithChatEngine:self.client]];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENUnreadMessagesExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: setChatActive

- (void)testSetChatActive_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENUnreadMessagesPlugin.identifier context:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENUnreadMessagesPlugin setChat:chat active:YES];
    }];
}

- (void)testSetChatActive_ShouldCallExtensionMethod_WhenActiveIsYes {
    
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test"
                                                                                  configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENUnreadMessagesExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock active]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENUnreadMessagesPlugin setChat:chat active:YES];
    }];
}

- (void)testSetChatActive_ShouldCallExtensionMethod_WhenActiveIsNo {
    
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test"
                                                                                  configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENUnreadMessagesExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock inactive]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENUnreadMessagesPlugin setChat:chat active:NO];
    }];
}


#pragma mark - Tests :: fetchUnreadCount

- (void)testFetchUnreadCount_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENUnreadMessagesPlugin.identifier context:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENUnreadMessagesPlugin fetchUnreadCountForChat:chat withCompletion:^(NSUInteger count) { }];
    }];
}

- (void)testFetchUnreadCount_ShouldCallExtensionMethod {
    
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test"
                                                                                  configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENUnreadMessagesExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock unreadCount]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENUnreadMessagesPlugin fetchUnreadCountForChat:chat withCompletion:^(NSUInteger count) { }];
    }];
}

#pragma mark -


@end
