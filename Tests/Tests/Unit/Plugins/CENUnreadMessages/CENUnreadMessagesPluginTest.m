/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
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


#pragma mark - Tests

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

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
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
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENUnreadMessagesPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin setChat:chat active:YES];
    }];
}

- (void)testSetChatActive_ShouldCallExtensionMethod_WhenActiveIsYes {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionForObject:chat withIdentifier:@"test"
                                                                             configuration:self.plugin.configuration];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock active]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin setChat:chat active:YES];
    }];
}

- (void)testSetChatActive_ShouldCallExtensionMethod_WhenActiveIsNo {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionForObject:chat withIdentifier:@"test"
                                                                             configuration:self.plugin.configuration];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock inactive]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin setChat:chat active:NO];
    }];
}


#pragma mark - Tests :: isActiveChat

- (void)testIsChatActive_ShouldRequestExtensionWithPluginIdentifier {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENUnreadMessagesPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin isChatActive:chat];
    }];
}

- (void)testIsChatActive_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionForObject:chat withIdentifier:@"test"
                                                                             configuration:self.plugin.configuration];


    id extensionMock = [self mockForObject:extension];

    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);

    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock isActive]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin isChatActive:chat];
    }];
}


#pragma mark - Tests :: fetchUnreadCount

- (void)testUnreadCount_ShouldRequestExtensionWithPluginIdentifier {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENUnreadMessagesPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin unreadCountForChat:chat];
    }];
}

- (void)testUnreadCount_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUnreadMessagesExtension *extension = [CENUnreadMessagesExtension extensionForObject:chat withIdentifier:@"test"
                                                                             configuration:self.plugin.configuration];


    id extensionMock = [self mockForObject:extension];

    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);

    id recorded = OCMExpect([(CENUnreadMessagesExtension *)extensionMock unreadCount]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUnreadMessagesPlugin unreadCountForChat:chat];
    }];
}


#pragma mark - Tests :: fetchUnreadCount

- (void)testFetchUnreadCount_ShouldForwardCall {

    CENChat *chat = [self publicChatWithChatEngine:self.client];


    id pluginMock = [self mockForObject:[CENUnreadMessagesPlugin class]];
    id recorded = OCMExpect([pluginMock unreadCountForChat:chat]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENUnreadMessagesPlugin fetchUnreadCountForChat:chat withCompletion:^(NSUInteger count) { }];
#pragma GCC diagnostic pop
    }];
}

#pragma mark -


@end
