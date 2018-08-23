/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTemporaryObjectsManager.h"
#import "CENConstants.h"


#pragma mark Structures

/**
 * @brief  Structure which describe keys under which temporary object data is stored.
 */
struct CETemporaryObjectDataKeys {
    
    /**
     * @brief  Stores reference on key name under which stored unixtimestamp which represent date
     *         when object should be removed from temporary storage.
     */
    __unsafe_unretained NSString *cleanUpDate;
    
    /**
     * @brief  Stores reference on key name under which temporary object is stored.
     */
    __unsafe_unretained NSString *object;
} CETemporaryObjectData = {
    .cleanUpDate = @"cd",
    .object = @"o"
};


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENTemporaryObjectsManager ()


#pragma mark - Information

@property (nonatomic, nullable, strong) NSMutableArray *temporaryObjects;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, nullable, strong) NSTimer *cleanUpTimer;


#pragma mark - Handlers

- (void)handleCleanUpTimer:(NSTimer *)timer;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation CENTemporaryObjectsManager


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    if ((self = [super init])) {
        NSString *resourceQueueIdentifier = [NSString stringWithFormat:@"com.chatengine.manager.temporary-objects.%p", self];
        _resourceAccessQueue = dispatch_queue_create([resourceQueueIdentifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _temporaryObjects = [NSMutableArray new];
        _cleanUpTimer = [NSTimer scheduledTimerWithTimeInterval:kCETemporaryStoreCleanUpInterval
                                                         target:self
                                                       selector:@selector(handleCleanUpTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
    }
    
    return self;
}


#pragma mark - Objects managment

- (void)storeTemporaryObject:(id)object {
    
    NSDictionary *objectData = @{
        CETemporaryObjectData.cleanUpDate: @([NSDate date].timeIntervalSince1970 + kCEMaximumTemporaryStoreTime),
        CETemporaryObjectData.object: object
    };
    
    dispatch_async(self.resourceAccessQueue, ^{
        [self.temporaryObjects addObject:objectData];
    });
}


#pragma mark - Handlers

- (void)handleCleanUpTimer:(__unused NSTimer *)timer {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
        NSMutableArray *oldObjects = [NSMutableArray new];
        
        [self.temporaryObjects enumerateObjectsUsingBlock:^(NSDictionary *data, __unused NSUInteger idx, __unused BOOL *stop) {
            if (((NSNumber *)data[CETemporaryObjectData.cleanUpDate]).doubleValue < currentTimestamp) {
                [oldObjects addObject:data];
            }
        }];
        
        [self.temporaryObjects removeObjectsInArray:oldObjects];
    });
}


#pragma mark - Clean up

- (void)destroy {
    
    if ([self.cleanUpTimer isValid]) {
        [self.cleanUpTimer invalidate];
    }
    
    self.cleanUpTimer = nil;
    
    dispatch_async(self.resourceAccessQueue, ^{
        [self.temporaryObjects removeAllObjects];
    });
}

#pragma mark -


@end
