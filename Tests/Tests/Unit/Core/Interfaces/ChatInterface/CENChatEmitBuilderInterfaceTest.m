/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENChatEmitBuilderInterface.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatEmitBuilderInterfaceTest : CENTestCase


#pragma mark - Misc

- (CENChatEmitBuilderInterface *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEmitBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: data

- (void)testData_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENChatEmitBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.data(@{ }), builder);
}

- (void)testData_ShouldSetEmittedData_WhenNSDictionaryPassed {
    
    CENChatEmitBuilderInterface *builder = [self builder];
    NSString *parameter = @"data";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = @{ @"PubNub": @2010 };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.data(expected);
    }];
}

- (void)testData_ShouldNotSetEmittedData_WhenNonNSDictionaryPassed {
    
    CENChatEmitBuilderInterface *builder = [self builder];
    NSString *parameter = @"data";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        builder.data(expected);
    }];
}


#pragma mark - Tests :: perform

- (void)testPerorm_ShouldPerformWithReturnValue_WhenCalled {
    
    CENChatEmitBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock performWithReturnValue]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.perform();
    }];
}


#pragma mark - Misc

- (CENChatEmitBuilderInterface *)builder {
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    return [CENChatEmitBuilderInterface builderWithExecutionBlock:block];
}

#pragma mark -


@end
