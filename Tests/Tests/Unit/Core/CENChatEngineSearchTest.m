/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatEngine+Search.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineSearchTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSearchTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = [self chatEngineWithConfiguration:configuration];
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
}


#pragma mark - Tests :: searchEventsInChat

- (void)testSearchEventsInChat_ShouldReturnSearcherInstance {
    
    CENChat *chat = self.clientMock.Chat().autoConnect(NO).create();
    
    OCMExpect([self.clientMock storeTemporaryObject:[OCMArg any]]);
    
    CENSearch *search = [self.clientMock searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil];
    
    OCMVerifyAll((id)self.clientMock);
    XCTAssertNotNil(search);
}

- (void)testSearchEventsInChat_ShouldNotReturnSearcherInstance_WhenNonCENChatInstancePassed {
    
    CENChat *chat = (id)@2010;
    
    XCTAssertNil([self.client searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil]);
}

#pragma mark -


@end
