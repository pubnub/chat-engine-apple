/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>


@interface CENInterfaceBuilderTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENInterfaceBuilderTest


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShoulThrowException_WhenInstanceCreatedWithNew {
    
    XCTAssertThrowsSpecificNamed([CENInterfaceBuilder new], NSException, NSDestinationInvalidException);
}

- (void)testConstructor_ShoulThrowException_WhenNilExecutionBlockHasBeenPassed {
    
    id executionBlock = nil;
    
    XCTAssertThrowsSpecificNamed([CENInterfaceBuilder builderWithExecutionBlock:executionBlock], NSException,
                                 NSInternalInconsistencyException);
}


#pragma mark - Tests :: setFlag

- (void)testSetFlag_ShouldSetFlag_WhenNSStringFlagPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = @"PubNub";
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(flags.count, 0);
        XCTAssertTrue([flags containsObject:expected]);
        
        return nil;
    };
    
    CENInterfaceBuilder *builder = [CENInterfaceBuilder builderWithExecutionBlock:block];
    [builder setFlag:expected];
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testSetFlag_ShouldNotSetFlag_WhenNonNSStringFlagPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(flags.count, 0);
        
        return nil;
    };
    
    CENInterfaceBuilder *builder = [CENInterfaceBuilder builderWithExecutionBlock:block];
    [builder setFlag:expected];
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: setArgument

- (void)testSetArgument_ShouldSetDataForParameter_WhenArgumentPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"PubNub"], expected);
        
        return nil;
    };
    
    CENInterfaceBuilder *builder = [CENInterfaceBuilder builderWithExecutionBlock:block];
    [builder setArgument:expected forParameter:@"PubNub"];
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testSetArgument_ShouldRemovePreviousParameterValue_WhenArgumentNotPassedOnSecondCall {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"PubNub"]);
        
        return nil;
    };
    
    CENInterfaceBuilder *builder = [CENInterfaceBuilder builderWithExecutionBlock:block];
    [builder setArgument:expected forParameter:@"PubNub"];
    [builder setArgument:nil forParameter:@"PubNub"];
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: performWithReturnValue

- (void)testPerformWithReturnValue_ShouldReturnValue_WhenCalled {
    
    NSNumber *expected = @2010;
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return expected;
    };
    
    CENInterfaceBuilder *builder = [CENInterfaceBuilder builderWithExecutionBlock:block];
    
    XCTAssertEqualObjects([builder performWithReturnValue], expected);
}


#pragma mark - Tests :: performWithBlock

- (void)testPerformWithBlock_ShouldCallBlock_WhenCompletionBlockPassed {
    
    __block BOOL blockCalled = NO;
    __block BOOL completionBlockCalled = NO;
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        dispatch_block_t completionBlock = arguments[@"block"];
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertNotNil(completionBlock);
        
        completionBlock();
        
        return nil;
    };
    
    CENInterfaceBuilder *builder = [CENInterfaceBuilder builderWithExecutionBlock:block];
    [builder performWithBlock:^{
        completionBlockCalled = YES;
    }];
    
    XCTAssertTrue(blockCalled);
    XCTAssertTrue(completionBlockCalled);
}

#pragma mark -


@end
