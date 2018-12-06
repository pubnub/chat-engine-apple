/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENOnlineUserSearchExtension.h>
#import <CENChatEngine/CENOnlineUserSearchPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUser+Interface.h>
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


@implementation CENOnlineUserSearchExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
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
    
    if ([self.name rangeOfString:@"StateChatConfigured"].location != NSNotFound) {
        configuration[CENOnlineUserSearchConfiguration.chat] = [self publicChatWithChatEngine:self.client];
    }
    
    if ([self.name rangeOfString:@"FindUsersByState"].location != NSNotFound) {
        configuration[CENOnlineUserSearchConfiguration.propertyName] = @"state.status";
    }
    
    if ([self.name rangeOfString:@"FindUsersByStateKeyPath"].location != NSNotFound) {
        configuration[CENOnlineUserSearchConfiguration.propertyName] = @"state.profile.firstName";
    }
    
    self.extension = [CENOnlineUserSearchExtension extensionWithIdentifier:@"test" configuration:configuration];
    self.extension.object = chat;
}


#pragma mark - Tests :: search

- (void)testSearch_ShouldFindUsersByUUID_WhenPartiallyMatch {
    
    [self.extension searchFor:@"test-u" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 2);
    }];
}

- (void)testSearch_ShouldNotFindUsersByUUID_WhenCaseSensitiveSearchUsed {
    
    [self.extension searchFor:@"test-U" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 0);
    }];
}

- (void)testSearch_ShouldFindUsersByState_WhenStateChatConfigured {
    
    [self.extension searchFor:@"online" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 1);
    }];
}

- (void)testSearch_ShouldFindUsersByStateForGlobalChat_WhenStateChatNotConfigured {
    
    [self.extension searchFor:@"online" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 1);
    }];
}

- (void)testSearch_ShouldNotFindUsersByState_WhenStateChatConfiguredAndCaseSensitiveSearchUsed {
    
    [self.extension searchFor:@"Online" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 0);
    }];
}

- (void)testSearch_ShouldFindUsersByStateKeyPath_WhenStateChatConfigured {
    
    [self.extension searchFor:@"Serhii" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 1);
    }];
}

- (void)testSearch_ShouldFindUsersByStateKeyPath_WhenStateChatConfiguredAndCaseSensitiveSearchUsed {
    
    [self.extension searchFor:@"serhii" withCompletion:^(NSArray<CENUser *> *users) {
        XCTAssertEqual(users.count, 0);
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
