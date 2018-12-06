/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENOnlineUserSearchExtension.h>
#import <CENChatEngine/CENOnlineUserSearchPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENOnlineUserSearchPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENOnlineUserSearchPlugin *plugin;

#pragma mark -

@end


@implementation CENOnlineUserSearchPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    self.plugin = [CENOnlineUserSearchPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENOnlineUserSearchPlugin.identifier, @"com.chatengine.plugin.online-user-search");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaults_WhenNilConfigurationPassed {
    
    CENOnlineUserSearchPlugin *plugin = [CENOnlineUserSearchPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENOnlineUserSearchConfiguration.propertyName], @"uuid");
    XCTAssertEqualObjects(plugin.configuration[CENOnlineUserSearchConfiguration.caseSensitive], @NO);
}

- (void)testConfiguration_ShouldNotReplaceConfiguredKeys_WhenConfigurationPassed {
    
    NSDictionary *configuration = @{
        CENOnlineUserSearchConfiguration.propertyName: @"state.email",
        CENOnlineUserSearchConfiguration.caseSensitive: @YES
    };
    
    CENOnlineUserSearchPlugin *plugin = [CENOnlineUserSearchPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENOnlineUserSearchConfiguration.propertyName],
                          configuration[CENOnlineUserSearchConfiguration.propertyName]);
    XCTAssertEqualObjects(plugin.configuration[CENOnlineUserSearchConfiguration.caseSensitive],
                          configuration[CENOnlineUserSearchConfiguration.caseSensitive]);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:[self publicChatWithChatEngine:self.client]];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENOnlineUserSearchExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: search

- (void)testSearch_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENOnlineUserSearchPlugin.identifier context:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENOnlineUserSearchPlugin search:@"something" inChat:chatMock withCompletion:^(NSArray<CENUser *> *users) { }];
    }];
}

- (void)testSearch_ShouldCallExtensionMethod {
    
    CENOnlineUserSearchExtension *extension = [CENOnlineUserSearchExtension extensionWithIdentifier:@"test"
                                                                                      configuration:self.plugin.configuration];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *expected = @"something";

    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENOnlineUserSearchExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(extensionMock);
    });
    
    id recorded = OCMExpect([extensionMock searchFor:expected withCompletion:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENOnlineUserSearchPlugin search:expected inChat:chatMock withCompletion:^(NSArray<CENUser *> *users) { }];
    }];
}

#pragma mark -

@end
