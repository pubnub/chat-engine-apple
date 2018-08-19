/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPPlugablePropertyStorage+Private.h>
#import <CENChatEngine/CENUnreadMessagesExtension.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENUnreadMessagesPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENEventEmitter.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUnreadMessagesExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine<PNObjectEventListener> *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, strong) CENUnreadMessagesExtension *extension;
@property (nonatomic, nullable, strong) NSMutableDictionary *extensionStorage;
@property (nonatomic, nullable, strong) NSDictionary *extensionConfiguration;


#pragma mark -


@end


@implementation CENUnreadMessagesExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.extensionStorage = [NSMutableDictionary new];
    self.extensionConfiguration = @{ CENUnreadMessagesConfiguration.events: @[@"$unread-test", @"$read-test"] };
    self.extension = [CENUnreadMessagesExtension extensionWithIdentifier:@"test" configuration:self.extensionConfiguration];
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
    
    NSArray *expectedEvents = self.extensionConfiguration[CENUnreadMessagesConfiguration.events];
    self.extension.object = self.client.global;
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.global.eventNames containsObject:expectedEvents.firstObject]);
    XCTAssertTrue([self.client.global.eventNames containsObject:expectedEvents.lastObject]);
}

- (void)testOnDestruct_ShouldUnsubscribeFromEvents {
    
    NSArray *expectedEvents = self.extensionConfiguration[CENUnreadMessagesConfiguration.events];
    self.extension.object = self.client.global;
    
    [self.extension onCreate];
    
    XCTAssertTrue([self.client.global.eventNames containsObject:expectedEvents.firstObject]);
    XCTAssertTrue([self.client.global.eventNames containsObject:expectedEvents.lastObject]);
    
    [self.extension onDestruct];
    
    XCTAssertFalse([self.client.global.eventNames containsObject:expectedEvents.firstObject]);
    XCTAssertFalse([self.client.global.eventNames containsObject:expectedEvents.lastObject]);
}

#pragma mark -


@end
