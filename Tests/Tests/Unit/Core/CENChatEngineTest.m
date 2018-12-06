/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENChatEngine+ConnectionInterface.h>
#import <CENChatEngine/CENChatEngine+PluginsPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChatEngine+Session.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENConstants.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENChatEngineTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldSynchronizeSessionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"SessionSynchronizationEnabled"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    id objectClassMock = [self mockForObject:[CENObject class]];
    OCMStub([objectClassMock objectType]).andReturn(CENObjectType.me);
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    XCTAssertNotNil(self.client);
    XCTAssertNotNil(self.client.temporaryObjectsManager);
    XCTAssertNil(self.client.synchronizationSession);
    XCTAssertNotNil(self.client.pubNubConfiguration);
    XCTAssertNotNil(self.client.functionClient);
    XCTAssertNotNil(self.client.pluginsManager);
    XCTAssertNotNil(self.client.chatsManager);
    XCTAssertNotNil(self.client.usersManager);
    XCTAssertFalse(self.client.isReady);
}

- (void)testConstructor_ShouldCreateSynchronizationInstance_WhenSessionSynchronizationEnabled {
    
    XCTAssertNotNil(self.client.synchronizationSession);
}

- (void)testConstructor_ShouldNotChangeConfiguration_WhenChangedPassedInstance {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.throwExceptions = NO;
    CENChatEngine *client = [self createChatEngineWithConfiguration:configuration];
    configuration.throwExceptions = YES;
    
    
    XCTAssertNotEqual(client.configuration.shouldThrowExceptions, configuration.shouldThrowExceptions);
}

- (void)testConstructor_ShouldSetupEventsDebugger {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.debugEvents = YES;
    CENChatEngine *client = [self createChatEngineWithConfiguration:configuration];
    
    
    XCTAssertTrue([client.eventNames containsObject:@"*"]);
}

- (void)testConstructor_ShouldHandleAnyEventsWhenDebugEnabled {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.debugEvents = YES;
    CENChatEngine *client = [self createChatEngineWithConfiguration:configuration];
    CENObject *object = [[CENObject alloc] initWithChatEngine:client];
    NSString *event = [NSUUID UUID].UUIDString;
    NSDictionary *data = @{ @"event": event };
    
    
    [self object:client shouldHandleEvent:@"*" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            if ([emittedEvent.event.lowercaseString isEqualToString:event.lowercaseString]) {
                XCTAssertNotNil(emittedEvent.event);
                XCTAssertNotNil(emittedEvent.emitter);
                XCTAssertNotNil(emittedEvent.data);
                XCTAssertEqualObjects(emittedEvent.emitter, object);
                XCTAssertEqualObjects(emittedEvent.data, data);
                handler();
            }
        };
    } afterBlock:^{
        [object emitEventLocally:event, data, nil];
    }];
}


#pragma mark - Tests :: storeTemporaryObject

- (void)testStoreTemporaryObject_ShouldStorePassedObject {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    id managerMock = [self mockForObject:self.client.temporaryObjectsManager];
    id recorded = OCMExpect([managerMock storeTemporaryObject:object]);
    [self waitForObject:managerMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client storeTemporaryObject:object];
    }];
}


#pragma mark - Tests :: unregisterAllFromObjects

- (void)testUnregisterAllFromObjects_ShouldRequestPluginsRemoval {
    
    self.usesMockedObjects = YES;
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client unregisterAllPluginsFromObjects:object]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.client unregisterAllFromObjects:object];
    }];
}


#pragma mark - Tests :: destroy

- (void)testDestroy_ShouldCleanUpResrcoues {
    
    self.usesMockedObjects = YES;
    [self.client currentConfiguration];
    
    
    OCMExpect([self.client destroySession]).andDo(nil);
    OCMExpect([self.client disconnectUser]).andDo(nil);
    OCMExpect([self.client destroyPubNub]).andDo(nil);
    OCMExpect([self.client destroyPlugins]).andDo(nil);
    OCMExpect([self.client destroyUsers]).andDo(nil);
    OCMExpect([self.client destroyChats]).andDo(nil);
    
    [self.client destroy];
    
    OCMVerifyAll((id)self.client);
}


#pragma mark - Tests :: currentConfiguration

- (void)testCurrentConfiguration_ShouldNotChangeClientConfguration_WhenReturnedInstanceModified {
    
    CENConfiguration *configuration = self.client.currentConfiguration;
    configuration.throwExceptions = YES;
    
    XCTAssertNotEqual(self.client.configuration.shouldThrowExceptions, configuration.shouldThrowExceptions);
}


#pragma mark - Tests :: sdkVersion

- (void)testSDKVersion_ShouldBeEqualToConstant {
    
    XCTAssertEqualObjects(CENChatEngine.sdkVersion, kCENLibraryVersion);
}


#pragma mark - Tests :: logger

- (void)testLogger_ShouldHaveConfiguredLogger {
    
    XCTAssertNotNil(self.client.logger);
}

- (void)testLogger_ShouldPrintLoggerConfiguration {
    
    self.client.logger.logLevel = CENVerboseLogLevel;
    
    id loggerMock = [self mockForObject:self.client.logger];
    id recored = OCMExpect([loggerMock log:CENInfoLogLevel message:[OCMArg any]]);
    [self waitForObject:loggerMock recordedInvocationCall:recored withinInterval:self.testCompletionDelay afterBlock:^{ }];
}

- (void)testLogger_ShouldPrintLoggerConfiguration_WhenChanged {
    
    self.client.logger.logLevel = CENVerboseLogLevel;
    
    
    id loggerMock = [self mockForObject:self.client.logger];
    id recored = OCMExpect([loggerMock log:CENInfoLogLevel message:[OCMArg any]]);
    [self waitForObject:loggerMock recordedInvocationCall:recored withinInterval:self.testCompletionDelay afterBlock:^{ }];
    
    OCMExpect([loggerMock log:CENInfoLogLevel message:[OCMArg any]]);
    [self.client.logger enableLogLevel:CENResourcesAllocationLogLevel];
    
    [self waitTask:@"waitingForChange" completionFor:self.delayedCheck];
    OCMVerifyAll(loggerMock);
}

#pragma maek -


@end
