/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENTemporaryObjectsManager.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENConstants.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENTemporaryObjectsManager (ProtectedTest)


#pragma mark - Information

@property (nonatomic, nullable, strong) NSMutableArray *temporaryObjects;
@property (nonatomic, nullable, strong) NSTimer *cleanUpTimer;


#pragma mark - Handlers

- (void)handleCleanUpTimer:(NSTimer *)timer;

#pragma mark -


@end


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
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.manager storeTemporaryObject:@"ChatEngine #1"];
    [self.manager storeTemporaryObject:@"ChatEngine #2"];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    XCTAssertEqual(self.manager.temporaryObjects.count, 2);
}


#pragma mark - Tests :: handleCleanUpTimer

- (void)testhandleCleanUpTimer_ShouldRemoveOutfatedObject {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSDictionary *oldObject = @{
        @"o": @"ChatEngine #1",
        @"cd": @([NSDate date].timeIntervalSince1970)
    };
    NSDictionary *freshObject = @{
        @"o": @"ChatEngine #2",
        @"cd": @([NSDate dateWithTimeIntervalSinceNow:kCEMaximumTemporaryStoreTime].timeIntervalSince1970)
    };
    self.manager.temporaryObjects = [NSMutableArray arrayWithArray:@[oldObject, freshObject]];
    [self.manager.cleanUpTimer fire];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    XCTAssertEqual(self.manager.temporaryObjects.count, 1);
}


#pragma mark - Tests :: Destructor

- (void)testDestroy_ShouldInvalidateTimer_WhenTimerStillActive {
    
    [self.manager destroy];
    
    XCTAssertNil(self.manager.cleanUpTimer);
}

- (void)testDestroy_ShouldRemoveAllTemporaryObjects {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.manager storeTemporaryObject:@"ChatEngine #1"];
    [self.manager storeTemporaryObject:@"ChatEngine #2"];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    
    [self.manager destroy];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    XCTAssertEqual(self.manager.temporaryObjects.count, 0);
}

#pragma mark -


@end
