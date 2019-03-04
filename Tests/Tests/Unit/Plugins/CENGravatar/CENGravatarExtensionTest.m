/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENObject+PluginsDeveloper.h>
#import <CENChatEngine/CENGravatarExtension.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENGravatarPlugin.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENGravatarExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENGravatarExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


#pragma mark - Tsts

@implementation CENGravatarExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {

    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    XCTAssertTrue([self isObjectMocked:self.client]);

    [self completeChatEngineConfiguration:self.client];
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    OCMStub([self.client global]).andReturn(self.chat);

    OCMStub([self.client me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.client]);
    self.chat = [self publicChatWithChatEngine:self.client];
    
    NSMutableDictionary *configuration = [@{
        CENGravatarPluginConfiguration.emailKey: @"email",
        CENGravatarPluginConfiguration.gravatarURLKey: @"gravatar"
    } mutableCopy];
    
    if ([self.name rangeOfString:@"EmailAvailableForKeyPath"].location != NSNotFound) {
        configuration[CENGravatarPluginConfiguration.emailKey] = @"profile.email";
        configuration[CENGravatarPluginConfiguration.gravatarURLKey] = @"profile.images.gravatar";
    }
    
    self.extension = [CENGravatarExtension extensionForObject:self.client.me withIdentifier:@"test" configuration:configuration];
}


#pragma mark - Tests :: Constructor / Destructor

- (void)testOnCreate_ShouldSubscribeFromEvents {
    
    NSString *expectedEvent = @"$.state";
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
}

- (void)testOnCreate_ShouldProcessCurrentUserState {
    
    NSString *expectedEvent = @"$.state";
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
}

- (void)testOnCreate_ShouldUpdateGravatar_WhenStateWithDifferentEmailReceived {
    
    [self.extension onCreate];
    
    id meMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([meMock stateForChat:nil]);
    [self waitForObject:meMock recordedInvocationCall:recorded afterBlock:^{
        [self.chat emitEventLocally:@"$.state", meMock, nil];
    }];
}

- (void)testOnCreate_ShouldUpdateGravatar_WhenEmailChanged {
    
    NSDictionary *state1 = @{ @"email": @"support1@pubnub.com" };
    NSDictionary *state2 = @{ @"email": @"support2@pubnub.com" };
    NSDictionary *expected = @{
        @"email": @"support2@pubnub.com",
        @"gravatar": @"https://www.gravatar.com/avatar/b8fd827c0463bedda706b8ba2b0dbb78"
    };
    
    
    id meMock = [self mockForObject:self.client.me];
    OCMStub([(CENMe *)meMock state]).andReturn(state1);
    
    [self.extension onCreate];
    
    [meMock stopMocking];
    meMock = [self mockForObject:self.client.me];
    OCMStub([(CENMe *)meMock state]).andReturn(state2);
    
    id recorded = OCMExpect([meMock updateState:expected forChat:nil]);
    [self waitForObject:meMock recordedInvocationCall:recorded afterBlock:^{
        [self.chat emitEventLocally:@"$.state", meMock, nil];
    }];
}

- (void)testOnCreate_ShouldNotUpdateGravatar_WhenStateWithSameEmailReceived {
    
    NSDictionary *state1 = @{ @"email": @"support1@pubnub.com" };
    NSDictionary *state2 = @{ @"email": @"support1@pubnub.com" };
    NSDictionary *expected = @{
        @"email": @"support1@pubnub.com",
        @"gravatar": @"https://www.gravatar.com/avatar/145c824d9e33a1e74615da67e16e7a26"
    };
    
    
    id meMock = [self mockForObject:self.client.me];
    OCMStub([(CENMe *)meMock state]).andReturn(state1);
    
    [self.extension onCreate];
    
    [meMock stopMocking];
    meMock = [self mockForObject:self.client.me];
    OCMStub([(CENMe *)meMock state]).andReturn(state2);
    
    id recorded = OCMExpect([[meMock reject] updateState:expected forChat:nil]);
    [self waitForObject:meMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.chat emitEventLocally:@"$.state", meMock, nil];
    }];
}

- (void)testOnDestruct_ShouldUnsubscribeFromEvents {
    
    NSString *expectedEvent = @"$.state";
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onDestruct];
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
}


#pragma mark - Tests :: handleUserState

- (void)testHandleUserState_ShouldUseUserStateFromGlobalChat {
    
    OCMStub([self.client global]).andReturn([self publicChatWithChatEngine:self.client]);
    
    id meMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([(CENMe *)meMock state]);
    [self waitForObject:meMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension onCreate];
    }];
}

- (void)testHandleUserState_ShouldAddGravatarForKey_WhenEmailAvailableForKey {
    
    NSDictionary *state = @{ @"email": @"support@pubnub.com" };
    NSDictionary *expected = @{
        @"email": @"support@pubnub.com",
        @"gravatar": @"https://www.gravatar.com/avatar/145c824d9e33a1e74615da67e16e7a26"
    };
    
    
    id meMock = [self mockForObject:self.client.me];
    OCMStub([(CENMe *)meMock state]).andReturn(state);
    
    id recorded = OCMExpect([meMock updateState:expected forChat:nil]);
    [self waitForObject:meMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension onCreate];
    }];
}

- (void)testHandleUserState_ShouldAddGravatarForKeyPath_WhenEmailAvailableForKeyPath {
    
    NSDictionary *state = @{ @"profile": @{ @"email": @"support@pubnub.com" } };
    NSDictionary *expected = @{
        @"profile": @{
                @"email": @"support@pubnub.com",
                @"images": @{
                    @"gravatar": @"https://www.gravatar.com/avatar/145c824d9e33a1e74615da67e16e7a26"
                }
        }
    };
    
    
    id meMock = [self mockForObject:self.client.me];
    OCMStub([(CENMe *)meMock state]).andReturn(state);
    
    id recorded = OCMExpect([meMock updateState:expected forChat:nil]);
    [self waitForObject:meMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension onCreate];
    }];
}

#pragma mark -


@end
