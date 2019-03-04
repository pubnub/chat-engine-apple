/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
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


#pragma mark - Tests

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

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
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
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENOnlineUserSearchPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENOnlineUserSearchPlugin search:@"something" inChat:chatMock];
    }];
}

- (void)testSearch_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENOnlineUserSearchExtension *extension = [CENOnlineUserSearchExtension extensionForObject:chat withIdentifier:@"test"
                                                                                 configuration:self.plugin.configuration];
    NSString *expected = @"something";


    id extensionMock = [self mockForObject:extension];

    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);

    id recorded = OCMExpect([extensionMock usersMatchingCriteria:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENOnlineUserSearchPlugin search:expected inChat:chatMock];
    }];
}

- (void)testSearch_ShouldForwardCall {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENOnlineUserSearchExtension *extension = [CENOnlineUserSearchExtension extensionForObject:chat withIdentifier:@"test"
                                                                                 configuration:self.plugin.configuration];
    NSString *expected = @"something";

    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);

    id recorded = OCMExpect([extensionMock usersMatchingCriteria:expected]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENOnlineUserSearchPlugin search:expected inChat:chat withCompletion:^(NSArray<CENUser *> *users) { }];
#pragma GCC diagnostic pop
    }];
}

#pragma mark -

@end
