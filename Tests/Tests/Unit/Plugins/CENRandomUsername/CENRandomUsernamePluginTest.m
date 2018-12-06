/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENRandomUsernameExtension.h>
#import <CENChatEngine/CENRandomUsernamePlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENRandomUsernamePluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENRandomUsernamePlugin *plugin;


#pragma mark - Misc

- (void)stubLocalUser;

#pragma mark -


@end

@implementation CENRandomUsernamePluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    self.plugin = [CENRandomUsernamePlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENRandomUsernamePlugin.identifier, @"com.chatengine.plugin.random-username");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaults_WhenNilConfigurationPassed {
    
    CENRandomUsernamePlugin *plugin = [CENRandomUsernamePlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENRandomUsernameConfiguration.propertyName], @"username");
}

- (void)testConfiguration_ShouldNotReplaceConfiguredKeys_WhenConfigurationPassed {
    
    NSDictionary *configuration = @{ CENRandomUsernameConfiguration.propertyName: @"nick" };
    
    CENRandomUsernamePlugin *plugin = [CENRandomUsernamePlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENRandomUsernameConfiguration.propertyName],
                          configuration[CENRandomUsernameConfiguration.propertyName]);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENMeInstancePassed {
    
    [self stubLocalUser];
    
    Class extensionClass = [self.plugin extensionClassFor:self.client.me];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENRandomUsernameExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENMeInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Misc

- (void)stubLocalUser {
    
    self.usesMockedObjects = YES;
    CENChatEngine *client = self.client;
    
    [self stubChatConnection];
    
    CENMe *user = [CENMe userWithUUID:[NSUUID UUID].UUIDString state:@{} chatEngine:client];
    OCMStub([client me]).andReturn(user);
}

#pragma mark -


@end
