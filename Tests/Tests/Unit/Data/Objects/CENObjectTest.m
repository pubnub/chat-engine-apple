/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENStateRestoreAugmentationPlugin.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENObject+Plugins.h>
#import <CENChatEngine/ChatEngine.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENObjectTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) NSString *defaultObjectType;
@property (nonatomic, nullable, weak) id objectClassMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENObjectTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"testDestruct_ShouldUnregisterObjectByClient"].location != NSNotFound;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.defaultObjectType = @"test-object";
    self.objectClassMock = [self mockForObject:[CENObject class]];
    
    OCMStub([self.objectClassMock objectType]).andReturn(self.defaultObjectType);
}

- (void)tearDown {
    
    [self.objectClassMock stopMocking];
    self.objectClassMock = nil;
    
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    XCTAssertNotNil(object);
    XCTAssertNotNil(object.identifier);
    XCTAssertEqual(object.chatEngine, self.client);
}

- (void)testConstructor_ShouldThrow_WhenDesignatedInitializedNotUsed {
    
    XCTAssertThrowsSpecificNamed([CENObject new], NSException, NSInternalInconsistencyException);
}


#pragma mark - Tests :: emitEventLocally

- (void)testEmitEventLocally_ShouldEmitEventFromObjectAndChatEngineClient {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    [self object:self.client shouldHandleEvent:@"test-event" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(emittedEvent.emitter, object);
            handler();
        };
    } afterBlock:^{
        [object emitEventLocally:@"test-event", nil];
    }];
    
    [self object:object shouldHandleEvent:@"test-event" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [object emitEventLocally:@"test-event", nil];
    }];
}


#pragma mark - Tests :: onCreate

- (void)testOnCreate_ShouldEmitConstructionEvent {
    
    NSString *expectedEvent = [@[@"$.created", self.defaultObjectType] componentsJoinedByString:@"."];
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    
    
    [self object:self.client shouldHandleEvent:expectedEvent withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqual(emittedEvent.emitter, object);
            handler();
        };
    } afterBlock:^{
        [object onCreate];
    }];
    
    [self object:object shouldHandleEvent:expectedEvent withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [object onCreate];
    }];
}


#pragma mark - Tests :: destruct

- (void)testDestruct_ShouldUnregisterObjectByClient {

    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];


    XCTAssertTrue([self isObjectMocked:self.client]);

    id recorded = OCMExpect([self.client unregisterAllFromObjects:object]);
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [object destruct];
    }];
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


#pragma mark - Tests :: restoreStateForChat

- (void)testRestoreState_ShouldRegisterUserStateResolverPlugin_WhenStateRestoreCalledWithData {
    
    CENObject *object = [[CENObject alloc] initWithChatEngine:self.client];
    [object restoreStateForChat:(id)@"PubNub"];
    
    
    XCTAssertTrue(object.plugin([CENStateRestoreAugmentationPlugin class]).exists());
}

- (void)testRestoreState_ShouldNotRegisterUserStateResolverPluginTwice_WhenAlreadyCalledBefore {

    OCMStub([self.client global]).andReturn(@"PubNub");
    CENObject *object = [[CENSearch alloc] initWithChatEngine:self.client];
    
    
    id objectMock = [self mockForObject:object];
    OCMExpect([objectMock registerPlugin:[CENStateRestoreAugmentationPlugin class] withConfiguration:[OCMArg any]])
        .andForwardToRealObject();
    OCMExpect([[objectMock reject] registerPlugin:[CENStateRestoreAugmentationPlugin class] withConfiguration:[OCMArg any]]);
    
    [object restoreStateForChat:(id)@"PubNub"];
    [object restoreStateForChat:(id)@"PubNub"];
    
    OCMVerifyAll(objectMock);
}

#pragma mark -


@end
