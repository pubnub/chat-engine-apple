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


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSearchTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: searchEventsInChat

- (void)testSearchEventsInChat_ShouldReturnSearcherInstance {
    
    self.usesMockedObjects = YES;
    CENChat *chat = self.client.Chat().autoConnect(NO).create();
    
    
    id recorded = OCMExpect([self.client storeTemporaryObject:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        XCTAssertNotNil([self.client searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil]);
    }];
}

- (void)testSearchEventsInChat_ShouldNotReturnSearcherInstance_WhenNonCENChatInstancePassed {
    
    CENChat *chat = (id)@2010;
    
    
    XCTAssertNil([self.client searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil]);
}

#pragma mark -


@end
