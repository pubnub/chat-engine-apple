/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENObject+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


@interface CENObjectPluginsTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSString *defaultObjectType;
@property (nonatomic, nullable, strong) id objectClassMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENObjectPluginsTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    CEDummyPlugin.classesWithExtensions = nil;
    CEDummyPlugin.middlewareLocationClasses = nil;
    
    self.defaultObjectType = CENObjectType.search;
    self.objectClassMock = [self mockForObject:[CENObject class]];
    OCMStub([self.objectClassMock objectType]).andReturn(self.defaultObjectType);
}


#pragma mark - Tests :: plugin / hasPlugin / hasPluginWithIdentifier

- (void)testPluginHasPlugin_ShouldCheckByClass {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client hasPluginWithIdentifier:CENSearchFilterPlugin.identifier forObject:object]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        object.plugin([CENSearchFilterPlugin class]).exists();
    }];
    
    recorded = OCMExpect([self.client hasPluginWithIdentifier:CENSearchFilterPlugin.identifier forObject:object]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [object hasPlugin:[CENSearchFilterPlugin class]];
    }];
}

- (void)testPluginHasPlugin_ShouldNotCheckByClass_WhenUnsupportedClassPassed {

    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        object.plugin([NSArray class]).exists();
    }];
    
    recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [object hasPlugin:[NSArray class]];
    }];
}

- (void)testPluginHasPlugin_ShouldCheckByIdentifier {
    
    NSString *identifier = @"test-identifier";
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client hasPluginWithIdentifier:identifier forObject:object]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        object.plugin(identifier).exists();
    }];
    
    recorded = OCMExpect([self.client hasPluginWithIdentifier:identifier forObject:object]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [object hasPluginWithIdentifier:identifier];
    }];
}

- (void)testPluginHasPlugin_ShouldNotCheckByIdentifier_WhenUnsupportedIdentifierPassed {
    
    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSString *identifier = (id)@2010;

    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        object.plugin(identifier).exists();
    }];
    
    recorded = OCMExpect([[managerMock reject] hasPluginWithIdentifier:[OCMArg any] forObject:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [object hasPluginWithIdentifier:identifier];
    }];
}


#pragma mark - Tests :: plugin / registerPlugin / registerPluginWithIdentifier

- (void)testPluginRegisterPlugin_ShouldRegisterPluginByClass {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSString *identifier = CENSearchFilterPlugin.identifier;
    Class cls = [CENSearchFilterPlugin class];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client registerPlugin:cls withIdentifier:identifier configuration:[OCMArg any]
                                              forObject:object firstInList:NO completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        object.plugin(cls).store();
    }];
}

- (void)testPluginRegisterPlugin_ShouldRegisterPluginByClassWithConfiguration {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSDictionary *configuration = @{ @"plugin": @"configuration" };
    NSString *identifier = CENSearchFilterPlugin.identifier;
    Class cls = [CENSearchFilterPlugin class];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client registerPlugin:cls withIdentifier:identifier configuration:configuration
                                              forObject:object firstInList:NO completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [object registerPlugin:cls withConfiguration:configuration];
    }];
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginByClass_WhenUnsupportedClassPassed {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                              forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [object registerPlugin:[NSArray class] withConfiguration:nil];
    }];
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginByClassWithConfiguration_WhenUnsupportedClassPassed {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSDictionary *configuration = @{ @"plugin": @"configuration" };


    XCTAssertTrue([self isObjectMocked:self.client]);

    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                              forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [object registerPlugin:[NSArray class] withConfiguration:configuration];
    }];
}

