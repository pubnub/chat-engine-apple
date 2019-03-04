/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENOnlineUserSearchPlugin.h>


#pragma mark Interface declaration

@interface CEN9OnlineUserSearchPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN9OnlineUserSearchPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {
    
    NSDictionary *state = @{ @"works": @YES };
    
    if ([user isEqualToString:@"stephen2"]) {
        state = @{ @"works": @NO, @"lastName": @"Blum" };
    }
    
    return state;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSMutableDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"ShouldFindUserByFieldInState"].location != NSNotFound ||
        [self.name rangeOfString:@"ShouldNotFindUserByFieldInState"].location != NSNotFound) {
        
        configuration = [NSMutableDictionary dictionaryWithDictionary:@{ CENOnlineUserSearchConfiguration.propertyName: @"state.lastName" }];
        
        if ([self.name rangeOfString:@"CaseSensitive"].location != NSNotFound) {
            configuration[CENOnlineUserSearchConfiguration.caseSensitive] = @YES;
        }
    }
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen1"];
    [self setupChatEngineForUser:@"stephen2"];
    [self chatEngineForUser:@"ian"].global.plugin([CENOnlineUserSearchPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen1"].global.plugin([CENOnlineUserSearchPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen2"].global.plugin([CENOnlineUserSearchPlugin class]).configuration(configuration).store();
}


#pragma mark - Tests :: Search default

- (void)testSearch_ShouldFindUserByDefaultUUIDKey_WhenFullCriteriaSpecified {

    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen1"];


    [self waitForOtherUsers:3 withClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"stephen1" inChat:client1.global];

        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
        handler();
    }];
}

- (void)testSearch_ShouldFindUserByDefaultUUIDKey_WhenPartialCriteriaSpecified {

    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];


    [self waitForOtherUsers:3 withClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"hen" inChat:client1.global];

        XCTAssertEqual(users.count, 2);
        XCTAssertTrue([[users valueForKey:@"uuid"] containsObject:client2.me.uuid]);
        handler();
    }];
}


#pragma mark - Tests :: Search in state

- (void)testSearch_ShouldFindUserByFieldInState_WhenFullCriteriaSpecified {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    
    
    [self waitForOtherUsers:3 withClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"Blum" inChat:client1.global];

        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
        handler();
    }];
}

- (void)testSearch_ShouldFindUserByFieldInState_WhenPartialCriteriaSpecified {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    
    
    [self waitForOtherUsers:3 withClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"bl" inChat:client1.global];

        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
        handler();
    }];
}

- (void)testSearch_ShouldNotFindUserByFieldInState_WhenCaseSensitiveCriteriaSpecifiedUsingWrongCase {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    
    
    [self waitForOtherUsers:3 withClient:client];
    [self waitTask:@"waitForUsersListUpdate" completionFor:1.f];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"blum" inChat:client.global];

        XCTAssertEqual(users.count, 0);
        handler();
    }];
}

#pragma mark -


@end
