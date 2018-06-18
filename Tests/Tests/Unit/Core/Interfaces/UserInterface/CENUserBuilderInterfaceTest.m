/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENUserBuilderInterface.h>


@interface CENUserBuilderInterfaceTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENUserBuilderInterfaceTest


#pragma mark - Tests :: state

- (void)testState_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.state(@{ }), builder);
}

- (void)testState_ShouldSetUserState_WhenNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = @{ @"PubNub": @2010 };
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"state"], expected);
        
        return nil;
    };
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:block];
    builder.state(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testState_ShouldNotSetUserState_WhenNonNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"state"]);
        
        return nil;
    };
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:block];
    builder.state(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: create

- (void)testCreate_ShouldSetCreateFlag_WhenCalled {
    
    __block BOOL blockCalled = NO;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(flags.count, 0);
        XCTAssertTrue([flags containsObject:@"create"]);
        
        return nil;
    };
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:block];
    builder.create();
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: get

- (void)testGet_ShouldSetGetFlag_WhenCalled {
    
    __block BOOL blockCalled = NO;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(flags.count, 0);
        XCTAssertTrue([flags containsObject:@"get"]);
        
        return nil;
    };
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:block];
    builder.get();
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

#pragma mark -


@end
