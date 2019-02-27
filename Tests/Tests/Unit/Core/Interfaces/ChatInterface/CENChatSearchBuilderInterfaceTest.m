/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatSearchBuilderInterface.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatSearchBuilderInterfaceTest : CENTestCase


#pragma mark - Misc

- (CENChatSearchBuilderInterface *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatSearchBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: event

- (void)testEvent_ShouldReturnReferenceOnBuilder_WhenCalled {

    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.event(@"PubNub"), builder);
}

- (void)testEvent_ShouldSetSearchEvent_WhenNSStringPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_event";
    NSString *expected = @"message";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.event(expected);
    }];
}

- (void)testEvent_ShouldNotSetSearchEvent_WhenNonNSStringPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_event";
    NSString *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.event(expected);
    }];
}


#pragma mark - Tests :: sender

- (void)testSender_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.sender(user), builder);
}

- (void)testSender_ShouldSetSearchSender_WhenCENUserPassed {
    
    CENUser *expected = self.client.User([NSUUID UUID].UUIDString).create();
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_sender";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.sender(expected);
    }];
}

- (void)testSender_ShouldNotSetSearchSender_WhenNonCENUserPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_sender";
    CENUser *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.sender(expected);
    }];
}


#pragma mark - Tests :: limit

- (void)testLimit_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.limit(2010), builder);
}

- (void)testPrivate_ShouldSetSearchLimit_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_limit";
    NSUInteger expected = 2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:@(expected) forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.limit(expected);
    }];
}


#pragma mark - Tests :: pages

- (void)testPages_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.pages(2010), builder);
}

- (void)testPages_ShouldSetSearchPages_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_pages";
    NSUInteger expected = 2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:@(expected) forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.pages(expected);
    }];
}


#pragma mark - Tests :: count

- (void)testCount_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.count(2010), builder);
}

- (void)testCount_ShouldSetSearchCount_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_count";
    NSUInteger expected = 2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:@(expected) forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.count(expected);
    }];
}



#pragma mark - Tests :: start

- (void)testStart_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.start(@2010), builder);
}

- (void)testStart_ShouldSetSearchStart_WhenNSNumberPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_start";
    NSNumber *expected = @2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.start(expected);
    }];
}

- (void)testStart_ShouldNotSetSearchStart_WhenNonNSNumberPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_start";
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.start(expected);
    }];
}


#pragma mark - Tests :: end

- (void)testEnd_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.end(@2010), builder);
}

- (void)testEnd_ShouldSetSearchEnd_WhenNSNumberPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_end";
    NSNumber *expected = @2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.end(expected);
    }];
}

- (void)testEnd_ShouldNotSetSearchEnd_WhenNonNSNumberPassed {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_end";
    NSNumber *expected = (id)@"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.end(expected);
    }];
}


#pragma mark - Tests :: create

- (void)testCreate_ShouldPerformWithReturnValue_WhenCalled {
    
    CENChatSearchBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock performWithReturnValue]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.create();
    }];
}


#pragma mark - Misc

- (CENChatSearchBuilderInterface *)builder {
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    return [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
}

#pragma mark -


@end
