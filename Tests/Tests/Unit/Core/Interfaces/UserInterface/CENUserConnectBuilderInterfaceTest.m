/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
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
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    XCTAssertEqualObjects(builder.state(@{}), builder);
#pragma clang diagnostic pop
}

- (void)testState_ShouldNotSetState_WhenNSDictionaryPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *parameter = @"state";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = @{ @"test": @"state" };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        builder.state(expected);
#pragma clang diagnostic pop
    }];
}


#pragma mark - Tests :: authKey

- (void)testAuthKey_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.authKey(@"PubNub"), builder);
}

- (void)testAuthKey_ShouldSetUserAuthKey_WhenNSStringPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *parameter = @"authKey";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = @"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.authKey(expected);
    }];
}

- (void)testAuthKey_ShouldSetUserAuthKey_WhenNSNumberPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *parameter = @"authKey";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSNumber *expected = @2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.authKey(expected);
    }];
}

- (void)testAuthKey_ShouldNotSetUserAuthKey_WhenUnsupportedTypePassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *parameter = @"authKey";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = (id)[NSArray new];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        builder.authKey(expected);
    }];
}


#pragma mark - Tests :: globalChannel

- (void)testGlobalChannel_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.globalChannel(@"chatEngine"), builder);
}

- (void)testGlobalChannel_ShouldSetGlobalChatName_WhenNSStringPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *parameter = @"globalChannel";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = @"chatEngine";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.globalChannel(expected);
    }];
}

- (void)testGlobalChannel_ShouldNotSetGlobalChatName_WhenNonNSStringPassed {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    NSString *parameter = @"globalChannel";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        builder.globalChannel(expected);
    }];
}


#pragma mark - Tests :: perform

- (void)testPerform_ShouldPerformWithReturnValue_WhenCalled {
    
    CENUserConnectBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock performWithReturnValue]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
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
