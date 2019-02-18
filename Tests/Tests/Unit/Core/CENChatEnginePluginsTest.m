/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CEDummyPlugin.h"
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatEnginePluginsTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEnginePluginsTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: proto / hasProtoPlugin

- (void)testHasProtoPlugin_ShouldSearchProtoPluginByClass {
    
    NSString *identifier = CENSearchFilterPlugin.identifier;
    NSString *objectType = @"Chat";


    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock hasProtoPluginWithIdentifier:identifier forObjectType:objectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client hasProtoPlugin:[CENSearchFilterPlugin class] forObjectType:@"Chat"];
    }];
}

- (void)testHasProtoPlugin_ShouldNotSearchProtoPluginByClass_WhenUnsupportedProtoPluginSpecified {
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasProtoPlugin:[NSArray class] forObjectType:@"Chat"];
    }];
}

- (void)testHasProtoPlugin_ShouldNotSearchProtoPluginByClass_WhenUnknownObjectTypeSpecified {
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasProtoPlugin:[CENSearchFilterPlugin class] forObjectType:@"PubNub"];
    }];
}


#pragma mark - Tests :: proto / hasProtoPluginWithIdentifier

- (void)testHasProtoPluginWithIdentifier_ShouldNotSearchProtoPluginByIdentifier {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        self.client.proto(expectedObjectType, [CEDummyPlugin class]).exists();
    }];
    
    recorded = OCMExpect([managerMock hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        self.client.proto(expectedObjectType, expectedIdentifier).exists();
    }];
}

- (void)testHasProtoPluginWithIdentifier_ShouldNotSearchProtoPluginByIdentifier_WhenUnknownObjectType {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"PubNub";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    }];
}

- (void)testHasProtoPluginWithIdentifier_ShouldNotSearchProtoPluginByIdentifier_WhenNonNSStringIdentifier {
    
    NSString *expectedIdentifier = (id)@2010;
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    }];
}

- (void)testHasProtoPluginWithIdentifier_ShouldNotSearchProtoPluginByIdentifier_WhenEmptyIdentifier {
    
    NSString *expectedObjectType = @"Search";
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    }];
}


#pragma mark - Tests :: setupProtoPluginsForObject

- (void)testSetupProtoPluginsForObject_ShouldConfigureProtoForObjectUsingPluginsManager {
    
    CENChat *expectedChat = [self publicChatWithChatEngine:self.client];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock setupProtoPluginsForObject:expectedChat withCompletion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client setupProtoPluginsForObject:expectedChat withCompletion:^{}];
    }];
}


#pragma mark - Tests :: proto / registerProtoPlugin

- (void)testRegisterProtoPlugin_ShouldRegisterProtoWithDefaultIdentifier_WhenOnlyClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";

    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier
                                               configuration:expectedConfiguration forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        self.client.proto(expectedObjectType, expectedClass).configuration(expectedConfiguration).store();
    }];
    
    recorded = OCMExpect([managerMock registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier
                                            configuration:expectedConfiguration forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    }];
}

- (void)testRegisterProtoPlugin_ShouldNotRegisterProtoWithDefaultIdentifier_WhenUnsupportedClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedObjectType = @"Search";
    Class expectedClass = [NSArray class];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                        configuration:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    }];
}

- (void)testProtoRegisterProtoPlugin_ShouldNotRegisterProtoWithDefaultIdentifier_WhenUnknownObjectTypePassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedObjectType = @"PubNub";
    Class expectedClass = [NSArray class];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                        configuration:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    }];
}


#pragma mark - Tests :: proto / registerProtoPluginWithIdentifier

- (void)testProtoRegisterProtoPluginWithIdentifier_ShouldRegisterUsingPluginsManager {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier
                                               configuration:expectedConfiguration forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        self.client.proto(expectedObjectType, expectedClass).configuration(expectedConfiguration)
            .identifier(expectedIdentifier).store();
    }];
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShouldNotRegisterUsingPluginsManager_WhenUnsupportedClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [NSArray class];
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                        configuration:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                           forObjectType:expectedObjectType];
    }];
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShouldNotRegisterUsingPluginsManager_WhenUnknownObjectTypePassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                        configuration:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                           forObjectType:expectedObjectType];
    }];
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShouldNotRegisterUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    NSString *expectedIdentifier = (id)@2010;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                        configuration:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                           forObjectType:expectedObjectType];
    }];
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShouldNotRegisterUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                        configuration:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                           forObjectType:expectedObjectType];
    }];
}


#pragma mark - Tests :: proto / unregisterProtoPlugin

