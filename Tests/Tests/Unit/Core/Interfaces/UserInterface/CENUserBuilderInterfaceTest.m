/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUserBuilderInterfaceTest : CENTestCase


#pragma mark - Misc

- (CENUserBuilderInterface *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUserBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: state

- (void)testState_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENUserBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.state(@{ }), builder);
}

- (void)testState_ShouldSetUserState_WhenNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_state";
    CENUserBuilderInterface *builder = [self builder];
    NSDictionary *expected = @{ @"PubNub": @2010 };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.state(expected);
    }];
}

- (void)testState_ShouldNotSetUserState_WhenNonNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_state";
    CENUserBuilderInterface *builder = [self builder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.state(expected);
    }];
}


#pragma mark - Tests :: create

- (void)testCreate_ShouldSetCreateFlag_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_create";
    CENUserBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.create();
    }];
}


#pragma mark - Tests :: get

- (void)testGet_ShouldSetGetFlag_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_get";
    CENUserBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.get();
    }];
}


#pragma mark - Misc

- (CENUserBuilderInterface *)builder {
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    return [CENUserBuilderInterface builderWithExecutionBlock:block];
}

#pragma mark -


@end
