/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUsersManager.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUsersManagerTest: CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) CENUsersManager *manager;

#pragma mark -


@end



@implementation CENUsersManagerTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.throwExceptions = YES;
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    self.manager = [CENUsersManager managerForChatEngine:self.defaultClient];
}

- (void)tearDown {
    
    [self.manager destroy];
    self.manager = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShoulThrowException_WhenInstanceCreatedWithNew {
    
    XCTAssertThrowsSpecificNamed([CENUsersManager new], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: createUserWithUUID

- (void)testCreateUserWithUUID_ShouldCreateUserWithSpecifiedName {
    
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    NSDictionary *expectedState = @{};
    
    CENUser *user = [self.manager createUserWithUUID:expectedUUID state:nil];
    
    XCTAssertNotNil(user);
    XCTAssertNotNil(user.uuid);
    XCTAssertNotNil(user.feed);
    XCTAssertNotNil(user.direct);
    XCTAssertEqualObjects(user.uuid, expectedUUID);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testCreateUserWithUUID_ShouldNotCreateUser_WhenUUIDIsNil {
    
    NSString *uuid = nil;
    
    CENUser *user = [self.manager createUserWithUUID:uuid state:nil];
    
    XCTAssertNil(user);
}

- (void)testCreateUserWithUUID_ShouldNotCreateUser_WhenUUIDIsEmptyString {
    
    CENUser *user = [self.manager createUserWithUUID:@"" state:nil];
    
    XCTAssertNil(user);
}

- (void)testCreateUserWithUUID_ShouldNotCreateUser_WhenUUIDNotNSString {
    
    CENUser *user = [self.manager createUserWithUUID:(id)@2010 state:nil];
    
    XCTAssertNil(user);
}

- (void)testCreateUserWithUUID_ShouldCreateWithEmptyState_WhenNonNSDictionaryStatePassed {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSDictionary *expectedState = @{};
    
    CENUser *user = [self.manager createUserWithUUID:uuid state:(id)@2010];
    
    XCTAssertNotNil(user);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testCreateUserWithUUID_ShouldReturnExistingUser_WhenRequestedToCreateUserWithSameUUID {
    
    NSUInteger expectedUsersCount = 1;
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    
    CENUser *user1 = [self.manager createUserWithUUID:expectedUUID state:expectedState];
    CENUser *user2 = [self.manager createUserWithUUID:expectedUUID state:nil];
    
    XCTAssertEqual(user1, user2);
    XCTAssertEqualObjects(user1.uuid, user2.uuid);
    XCTAssertEqualObjects(user1.state, user2.state);
    XCTAssertEqualObjects(user2.state, expectedState);
    XCTAssertEqual(self.manager.users.count, expectedUsersCount);
}

- (void)testCreateUserWithUUID_ShouldNotSetupProtoPluginsTwiceForUser_WhenRequestedToCreateUserWithSameUUID {
    
    NSUInteger expectedUsersCount = 1;
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    
    
    OCMExpect([self.defaultClient setupProtoPluginsForObject:[OCMArg any] withCompletion:[OCMArg any]]);
    
    CENUser *user1 = [self.manager createUserWithUUID:expectedUUID state:expectedState];
    CENUser *user2 = [self.manager createUserWithUUID:expectedUUID state:nil];
    
    XCTAssertEqual(user1, user2);
    XCTAssertEqualObjects(user1.uuid, user2.uuid);
    XCTAssertEqualObjects(user1.state, user2.state);
    XCTAssertEqualObjects(user2.state, expectedState);
    XCTAssertEqual(self.manager.users.count, expectedUsersCount);
    OCMVerifyAll((id)self.defaultClient);
}

- (void)testCreateUserWithUUID_ShouldCreateLocalUser_WhenPassedNameAsProvidedForUUIDEngineConfiguration {
    
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    OCMStub([self.defaultClient pubNubUUID]).andReturn(expectedUUID);
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]]).andReturn(nil);
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]]).andReturn(nil);
    OCMStub([self.defaultClient setupProtoPluginsForObject:[OCMArg any] withCompletion:[OCMArg any]]).andDo(nil);
    
    [self.manager createUserWithUUID:expectedUUID state:nil];
    
    XCTAssertNotNil(self.manager.me);
    XCTAssertEqualObjects(self.manager.me.uuid, expectedUUID);
}


#pragma mark - Tests :: createUsersWithUUID

- (void)testCreateUsersWithUUID_ShouldCreateSetOfUsersWithUUIDsFromList {
    
    NSArray<NSString *> *uuids = @[@"User-1", @"User-2", @"User-3"];
    
    NSArray<CENUser *> *users = [self.manager createUsersWithUUID:uuids];
    
    XCTAssertEqual(users.count, uuids.count);
    XCTAssertEqualObjects([users valueForKey:@"uuid"], uuids);
}


#pragma mark - Tests :: userWithUUID

- (void)testUserWithUUID_ShouldReturnPreviouslyCreatedUser_WhenCalledWithSameUUID {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedUUID = @"test-user";
    
    [self.manager createUserWithUUID:expectedUUID state:expectedState];
    CENUser *user = [self.manager userWithUUID:expectedUUID];
    
    XCTAssertNotNil(user);
    XCTAssertEqualObjects(user.uuid, expectedUUID);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testUserWithUUID_ShouldReturnPreviouslyCreatedLocalUser {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedUUID =  [self.defaultClient pubNubUUID];
    
    [self.manager createUserWithUUID:expectedUUID state:expectedState];
    CENUser *user = [self.manager userWithUUID:expectedUUID];
    
    XCTAssertNotNil(user);
    XCTAssertEqualObjects(user.uuid, expectedUUID);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testUserWithUUID_ShouldReturnNil_WhenDifferentUUIDUsed {
    
    [self.manager createUserWithUUID:@"test-user1" state:nil];
    CENUser *user = [self.manager userWithUUID:@"test-user2"];
    
    XCTAssertNil(user);
}


#pragma mark -


@end
