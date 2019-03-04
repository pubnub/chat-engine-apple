/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENMuterExtension.h>
#import "CENTestCase.h"


@interface CENMuterExtension (TextExtension)


#pragma mark - Information

/**
 * @brief Set of users which has been silenced by chat local user.
 */
@property (nonatomic, strong) NSMutableSet<CENUser *> *muted;

#pragma mark -


@end


@interface CENMuterExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENMuterExtension *extension;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENMuterExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];


    CENChat *chat = [self publicChatWithChatEngine:self.client];
    self.extension = [CENMuterExtension extensionForObject:chat withIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Handler

- (void)testOnCreate_ShouldPrepareStorageForMutedUsers {
    
    [self.extension onCreate];
    
    XCTAssertNotNil(self.extension.muted);
}


#pragma mark - Tests :: muteUser

- (void)testMuteUser_ShouldAddUser_WhenCalled {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    [self.extension onCreate];
    
    
    [self.extension muteUser:user];
    XCTAssertTrue([self.extension.muted containsObject:user]);
}

- (void)testMuteUser_ShouldAddUserOnce_WhenCalledForSameUserTwice {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    [self.extension onCreate];
    
    
    [self.extension muteUser:user];
    [self.extension muteUser:user];
    XCTAssertEqual(self.extension.muted.count, 1);
}


#pragma mark - Tests :: unmuteUser

- (void)testUnmuteUser_ShouldRemovePreviouslyAddedUser_WhenCalledForSameUser {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    [self.extension onCreate];
    
    
    [self.extension muteUser:user];
    [self.extension unmuteUser:user];
    XCTAssertTrue(![self.extension.muted containsObject:user]);
}

- (void)testUnmuteUser_ShouldNotRemoveAnyUser_WhenCalledForUnknownUser {
    
    CENUser *user1 = self.client.User([NSUUID UUID].UUIDString).create();
    CENUser *user2 = self.client.User([NSUUID UUID].UUIDString).create();
    [self.extension onCreate];
    
    
    [self.extension muteUser:user1];
    [self.extension unmuteUser:user2];
    XCTAssertEqual(self.extension.muted.count, 1);
}


#pragma mark - Tests :: isMutedUser

- (void)testIsMutedUser_ShouldReturnYes_WhenCalledForPreviouslyAddedUser {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    [self.extension onCreate];
    
    
    [self.extension muteUser:user];
    XCTAssertTrue([self.extension isMutedUser:user]);
}

- (void)testIsMutedUser_ShouldReturnNo_WhenCalledForUnknownAddedUser {
    
    CENUser *user1 = self.client.User([NSUUID UUID].UUIDString).create();
    CENUser *user2 = self.client.User([NSUUID UUID].UUIDString).create();
    [self.extension onCreate];
    
    
    [self.extension muteUser:user1];
    XCTAssertFalse([self.extension isMutedUser:user2]);
}

#pragma mark -


@end
