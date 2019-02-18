/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENOnlineUserSearchExtension.h>
#import <CENChatEngine/CENOnlineUserSearchPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENOnlineUserSearchExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENOnlineUserSearchExtension *extension;
@property (nonatomic, nullable, strong) NSDictionary *users;


#pragma mark - Misc

- (void)prepareUsers;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENOnlineUserSearchExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {

    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    [self completeChatEngineConfiguration:self.client];

    XCTAssertTrue([self isObjectMocked:self.client]);

    if ([self.name rangeOfString:@"GlobalChat"].location != NSNotFound) {
        CENChat *globalChat = [self publicChatWithChatEngine:self.client];
        
        OCMStub([self.client global]).andReturn(globalChat);
    }
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    [self prepareUsers];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock users]).andReturn(self.users);
    
    NSMutableDictionary *configuration = [@{
        CENOnlineUserSearchConfiguration.propertyName: @"uuid",
        CENOnlineUserSearchConfiguration.caseSensitive: @NO
    } mutableCopy];
    
    if ([self.name rangeOfString:@"CaseSensitiveSearch"].location != NSNotFound) {
        configuration[CENOnlineUserSearchConfiguration.caseSensitive] = @YES;
    }
    
    if ([self.name rangeOfString:@"FindUsersByState"].location != NSNotFound) {
        configuration[CENOnlineUserSearchConfiguration.propertyName] = @"state.status";
    }
    
    if ([self.name rangeOfString:@"FindUsersByStateKeyPath"].location != NSNotFound) {
        configuration[CENOnlineUserSearchConfiguration.propertyName] = @"state.profile.firstName";
    }
    
    self.extension = [CENOnlineUserSearchExtension extensionForObject:chat withIdentifier:@"test" configuration:configuration];
}


#pragma mark - Tests :: usersMatching

- (void)testUsersMatching_ShouldFindUsersByUUID_WhenPartiallyMatch {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"test-u"];
    
    XCTAssertEqual(users.count, 2);
}

- (void)testUsersMatching_ShouldNotFindUsersByUUID_WhenCaseSensitiveSearchUsed {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"test-U"];
    
    XCTAssertEqual(users.count, 0);
}

- (void)testUsersMatching_ShouldFindUsersByStateForGlobalChat {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"online"];
    
    XCTAssertEqual(users.count, 1);
}

- (void)testUsersMatching_ShouldFindUsersByStateKeyPath_WhenStateChatConfigured {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"Serhii"];
    
    XCTAssertEqual(users.count, 1);
}

- (void)testUsersMatching_ShouldNotFindUsersByStateKeyPath_WhenCaseSensitiveSearchUsed {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"serhii"];
    
    XCTAssertEqual(users.count, 0);
}


#pragma mark - Tests :: search

- (void)testSearch_ShouldFindUsersByUUID_WhenPartiallyMatch {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"test-u"];
    
    XCTAssertEqual(users.count, 2);
}

- (void)testSearch_ShouldNotFindUsersByUUID_WhenCaseSensitiveSearchUsed {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"test-U"];
    
    XCTAssertEqual(users.count, 0);
}

- (void)testSearch_ShouldFindUsersByStateForGlobalChat {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"online"];
    
    XCTAssertEqual(users.count, 1);
}

- (void)testSearch_ShouldNotFindUsersByState_WhenCaseSensitiveSearchUsed {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"Online"];
    
    XCTAssertEqual(users.count, 0);
}

- (void)testSearch_ShouldFindUsersByStateKeyPath {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"Serhii"];
    
    XCTAssertEqual(users.count, 1);
}

- (void)testSearch_ShouldNotFindUsersByStateKeyPath_WhenCaseSensitiveSearchUsed {
    
    NSArray<CENUser *> *users = [self.extension usersMatchingCriteria:@"serhii"];
    
    XCTAssertEqual(users.count, 0);
}

- (void)testSearch_ShouldForwardCall {

    NSString *expected = @"something";

    
    id extensionMock = [self mockForObject:self.extension];

    id recorded = OCMExpect([extensionMock usersMatchingCriteria:expected]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.extension searchFor:expected withCompletion:^(NSArray<CENUser *> *users) { }];
#pragma GCC diagnostic pop
    }];
}



#pragma mark - Misc

- (void)prepareUsers {
    
    CENUser *user1 = [CENUser userWithUUID:@"test-user-1" state:@{} chatEngine:self.client];
    CENUser *user2 = [CENUser userWithUUID:@"test-user-2" state:@{} chatEngine:self.client];
    CENUser *user3 = [CENUser userWithUUID:@"another-user" state:@{} chatEngine:self.client];
    
    id user1Mock = [self mockForObject:user1];
    OCMStub([user1Mock stateForChat:[OCMArg any]]).andReturn(@{ @"profile": @{ @"email": @"support1@pubnub.com" } });
    id user2Mock = [self mockForObject:user2];
    OCMStub([user2Mock stateForChat:[OCMArg any]]).andReturn(@{ @"profile": @{ @"firstName": @"Serhii" } });
    id user3Mock = [self mockForObject:user3];
    OCMStub([user3Mock stateForChat:[OCMArg any]]).andReturn(@{ @"status": @"online" });
    
    self.users = @{ user1.uuid: user1Mock, user2.uuid: user2Mock, user3.uuid: user3Mock };
}

#pragma mark -


@end
