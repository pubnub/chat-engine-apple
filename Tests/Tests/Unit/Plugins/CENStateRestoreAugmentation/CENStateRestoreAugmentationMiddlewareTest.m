/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENStateRestoreAugmentationMiddleware.h>
#import <CENChatEngine/CENStateRestoreAugmentationPlugin.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENStateRestoreAugmentationMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENStateRestoreAugmentationMiddleware *middleware;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENStateRestoreAugmentationMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldNotRestoreUserState"].location != NSNotFound;
}

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"ChatConfigured"].location != NSNotFound) {
        CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
        configuration = @{ CENStateRestoreAugmentationConfiguration.chat: chat };
    }
    self.middleware = [CENStateRestoreAugmentationMiddleware middlewareForObject:chat withIdentifier:@"test"
                                                                   configuration:configuration];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENStateRestoreAugmentationMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENStateRestoreAugmentationMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: restoreState

- (void)testRestoreState_ShouldRestoreUserStateForGlobal_WhenChatNotConfigured {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSMutableDictionary *payload = [@{
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    CENChat *expectedChat = nil;

    
    id userMock = [self mockForObject:user];
    id recorded = OCMExpect([userMock restoreStateForChat:expectedChat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSDictionary *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(@{});
    });
    
    [self waitForObject:userMock recordedInvocationCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testRestoreState_ShouldRestoreUserStateForSpecificChat_WhenChatConfigured {
    
    CENChat *expectedChat = self.middleware.configuration[CENStateRestoreAugmentationConfiguration.chat];
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    NSMutableDictionary *payload = [@{
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    
    
    id userMock = [self mockForObject:user];
    id recorded = OCMExpect([userMock restoreStateForChat:expectedChat withCompletion:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testRestoreState_ShouldNotRestoreUserStateForGlobal_WhenSenderIsMissing {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    NSMutableDictionary *payload = [@{ CENEventData.chat: chat } mutableCopy];
    
    
    id clientExpect = [(id)self.client reject];
    id recorded = OCMExpect([clientExpect fetchUserState:[OCMArg any] forChat:[OCMArg any] withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testRestoreState_ShouldNotRestoreUserStateForGlobal_WhenSenderIsNotCENUserInstance {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    NSMutableDictionary *payload = [@{
        CENEventData.chat: chat,
        CENEventData.sender: [NSUUID UUID].UUIDString
    } mutableCopy];
    
    
    id clientExpect = [(id)self.client reject];
    id recorded = OCMExpect([clientExpect fetchUserState:[OCMArg any] forChat:[OCMArg any] withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
        }];
    }];
}

#pragma mark -


@end
