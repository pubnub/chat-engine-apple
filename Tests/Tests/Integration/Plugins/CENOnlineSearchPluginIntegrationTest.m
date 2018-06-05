/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENOnlineSearchPlugin.h>


#pragma mark Interface declaration

@interface CENOnlineSearchPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENOnlineSearchPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    NSMutableDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"ShouldFindUserByFieldInState"].location != NSNotFound ||
        [self.name rangeOfString:@"ShouldNotFindUserByFieldInState"].location != NSNotFound) {
        
        configuration = [NSMutableDictionary dictionaryWithDictionary:@{ CENOnlineSearchConfiguration.propertyName: @"state.lastName" }];
        
        if ([self.name rangeOfString:@"CaseSensitive"].location != NSNotFound) {
            configuration[CENOnlineSearchConfiguration.caseSensitive] = @YES;
        }
    }
    
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    [self setupChatEngineWithGlobal:global forUser:@"stephen1" synchronization:NO meta:NO state:@{ @"works": @YES }];
    [self setupChatEngineWithGlobal:global forUser:@"stephen2" synchronization:NO meta:NO state:@{ @"works": @NO, @"lastName": @"Blum" }];
    
    [self chatEngineForUser:@"ian"].global.plugin([CENOnlineSearchPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen1"].global.plugin([CENOnlineSearchPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen2"].global.plugin([CENOnlineSearchPlugin class]).configuration(configuration).store();
}


#pragma mark - Tests :: Search default

- (void)testSearch_ShouldFindUserByDefaultUUIDKey_WhenFullCriteriaSpecified {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen1"];
    __block BOOL handlerCalled = NO;
    
    // Wait for all users to connect to global chat.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    [CENOnlineSearchPlugin search:@"stephen1" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
        handlerCalled = YES;
        
        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFindUserByDefaultUUIDKey_WhenPartialCriteriaSpecified {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    __block BOOL handlerCalled = NO;
    
    // Wait for all users to connect to global chat.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    [CENOnlineSearchPlugin search:@"hen" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
        handlerCalled = YES;
        
        XCTAssertEqual(users.count, 2);
        XCTAssertTrue([[users valueForKey:@"uuid"] containsObject:client2.me.uuid]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Search in state

- (void)testSearch_ShouldFindUserByFieldInState_WhenFullCriteriaSpecified {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    __block BOOL handlerCalled = NO;
    
    // Wait for all users to connect to global chat.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    [CENOnlineSearchPlugin search:@"Blum" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
        handlerCalled = YES;
        
        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldFindUserByFieldInState_WhenPartialCriteriaSpecified {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    __block BOOL handlerCalled = NO;
    
    // Wait for all users to connect to global chat.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    [CENOnlineSearchPlugin search:@"bl" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
        handlerCalled = YES;
        
        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects(users.firstObject.uuid, client2.me.uuid);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testSearch_ShouldNotFindUserByFieldInState_WhenCaseSensitiveCriteriaSpecifiedUsingWrongCase {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen2"];
    __block BOOL handlerCalled = NO;
    
    // Wait for all users to connect to global chat.
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    
    [CENOnlineSearchPlugin search:@"blum" inChat:client1.global withCompletion:^(NSArray<CENUser *> *users) {
        handlerCalled = YES;
        
        XCTAssertEqual(users.count, 0);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
