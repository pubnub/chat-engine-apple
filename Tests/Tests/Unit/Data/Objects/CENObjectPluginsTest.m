/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENObject+PluginsPrivate.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CEPStructures.h>
#import <CENChatEngine/ChatEngine.h>
#import "CEDummyPlugin.h"
#import "CENTestCase.h"


@interface CENObjectPluginsTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, strong) NSString *defaultObjectType;
@property (nonatomic, nullable, strong) id objectClassMock;
@property (nonatomic, nullable, strong) CENObject *object;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENObjectPluginsTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    self.clientMock = [self partialMockForObject:self.client];
    
    self.defaultObjectType = CENObjectType.search;
    self.objectClassMock = [self mockForClass:[CENObject class]];
    OCMStub([self.objectClassMock objectType]).andReturn(self.defaultObjectType);
    
    self.object = [[CENObject alloc] initWithChatEngine:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
}

- (void)tearDown {

    [self.object destruct];
    self.object = nil;
    
    CEDummyPlugin.classesWithExtensions = nil;
    CEDummyPlugin.middlewareLocationClasses = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: plugin / hasPlugin / hasPluginWithIdentifier

- (void)testPluginHasPlugin_ShouldCheckByClassAndReturnYes_WhenObjectHasRegisteredPlugin {
    
    [self.object registerPlugin:[CENSearchFilterPlugin class] withConfiguration:nil];
    
    XCTAssertTrue(self.object.plugin([CENSearchFilterPlugin class]).exists());
    XCTAssertTrue([self.object hasPlugin:[CENSearchFilterPlugin class]]);
}

- (void)testPluginHasPlugin_ShouldCheckByClassAndReturnNo_WhenUnsupportedClassPassed {
    
    [self.object registerPlugin:[CENSearchFilterPlugin class] withConfiguration:nil];
    
    XCTAssertFalse(self.object.plugin([NSArray class]).exists());
    XCTAssertFalse([self.object hasPlugin:[NSArray class]]);
}

- (void)testPluginHasPlugin_ShouldCheckByIdentifierAndReturnYes_WhenObjectHasRegisteredPlugin {
    
    NSString *identifier = CENSearchFilterPlugin.identifier;
    [self.object registerPlugin:[CENSearchFilterPlugin class] withConfiguration:nil];
    
    XCTAssertTrue(self.object.plugin(identifier).exists());
    XCTAssertTrue([self.object hasPluginWithIdentifier:identifier]);
}

- (void)testPluginHasPlugin_ShouldCheckByIdentifierAndReturnNo_WhenUnsupportedIdentifierPassed {
    
    NSString *identifier = (id)@2010;
    [self.object registerPlugin:[CENSearchFilterPlugin class] withConfiguration:nil];
    
    XCTAssertFalse(self.object.plugin(identifier).exists());
    XCTAssertFalse([self.object hasPluginWithIdentifier:identifier]);
}


#pragma mark - Tests :: plugin / registerPlugin / registerPluginWithIdentifier

- (void)testPluginRegisterPlugin_ShouldRegisterPluginWithDefaultIdentifier_WhenOnlyClassPassed {
    
    self.object.plugin([CENSearchFilterPlugin class]).store();
    
    XCTAssertTrue(self.object.plugin([CENSearchFilterPlugin class]).exists());
    XCTAssertTrue(self.object.plugin(CENSearchFilterPlugin.identifier).exists());
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginWithDefaultIdentifier_WhenUnsupportedClassPassed {
    
    OCMExpect([[(id)self.clientMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                 forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.object registerPlugin:[NSArray class] withConfiguration:nil];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testPluginRegisterPlugin_ShouldRegisterPluginWithCustomIdentifier_WhenPassedDuringRegistration {
    
    self.object.plugin([CENSearchFilterPlugin class]).identifier(@"test-identifier").store();
    
    XCTAssertTrue(self.object.plugin(@"test-identifier").exists());
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginWithCustomIdentifier_WhenUnsupportedClassPassed {
    
    OCMExpect([[(id)self.clientMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                 forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.object registerPlugin:[NSArray class] withIdentifier:@"test-identifier" configuration:nil];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testPluginRegisterPlugin_ShouldNotRegisterPluginWithCustomIdentifier_WhenUnsupportedIdentifierPassed {
    
    OCMExpect([[(id)self.clientMock reject] registerPlugin:[OCMArg any] withIdentifier:[OCMArg any] configuration:[OCMArg any]
                                                 forObject:[OCMArg any] firstInList:NO completion:[OCMArg any]]);
    
    [self.object registerPlugin:[CENSearchFilterPlugin class] withIdentifier:(id)@2010 configuration:nil];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: plugin / unregisterPlugin / unregisterPluginWithIdentifier

- (void)testPluginUnregisterPlugin_ShouldUnregisterPluginByClass {
    
    self.object.plugin([CENSearchFilterPlugin class]).store();
    XCTAssertTrue(self.object.plugin([CENSearchFilterPlugin class]).exists());
    
    [self.object unregisterPlugin:[CENSearchFilterPlugin class]];
    
    XCTAssertFalse(self.object.plugin(CENSearchFilterPlugin.identifier).exists());
}

- (void)testPluginUnregisterPlugin_ShouldUnregisterPluginByClassWithDefaultIdentifier {
    
    self.object.plugin([CENSearchFilterPlugin class]).store();
    XCTAssertTrue(self.object.plugin([CENSearchFilterPlugin class]).exists());
    
    self.object.plugin([CENSearchFilterPlugin class]).remove();
    
    XCTAssertFalse(self.object.plugin(CENSearchFilterPlugin.identifier).exists());
}

- (void)testPluginUnregisterPlugin_ShouldNotUnregisterPluginByClass_WhenUnsupportedClassPassed {
    
    self.object.plugin([CENSearchFilterPlugin class]).store();
    XCTAssertTrue(self.object.plugin([CENSearchFilterPlugin class]).exists());
    
    [self.object unregisterPlugin:[NSArray class]];
    
    XCTAssertTrue(self.object.plugin(CENSearchFilterPlugin.identifier).exists());
}

- (void)testPluginUnregisterPlugin_ShouldUnregisterPluginByIdcentifier {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENObject class]] };
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    
    self.object.plugin([CEDummyPlugin class]).identifier(@"test-identifier").store();
    XCTAssertTrue(self.object.plugin(@"test-identifier").exists());
    
    self.object.plugin(@"test-identifier").remove();
    
    XCTAssertFalse(self.object.plugin(@"test-identifier").exists());
}

- (void)testPluginUnregisterPlugin_ShouldNotUnregisterPluginByIdcentifier_WhenUnsupportedIdentifierPassed {
    
    self.object.plugin([CENSearchFilterPlugin class]).identifier(@"test-identifier").store();
    XCTAssertTrue(self.object.plugin(@"test-identifier").exists());
    
    [self.object unregisterPluginWithIdentifier:(id)@2010];
    
    XCTAssertTrue(self.object.plugin(@"test-identifier").exists());
}


#pragma mark - Tests :: extension / extensionWithContext / extensionWithIdentifier

- (void)testExtension_ShouldReturnRegisteredExtensionWithDefaultIdentifier {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    __block BOOL handlerCalled = NO;
    
    self.object.plugin([CEDummyPlugin class]).store();
    
   self.object.extension([CEDummyPlugin class], ^(CEDummyExtension *extension) {
        handlerCalled = YES;
        
        XCTAssertNotNil(extension);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testExtensionWithContext_ShouldReturnRegisteredExtensionWithDefaultIdentifier {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    __block BOOL handlerCalled = NO;
    
    self.object.plugin([CEDummyPlugin class]).store();
    
    [self.object extension:[CEDummyPlugin class] withContext:^(CEDummyExtension *extension) {
        handlerCalled = YES;
        
        XCTAssertNotNil(extension);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testExtensionWithContext_ShouldReturnNil_WhenUnsupportedClassPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    __block BOOL handlerCalled = NO;
    
    self.object.plugin([CEDummyPlugin class]).store();
    
    [self.object extension:[NSArray class] withContext:^(CEDummyExtension *extension) {
        handlerCalled = YES;
        
        XCTAssertNil(extension);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testExtensionWithContext_ShouldNotReturnNil_WhenUnsupportedClassAndNotContextBlockPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    void(^handlerBlock)(id extension) = nil;
    
    OCMExpect([[(id)self.objectClassMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    self.object.plugin([CEDummyPlugin class]).store();
    
    [self.object extension:[NSArray class] withContext:handlerBlock];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll(self.objectClassMock);
}

- (void)testExtension_ShouldReturnRegisteredExtensionWithCustomIdentifier {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    __block BOOL handlerCalled = NO;
    
    self.object.plugin([CEDummyPlugin class]).identifier(@"test-identifier").store();
    
    self.object.extension(@"test-identifier", ^(CEDummyExtension *extension) {
        handlerCalled = YES;
        
        XCTAssertNotNil(extension);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testExtensionWithIdentifier_ShouldReturnRegisteredExtensionWithCustomIdentifier {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    __block BOOL handlerCalled = NO;
    
    self.object.plugin([CEDummyPlugin class]).identifier(@"test-identifier").store();
    
    [self.object extensionWithIdentifier:@"test-identifier" context:^(CEDummyExtension *extension) {
        handlerCalled = YES;
        
        XCTAssertNotNil(extension);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testExtensionWithIdentifier_ShouldReturnNil_WhenUnsupportedIdentifierPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    __block BOOL handlerCalled = NO;
    
    self.object.plugin([CEDummyPlugin class]).store();
    
    [self.object extensionWithIdentifier:(id)@2010 context:^(CEDummyExtension *extension) {
        handlerCalled = YES;
        
        XCTAssertNil(extension);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testExtensionWithIdentifier_ShouldNotReturnNil_WhenUnsupportedIdentifierNotContextBlockPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENObject class]];
    void(^handlerBlock)(id extension) = nil;
    
    OCMExpect([[(id)self.clientMock reject] extensionForObject:[OCMArg any] withIdentifier:[OCMArg any] context:[OCMArg any]]);
    self.object.plugin([CEDummyPlugin class]).store();
    
    [self.object extensionWithIdentifier:(id)@2010 context:handlerBlock];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.falseTestCompletionDelay * NSEC_PER_SEC)));
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark -


@end
