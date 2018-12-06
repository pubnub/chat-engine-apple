/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENRandomUsernameExtension.h>
#import <CENChatEngine/CENRandomUsernamePlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUser+Interface.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENRandomUsernameExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENRandomUsernameExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


@implementation CENRandomUsernameExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.usesMockedObjects = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = self.client.currentConfiguration.namespace;
#pragma clang diagnostic pop
    
    [self stubUserAuthorization];
    [self stubChatConnection];
    
    OCMStub([self.client me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.client]);
    self.chat = [self publicChatWithChatEngine:self.client];
    
    NSMutableDictionary *configuration = [@{
        CENRandomUsernameConfiguration.propertyName: @"username"
    } mutableCopy];
    
    if ([self.name rangeOfString:@"StateChatConfigured"].location != NSNotFound) {
        configuration[CENRandomUsernameConfiguration.chat] = self.chat;
    }
    
    if ([self.name rangeOfString:@"AtKeyPath"].location != NSNotFound) {
        configuration[CENRandomUsernameConfiguration.propertyName] = @"profile.data.username";
    }
    
    self.extension = [CENRandomUsernameExtension extensionWithIdentifier:@"test" configuration:configuration];
    self.extension.object = self.client.me;
}


#pragma mark - Tests :: Constructor / Destructor

- (void)testOnCreate_ShouldAddUsernameInStateForGlobalChat_WhenStateChatNotConfigured {
    
    NSString *keyPath = self.extension.configuration[CENRandomUsernameConfiguration.propertyName];
    
    id meMock = [self mockForObject:self.client.me];
    OCMExpect([meMock updateState:[OCMArg any] forChat:nil]).andDo(^(NSInvocation *invocation) {
        NSDictionary *state = [self objectForInvocation:invocation argumentAtIndex:1];
        
        XCTAssertNotNil([state valueForKeyPath:keyPath]);
    });
    
    [self.extension onCreate];
    
    OCMVerifyAll(meMock);
}

- (void)testOnCreate_ShouldAddUsernameInStateForGlobalChat_WhenStateChatConfigured {
    
    NSString *keyPath = self.extension.configuration[CENRandomUsernameConfiguration.propertyName];
    
    id meMock = [self mockForObject:self.client.me];
    OCMExpect([meMock updateState:[OCMArg any] forChat:self.chat]).andDo(^(NSInvocation *invocation) {
        NSDictionary *state = [self objectForInvocation:invocation argumentAtIndex:1];
        
        XCTAssertNotNil([state valueForKeyPath:keyPath]);
    });
    
    [self.extension onCreate];
    
    OCMVerifyAll(meMock);
}

- (void)testOnCreate_ShouldAddUsernameAtKeyPath_WhenStateChatConfigured {
    
    NSString *keyPath = self.extension.configuration[CENRandomUsernameConfiguration.propertyName];
    
    
    id meMock = [self mockForObject:self.client.me];
    OCMStub([meMock stateForChat:self.chat]).andReturn(@{ @"profile": @{ @"firstName": @"Serhii" } });
    OCMExpect([meMock updateState:[OCMArg any] forChat:self.chat]).andDo(^(NSInvocation *invocation) {
        NSDictionary *state = [self objectForInvocation:invocation argumentAtIndex:1];
        
        XCTAssertNotNil(state[[keyPath componentsSeparatedByString:@"."].firstObject]);
        XCTAssertNotNil([state valueForKeyPath:keyPath]);
    });
    
    [self.extension onCreate];
    
    OCMVerifyAll(meMock);
}

#pragma mark -


@end
