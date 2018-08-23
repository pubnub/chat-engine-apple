/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPPlugablePropertyStorage+Private.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENGravatarExtension.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENGravatarPlugin.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENEventEmitter.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"

@interface CENGravatarExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, strong) CENGravatarExtension *extension;
@property (nonatomic, nullable, strong) NSMutableDictionary *extensionStorage;

#pragma mark -


@end


@implementation CENGravatarExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.extensionStorage = [NSMutableDictionary new];
    self.extension = [CENGravatarExtension extensionWithIdentifier:@"test" configuration:nil];
    self.extension.storage = self.extensionStorage;
    
    CENConfiguration *clientConfiguration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = (CENChatEngine<PNObjectEventListener> *)[self chatEngineWithConfiguration:clientConfiguration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);
    
    OCMStub([self.clientMock connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
    
    [self.clientMock createGlobalChat];
}


#pragma mark - Tests :: Destructor

- (void)testOnCreate_ShouldSubscribeFromEvents {
    
    NSString *expectedEvent = @"$.state";
    self.extension.object = self.client.me;
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
}

- (void)testOnDestruct_ShouldUnsubscribeFromEvents {
    
    NSString *expectedEvent = @"$.state";
    self.extension.object = self.client.me;
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.eventNames containsObject:expectedEvent]);
    
    [self.extension onDestruct];
    
    XCTAssertFalse([self.client.eventNames containsObject:expectedEvent]);
}

#pragma mark -


@end
