/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUsersManagerTest: CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENUsersManager *manager;


#pragma mark - Misc

- (void)threadSafeObjectData:(CENObject *)object accessWith:(dispatch_block_t)block;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUsersManagerTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"GlobalChatNotEnabled"].location == NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.manager = [CENUsersManager managerForChatEngine:self.client];

    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client usersManager]).andReturn(self.manager);
    
    if ([self shouldEnableGlobalChatForTestCaseWithName:self.name]) {
        CENChat *chat = [self publicChatWithChatEngine:self.client];
        OCMStub([self.client global]).andReturn(chat);
    }
}

- (void)tearDown {
    
    [self.manager destroy];
    self.manager = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldThrowException_WhenInstanceCreatedWithNew {
    
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

- (void)testCreateUserWithUUID_ShouldNotCreateUser_WhenUUIDIsNotNSString {
    
    NSString *uuid = (id)@2010;
    
    
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

- (void)testCreateUserWithUUID_ShouldCreateUserWithState {
    
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    NSDictionary *expectedState = @{ @"user": @"data" };
    
    
    CENUser *user = [self.manager createUserWithUUID:expectedUUID state:expectedState];
    
    XCTAssertEqualObjects(user.state, expectedState);
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
    __block CENUser *user2 = nil;
    
    
    CENUser *user1 = [self.manager createUserWithUUID:expectedUUID state:expectedState];
    
    id classMock = [self mockForObject:[CENUser class]];
    id recorded = OCMExpect([[classMock reject] userWithUUID:[OCMArg any] state:[OCMArg any] chatEngine:[OCMArg any]]);
    [self waitForObject:classMock recordedInvocationNotCall:recorded afterBlock:^{
        user2 = [self.manager createUserWithUUID:expectedUUID state:nil];
    }];
    
    XCTAssertEqual(user1, user2);
    XCTAssertEqualObjects(user1.uuid, user2.uuid);
    XCTAssertEqualObjects(user1.state, user2.state);
    XCTAssertEqualObjects(user2.state, expectedState);
    XCTAssertEqual(self.manager.users.count, expectedUsersCount);
    
}

- (void)testCreateUserWithUUID_ShouldNotSetupProtoPluginsTwiceForUser_WhenRequestedToCreateUserWithSameUUID {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    
    
    [self.manager createUserWithUUID:expectedUUID state:expectedState];
    
    id recorded = OCMExpect([[(id)self.client reject] setupProtoPluginsForObject:[OCMArg any] withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.manager createUserWithUUID:expectedUUID state:nil];
    }];
    
    OCMVerifyAll((id)self.client);
}

- (void)testCreateUserWithUUID_ShouldCreateLocalUser_WhenPassedNameAsProvidedForUUIDEngineConfiguration {
    
    NSString *expectedUUID = [[NSUUID UUID] UUIDString];
    NSDictionary *expectedState = @{};
    
    
    [self stubChatConnection];
    
    OCMStub([self.client pubNubUUID]).andReturn(expectedUUID);
    OCMStub([self.client setupProtoPluginsForObject:[OCMArg any] withCompletion:[OCMArg any]]).andDo(nil);
    
    [self.manager createUserWithUUID:expectedUUID state:nil];
    
    XCTAssertNotNil(self.manager.me);
    XCTAssertEqualObjects(self.manager.me.uuid, expectedUUID);
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self threadSafeObjectData:self.manager.me accessWith:^{
            XCTAssertEqualObjects(self.manager.me.states, expectedState);
            handler();
        }];
    }];
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
    NSString *expectedUUID = [NSUUID UUID].UUIDString;
    
    
    [self.manager createUserWithUUID:expectedUUID state:expectedState];
    CENUser *user = [self.manager userWithUUID:expectedUUID];
    
    XCTAssertNotNil(user);
    XCTAssertEqualObjects(user.uuid, expectedUUID);
    XCTAssertEqualObjects(user.state, expectedState);
}

- (void)testUserWithUUID_ShouldReturnPreviouslyCreatedLocalUser {
    
    NSDictionary *expectedState = @{ @"test": @"state" };
    NSString *expectedUUID =  [NSUUID UUID].UUIDString;
    
    
    [self stubChatConnection];
    
    OCMStub([self.client pubNubUUID]).andReturn(expectedUUID);
    
    [self.manager createUserWithUUID:expectedUUID state:expectedState];
    CENUser *user = [self.manager userWithUUID:expectedUUID];
    
    XCTAssertNotNil(user);
    XCTAssertTrue([user isKindOfClass:[CENMe class]]);
    XCTAssertEqualObjects(user.uuid, expectedUUID);
}

- (void)testUserWithUUID_ShouldReturnNil_WhenDifferentUUIDUsed {
    
    [self.manager createUserWithUUID:[NSUUID UUID].UUIDString state:nil];
    
    
    CENUser *user = [self.manager userWithUUID:[NSUUID UUID].UUIDString];
    
    XCTAssertNil(user);
}


#pragma mark - Misc

- (void)threadSafeObjectData:(CENObject *)object accessWith:(dispatch_block_t)block {
    
    dispatch_async(object.resourceAccessQueue, block);
}

#pragma mark -


@end
