/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENConfiguration+Private.h>
#import <CENChatEngine/CENConstants.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENConfigurationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENConfiguration *configuration;

#pragma mark -


@end


@implementation CENConfigurationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    
    self.configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
}

- (void)tearDown {
    
    [super tearDown];
    
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldSetDefaults {
    
    XCTAssertNotNil(self.configuration.publishKey);
    XCTAssertNotNil(self.configuration.subscribeKey);
    XCTAssertEqual(self.configuration.presenceHeartbeatValue, kCEDefaultPresenceHeartbeatValue);
    XCTAssertEqual(self.configuration.presenceHeartbeatInterval, kCEDefaultPresenceHeartbeatInterval);
    XCTAssertEqualObjects(self.configuration.globalChannel, kCEDefaultGlobalChannel);
    XCTAssertEqual(self.configuration.shouldSynchronizeSession, kCEDefaultShouldSynchronizeSession);
    XCTAssertNotNil(self.configuration.functionEndpoint);
    XCTAssertTrue([self.configuration.functionEndpoint hasPrefix:kCEPNFunctionsBaseURI]);
}

- (void)testNew_ShouldThrow_WhenUsed {
    
    XCTAssertThrowsSpecificNamed([CENConfiguration new], NSException, NSDestinationInvalidException);
}

- (void)testConstructor_ShouldThrow_WhenKeysNotProvided {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrowsSpecificNamed([CENConfiguration configurationWithPublishKey:nil subscribeKey:nil],
                                 NSException, NSInternalInconsistencyException);
#pragma clang diagnostic pop
}

- (void)testConstructor_ShouldThrow_WhenPublishKeyNotProvided {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrowsSpecificNamed([CENConfiguration configurationWithPublishKey:nil subscribeKey:@"test-36"],
                                 NSException, NSInternalInconsistencyException);
#pragma clang diagnostic pop
}

- (void)testConstructor_ShouldThrow_WhenSubscribeKeyNotProvided {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrowsSpecificNamed([CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:nil],
                                 NSException, NSInternalInconsistencyException);
#pragma clang diagnostic pop
}


#pragma mark - Tests :: Potocols :: NSCopying

- (void)testCopy_ShouldCreateIdenticalCopy {
    
    self.configuration.presenceHeartbeatInterval = 20.f;
    self.configuration.presenceHeartbeatValue = 60.f;
    self.configuration.functionEndpoint = @"https://pubnub.com";
    self.configuration.synchronizeSession = YES;
    self.configuration.throwExceptions = YES;
    
    CENConfiguration *configurationCopy = [self.configuration copy];
    
    XCTAssertNotNil(configurationCopy.publishKey);
    XCTAssertNotNil(configurationCopy.subscribeKey);
    XCTAssertEqualObjects(configurationCopy.functionEndpoint, self.configuration.functionEndpoint);
    XCTAssertEqual(configurationCopy.presenceHeartbeatInterval, self.configuration.presenceHeartbeatInterval);
    XCTAssertEqual(configurationCopy.presenceHeartbeatValue, self.configuration.presenceHeartbeatValue);
    XCTAssertEqual(configurationCopy.shouldSynchronizeSession, self.configuration.shouldSynchronizeSession);
    XCTAssertEqual(configurationCopy.shouldThrowExceptions, self.configuration.shouldThrowExceptions);
}


#pragma mark - Tests :: Property :: publishKey

- (void)testSetPublishKey_ShouldChange_WhenNonEmptyNSStringPassed {
    
    NSString *expected = @"tets-2010";
    
    self.configuration.publishKey = expected;
    
    XCTAssertEqualObjects(self.configuration.publishKey, expected);
}

- (void)testSetPublishKey_ShouldNotChange_WhenPassedNSMutableStringChanged {
    
    NSMutableString *publishKey = [NSMutableString stringWithString:@"test-37"];
    NSString *expected = [publishKey copy];
    
    self.configuration.publishKey = publishKey;
    [publishKey setString:@"test-38"];
    
    XCTAssertEqualObjects(self.configuration.publishKey, expected);
}

- (void)testSetPublishKey_ShouldThrow_WhenNilProvided {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrowsSpecificNamed([self.configuration setPublishKey:nil], NSException, NSDestinationInvalidException);
#pragma clang diagnostic pop
}

- (void)testSetPublishKey_ShouldThrow_WhenEmptyNSStringProvided {
    
    XCTAssertThrowsSpecificNamed([self.configuration setPublishKey:@""], NSException, NSDestinationInvalidException);
}

- (void)testSetPublishKey_ShouldThrow_WhenNonNSStringProvided {
    
    XCTAssertThrowsSpecificNamed([self.configuration setPublishKey:(id)@2010], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: Property :: subscribeKey

- (void)testSetSubscribeKey_ShouldChange_WhenNonEmptyNSStringPassed {
    
    NSString *expected = @"tets-2010";
    
    self.configuration.subscribeKey = expected;
    
    XCTAssertEqualObjects(self.configuration.subscribeKey, expected);
}

- (void)testSetSubscribeKey_ShouldNotChange_WhenPassedNSMutableStringChanged {
    
    NSMutableString *subscribeKey = [NSMutableString stringWithString:@"test-37"];
    NSString *expected = [subscribeKey copy];
    
    self.configuration.subscribeKey = subscribeKey;
    [subscribeKey setString:@"test-38"];
    
    XCTAssertEqualObjects(self.configuration.subscribeKey, expected);
}

- (void)testSetSubscribeKey_ShouldThrow_WhenNilProvided {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrowsSpecificNamed([self.configuration setSubscribeKey:nil], NSException, NSDestinationInvalidException);
#pragma clang diagnostic pop
}

- (void)testSetSubscribeKey_ShouldThrow_WhenEmptyNSStringProvided {
    
    XCTAssertThrowsSpecificNamed([self.configuration setSubscribeKey:@""], NSException, NSDestinationInvalidException);
}

- (void)testSetSubscribeKey_ShouldThrow_WhenNonNSStringProvided {
    
    XCTAssertThrowsSpecificNamed([self.configuration setSubscribeKey:(id)@2010], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: Property :: functionEndpoint

- (void)testSetFunctionEndpoint_ShouldChange_WhenNonEmptyNSStringPassed {
    
    NSString *expected = @"https://pubnub.com";
    
    self.configuration.functionEndpoint = expected;
    
    XCTAssertEqualObjects(self.configuration.functionEndpoint, expected);
}

- (void)testSetFunctionEndpoint_ShouldNotChange_WhenPassedNSMutableStringChanged {
    
    NSMutableString *functionEndpoint = [NSMutableString stringWithString:@"https://pubnub.com"];
    NSString *expected = [functionEndpoint copy];
    
    self.configuration.functionEndpoint = functionEndpoint;
    [functionEndpoint setString:@"https://admin.pubnub.com"];
    
    XCTAssertEqualObjects(self.configuration.functionEndpoint, expected);
}

- (void)testSetFunctionEndpoint_ShouldNotChange_WhenNilPassed {
    
    NSString *expected = [self.configuration.functionEndpoint copy];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    self.configuration.functionEndpoint = nil;
#pragma clang diagnostic pop
    
    XCTAssertEqualObjects(self.configuration.functionEndpoint, expected);
}

- (void)testSetFunctionEndpoint_ShouldNotChange_WhenNonNSStringPassed {
    
    NSString *expected = [self.configuration.functionEndpoint copy];
    
    self.configuration.functionEndpoint = (id)@2010;
    
    XCTAssertEqualObjects(self.configuration.functionEndpoint, expected);
}

- (void)testSetFunctionEndpoint_ShouldNotChange_WhenEmptyNSStringPassed {
    
    NSString *expected = [self.configuration.functionEndpoint copy];
    
    self.configuration.functionEndpoint = @"";
    
    XCTAssertEqualObjects(self.configuration.functionEndpoint, expected);
}


#pragma mark - Tests :: Property :: presenceHeartbeatValue


- (void)testSetPresenceHeartbeatValue_ShouldChangeHeartbeatInterval_WhenHeartbeatIntervalNotSet {
    
    NSInteger heartbeatValue = 10;
    NSInteger expected = (NSInteger)(heartbeatValue * 0.5f) - 1;
    self.configuration.presenceHeartbeatInterval = 0;
    
    self.configuration.presenceHeartbeatValue = heartbeatValue;
    
    XCTAssertEqual(self.configuration.presenceHeartbeatValue, heartbeatValue);
    XCTAssertEqual(self.configuration.presenceHeartbeatInterval, expected);
}

- (void)testSetPresenceHeartbeatValue_ShouldNotChangeHeartbeatInterval_WhenHeartbeatIntervalIsSet {
    
    NSInteger heartbeatValue = 10;
    NSInteger expected = self.configuration.presenceHeartbeatInterval;
    
    self.configuration.presenceHeartbeatValue = heartbeatValue;
    
    XCTAssertEqual(self.configuration.presenceHeartbeatValue, heartbeatValue);
    XCTAssertEqual(self.configuration.presenceHeartbeatInterval, expected);
}


#pragma mark - Tests :: pubNubConfiguration

- (void)testPubNubConfiguration_ShouldReturnPubNubClientConfiguration {

    PNConfiguration *configuraiton = [self.configuration pubNubConfiguration];
    
    XCTAssertEqual(configuraiton.presenceHeartbeatInterval, self.configuration.presenceHeartbeatInterval);
    XCTAssertEqual(configuraiton.presenceHeartbeatValue, self.configuration.presenceHeartbeatValue);
    XCTAssertEqualObjects(configuraiton.subscribeKey, self.configuration.subscribeKey);
    XCTAssertEqualObjects(configuraiton.publishKey, self.configuration.publishKey);
}

#pragma mark -


@end
