/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENMuterPlugin.h>
#import "CENTestCase.h"


@interface CEN14MuterPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN14MuterPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    [self chatEngineForUser:@"ian"].global.plugin([CENMuterPlugin class]).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENMuterPlugin class]).store();
}


#pragma mark - Tests :: Mute

- (void)testMuteUser_ShouldStopReceivingEvents_WhenSecondUserHasBeenMuted {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Hello #1 from ian" }).perform();
    }];
    
    [self waitForOtherUsers:2 withClient:client2];
    [CENMuterPlugin muteUser:client2.User(client1.me.uuid).get() inChat:client2.global];
    [self waitTask:@"ensureMuted" completionFor:self.delayedCheck];

    [self object:client2.global shouldNotHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Hello #2 from ian" }).perform();

    }];
}


#pragma mark - Tests :: Unmute

- (void)testUnmuteUser_ShouldStartReceivingEvents_WhenSecondUserHasBeenUnmuted {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    [self waitForOtherUsers:2 withClient:client2];
    [CENMuterPlugin muteUser:client2.User(client1.me.uuid).get() inChat:client2.global];
    [self waitTask:@"ensureMuted" completionFor:self.delayedCheck];
    
    [self object:client2.global shouldNotHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Hello #1 from ian" }).perform();
        
    }];
    
    [CENMuterPlugin unmuteUser:client2.User(client1.me.uuid).get() inChat:client2.global];
    [self waitTask:@"ensureMuted" completionFor:self.delayedCheck];
    
    [self object:client2.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Hello #2 from ian" }).perform();
    }];
}

#pragma mark -


@end
