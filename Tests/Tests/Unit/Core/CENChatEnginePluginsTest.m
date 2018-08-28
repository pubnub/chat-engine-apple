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

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEnginePluginsTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}


#pragma mark - Tests :: proto / hasProtoPlugin

- (void)testHasProtoPlugin_ShouldReturnYes_WhenProtoPluginWithSpecifiedClassExists {
    
    [self.client registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertTrue([self.client hasProtoPlugin:[CENSearchFilterPlugin class] forObjectType:@"Chat"]);
}

- (void)testProtoHasProtoPlugin_ShouldReturnYes_WhenProtoPluginWithSpecifiedClassExists {
    
    [self.client registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertTrue(self.client.proto(@"Chat", [CENSearchFilterPlugin class]).exists());
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenProtoPluginWithSpecifiedClassNotRegistered {
    
    [self.client registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse(self.client.proto(@"Chat", [CEDummyPlugin class]).exists());
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenProtoPluginWithSpecifiedClassNotRegisteredForObjectType {
    
    [self.client registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse(self.client.proto(@"User", [CENSearchFilterPlugin class]).exists());
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenUnsupportedProtoPluginSpecified {
    
    [self.client registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse([self.client hasProtoPlugin:[NSArray class] forObjectType:@"Chat"]);
}

- (void)testProtoHasProtoPlugin_ShouldReturnNo_WhenUnknownObjectTypeSpecifided {
    
    [self.client registerProtoPlugin:[CENSearchFilterPlugin class] withConfiguration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse([self.client hasProtoPlugin:[CENSearchFilterPlugin class] forObjectType:@"PubNub"]);
}


#pragma mark - Tests :: proto / hasProtoPluginWithIdentifier

- (void)testProtoHasProtoPluginWithIdentifier_ShuldSearchUsingPluingsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([pluginsManagerPartialMock hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    
    self.client.proto(expectedObjectType, expectedIdentifier).exists();
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoHasProtoPluginWithIdentifier_ShuldNotSearchForUnknownObjectType {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.client hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoHasProtoPluginWithIdentifier_ShuldNotSearchForNonNSStringIdentifier {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = (id)@2010;
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.client hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoHasProtoPluginWithIdentifier_ShuldNotSearchForEmptyIdentifier {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = @"";
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.client hasProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: setupProtoPluginsForObject

- (void)testSetupProtoPluginsForObject_ShouldConfigureProtoForObject {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENChat *expectedChat = self.client.global;
    
    OCMExpect([pluginsManagerPartialMock setupProtoPluginsForObject:expectedChat withCompletion:[OCMArg any]]);
    
    [self.client setupProtoPluginsForObject:expectedChat withCompletion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: proto / registerProtoPlugin

- (void)testProtoRegisterProtoPlugin_ShouldRegisterProtoWithDefaultIdentifier_WhenOnlyClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([self.clientMock registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                                     forObjectType:expectedObjectType]);
    
    self.clientMock.proto(expectedObjectType, expectedClass).configuration(expectedConfiguration).store();
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testProtoRegisterProtoPlugin_ShouldNotRegisterProtoWithDefaultIdentifier_WhenUnsupportedClassPassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedObjectType = @"Search";
    Class expectedClass = [NSArray class];
    
    OCMExpect([[(id)self.clientMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                  forObjectType:[OCMArg any]]);
    
    [self.clientMock registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testProtoRegisterProtoPlugin_ShouldNotRegisterProtoWithDefaultIdentifier_WhenUnknownObjectTypePassed {
    
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedObjectType = @"PubNub";
    Class expectedClass = [NSArray class];
    
    OCMExpect([[(id)self.clientMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                  forObjectType:[OCMArg any]]);
    
    [self.clientMock registerProtoPlugin:expectedClass withConfiguration:expectedConfiguration forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: proto / registerProtoPluginWithIdentifier

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldRegisterUsingPluingsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([pluginsManagerPartialMock registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                                               forObjectType:expectedObjectType]);
    
    self.client.proto(expectedObjectType, expectedClass).configuration(expectedConfiguration).identifier(expectedIdentifier).store();
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenUnsupportedClassPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [NSArray class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                       forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenUnknownObjectTypePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                       forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                       forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoRegisterProtoPluginWithIdentifier_ShuldNotRegisterUsingPluingsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerProtoPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                        forObjectType:[OCMArg any]]);
    
    [self.client registerProtoPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                       forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: proto / unregisterProtoPlugin

- (void)testProtoUnregisterProtoPlugin_ShouldCallDesignatedMethod {
    
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([self.clientMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    OCMExpect([self.clientMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    
    self.clientMock.proto(expectedObjectType, expectedClass).remove();
    [self.clientMock unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotCallDesignatedMethod_WhenUnsupportedClassPassed {
    
    Class expectedClass = [NSArray class];
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([[(id)self.clientMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.clientMock unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotCallDesignatedMethod_WhenUnknownObjectTypePassed {
    
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[(id)self.clientMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.clientMock unregisterProtoPlugin:expectedClass forObjectType:expectedObjectType];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: proto / unregisterProtoPluginWithIdentifier

- (void)testProtoUnregisterProtoPlugin_ShouldUnregisterUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"Search";
    
    OCMExpect([pluginsManagerPartialMock unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType]);
    
    self.client.proto(expectedObjectType, expectedIdentifier).remove();
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenUnsupportedClassPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.client unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = (id)@2010;
    NSString *expectedObjectType = @"PubNub";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.client unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testProtoUnregisterProtoPlugin_ShouldNotUnregisterUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedObjectType = @"PubNub";
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterProtoPluginWithIdentifier:[OCMArg any] forObjectType:[OCMArg any]]);
    
    [self.client unregisterProtoPluginWithIdentifier:expectedIdentifier forObjectType:expectedObjectType];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: hasPluginWithIdentifier

- (void)testHasPluginWithIdentifier_ShouldSearchObjectPluginUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    OCMExpect([pluginsManagerPartialMock hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject]);
    
    [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    
    [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    
    [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testHasPluginWithIdentifier_ShouldNotSearchObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    
    [self.client hasPluginWithIdentifier:expectedIdentifier forObject:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: registerPlugin

- (void)testRegisterPlugin_ShouldRegisterObjectPluginUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    
    OCMExpect([pluginsManagerPartialMock registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                                              forObject:expectedObject firstInList:NO completion:[OCMArg any]]);
    
    [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                      forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [CEDummyPlugin class];
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                      forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenUnsupportedClassPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    Class expectedClass = [NSArray class];
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                      forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                      forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testRegisterPlugin_ShouldNotRegisterObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSDictionary *expectedConfiguration = @{ @"plugin": @"configuration" };
    CENUser *expectedObject = self.client.User(@"tests").create();
    Class expectedClass = [CEDummyPlugin class];
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                       forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.client registerPlugin:expectedClass withIdentifier:expectedIdentifier configuration:expectedConfiguration
                      forObject:expectedObject firstInList:NO completion:^{}];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: unregisterObjects

- (void)testUnregisterObjects_ShouldUnregisterObjectPluginUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    
    OCMExpect([pluginsManagerPartialMock unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier]);
    
    [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    
    [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = (id)@2010;
    id expectedObject = [CEDummyPlugin new];
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    
    [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterObjects_ShouldNotUnregisterObjectPluginUsingPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    id expectedObject = [CEDummyPlugin new];
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    
    [self.client unregisterObjects:expectedObject pluginWithIdentifier:expectedIdentifier];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: unregisterAllPluginsFromObjects

- (void)testUnregisterAllPluginsFromObjects_ShouldUnregisterAllObjectsPluginsUsingPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();

    OCMExpect([pluginsManagerPartialMock unregisterAllFromObjects:expectedObject]);
    
    [self.client unregisterAllPluginsFromObjects:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testUnregisterAllPluginsFromObjects_ShouldNotUnregisterAllObjectsPluginsUsingPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] unregisterAllFromObjects:[OCMArg any]]);
    
    [self.client unregisterAllPluginsFromObjects:expectedObject];
    
    OCMVerifyAll(pluginsManagerPartialMock);
    [pluginsManagerPartialMock stopMocking];
}


#pragma mark - Tests :: extensionForObject

- (void)testExtensionForObject_ShouldRequestExtensionFromPluginsManager {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    void(^expectedContextBlock)(id) = ^(id extension) {};
    
    OCMExpect([pluginsManagerPartialMock extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock]);
    
    [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenUnsupportedObjectInstancePassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    void(^expectedContextBlock)(id) = ^(id extension) {};
    id expectedObject = [NSArray new];
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenNonNSStringIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    void(^expectedContextBlock)(id) = ^(id extension) {};
    NSString *expectedIdentifier = (id)@2010;
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenEmptyIdentifierPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    void(^expectedContextBlock)(id) = ^(id extension) {};
    NSString *expectedIdentifier = @"";
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

- (void)testExtensionForObject_ShouldNotRequestExtensionFromPluginsManager_WhenNilContextBlockPassed {
    
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    NSString *expectedIdentifier = CEDummyPlugin.identifier;
    void(^expectedContextBlock)(id) = nil;
    
    OCMExpect([[pluginsManagerPartialMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    
    [self.client extensionForObject:expectedObject withIdentifier:expectedIdentifier context:expectedContextBlock];
    
    OCMVerifyAll(pluginsManagerPartialMock);
}


#pragma mark - Tests :: runMiddlewaresAtLocation

- (void)testRunMiddlewaresAtLocation_ShouldRequestToRunMiddlewaresUsingPluginsManager {
    
    NSMutableDictionary *expectedPayload = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"payload" }];
    id pluginsManagerPartialMock = [self partialMockForObject:self.client.pluginsManager];
    CENUser *expectedObject = self.client.User(@"tests").create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *expectedLocation = CEPMiddlewareLocation.on;
    NSString *expectedEvent = @"test-event";
    
    OCMExpect([pluginsManagerPartialMock runMiddlewaresAtLocation:expectedLocation forEvent:expectedEvent object:expectedObject
                                                      withPayload:expectedPayload completion:[OCMArg any]]);
    
    [self.client runMiddlewaresAtLocation:expectedLocation forEvent:expectedEvent object:expectedObject withPayload:expectedPayload
                                      completion:^(BOOL rejected, id data) { }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    OCMVerifyAll(pluginsManagerPartialMock);
}

#pragma mark -


@end
