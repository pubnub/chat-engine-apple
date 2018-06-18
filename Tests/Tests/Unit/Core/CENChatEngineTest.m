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


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, weak) id loggerClassMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.loggerClassMock = [self mockForClass:[PNLLogger class]];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.defaultClient = [self partialMockForObject:[self chatEngineWithConfiguration:configuration]];
    self.defaultClient.logger.logLevel = CENExceptionsLogLevel;
    
    id objectClassMock = [self mockForClass:[CENObject class]];
    OCMStub([objectClassMock objectType]).andReturn(CENObjectType.me);
    
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    XCTAssertNotNil(self.defaultClient);
    XCTAssertNotNil(self.defaultClient.temporaryObjectsManager);
    XCTAssertNil(self.defaultClient.synchronizationSession);
    XCTAssertNotNil(self.defaultClient.pubNubConfiguration);
    XCTAssertNotNil(self.defaultClient.functionsClient);
    XCTAssertNotNil(self.defaultClient.pluginsManager);
    XCTAssertNotNil(self.defaultClient.chatsManager);
    XCTAssertNotNil(self.defaultClient.usersManager);
    XCTAssertFalse(self.defaultClient.isReady);
}

- (void)testConstructor_ShouldCreateSynchronizationInstance_WhenRequestedByConfiguration {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.synchronizeSession = YES;
    CENChatEngine *client = [CENChatEngine clientWithConfiguration:configuration];
    
    XCTAssertNotNil(client.synchronizationSession);
}

- (void)testConstructor_ShouldNotChangeConfiguration_WhenChangedPassedInstance {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    CENChatEngine *client = [CENChatEngine clientWithConfiguration:configuration];
    configuration.throwExceptions = YES;
    
    XCTAssertNotEqual(client.configuration.shouldThrowExceptions, configuration.shouldThrowExceptions);
}


#pragma mark - Tests :: storeTemporaryObject

- (void)testStoreTemporaryObject_ShouldStorePassedObject {
    
    id managerPartialMock = [self partialMockForObject:self.defaultClient.temporaryObjectsManager];
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.defaultClient];
    
    OCMExpect([managerPartialMock storeTemporaryObject:object]).andDo(nil);
    
    [self.defaultClient storeTemporaryObject:object];
    
    OCMVerifyAll(managerPartialMock);
}


#pragma mark - Tests :: unregisterAllFromObjects

- (void)testUnregisterAllFromObjects_ShouldRequestPluginsRemoval {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.defaultClient];
    
    OCMExpect([self.defaultClient unregisterAllPluginsFromObjects:object]);
    
    [self.defaultClient unregisterAllFromObjects:object];
    
    OCMExpect((id)self.defaultClient);
}


#pragma mark - Tests :: destroy

- (void)testDestroy_ShouldCleanUpResrcoues {
    
    OCMExpect([self.defaultClient destroySession]).andDo(nil);
    OCMExpect([self.defaultClient disconnectUser]).andDo(nil);
    OCMExpect([self.defaultClient destroyPubNub]).andDo(nil);
    OCMExpect([self.defaultClient destroyPlugins]).andDo(nil);
    OCMExpect([self.defaultClient destroyUsers]).andDo(nil);
    OCMExpect([self.defaultClient destroyChats]).andDo(nil);
    
    [self.defaultClient destroy];
    
    OCMVerifyAll((id)self.defaultClient);
    [(id)self.defaultClient stopMocking];
}


#pragma mark - Tests :: currentConfiguration

- (void)testCurrentConfiguration_ShouldNotChangeClientConfguration_WhenReturnedInstanceModified {
    
    CENConfiguration *configuration = self.defaultClient.currentConfiguration;
    configuration.throwExceptions = YES;
    
    XCTAssertNotEqual(self.defaultClient.configuration.shouldThrowExceptions, configuration.shouldThrowExceptions);
}


#pragma mark - Tests :: sdkVersion

- (void)testSDKVersion_ShouldBeEqualToConstant {
    
    XCTAssertEqualObjects(CENChatEngine.sdkVersion, kCELibraryVersion);
}


#pragma mark - Tests :: logger

- (void)testLogger_ShouldHaveConfiguredLogger {
    
    XCTAssertNotNil(self.defaultClient.logger);
}

#pragma maek -


@end