- (void)testProtoUnregisterProtoPlugin_ShouldCallDesignatedMethod {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        self.client.proto(expectedObjectType, expectedClass).remove();
    }];
    
    recorded = OCMExpect([managerMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    }];
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotCallDesignatedMethod_WhenUnsupportedClassPassed {
    
    Class expectedClass = [NSArray class];
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    }];
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotCallDesignatedMethod_WhenUnknownObjectTypePassed {
    
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    }];
}


#pragma mark - Tests :: proto / unregisterProtoPluginWithIdentifier

- (void)testProtoUnregisterProtoPlugin_ShouldUnregisterUsingPluginsManager {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        self.client.proto(expectedObjectType, expectedIdentifier).remove();
    }];
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenUnknownObjectTypePassed {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"PubNub";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    }];
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    NSString *expectedIdentifier = (id)@2010;
    NSString *expectedObjectType = @"Search";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    }];
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    NSString *expectedObjectType = @"Search";
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    }];
}


#pragma mark - Tests :: hasPluginWithIdentifier

- (void)testHasPluginWithIdentifier_ShouldSearchObjectPluginUsingPluginsManager {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    }];
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    }];
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = (id)@2010;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    }];
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    }];
}


#pragma mark - Tests :: registerPlugin

- (void)testRegisterPlugin_ShouldRegisterObjectPluginUsingPluginsManager {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock registerPlugin:expectedClass withIdentifier:expectedIdentifier
                                          configuration:expectedConfiguration forObject:expectedObject firstInList:NO
                                             completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                          forObject:expectedObject firstInList:NO completion:^{}];
    }];
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    id expectedObject = [NSArray new];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                   configuration:[OCMArg any] forObject:[OCMArg any] firstInList:NO
                                                      completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                          forObject:expectedObject firstInList:NO completion:^{}];
    }];
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenUnsupportedClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [NSArray class];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                   configuration:[OCMArg any] forObject:[OCMArg any] firstInList:NO
                                                      completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                          forObject:expectedObject firstInList:NO completion:^{}];
    }];
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedIdentifier = (id)@2010;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                   configuration:[OCMArg any] forObject:[OCMArg any] firstInList:NO
                                                      completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                          forObject:expectedObject firstInList:NO completion:^{}];
    }];
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                   configuration:[OCMArg any] forObject:[OCMArg any] firstInList:NO
                                                      completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                          forObject:expectedObject firstInList:NO completion:^{}];
    }];
}


#pragma mark - Tests :: unregisterObjects

- (void)testUnregisterObjects_ShouldUnregisterObjectPluginUsingPluginsManager {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    }];
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    }];
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = (id)@2010;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    }];
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    }];
}


#pragma mark - Tests :: unregisterAllPluginsFromObjects

- (void)testUnregisterAllPluginsFromObjects_ShouldUnregisterAllObjectsPluginsUsingPluginsManager {
    
    CENUser *expectedObject = self.client.User(@"tests").create();

    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock unregisterAllFromObjects:expectedObject]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client unregisterAllPluginsFromObjects:expectedObject];
    }];
}

- (void)testUnregisterAllPluginsFromObjects_ShouldNotUnregisterAllObjectsPluginsUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id expectedObject = [NSArray new];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterAllFromObjects:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client unregisterAllPluginsFromObjects:expectedObject];
    }];
}


#pragma mark - Tests :: extensionForObject

- (void)testExtensionForObject_ShouldRequestExtensionFromPluginsManager {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock extensionForObject:expectedObject withIdentifier:expectedIdentifier]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier];
    }];
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier];
    }];
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenNonNSStringIdentifierPassed {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = (id)@2010;
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier];
    }];
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenEmptyIdentifierPassed {
    
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = @"";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier];
    }];
}


#pragma mark - Tests :: runMiddlewaresAtLocation

- (void)testRunMiddlewaresAtLocation_ShouldRequestToRunMiddlewaresUsingPluginsManager {
    
    NSMutableDictionary *expectedPayload = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"payload" }];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedLocation = CEPMiddlewareLocation.on;
    NSString *expectedEvent = @"test-event";
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock runMiddlewaresAtLocation:expectedLocation forEvent:expectedEvent object:expectedObject
                                                      withPayload:expectedPayload completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client runMiddlewaresAtLocation:expectedLocation forEvent:expectedEvent object:expectedObject
                                  withPayload:expectedPayload completion:^(BOOL rejected, id data) { }];
    }];
}


#pragma mark - Tests :: destroyPubNub

- (void)testDestroyPlugins_ShouldCallPluginsManagerDestroy {
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([managerMock destroy]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.client destroyPlugins];
    }];
}

#pragma mark -


@end
