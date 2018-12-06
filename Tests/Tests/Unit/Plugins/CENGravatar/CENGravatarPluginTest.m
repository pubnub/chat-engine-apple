/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENGravatarExtension.h>
#import <CENChatEngine/CENGravatarPlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENGravatarPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENGravatarPlugin *plugin;


#pragma mark - Misc

- (void)stubLocalUser;

#pragma mark -


@end


@implementation CENGravatarPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.plugin = [CENGravatarPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENGravatarPlugin.identifier, @"com.chatengine.plugin.gravatar");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaults_WhenNilConfigurationPassed {
    
    CENGravatarPlugin *plugin = [CENGravatarPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENGravatarPluginConfiguration.emailKey], @"email");
    XCTAssertEqualObjects(plugin.configuration[CENGravatarPluginConfiguration.gravatarURLKey], @"gravatar");
}

- (void)testConfiguration_ShouldNotReplaceConfiguredKeys_WhenConfigurationPassed {
    
    NSDictionary *configuration = @{
        CENGravatarPluginConfiguration.emailKey: @"profile.email",
        CENGravatarPluginConfiguration.gravatarURLKey: @"profile.avatar"
    };
    
    CENGravatarPlugin *plugin = [CENGravatarPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration[CENGravatarPluginConfiguration.emailKey],
                          configuration[CENGravatarPluginConfiguration.emailKey]);
    XCTAssertEqualObjects(plugin.configuration[CENGravatarPluginConfiguration.gravatarURLKey],
                          configuration[CENGravatarPluginConfiguration.gravatarURLKey]);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENMeInstancePassed {
    
    [self stubLocalUser];
    
    Class extensionClass = [self.plugin extensionClassFor:self.client.me];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENGravatarExtension class]);
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
