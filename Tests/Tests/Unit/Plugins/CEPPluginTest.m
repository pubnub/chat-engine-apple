/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


@interface CEPPluginTest : CENTestCase


#pragma mark -


@end


@implementation CEPPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
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
    
    
    id classMock = [self mockForObject:[CEPPlugin class]];
    OCMStub(ClassMethod([classMock identifier])).andReturn(expectedIdentifier);
    
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:nil configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.identifier, expectedIdentifier);
    XCTAssertEqualObjects(plugin.configuration, configuration);
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenNonNSDictionaryPassed {
    
    NSDictionary *configuration = (id)@2010;
    
    
    id classMock = [self mockForObject:[CEPPlugin class]];
    OCMStub(ClassMethod([classMock identifier])).andReturn(@"ChatEnginePlugin");
    
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration, @{});
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenConfigurationNotPassed {
    
    id classMock = [self mockForObject:[CEPPlugin class]];
    OCMStub(ClassMethod([classMock identifier])).andReturn(@"ChatEnginePlugin");
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqualObjects(plugin.configuration, @{});
}


#pragma mark - Tests :: extensionClassFor

- (void)testExtensionClassFor_ShouldReturnNilByDefault {
    
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:@"ChatEnginePlugin" configuration:nil];
    
    
    XCTAssertNil([plugin extensionClassFor:(id)@"ChatEngine"]);
}


#pragma mark - Tests :: middlewareClassForLocation

- (void)testMiddlewareClassForLocation_ShouldReturnNilByDefault {
    
    CEPPlugin *plugin = [CEPPlugin pluginWithIdentifier:@"ChatEnginePlugin" configuration:nil];
    
    
    XCTAssertNil([plugin middlewareClassForLocation:@"test" object:(id)@"ChatEngine"]);
}


#pragma mark - Tests :: isValidIdentifier

- (void)testIsValidIdentifier_ShouldReturnYES_WhenValidIdentifierPassed {
    
    XCTAssertTrue([CEPPlugin isValidIdentifier:@"test.plugin-identifier"]);
}

- (void)testIsValidIdentifier_ShouldReturnNO_WhenNonNSStringPassed {
    
    XCTAssertFalse([CEPPlugin isValidIdentifier:(id)@2010]);
}

- (void)testIsValidIdentifier_ShouldReturnNO_WhenEmptyStringPassed {
    
    XCTAssertFalse([CEPPlugin isValidIdentifier:@""]);
}

- (void)testIsValidIdentifier_ShouldReturnNO_WhenNilPassed {
    
    NSString *identifier = nil;
    
    
    XCTAssertFalse([CEPPlugin isValidIdentifier:identifier]);
}


#pragma mark - Tests :: isValidObjectType

- (void)testIsValidObjectType_ShoulReturnYES_WhenOneOfKnownObjectTypesPassed {
    
    XCTAssertTrue([CEPPlugin isValidObjectType:CENObjectType.chat]);
}

- (void)testIsValidObjectType_ShoulReturnNO_WhenUnknownObjectTypesPassed {
    
    XCTAssertFalse([CEPPlugin isValidObjectType:@"test"]);
}

- (void)testIsValidObjectType_ShoulReturnNO_WhenNilObjectTypesPassed {
    
    NSString *type = nil;
    
    
    XCTAssertFalse([CEPPlugin isValidObjectType:type]);
}


#pragma mark - Tests :: isValidObject

- (void)testIsValidObject_ShoulReturnYES_WhenCENObjectInstancePassed {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    XCTAssertTrue([CEPPlugin isValidObject:user]);
}

- (void)testIsValidObject_ShoulReturnNO_WhenNonCENObjectInstancePassed {
    
    XCTAssertFalse([CEPPlugin isValidObject:(id)@"test"]);
}

- (void)testIsValidObject_ShoulReturnNO_WhenNilInstancePassed {
    
    id object = nil;
    
    
    XCTAssertFalse([CEPPlugin isValidObject:object]);
}


#pragma mark - Tests :: isValidConfiguration

- (void)testIsValidConfiguration_ShoulReturnYES_WhenNSDictionaryPassed {
    
    XCTAssertTrue([CEPPlugin isValidConfiguration:@{ @"test": @"configuration" }]);
}

- (void)testIsValidConfiguration_ShoulReturnNO_WhenNonNSDictionaryPassed {
    
    XCTAssertFalse([CEPPlugin isValidConfiguration:(id)@"test"]);
}

- (void)testIsValidConfiguration_ShoulReturnNO_WhenNilPassed {
    
    id configuration = nil;
    
    
    XCTAssertFalse([CEPPlugin isValidConfiguration:configuration]);
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
