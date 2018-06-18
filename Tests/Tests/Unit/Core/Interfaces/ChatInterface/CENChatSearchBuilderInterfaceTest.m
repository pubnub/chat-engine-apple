/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENChatSearchBuilderInterface.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatSearchBuilderInterfaceTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) CENUser *user;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatSearchBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENChatEngine *client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    self.defaultClient = [self partialMockForObject:client];
    
    OCMStub([self.defaultClient createDirectChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-direct").autoConnect(NO).create());
    OCMStub([self.defaultClient createFeedChatForUser:[OCMArg any]])
        .andReturn(self.defaultClient.Chat().name(@"user-feed").autoConnect(NO).create());

    self.user = [CENUser userWithUUID:@"tester" state:@{ } chatEngine:self.defaultClient];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [self.user destruct];
    self.user = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: event

- (void)testEvent_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.event(@"PubNub"), builder);
}

- (void)testEvent_ShouldSetSearchEvent_WhenNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = @"message";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"event"], expected);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.event(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testEvent_ShouldNotSetSearchEvent_WhenNonNSStringPassed {
    
    __block BOOL blockCalled = NO;
    NSString *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"name"]);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.event(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: sender

- (void)testSender_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.sender(self.user), builder);
}

- (void)testSender_ShouldSetSearchSender_WhenCENUserPassed {
    
    __block BOOL blockCalled = NO;
    CENUser *expected = self.user;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"sender"], expected);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.sender(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testSender_ShouldNotSetSearchSender_WhenNonCENUserPassed {
    
    __block BOOL blockCalled = NO;
    CENUser *expected = (id)@2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"sender"]);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.sender(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: limit

- (void)testLimit_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.limit(2010), builder);
}

- (void)testPrivate_ShouldSetSearchLimit_WhenCalled {
    
    __block BOOL blockCalled = NO;
    NSUInteger expected = 2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"limit"], @(expected));
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.limit(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: pages

- (void)testPages_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.pages(2010), builder);
}

- (void)testPages_ShouldSetSearchPages_WhenCalled {
    
    __block BOOL blockCalled = NO;
    NSUInteger expected = 2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"pages"], @(expected));
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.pages(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: count

- (void)testCount_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.count(2010), builder);
}

- (void)testCount_ShouldSetSearchCount_WhenCalled {
    
    __block BOOL blockCalled = NO;
    NSUInteger expected = 2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"count"], @(expected));
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.count(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}



#pragma mark - Tests :: start

- (void)testStart_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.start(@2010), builder);
}

- (void)testStart_ShouldSetSearchStart_WhenNSNumberPassed {
    
    __block BOOL blockCalled = NO;
    NSNumber *expected = @2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"start"], expected);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.start(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testStart_ShouldNotSetSearchStart_WhenNonNSNumberPassed {
    
    __block BOOL blockCalled = NO;
    NSNumber *expected = (id)@"PubNub";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"start"]);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.start(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: end

- (void)testEnd_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    XCTAssertEqualObjects(builder.end(@2010), builder);
}

- (void)testEnd_ShouldSetSearchEnd_WhenNSNumberPassed {
    
    __block BOOL blockCalled = NO;
    NSNumber *expected = @2010;
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertGreaterThan(arguments.count, 0);
        XCTAssertEqualObjects(arguments[@"end"], expected);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.end(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}

- (void)testEnd_ShouldNotSetSearchEnd_WhenNonNSNumberPassed {
    
    __block BOOL blockCalled = NO;
    NSNumber *expected = (id)@"PubNub";
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        blockCalled = YES;
        
        XCTAssertEqual(arguments.count, 0);
        XCTAssertNil(arguments[@"end"]);
        
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    builder.end(expected);
    [builder performWithReturnValue];
    
    XCTAssertTrue(blockCalled);
}


#pragma mark - Tests :: create

- (void)testCreate_ShouldPerformWithReturnValue_WhenCalled {
    
    CEInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    CENChatSearchBuilderInterface *builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    id builderPartialMock = OCMPartialMock(builder);
    OCMExpect([builderPartialMock performWithReturnValue]);
    
    builder.create();
    
    OCMVerifyAll(builderPartialMock);
    [builderPartialMock stopMocking];
}

#pragma mark -


@end
