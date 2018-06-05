/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENRandomUsernamePlugin.h>


#pragma mark Interface declaration

@interface CENRandomUsernamePluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENRandomUsernamePluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"WhenConfigurationPassed"].location != NSNotFound) {
        configuration = @{ CENRandomUsernameConfiguration.propertyName: @"innerAnimal" };
    }
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:@{ @"works": @YES }];
    
    [self chatEngineForUser:@"ian"].me.plugin([CENRandomUsernamePlugin class]).configuration(configuration).store();
}


#pragma mark - Tests

- (void)testRandomName_ShouldAssignNameToDefaultStateKey_WhenConfigurationNotPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL hanlderCalled = NO;
    
    client.on(@"$.state", ^(CENUser *user) {
        hanlderCalled = YES;
        
        XCTAssertNotNil(user.state[@"username"]);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)));
    XCTAssertTrue(hanlderCalled);
}

- (void)testRandomName_ShouldAssignNameToCustomStateKey_WhenConfigurationPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL hanlderCalled = NO;
    
    client.on(@"$.state", ^(CENUser *user) {
        hanlderCalled = YES;
        
        XCTAssertNotNil(user.state[@"innerAnimal"]);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)));
    XCTAssertTrue(hanlderCalled);
}

#pragma mark -


@end
