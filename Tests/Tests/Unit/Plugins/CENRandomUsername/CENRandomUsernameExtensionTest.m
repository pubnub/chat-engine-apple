/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENRandomUsernameExtension.h>
#import <CENChatEngine/CENRandomUsernamePlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENRandomUsernameExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENRandomUsernameExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENRandomUsernameExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {

    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];


    [self completeChatEngineConfiguration:self.client];

    XCTAssertTrue([self isObjectMocked:self.client]);

    [self stubUserAuthorization];
    [self stubChatConnection];
    
    OCMStub([self.client global]).andReturn(self.chat);
    
    OCMStub([self.client me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.client]);
    self.chat = [self publicChatWithChatEngine:self.client];
    
    NSMutableDictionary *configuration = [@{
        CENRandomUsernameConfiguration.propertyName: @"username"
    } mutableCopy];
    
    if ([self.name rangeOfString:@"AtKeyPath"].location != NSNotFound) {
        configuration[CENRandomUsernameConfiguration.propertyName] = @"profile.data.username";
    }
    
    self.extension = [CENRandomUsernameExtension extensionForObject:self.client.me withIdentifier:@"test"
                                                      configuration:configuration];
}


#pragma mark - Tests :: Constructor / Destructor

- (void)testOnCreate_ShouldAddUsernameInStateForGlobalChat {
    
    NSString *keyPath = self.extension.configuration[CENRandomUsernameConfiguration.propertyName];
    
    id meMock = [self mockForObject:self.client.me];
    OCMExpect([meMock updateState:[OCMArg any] forChat:nil]).andDo(^(NSInvocation *invocation) {
        NSDictionary *state = [self objectForInvocation:invocation argumentAtIndex:1];
        
        XCTAssertNotNil([state valueForKeyPath:keyPath]);
    });
    
    [self.extension onCreate];
    
    OCMVerifyAll(meMock);
}

- (void)testOnCreate_ShouldAddUsernameAtKeyPath {
    
    NSString *keyPath = self.extension.configuration[CENRandomUsernameConfiguration.propertyName];
    CENChat *expectedChat = self.client.global;
    
    
    id meMock = [self mockForObject:self.client.me];
    OCMStub([meMock stateForChat:self.chat]).andReturn(@{ @"profile": @{ @"firstName": @"Serhii" } });
    OCMExpect([meMock updateState:[OCMArg any] forChat:expectedChat]).andDo(^(NSInvocation *invocation) {
        NSDictionary *state = [self objectForInvocation:invocation argumentAtIndex:1];
        
        XCTAssertNotNil(state[[keyPath componentsSeparatedByString:@"."].firstObject]);
        XCTAssertNotNil([state valueForKeyPath:keyPath]);
    });
    
    [self.extension onCreate];
    
    OCMVerifyAll(meMock);
}

#pragma mark -


@end
