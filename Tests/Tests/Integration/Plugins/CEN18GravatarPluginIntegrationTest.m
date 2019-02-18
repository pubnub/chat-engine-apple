/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENGravatarPlugin.h>


#pragma mark Interface declaration

@interface CEN18GravatarPluginIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *configuration;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN18GravatarPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name {
    
    NSDictionary *state = nil;
    
    if ([user isEqualToString:@"ian"]) {
        state = @{ @"email": @"test@pubnub.com", @"address": @"test2@pubnub.com" };
        
        if ([self.name rangeOfString:@"WhenEmailNotPassed"].location != NSNotFound) {
            state = @{ @"works": @YES };
        }
    }
    
    return state;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"EmailSetWithCustomKey"].location != NSNotFound) {
        configuration = @{ CENGravatarPluginConfiguration.emailKey: @"address" };
    }
    
    if ([self.name rangeOfString:@"WhenUserChangeEmailAddress"].location != NSNotFound) {
        configuration = @{ CENGravatarPluginConfiguration.gravatarURLKey: @"imgURL" };
    }
    
    self.configuration = configuration;
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
}


#pragma mark - Tests

- (void)testStateEvent_ShouldReceiveStateWithGravatarURL_WhenEmailSetWithDefaultKey {
    
    NSString *expected = @"https://www.gravatar.com/avatar/b02585c8494d87b9f634eb41b17fbd28";
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            NSDictionary *state = user.state;
            
            if (state[@"gravatar"]) {
                XCTAssertEqualObjects(state[@"gravatar"], expected);
                handler();
            }
        };
    } afterBlock:^{
        client1.me.plugin([CENGravatarPlugin class]).configuration(self.configuration).store();
    }];
}

- (void)testStateEvent_ShouldNotReceiveStateWithGravatarURL_WhenEmailNotPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldNotHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.me.plugin([CENGravatarPlugin class]).configuration(self.configuration).store();
    }];
}

- (void)testStateEvent_ShouldReceiveStateWithGravatarURL_WhenEmailSetWithCustomKey {
    
    NSString *expected = @"https://www.gravatar.com/avatar/b73daa7d238779c2dbd7dc3e0ac627d2";
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            NSDictionary *state = user.state;
            
            if (state[@"gravatar"]) {
                XCTAssertEqualObjects(state[@"gravatar"], expected);
                handler();
            }
        };
    } afterBlock:^{
        client1.me.plugin([CENGravatarPlugin class]).configuration(self.configuration).store();
    }];
}

- (void)testStateEvent_ShouldReceiveStateWithGravatarURL_WhenUserChangeEmailAddress {
    
    NSString *expected = @"https://www.gravatar.com/avatar/9c0a62f30107b5ad7dbf83d97b27634f";
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            NSDictionary *state = user.state;
            
            if ([state[@"email"] isEqualToString:@"test@pubnub.com"]) {
                handler();
            }
        };
    } afterBlock:^{
        client1.me.plugin([CENGravatarPlugin class]).configuration(self.configuration).store();
    }];
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            NSDictionary *state = user.state;
            
            if (state[@"imgURL"] && [state[@"imgURL"] isEqualToString:expected]) {
                handler();
            }
        };
    } afterBlock:^{
        client1.me.update(@{ @"email": @"test1@pubnub.com" });
    }];
}

#pragma mark -


@end
