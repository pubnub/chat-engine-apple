/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineUserStateIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineUserStateIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testState_ShouldGetPreviouslyState_WhenUserJoinChat {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client1.on(@"$.online.*", ^(NSString *event, CENChat *chat, CENUser *user) {
        CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
        
        if (!handlerCalled && [user.uuid isEqualToString:client2.me.uuid]) {
            handlerCalled = YES;
            
            XCTAssertTrue(user.state[@"works"]);
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    [self setupChatEngineWithGlobal:client1.currentConfiguration.globalChannel forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testState_ShouldGetStateUpdate_WhenUserChangeHisState {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client1.on(@"$.state", ^(CENUser *user) {
        CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
        
        if (!handlerCalled && [user.uuid isEqualToString:client2.me.uuid]) {
            handlerCalled = YES;
            
            XCTAssertNotNil(user.state[@"newParameter"]);
            XCTAssertTrue(user.state[@"newParameter"]);
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    [self setupChatEngineWithGlobal:client1.currentConfiguration.globalChannel forUser:@"stephen" synchronization:NO meta:NO state:@{ @"works": @YES }];
    [self chatEngineForUser:@"stephen"].me.update(@{ @"newParameter": @YES });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
