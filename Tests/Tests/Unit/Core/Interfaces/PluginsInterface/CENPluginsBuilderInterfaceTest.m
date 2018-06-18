/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENPluginsBuilderInterface.h>


@interface CENPluginsBuilderInterfaceTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENPluginsBuilderInterfaceTest


#pragma mark - Tests :: identifier

- (void)testIdentifier_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.identifier(@"PubNub"), builder);
}

- (void)testIdentifier_ShouldSetPluginIdentifier_WhenNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = @"PubNub";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"identifier"], expected);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.identifier(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testIdentifier_ShouldNotSetPluginIdentifier_WhenNonNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"identifier"]);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.identifier(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: configuration

- (void)testConfiguration_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.configuration(@{ }), builder);
}

- (void)testConfiguration_ShouldSetPluginConfiguration_WhenNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = @{ @"PubNub": @2010 };
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"configuration"], expected);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.configuration(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testConfiguration_ShouldNotSetPluginConfiguration_WhenNonNSDictionaryPassed {
    
    __block BOOL blockCalled = NO;
    NSDictionary *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"configuration"]);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.configuration(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: store

- (void)testStore_ShouldSetStoreFlag_WhenCalled {
    
    __block BOOL blockCalled = NO;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(flags.count, 0);
        XCTAssertTrue([flags containsObject:@"store"]);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.store();
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: remove

- (void)testRemove_ShouldSetRemoveFlag_WhenCalled {
    
    __block BOOL blockCalled = NO;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(flags.count, 0);
        XCTAssertTrue([flags containsObject:@"remove"]);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.remove();
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: exists

- (void)testExists_ShouldSetExistsFlag_WhenCalled {
    
    __block BOOL blockCalled = NO;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(flags.count, 0);
        XCTAssertTrue([flags containsObject:@"exists"]);
        
        return nil;
    };
    
    CENPluginsBuilderInterface *builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    builder.exists();
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

#pragma mark -


@end
