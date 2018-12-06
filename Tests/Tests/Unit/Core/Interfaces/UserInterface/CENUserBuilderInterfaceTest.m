/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENUserBuilderInterface.h>
#import <OCMock/OCMock.h>


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
    
    CENUserBuilderInterface *builder = [self builder];
    NSString *parameter = @"state";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = @{ @"PubNub": @2010 };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.state(expected);
    }];
}

- (void)testState_ShouldNotSetUserState_WhenNonNSDictionaryPassed {
    
    CENUserBuilderInterface *builder = [self builder];
    NSString *parameter = @"state";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        builder.state(expected);
    }];
}


#pragma mark - Tests :: create

- (void)testCreate_ShouldSetCreateFlag_WhenCalled {
    
    CENUserBuilderInterface *builder = [self builder];
    NSString *parameter = @"create";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.create();
    }];
}


#pragma mark - Tests :: get

- (void)testGet_ShouldSetGetFlag_WhenCalled {
    
    CENUserBuilderInterface *builder = [self builder];
    NSString *parameter = @"get";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
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
