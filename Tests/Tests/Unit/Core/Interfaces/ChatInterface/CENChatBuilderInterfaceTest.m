/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENChatBuilderInterface.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatBuilderInterfaceTest : CENTestCase


#pragma mark - Misc

- (CENChatBuilderInterface *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: name

- (void)testName_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.name(@"PubNub"), builder);
}

- (void)testName_ShouldSetChatName_WhenNSStringPassed {
    
    CENChatBuilderInterface *builder = [self builder];
    NSString *parameter = @"name";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = @"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.name(expected);
    }];
}

- (void)testName_ShouldNotSetChatName_WhenNonNSStringPassed {

    NSString *mockedParameter = @"ocmock_replaced_name";
    CENChatBuilderInterface *builder = [self builder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.name(expected);
    }];
}


#pragma mark - Tests :: private

- (void)testPrivate_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.private(YES), builder);
}

- (void)testPrivate_ShouldSetChatAsPrivate_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_private";
    CENChatBuilderInterface *builder = [self builder];
    BOOL expected = YES;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:@(expected) forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.private(expected);
    }];
}


#pragma mark - Tests :: autoConnect

- (void)testAutoConnect_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.autoConnect(YES), builder);
}

- (void)testAutoConnect_ShouldSetChatAutoConnection_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_autoConnect";
    CENChatBuilderInterface *builder = [self builder];
    BOOL expected = NO;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:@(expected) forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.autoConnect(expected);
    }];
}


#pragma mark - Tests :: meta

- (void)testMeta_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.meta(@{ }), builder);
}

- (void)testMeta_ShouldSetChatMeta_WhenNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_meta";
    CENChatBuilderInterface *builder = [self builder];
    NSDictionary *expected = @{ @"PubNub": @2010 };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.meta(expected);
    }];
}

- (void)testMeta_ShouldNotSetChatMeta_WhenNonNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_meta";
    CENChatBuilderInterface *builder = [self builder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.meta(expected);
    }];
}


#pragma mark - Tests :: group

- (void)testGroup_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatBuilderInterface *builder = [self builder];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertEqualObjects(builder.group(@"testGroup"), builder);
#pragma clang diagnostic pop
}

- (void)testGroup_ShouldNotSetState_WhenNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_group";
    CENChatBuilderInterface *builder = [self builder];
    NSString *expected = @"testGroup";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        builder.group(expected);
#pragma clang diagnostic pop
    }];
}


#pragma mark - Tests :: create

- (void)testCreate_ShouldSetCreateFlag_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_create";
    CENChatBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.create();
    }];
}


#pragma mark - Tests :: get

- (void)testGet_ShouldSetGetFlag_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_get";
    CENChatBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.get();
    }];
}


#pragma mark - Misc

- (CENChatBuilderInterface *)builder {
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    return [CENChatBuilderInterface builderWithExecutionBlock:block];
}

#pragma mark -


@end
