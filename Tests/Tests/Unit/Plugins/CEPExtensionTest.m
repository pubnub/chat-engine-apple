/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Private.h>
#import <XCTest/XCTest.h>


@interface CEPExtensionTest : XCTestCase


#pragma mark -


@end


@implementation CEPExtensionTest


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldReturnMiddlewareInstance_WhenAllInformationPassed {
    
    NSDictionary *configuration = @{ @"test": @"configuration" };
    NSString *identifier = @"test";
    
    CEPExtension *extension = [CEPExtension extensionWithIdentifier:identifier configuration:configuration];
    
    XCTAssertNotNil(extension);
    XCTAssertEqualObjects(extension.identifier, identifier);
    XCTAssertEqualObjects(extension.configuration, configuration);
}

- (void)testConstructor_ShouldReturnNil_WhenNilIdentifierPassed {
    
    NSString *identifier = nil;

    XCTAssertNil([CEPExtension extensionWithIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenEmptyIdentifierPassed {
    
    NSString *identifier = @"";

    XCTAssertNil([CEPExtension extensionWithIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldReturnNil_WhenNonNSStringPassed {
    
    NSString *identifier = (id)@2010;

    XCTAssertNil([CEPExtension extensionWithIdentifier:identifier configuration:nil]);
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenNonNSDictionaryPassed {
    
    NSDictionary *configuration = (id)@2010;

    CEPExtension *extension = [CEPExtension extensionWithIdentifier:@"test" configuration:configuration];
    
    XCTAssertNotNil(extension);
    XCTAssertEqualObjects(extension.configuration, @{});
}

- (void)testConstructor_ShouldSetEmptyDictionaryConfiguration_WhenConfigurationNotPassed {

    CEPExtension *extension = [CEPExtension extensionWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(extension);
    XCTAssertEqualObjects(extension.configuration, @{});
}

#pragma mark -


@end
