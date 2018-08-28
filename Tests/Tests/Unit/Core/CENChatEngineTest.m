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

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;
@property (nonatomic, nullable, weak) id loggerClassMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatEngineTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    self.loggerClassMock = [self mockForClass:[PNLLogger class]];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    self.client.logger.logLevel = CENExceptionsLogLevel;
    
    id objectClassMock = [self mockForClass:[CENObject class]];
    OCMStub([objectClassMock objectType]).andReturn(CENObjectType.me);
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    XCTAssertNotNil(self.client);
    XCTAssertNotNil(self.client.temporaryObjectsManager);
    XCTAssertNil(self.client.synchronizationSession);
    XCTAssertNotNil(self.client.pubNubConfiguration);
    XCTAssertNotNil(self.client.functionsClient);
    XCTAssertNotNil(self.client.pluginsManager);
    XCTAssertNotNil(self.client.chatsManager);
    XCTAssertNotNil(self.client.usersManager);
    XCTAssertFalse(self.client.isReady);
}

- (void)testConstructor_ShouldCreateSynchronizationInstance_WhenRequestedByConfiguration {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.synchronizeSession = YES;
    CENChatEngine *client = [self chatEngineWithConfiguration:configuration];
    
    XCTAssertNotNil(client.synchronizationSession);
}

- (void)testConstructor_ShouldNotChangeConfiguration_WhenChangedPassedInstance {
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    CENChatEngine *client = [self chatEngineWithConfiguration:configuration];
    configuration.throwExceptions = YES;
    
    XCTAssertNotEqual(client.configuration.shouldThrowExceptions, configuration.shouldThrowExceptions);
}


#pragma mark - Tests :: storeTemporaryObject

- (void)testStoreTemporaryObject_ShouldStorePassedObject {
    
    id managerPartialMock = [self partialMockForObject:self.client.temporaryObjectsManager];
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    OCMExpect([managerPartialMock storeTemporaryObject:object]).andDo(nil);
    
    [self.client storeTemporaryObject:object];
    
    OCMVerifyAll(managerPartialMock);
}


#pragma mark - Tests :: unregisterAllFromObjects

- (void)testUnregisterAllFromObjects_ShouldRequestPluginsRemoval {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    OCMExpect([self.clientMock unregisterAllPluginsFromObjects:object]);
    
    [self.clientMock unregisterAllFromObjects:object];
    
    OCMExpect((id)self.clientMock);
}


#pragma mark - Tests :: destroy

- (void)testDestroy_ShouldCleanUpResrcoues {
    
    OCMExpect([self.clientMock destroySession]).andDo(nil);
    OCMExpect([self.clientMock disconnectUser]).andDo(nil);
    OCMExpect([self.clientMock destroyPubNub]).andDo(nil);
    OCMExpect([self.clientMock destroyPlugins]).andDo(nil);
    OCMExpect([self.clientMock destroyUsers]).andDo(nil);
    OCMExpect([self.clientMock destroyChats]).andDo(nil);
    
    [self.client destroy];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: currentConfiguration

- (void)testCurrentConfiguration_ShouldNotChangeClientConfguration_WhenReturnedInstanceModified {
    
    CENConfiguration *configuration = self.client.currentConfiguration;
    configuration.throwExceptions = YES;
    
    XCTAssertNotEqual(self.client.configuration.shouldThrowExceptions, configuration.shouldThrowExceptions);
}


#pragma mark - Tests :: sdkVersion

- (void)testSDKVersion_ShouldBeEqualToConstant {
    
    XCTAssertEqualObjects(CENChatEngine.sdkVersion, kCELibraryVersion);
}


#pragma mark - Tests :: logger

- (void)testLogger_ShouldHaveConfiguredLogger {
    
    XCTAssertNotNil(self.client.logger);
}

#pragma maek -


@end
