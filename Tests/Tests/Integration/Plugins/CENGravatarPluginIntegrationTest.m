/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENGravatarPlugin.h>


#pragma mark Interface declaration

@interface CENGravatarPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENGravatarPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSDictionary *state = @{ @"email": @"test@pubnub.com", @"address": @"test2@pubnub.com" };
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"EmailSetWithCustomKey"].location != NSNotFound) {
        configuration = @{ CENGravatarPluginConfiguration.emailKey: @"address" };
    }
    
    if ([self.name rangeOfString:@"WhenEmailNotPassed"].location != NSNotFound) {
        state = @{ @"works": @YES };
    }
    
    if ([self.name rangeOfString:@"WhenUserChangeEmailAddress"].location != NSNotFound) {
        configuration = @{ CENGravatarPluginConfiguration.gravatarURLKey: @"imgURL" };
    }
    
    NSString *global = [@[@"test", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    [self setupChatEngineWithGlobal:global forUser:@"ian" synchronization:NO meta:NO state:state];
    
    [self chatEngineForUser:@"ian"].me.plugin([CENGravatarPlugin class]).configuration(configuration).store();
}


#pragma mark - Tests

- (void)testStateEvent_ShouldReceiveStateWithGravatarURL_WhenEmailSetWithDefaultKey {
    
    NSString *expected = @"https:/www.gravatar.com/avatar/b02585c8494d87b9f634eb41b17fbd28";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL hanlderCalled = NO;
    
    client.on(@"$.state", ^(CENUser *user) {
        hanlderCalled = YES;
        
        XCTAssertNotNil(user.state[@"gravatar"]);
        XCTAssertEqualObjects(user.state[@"gravatar"], expected);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(hanlderCalled);
}

- (void)testStateEvent_ShouldNotReceiveStateWithGravatarURL_WhenEmailNotPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL hanlderCalled = NO;
    
    client.on(@"$.state", ^(CENUser *user) {
        hanlderCalled = YES;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    XCTAssertFalse(hanlderCalled);
}

- (void)testStateEvent_ShouldReceiveStateWithGravatarURL_WhenEmailSetWithCustomKey {
    
    NSString *expected = @"https:/www.gravatar.com/avatar/b73daa7d238779c2dbd7dc3e0ac627d2";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client.on(@"$.state", ^(CENUser *user) {
        handlerCalled = YES;
        
        XCTAssertNotNil(user.state[@"gravatar"]);
        XCTAssertEqualObjects(user.state[@"gravatar"], expected);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testStateEvent_ShouldReceiveStateWithGravatarURL_WhenUserChangeEmailAddress {
    
    NSString *expected = @"https:/www.gravatar.com/avatar/9c0a62f30107b5ad7dbf83d97b27634f";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    __block BOOL handlerCalled = NO;
    
    client.on(@"$.state", ^(CENUser *user) {
        if (user.state[@"imgURL"] && [user.state[@"imgURL"] isEqualToString:expected]) {
            handlerCalled = YES;
            
            XCTAssertNotNil(user.state[@"imgURL"]);
            dispatch_semaphore_signal(semaphore);
        }
        
        if ([user.state[@"email"] isEqualToString:@"test@pubnub.com"]) {
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
            client.me.update(@{ @"email": @"test1@pubnub.com" });
        }
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