- (void)testPluginRegisterPlugin_ShouldRegisterPluginByIdentifier {
    
    self.usesMockedObjects = YES;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSString *identifier = @"test-identifier";


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client registerPlugin:[OCMArg any] withIdentifier:identifier configuration:[OCMArg any]
                                              forObject:object firstInList:NO completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        object.plugin([CENSearchFilterPlugin class]).identifier(identifier).store();
    }];
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginByIdentifier_WhenUnsupportedClassPassed {
    
    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                   configuration:[OCMArg any] forObject:[OCMArg any] firstInList:NO
                                                      completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [object registerPlugin:[NSArray class] withIdentifier:@"test-identifier" configuration:nil];
    }];
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginByIdentifier_WhenUnsupportedIdentifierPassed {
    
    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any]
                                                   configuration:[OCMArg any] forObject:[OCMArg any] firstInList:NO
                                                      completion:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [object registerPlugin:[CENSearchFilterPlugin class] withIdentifier:(id)@2010 configuration:nil];
    }];
}


#pragma mark - Tests :: plugin / unregisterPlugin / unregisterPluginWithIdentifier

- (void)testPluginUnregisterPlugin_ShouldUnregisterPluginByClass {

    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client unregisterObjects:object pluginWithIdentifier:CENSearchFilterPlugin.identifier]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [object unregisterPlugin:[CENSearchFilterPlugin class]];
    }];
}

- (void)testPluginUnregisterPlugin_ShouldUnregisterPluginByIdentifier {

    NSString *identifier = @"test-identifier";
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client unregisterObjects:object pluginWithIdentifier:identifier]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        object.plugin(identifier).remove();
    }];
}

- (void)testPluginUnregisterPlugin_ShouldNotUnregisterPluginByClass_WhenUnsupportedClassPassed {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [object unregisterPlugin:[NSArray class]];
    }];
}

- (void)testPluginUnregisterPlugin_ShouldNotUnregisterPluginByIdentifier_WhenUnsupportedIdentifierPassed {

    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] unregisterObjects:[OCMArg any] pluginWithIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [object unregisterPluginWithIdentifier:(id)@2010];
    }];
}


#pragma mark - Tests :: extension / extensionWithContext / extensionWithIdentifier

- (void)testExtensionWithContext_ShouldRequestExtensionByClass {

    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;


    XCTAssertTrue([self isObjectMocked:self.client]);

    id objectMock = [self mockForObject:object];
    OCMStub([objectMock hasPluginWithIdentifier:[OCMArg any]]).andReturn(YES);

    id recorded = OCMExpect([self.client extensionForObject:object withIdentifier:identifier]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [object extension:[CEDummyPlugin class]];
    }];
}

- (void)testExtensionWithContext_ShouldRequestExtensionByIdentifier {

    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;


    XCTAssertTrue([self isObjectMocked:self.client]);

    id objectMock = [self mockForObject:object];
    OCMStub([objectMock hasPluginWithIdentifier:[OCMArg any]]).andReturn(YES);
    
    id recorded = OCMExpect([self.client extensionForObject:object withIdentifier:identifier]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        object.extension(identifier);
    }];
}

- (void)testExtensionWithContext_ShouldNotRequestExtensionByClass_WhenUnsupportedClassPassed {

    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect extensionForObject:[OCMArg any] withIdentifier:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded afterBlock:^{
        [object extension:[NSArray class]];
    }];
}

- (void)testExtensionWithContext_ShouldNotRequestExtensionByIdentifier_WhenUnsupportedIdentifierPassed {

    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    id managerMock = [self mockForObject:self.client.pluginsManager];
    id recorded = OCMExpect([[managerMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        object.extension((id)@2010);
    }];
}

- (void)testExtensionWithContext_ShouldRequestExtensionByClassAndReturnNil_WhenUnsupportedClassPassed {

    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        CEDummyExtension *extension = [object extension:[NSArray class]];
        
        XCTAssertNil(extension);
        handler();
    }];
}

- (void)testExtensionWithContext_ShouldRequestExtensionByIdentifierAndReturnNil_WhenUnsupportedIdentifierPassed {

    self.usesMockedObjects = NO;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        CEDummyExtension *extension = object.extension((id)@2010);
        
        XCTAssertNil(extension);
        handler();
    }];
}

#pragma mark -


@end
