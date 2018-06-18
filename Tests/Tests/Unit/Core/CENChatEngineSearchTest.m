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

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSearchTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());
    OCMStub([self.defaultClient me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.defaultClient]);
    
    OCMStub([self.defaultClient connectToChat:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^handleBlock)(NSDictionary *) = nil;
        
        [invocation getArgument:&handleBlock atIndex:3];
        handleBlock(nil);
    });
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: searchEventsInChat

- (void)testSearchEventsInChat_ShouldReturnSearcherInstance {
    
    CENChat *chat = self.defaultClient.Chat().autoConnect(NO).create();
    
    OCMExpect([self.defaultClient storeTemporaryObject:[OCMArg any]]);
    
    CENSearch *search = [self.defaultClient searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil];
    
    OCMVerifyAll((id)self.defaultClient);
    XCTAssertNotNil(search);
}

- (void)testSearchEventsInChat_ShouldNotReturnSearcherInstance_WhenNonCENChatInstancePassed {
    
    CENChat *chat = (id)@2010;
    
    XCTAssertNil([self.defaultClient searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil]);
}

#pragma mark -


@end
