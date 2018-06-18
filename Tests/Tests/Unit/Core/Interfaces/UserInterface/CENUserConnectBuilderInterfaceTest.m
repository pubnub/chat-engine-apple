/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENUserConnectBuilderInterface.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <OCMock/OCMock.h>


@interface CENUserConnectBuilderInterfaceTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENUserConnectBuilderInterfaceTest


#pragma mark - Tests :: state

- (void)testState_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.state(@{ }), builder);
}

- (void)testState_ShouldSetUserConnectionState_WhenNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = @{ @"PubNub": @2010 };
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"state"], expected);
        
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    builder.state(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testState_ShouldNotSetUserConnectionState_WhenNonNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"state"]);
        
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    builder.state(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: authKey

- (void)testAuthKey_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.authKey(@"PubNub"), builder);
}

- (void)testAuthKey_ShouldSetUserAuthKey_WhenNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = @"PubNub";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"authKey"], expected);
        
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    builder.authKey(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testAuthKey_ShouldNotSetUserAuthKey_WhenNonNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"authKey"]);
        
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    builder.authKey(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: perform

- (void)testPerform_ShouldPerformWithReturnValue_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENUserConnectBuilderInterface *builder = [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
    id builderPartialMock = OCMPartialMock(builder);
    OCMExpect([builderPartialMock performWithReturnValue]);
    
    builder.perform();
    
    OCMVerifyAll(builderPartialMock);
    [builderPartialMock stopMocking];
}

#pragma mark -


@end
