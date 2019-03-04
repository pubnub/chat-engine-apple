/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Private.h>
#import "CENTestCase.h"


@interface CEPExtensionTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CEPExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldReturnMiddlewareInstance_WhenAllInformationPassed {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSDictionary *configuration = @{ @"test": @"configuration" };
    NSString *identifier = @"test";
    
    
    CEPExtension *extension = [CEPExtension extensionForObject:user withIdentifier:identifier configuration:configuration];
    
    XCTAssertNotNil(extension);
    XCTAssertEqualObjects(extension.object, user);
    XCTAssertEqualObjects(extension.identifier, identifier);
    XCTAssertEqualObjects(extension.configuration, configuration);
}

- (void)testConstructor_ShouldReturnNil_WhenNilObjectPassed {

    NSString *identifier = nil;
    CENUser *user = nil;


    XCTAssertNil([CEPExtension extensionForObject:user withIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenNonCENObjectPassed {

    NSString *identifier = nil;


    XCTAssertNil([CEPExtension extensionForObject:(id)@2010 withIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenNilIdentifierPassed {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSString *identifier = nil;


    XCTAssertNil([CEPExtension extensionForObject:user withIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenEmptyIdentifierPassed {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSString *identifier = @"";


    XCTAssertNil([CEPExtension extensionForObject:user withIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenNonNSStringPassed {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSString *identifier = (id)@2010;


    XCTAssertNil([CEPExtension extensionForObject:user withIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenNonNSDictionaryPassed {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSDictionary *configuration = (id)@2010;


    CEPExtension *extension = [CEPExtension extensionForObject:user withIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(extension);
    XCTAssertEqualObjects(extension.configuration, @{});
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenConfigurationNotPassed {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();


    CEPExtension *extension = [CEPExtension extensionForObject:user withIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(extension);
    XCTAssertEqualObjects(extension.configuration, @{});
}


#pragma mark - Tests :: Handlers

- (void)testOnCreate_ShouldHaveMethod {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();

    
    CEPExtension *extension = [CEPExtension extensionForObject:user withIdentifier:@"test" configuration:nil];
    
    
    XCTAssertNoThrow([extension onCreate]);
}

- (void)testOnDestruct_ShouldHaveMethod {

    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();

    
    CEPExtension *extension = [CEPExtension extensionForObject:user withIdentifier:@"test" configuration:nil];
    
    
    XCTAssertNoThrow([extension onDestruct]);
}

#pragma mark -


@end
