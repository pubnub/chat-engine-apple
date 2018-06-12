/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CENTestCase.h"


@interface CENObjectTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSString *defaultObjectType;
@property (nonatomic, nullable, weak) CENChatEngine *defaultClient;
@property (nonatomic, nullable, strong) id objectClassMock;
@property (nonatomic, nullable, strong) CENObject *object;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENObjectTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    CENChatEngine *client = [self chatEngineWithConfiguration:[CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"]];
    self.defaultClient = [self partialMockForObject:client];
    
    self.defaultObjectType = @"test-object";
    self.objectClassMock = [self mockForClass:[CENObject class]];
    OCMStub([self.objectClassMock objectType]).andReturn(self.defaultObjectType);
    
    self.object = [[CENObject alloc] initWithChatEngine:self.defaultClient];
}

- (void)tearDown {
    
    [self.defaultClient destroy];
    self.defaultClient = nil;
    
    [self.object destruct];
    self.object = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.defaultClient];
    
    XCTAssertNotNil(object);
    XCTAssertNotNil(object.identifier);
    XCTAssertEqual(object.chatEngine, self.defaultClient);
}

- (void)testConstructor_ShouldThrow_WhenDesignatedInitializedNotUsed {
    
    XCTAssertThrowsSpecificNamed([CENObject new], NSException, NSInternalInconsistencyException);
}


#pragma mark - Tests :: emitEventLocally

- (void)testEmitEventLocally_ShouldEmitEventFromObjectAndChatEngineClient {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL clientHandlerCalled = NO;
    __block BOOL objectHandlerCalled = NO;
    
    [self.defaultClient handleEventOnce:@"test-event" withHandlerBlock:^(CENObject *object) {
        clientHandlerCalled = YES;
        
        XCTAssertEqual(object, self.object);
        if (objectHandlerCalled) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [self.object handleEventOnce:@"test-event" withHandlerBlock:^{
        objectHandlerCalled = YES;
        
        if (clientHandlerCalled) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [self.object emitEventLocally:@"test-event", nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(clientHandlerCalled);
    XCTAssertTrue(objectHandlerCalled);
}


#pragma mark - Tests :: onCreate

- (void)testOnCreate_ShouldEmitConstructionEvent {
    
    NSString *expectedEvent = [@[@"$.created", self.defaultObjectType] componentsJoinedByString:@"."];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL clientHandlerCalled = NO;
    __block BOOL objectHandlerCalled = NO;
    
    [self.defaultClient handleEventOnce:expectedEvent withHandlerBlock:^(CENObject *object) {
        clientHandlerCalled = YES;
        
        if (objectHandlerCalled) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [self.object handleEventOnce:expectedEvent withHandlerBlock:^{
        objectHandlerCalled = YES;
        
        if (clientHandlerCalled) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [self.object onCreate];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    XCTAssertTrue(clientHandlerCalled);
    XCTAssertTrue(objectHandlerCalled);
}


#pragma mark - Tests :: destruct

- (void)testDestruct_ShouldUnregisterObjectByClient {
    
    OCMExpect([self.defaultClient unregisterAllFromObjects:self.object]);
    
    [self.object destruct];
    
    OCMVerifyAll((id)self.defaultClient);
}


#pragma mark - Tests :: objectType

- (void)testObjectType_ShouldReturnSpecifiedValue {
    
    XCTAssertNotNil([CENObject objectType]);
    XCTAssertEqualObjects([CENObject objectType], self.defaultObjectType);
}

- (void)testObjectType_ShouldThrow_WhenSubclassDoesntHasImplementation {
    
    [self.objectClassMock stopMocking];
    self.objectClassMock = nil;
    
    XCTAssertThrowsSpecificNamed([CENObject objectType], NSException, NSInternalInconsistencyException);
}

#pragma mark -


@end
