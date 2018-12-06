/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <CENChatEngine/CENPluginsBuilderInterface.h>
#import <OCMock/OCMock.h>


@interface CENPluginsBuilderInterfaceTest : CENTestCase


#pragma mark - Misc

- (CENPluginsBuilderInterface *)builder;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENPluginsBuilderInterfaceTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: identifier

- (void)testIdentifier_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.identifier(@"PubNub"), builder);
}

- (void)testIdentifier_ShouldSetPluginIdentifier_WhenNSStringPassed {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"identifier";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = @"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.identifier(expected);
    }];
}

- (void)testIdentifier_ShouldNotSetPluginIdentifier_WhenNonNSStringPassed {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"identifier";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSString *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        builder.identifier(expected);
    }];
}


#pragma mark - Tests :: configuration

- (void)testConfiguration_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.configuration(@{ }), builder);
}

- (void)testConfiguration_ShouldSetPluginConfiguration_WhenNSDictionaryPassed {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"configuration";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = @{ @"PubNub": @2010 };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.configuration(expected);
    }];
}

- (void)testConfiguration_ShouldNotSetPluginConfiguration_WhenNonNSDictionaryPassed {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"configuration";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        builder.configuration(expected);
    }];
}


#pragma mark - Tests :: store

- (void)testStore_ShouldSetStoreFlag_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"store";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.store();
    }];
}


#pragma mark - Tests :: remove

- (void)testRemove_ShouldSetRemoveFlag_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"remove";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.remove();
    }];
}


#pragma mark - Tests :: exists

- (void)testExists_ShouldSetExistsFlag_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *parameter = @"exists";
    NSString *mockedParameter = [@[@"ocmock_replaced", parameter] componentsJoinedByString:@"_"];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        builder.exists();
    }];
}


#pragma mark - Misc

- (CENPluginsBuilderInterface *)builder {
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *arguments) {
        return nil;
    };
    
    return [CENPluginsBuilderInterface builderWithExecutionBlock:block];
}

#pragma mark -


@end
