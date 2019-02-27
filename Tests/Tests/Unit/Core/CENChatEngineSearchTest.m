/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENStateRestoreAugmentationPlugin.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatEngine+Search.h>
#import <CENChatEngine/CENObject+Plugins.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatEngineSearchTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineSearchTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldNotReturnSearcherInstance"].location == NSNotFound;
}

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: searchEventsInChat

- (void)testSearchEventsInChat_ShouldReturnSearcherInstance {
    
    CENChat *chat = self.client.Chat().autoConnect(NO).create();


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client storeTemporaryObject:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        XCTAssertNotNil([self.client searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0
                                                  start:nil end:nil]);
    }];
}

- (void)testSearchEventsInChat_ShouldRegisterStateRestorePlugin {
    
    CENChat *chat = self.client.Chat().autoConnect(NO).create();
    
    
    XCTAssertTrue([self isObjectMocked:self.client]);
    OCMStub([self.client global]).andReturn(chat);
    
    CENSearch *search = [self.client searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0
                                                  start:nil end:nil];
    
    XCTAssertTrue([search hasPlugin:[CENStateRestoreAugmentationPlugin class]]);
}

- (void)testSearchEventsInChat_ShouldNotReturnSearcherInstance_WhenNonCENChatInstancePassed {
    
    CENChat *chat = (id)@2010;
    
    
    XCTAssertNil([self.client searchEventsInChat:chat sentBy:nil withName:nil limit:0 pages:0 count:0 start:nil end:nil]);
}

#pragma mark -


@end
