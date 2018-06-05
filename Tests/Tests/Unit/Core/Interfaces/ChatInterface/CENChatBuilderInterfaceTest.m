/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENChatBuilderInterface.h>


@interface CENChatBuilderInterfaceTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatBuilderInterfaceTest


#pragma mark - Tests :: name

- (void)testName_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.name(@"PubNub"), builder);
}

- (void)testName_ShouldSetChatName_WhenNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = @"PubNub";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"name"], expected);
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.name(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testName_ShouldNotSetChatName_WhenNonNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"name"]);
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.name(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: private

- (void)testPrivate_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.private(YES), builder);
}

- (void)testPrivate_ShouldSetChatAsPrivate_WhenCalled {
    
    __block BOOL blockCalled = NO;
    BOOL expected = YES;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"private"], @(expected));
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.private(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: autoConnect

- (void)testAutoConnect_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.autoConnect(YES), builder);
}

- (void)testAutoConnect_ShouldSetChatAutoConnection_WhenCalled {
    
    __block BOOL blockCalled = NO;
    BOOL expected = NO;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"autoConnect"], @(expected));
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.autoConnect(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: meta

- (void)testMeta_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.meta(@{ }), builder);
}

- (void)testMeta_ShouldSetChatMeta_WhenNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = @{ @"PubNub": @2010 };
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"meta"], expected);
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.meta(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testMeta_ShouldNotSetChatMeta_WhenNonNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"meta"]);
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.meta(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: group

- (void)testGroup_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.group(@"PubNub"), builder);
}

- (void)testGroup_ShouldSetChatGroup_WhenNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = @"PubNub";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"group"], expected);
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.group(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testGroup_ShouldNotSetChatGroup_WhenNonNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"group"]);
        
        return nil;
    };
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.group(expected);
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
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
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
    
    CENChatBuilderInterface *builder = [CENChatBuilderInterface builderWithExecutionBlock:block];
    builder.get();
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

#pragma mark -


@end
