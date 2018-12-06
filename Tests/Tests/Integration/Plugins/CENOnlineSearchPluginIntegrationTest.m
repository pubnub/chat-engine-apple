/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENOnlineUserSearchPlugin.h>


#pragma mark Interface declaration

@interface CENOnlineUserSearchPluginIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSString *namespace;
@property (nonatomic, strong) NSString *globalChannel;


#pragma mark - Misc

/**
 * @brief Wait when global chat of \c client will have expected number of users which is \b 3 for
 * this test case.
 *
 * @param client Reference on \b ChatEngine instance for which test should wait for all users.
 */
- (void)waitForOtherUsersWithClient:(CENChatEngine *)client;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENOnlineUserSearchPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (NSString *)globalChatChannelForTestCaseWithName:(NSString *)name {
    
    NSString *channel = [super globalChatChannelForTestCaseWithName:name];
    
    if (!self.globalChannel) {
        self.globalChannel = channel;
    }
    
    return self.globalChannel ?: channel;
}

- (NSString *)namespaceForTestCaseWithName:(NSString *)name {
    
    NSString *namespace = [super namespaceForTestCaseWithName:name];
    
    if (!self.namespace) {
        self.namespace = namespace;
    }
    
    return self.namespace ?: namespace;
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
    

    [self waitForOtherUsersWithClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [CENOnlineUserSearchPlugin search:@"stephen1" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
            XCTAssertEqual(users.count, 1);
            XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldFindUserByDefaultUUIDKey_WhenPartialCriteriaSpecified {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    
    
    [self waitForOtherUsersWithClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [CENOnlineUserSearchPlugin search:@"hen" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
            XCTAssertEqual(users.count, 2);
            XCTAssertTrue([[users valueForKey:@"uuid"] containsObject:client2.me.uuid]);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Search in state

- (void)testSearch_ShouldFindUserByFieldInState_WhenFullCriteriaSpecified {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    
    
    [self waitForOtherUsersWithClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [CENOnlineUserSearchPlugin search:@"Blum" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
            XCTAssertEqual(users.count, 1);
            XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldFindUserByFieldInState_WhenPartialCriteriaSpecified {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    
    
    [self waitForOtherUsersWithClient:client1];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [CENOnlineUserSearchPlugin search:@"bl" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
            XCTAssertEqual(users.count, 1);
            XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
            handler();
        }];
    }];
}

- (void)testSearch_ShouldNotFindUserByFieldInState_WhenCaseSensitiveCriteriaSpecifiedUsingWrongCase {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    
    
    [self waitForOtherUsersWithClient:client];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [CENOnlineUserSearchPlugin search:@"blum" inChat:client.global withCompletion:^(NSArray<CENUser *> *users) {
            XCTAssertEqual(users.count, 0);
            handler();
        }];
    }];
}


#pragma mark - Misc

- (void)waitForOtherUsersWithClient:(CENChatEngine *)client {
    
    if (client.global.users.count != 3) {
        [self object:client shouldHandleEvent:@"$.online.*" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
            return ^(CENEmittedEvent *emittedEvent) {
                if (client.global.users.count == 3) {
                    handler();
                }
            };
        } afterBlock:^{ }];
    }
}

#pragma mark -


@end
