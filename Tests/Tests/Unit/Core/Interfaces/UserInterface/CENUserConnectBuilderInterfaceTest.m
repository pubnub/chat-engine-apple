/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUserConnectBuilderInterface.h>
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUserConnectBuilderInterfaceTest : CENTestCase


#pragma mark - Misc

- (CENUserConnectBuilderInterface *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUserConnectBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}


#pragma mark - Tests :: state

- (void)testState_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    
    XCTAssertEqualObjects(builder.state(@{}), builder);
}

- (void)testState_ShouldSetState_WhenNSDictionaryPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_state";
    NSDictionary *expected = @{ @"test": @"state" };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.state(expected);
    }];
}

- (void)testState_ShouldNotSetState_WhenNonNSDictionaryPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_state";
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.state(expected);
    }];
}


#pragma mark - Tests :: authKey

- (void)testAuthKey_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.authKey(@"PubNub"), builder);
}

- (void)testAuthKey_ShouldSetUserAuthKey_WhenNSStringPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_authKey";
    NSString *expected = @"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.authKey(expected);
    }];
}

- (void)testAuthKey_ShouldSetUserAuthKey_WhenNSNumberPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_authKey";
    NSNumber *expected = @2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.authKey(expected);
    }];
}

- (void)testAuthKey_ShouldNotSetUserAuthKey_WhenUnsupportedTypePassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_authKey";
    NSString *expected = (id)[NSArray new];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.authKey(expected);
    }];
}


#pragma mark - Tests :: perform

- (void)testPerform_ShouldPerformWithReturnValue_WhenCalled {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock performWithReturnValue]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.perform();
    }];
}


#pragma mark - Misc

- (CENUserConnectBuilderInterface *)builder {
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    return [CENUserConnectBuilderInterface builderWithExecutionBlock:block];
}

#pragma mark -


@end
