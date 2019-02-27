/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENTemporaryObjectsManager.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENConstants.h>
#import "CENTestCase.h"


@interface CENTemporaryObjectsManager (ProtectedTest)


#pragma mark - Information

@property (nonatomic, nullable, strong) NSMutableArray *temporaryObjects;
@property (nonatomic, nullable, strong) NSTimer *cleanUpTimer;


#pragma mark - Handlers

- (void)handleCleanUpTimer:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark - Tests

@interface CENTemporaryObjectsManagerTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENTemporaryObjectsManager *manager;

#pragma mark -

@end


@implementation CENTemporaryObjectsManagerTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];

    
    self.manager = [CENTemporaryObjectsManager new];
}


#pragma mark - Tests :: storeTemporaryObject

- (void)testStoreTemporaryObject_ShouldAddObjectToStorage {
    
    [self.manager storeTemporaryObject:@"ChatEngine #1"];
    [self.manager storeTemporaryObject:@"ChatEngine #2"];
    
    
    [self waitTask:@"delayedCheck" completionFor:self.delayedCheck];
    XCTAssertEqual(self.manager.temporaryObjects.count, 2);
}


#pragma mark - Tests :: handleCleanUpTimer

- (void)testHandleCleanUpTimer_ShouldRemoveOutdatedObject {
    
    NSDictionary *oldObject = @{
        @"o": @"ChatEngine #1",
        @"cd": @([NSDate date].timeIntervalSince1970)
    };
    NSDictionary *freshObject = @{
        @"o": @"ChatEngine #2",
        @"cd": @([NSDate dateWithTimeIntervalSinceNow:kCENMaximumTemporaryStoreTime].timeIntervalSince1970)
    };
    self.manager.temporaryObjects = [NSMutableArray arrayWithArray:@[oldObject, freshObject]];
    [self.manager.cleanUpTimer fire];
    
    
    [self waitTask:@"delayedCheck" completionFor:self.delayedCheck];
    XCTAssertEqual(self.manager.temporaryObjects.count, 1);
}


#pragma mark - Tests :: Destructor

- (void)testDestroy_ShouldInvalidateTimer_WhenTimerStillActive {
    
    [self.manager destroy];
    
    
    XCTAssertNil(self.manager.cleanUpTimer);
}

- (void)testDestroy_ShouldRemoveAllTemporaryObjects {
    
    [self.manager storeTemporaryObject:@"ChatEngine #1"];
    [self.manager storeTemporaryObject:@"ChatEngine #2"];
    
    
    [self waitTask:@"delayedCheck" completionFor:self.delayedCheck];
    
    [self.manager destroy];
    
    [self waitTask:@"delayedCheck" completionFor:self.delayedCheck];
    XCTAssertEqual(self.manager.temporaryObjects.count, 0);
}

#pragma mark -


@end
