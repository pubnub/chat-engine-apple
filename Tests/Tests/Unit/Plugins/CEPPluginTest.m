/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


@interface CEPPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) CEPPlugin *plugin;
@property (nonatomic, weak) id pluginClassMock;


#pragma mark -


@end


@implementation CEPPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.pluginClassMock = [self mockForClass:[CEPPlugin class]];
    self.plugin = [CEPPlugin pluginWithIdentifier:@"test" configuration:@{ @"test": @"configuration" }];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldThrow {
    
    XCTAssertThrows([CEPPlugin identifier]);
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldReturnPluginInstance {
    
    NSDictionary *configuration = @{ @"test": @"configuration" };
    NSString *identifier = @"test";
    
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:identifier configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.identifier, identifier);
    XCTAssertEqualObjects(plugin.configuration, configuration);
}

- (void)testConstructor_ShouldReturnPluginInstance_WhenNilIdentifierPassed {
    
    NSDictionary *configuration = @{ @"test": @"configuration" };
    NSString *expectedIdentifier = @"ChatEnginePlugin";
    
    OCMStub(ClassMethod([self.pluginClassMock identifier])).andReturn(expectedIdentifier);
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:nil configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.identifier, expectedIdentifier);
    XCTAssertEqualObjects(plugin.configuration, configuration);
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenNonNSDictionaryPassed {
    
    NSDictionary *configuration = (id)@2010;
    
    OCMStub(ClassMethod([self.pluginClassMock identifier])).andReturn(@"ChatEnginePlugin");
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration, @{});
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenConfigurationNotPassed {
    
    OCMStub(ClassMethod([self.pluginClassMock identifier])).andReturn(@"ChatEnginePlugin");
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration, @{});
}


#pragma mark - Tests :: extensionClassFor

- (void)testExtensionClassFor_ShouldReturnNilByDefault {
    
    XCTAssertNil([self.plugin extensionClassFor:(id)@"ChatEngine"]);
}


#pragma mark - Tests :: middlewareClassForLocation

- (void)testMiddlewareClassForLocation_ShouldReturnNilByDefault {
    
    XCTAssertNil([self.plugin middlewareClassForLocation:@"test" object:(id)@"ChatEngine"]);
}


#pragma mark - Tests :: isValidIdentifier

- (void)testisValidIdentifier_ShouldReturnYES_WhenValidIdentifierPassed {
    
    XCTAssertTrue([CEPPlugin isValidIdentifier:@"test.plugin-identifier"]);
}

- (void)testisValidIdentifier_ShouldReturnNO_WhenNonNSStringPassed {
    
    XCTAssertFalse([CEPPlugin isValidIdentifier:(id)@2010]);
}

- (void)testisValidIdentifier_ShouldReturnNO_WhenEmptyStringPassed {
    
    XCTAssertFalse([CEPPlugin isValidIdentifier:@""]);
}

- (void)testisValidIdentifier_ShouldReturnNO_WhenNilPassed {
    
    NSString *identifier = nil;
    
    XCTAssertFalse([CEPPlugin isValidIdentifier:identifier]);
}


#pragma mark - Tests :: isValidObjectType

- (void)testisValidObjectType_ShoulReturnYES_WhenOneOfKnownObjectTypesPassed {
    
    XCTAssertTrue([CEPPlugin isValidObjectType:CENObjectType.chat]);
}

- (void)testisValidObjectType_ShoulReturnNO_WhenUnknownObjectTypesPassed {
    
    XCTAssertFalse([CEPPlugin isValidObjectType:@"test"]);
}

- (void)testisValidObjectType_ShoulReturnNO_WhenNilObjectTypesPassed {
    
    NSString *type = nil;
    
    XCTAssertFalse([CEPPlugin isValidObjectType:type]);
}


#pragma mark - Tests :: isPluginClass

- (void)testisPluginClass_ShoulReturnYES_WhenCEPPluginSubclassPassed {
    
    XCTAssertTrue([CEPPlugin isPluginClass:[CEDummyPlugin class]]);
}

- (void)testisPluginClass_ShoulReturnNO_WhenNotCEPPluginSubclassPassed {
    
    XCTAssertFalse([CEPPlugin isPluginClass:[NSArray class]]);
}

- (void)testisPluginClass_ShoulReturnNO_WhenNilPassed {
    
    Class cls = nil;
    
    XCTAssertFalse([CEPPlugin isPluginClass:cls]);
}

#pragma mark -


@end
