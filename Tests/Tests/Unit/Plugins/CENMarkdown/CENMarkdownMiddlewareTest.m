/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENMarkdownMiddleware.h>
#import "CENTestCase.h"


@interface CENMarkdownMiddlewareTest : CENTestCase


#pragma mark -


@end


@implementation CENMarkdownMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENMarkdownMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENMarkdownMiddleware.location, CEPMiddlewareLocation.on);
}

#pragma mark -


@end
