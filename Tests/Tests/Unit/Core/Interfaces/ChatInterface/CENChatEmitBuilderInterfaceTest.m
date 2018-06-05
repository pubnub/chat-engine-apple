/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENChatEmitBuilderInterface.h>
#import <OCMock/OCMock.h>


@interface CENChatEmitBuilderInterfaceTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEmitBuilderInterfaceTest


#pragma mark - Tests :: data

- (void)testData_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatEmitBuilderInterface *builder = [CENChatEmitBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.data(@{ }), builder);
}

- (void)testData_ShouldSetEmittedData_WhenNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = @{ @"PubNub": @2010 };
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"data"], expected);
        
        return nil;
    };
    
    CENChatEmitBuilderInterface *builder = [CENChatEmitBuilderInterface builderWithExecutionBlock:block];
    builder.data(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testData_ShouldNotSetEmittedData_WhenNonNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"data"]);
        
        return nil;
    };
    
    CENChatEmitBuilderInterface *builder = [CENChatEmitBuilderInterface builderWithExecutionBlock:block];
    builder.data(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: perform

- (void)testPerorm_ShouldPerformWithReturnValue_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatEmitBuilderInterface *builder = [CENChatEmitBuilderInterface builderWithExecutionBlock:block];
    id builderPartialMock = OCMPartialMock(builder);
    OCMExpect([builderPartialMock performWithReturnValue]);
    
    builder.perform();
    
    OCMVerifyAll(builderPartialMock);
    [builderPartialMock stopMocking];
}

#pragma mark -


@end
