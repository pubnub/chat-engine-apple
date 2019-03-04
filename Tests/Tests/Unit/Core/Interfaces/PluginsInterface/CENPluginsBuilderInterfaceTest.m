/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENInterfaceBuilder+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


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
    NSString *mockedParameter = @"ocmock_replaced_identifier";
    NSString *expected = @"PubNub";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.identifier(expected);
    }];
}

- (void)testIdentifier_ShouldNotSetPluginIdentifier_WhenNonNSStringPassed {

    NSString *mockedParameter = @"ocmock_replaced_identifier";
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.identifier(expected);
    }];
}


#pragma mark - Tests :: configuration

- (void)testConfiguration_ShouldReturnReferenceOnBuilder_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    
    
    XCTAssertEqualObjects(builder.configuration(@{ }), builder);
}

- (void)testConfiguration_ShouldSetPluginConfiguration_WhenNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_configuration";
    CENPluginsBuilderInterface *builder = [self builder];
    NSDictionary *expected = @{ @"PubNub": @2010 };
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.configuration(expected);
    }];
}

- (void)testConfiguration_ShouldNotSetPluginConfiguration_WhenNonNSDictionaryPassed {

    NSString *mockedParameter = @"ocmock_replaced_configuration";
    CENPluginsBuilderInterface *builder = [self builder];
    NSDictionary *expected = (id)@2010;
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([[builderMock reject] setArgument:expected forParameter:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationNotCall:recorded afterBlock:^{
        builder.configuration(expected);
    }];
}


#pragma mark - Tests :: store

- (void)testStore_ShouldSetStoreFlag_WhenCalled {
    
    CENPluginsBuilderInterface *builder = [self builder];
    NSString *mockedParameter = @"ocmock_replaced_store";
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.store();
    }];
}


#pragma mark - Tests :: remove

- (void)testRemove_ShouldSetRemoveFlag_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_remove";
    CENPluginsBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
        builder.remove();
    }];
}


#pragma mark - Tests :: exists

- (void)testExists_ShouldSetExistsFlag_WhenCalled {

    NSString *mockedParameter = @"ocmock_replaced_exists";
    CENPluginsBuilderInterface *builder = [self builder];
    
    
    id builderMock = [self mockForObject:builder];
    id recorded = OCMExpect([builderMock setFlag:mockedParameter]);
    [self waitForObject:builderMock recordedInvocationCall:recorded afterBlock:^{
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
