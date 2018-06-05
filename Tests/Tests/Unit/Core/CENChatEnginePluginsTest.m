/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENPluginsManager.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


@interface CENChatEnginePluginsTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEnginePluginsTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: proto / hasProtoPlugin

- (void)testHasProtoPlugin_ShouldReturnYes_WhenProtoPluginWithSpecifiedClassExists {
    
    [self.defaultClient registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertTrue([self.defaultClient hasProtoPlugin:[CENSearchFilterPlugin class] forObjectType:@"Chat"]);
}

- (void)testProtoHasProtoPlugin_ShouldReturnYes_WhenProtoPluginWithSpecifiedClassExists {
    
    [self.defaultClient registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertTrue(self.defaultClient.proto(@"Chat", [CENSearchFilterPlugin class]).exists());
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenProtoPluginWithSpecifiedClassNotRegistered {
    
    [self.defaultClient registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse(self.defaultClient.proto(@"Chat", [CEDummyPlugin class]).exists());
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenProtoPluginWithSpecifiedClassNotRegisteredForObjectType {
    
    [self.defaultClient registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse(self.defaultClient.proto(@"User", [CENSearchFilterPlugin class]).exists());
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenUnsupportedProtoPluginSpecified {
    
    [self.defaultClient registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse([self.defaultClient hasProtoPlugin:[NSArray class] forObjectType:@"Chat"]);
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenUnknownObjectTypeSpecifided {
    
    [self.defaultClient registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse([self.defaultClient hasProtoPlugin:[CENSearchFilterPlugin class] forObjectType:@"PubNub"]);
}


#pragma mark - Tests :: proto / hasProtoPluginWithIdentifier

- (void)testProtoHasProtoPluginWithIdentifier_ShuldSearchUsingPluingsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([pluginsManagerPartialMock hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    
    self.defaultClient.proto(expectedObjectType, expectedIdentifier).exists();
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoHasProtoPluginWithIdentifier_ShuldNotSearchForUnknownObjectType {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoHasProtoPluginWithIdentifier_ShuldNotSearchForNonNSStringIdentifier {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = (id)@2010;
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoHasProtoPluginWithIdentifier_ShuldNotSearchForEmptyIdentifier {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = @"";
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: setupProtoPluginsForObject

- (void)testSetupProtoPluginsForObject_ShouldConfigureProtoForObject {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENChat *expectedChat = self.defaultClient.global;
    
    OCMExpect([pluginsManagerPartialMock setupProtoPluginsForObject:expectedChat withCompletion:[OCMArg any]]);
    
    [self.defaultClient setupProtoPluginsForObject:expectedChat withCompletion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: proto / registerProtoPlugin

- (void)testProtoRegisterProtoPlugin_ShouldRegisterProtoWithDefaultIdentifier_WhenOnlyClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([self.defaultClient registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                                        forObjectType:expectedObjectType]);
    
    self.defaultClient.proto(expectedObjectType, expectedClass).configuration(expectedConfiguration).store();
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testProtoRegisterProtoPlugin_ShouldNotRegisterProtoWithDefaultIdentifier_WhenUnsupportedClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedObjectType = @"Search";
    Class expectedClass = [NSArray class];
    
    OCMExpect([[(id)self.defaultClient reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                     forObjectType:[OCMArg any]]);
    
    [self.defaultClient registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testProtoRegisterProtoPlugin_ShouldNotRegisterProtoWithDefaultIdentifier_WhenUnknownObjectTypePassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedObjectType = @"PubNub";
    Class expectedClass = [NSArray class];
    
    OCMExpect([[(id)self.defaultClient reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                     forObjectType:[OCMArg any]]);
    
    [self.defaultClient registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: proto / registerProtoPluginWithIdentifier

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldRegisterUsingPluingsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([pluginsManagerPartialMock registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                                               forObjectType:expectedObjectType]);
    
    self.defaultClient.proto(expectedObjectType, expectedClass).configuration(expectedConfiguration).identifier(expectedIdentifier).store();
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenUnsupportedClassPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [NSArray class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.defaultClient registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                              forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenUnknownObjectTypePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.defaultClient registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                              forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.defaultClient registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                              forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.defaultClient registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                              forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: proto / unregisterProtoPlugin

- (void)testProtoUnregisterProtoPlugin_ShouldCallDesignatedMethod {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([self.defaultClient unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    OCMExpect([self.defaultClient unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    
    self.defaultClient.proto(expectedObjectType, expectedClass).remove();
    [self.defaultClient unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotCallDesignatedMethod_WhenUnsupportedClassPassed {
    
    Class expectedClass = [NSArray class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[(id)self.defaultClient reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotCallDesignatedMethod_WhenUnknownObjectTypePassed {
    
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[(id)self.defaultClient reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: proto / unregisterProtoPluginWithIdentifier

- (void)testProtoUnregisterProtoPlugin_ShouldUnregisterUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([pluginsManagerPartialMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    
    self.defaultClient.proto(expectedObjectType, expectedIdentifier).remove();
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenUnsupportedClassPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = (id)@2010;
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedObjectType = @"PubNub";
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.defaultClient unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: hasPluginWithIdentifier

- (void)testHasPluginWithIdentifier_ShouldSearchObjectPluginUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    OCMExpect([pluginsManagerPartialMock hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject]);
    
    [self.defaultClient hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    
    [self.defaultClient hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    
    [self.defaultClient hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    
    [self.defaultClient hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: registerPlugin

- (void)testRegisterPlugin_ShouldRegisterObjectPluginUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    
    OCMExpect([pluginsManagerPartialMock registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                                              forObject:expectedObject firstInList:NO completion:[OCMArg any]]);
    
    [self.defaultClient registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                             forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.defaultClient registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                             forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenUnsupportedClassPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [NSArray class];
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.defaultClient registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                             forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.defaultClient registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                             forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.defaultClient registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                             forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: unregisterObjects

- (void)testUnregisterObjects_ShouldUnregisterObjectPluginUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    OCMExpect([pluginsManagerPartialMock unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier]);
    
    [self.defaultClient unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    
    [self.defaultClient unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = (id)@2010;
    id expectedObject = [CEDummyPlugin new];
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    
    [self.defaultClient unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    id expectedObject = [CEDummyPlugin new];
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    
    [self.defaultClient unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: unregisterAllPluginsFromObjects

- (void)testUnregisterAllPluginsFromObjects_ShouldUnregisterAllObjectsPluginsUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();

    OCMExpect([pluginsManagerPartialMock unregisterAllFromObjects:expectedObject]);
    
    [self.defaultClient unregisterAllPluginsFromObjects:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterAllPluginsFromObjects_ShouldNotUnregisterAllObjectsPluginsUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterAllFromObjects:[OCMArg any]]);
    
    [self.defaultClient unregisterAllPluginsFromObjects:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
    [pluginsManagerPartialMock stopMocking];
}


#pragma mark - Tests :: extensionForObject

- (void)testExtensionForObject_ShouldRequestExtensionFromPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    void(^expectedContextBlock)(id) = ^(id extension) {};
    
    OCMExpect([pluginsManagerPartialMock extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock]);
    
    [self.defaultClient extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    void(^expectedContextBlock)(id) = ^(id extension) {};
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.defaultClient extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    void(^expectedContextBlock)(id) = ^(id extension) {};
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.defaultClient extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    void(^expectedContextBlock)(id) = ^(id extension) {};
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.defaultClient extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenNilContextBlockPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    void(^expectedContextBlock)(id) = nil;
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.defaultClient extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: runMiddlewaresAtLocation

- (void)testRunMiddlewaresAtLocation_ShouldRequestToRunMiddlewaresUsingPluginsManager {
    
    NSMutableDictionary *expectedPayload = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"payload" }];
    id pluginsManagerPartialMock = [self partialMockForObject:self.defaultClient.pluginsManager];
    CENUser *expectedObject = self.defaultClient.User(@"tests").create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedLocation = CEPMiddlewareLocation.on;
    NSString *expectedEvent = @"test-event";
    
    OCMExpect([pluginsManagerPartialMock runMiddlewaresAtLocation:expectedLocation forEvent:expectedEvent object:expectedObject
                                                      withPayload:expectedPayload completion:[OCMArg any]]);
    
    [self.defaultClient runMiddlewaresAtLocation:expectedLocation forEvent:expectedEvent object:expectedObject withPayload:expectedPayload
                                      completion:^(BOOL rejected, id data) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

#pragma mark -


@end
