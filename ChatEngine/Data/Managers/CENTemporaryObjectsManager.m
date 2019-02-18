/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENTemporaryObjectsManager.h"
#import "CENConstants.h"


#pragma mark Structures

/**
 * @brief Structure which provide keys to describe stored object and clean up time.
 */
struct CETemporaryObjectDataKeys {
    /**
     * @brief Timetoken which represent timestamp when object should be removed from temporary
     * storage.
     */
    __unsafe_unretained NSString *cleanUpDate;
    
    /**
     * @brief Object which should be stored.
     */
    __unsafe_unretained NSString *object;
} CETemporaryObjectData = { .cleanUpDate = @"cd", .object = @"o" };


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENTemporaryObjectsManager ()


#pragma mark - Information

/**
 * @brief \a NSMutableArray with \a NSDictionary instances containing information about stored
 * object and it's clean up date.
 */
@property (nonatomic, nullable, strong) NSMutableArray<NSDictionary *> *temporaryObjects;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief Temporary storage clean up timer.
 */
@property (nonatomic, nullable, strong) NSTimer *cleanUpTimer;


#pragma mark - Handlers

/**
 * @brief Handle clean up timer fire event to trigger clean up process.
 *
 * @param timer \a NSTimer which called this handler.
 */
- (void)handleCleanUpTimer:(NSTimer *)timer;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation CENTemporaryObjectsManager


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    if ((self = [super init])) {
        NSString *identifier = [NSString stringWithFormat:@"com.chatengine.manager.temporar.%p",
                                self];
        _resourceAccessQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _temporaryObjects = [NSMutableArray new];
        _cleanUpTimer = [NSTimer scheduledTimerWithTimeInterval:kCENTemporaryStoreCleanUpInterval
                                                         target:self
                                                       selector:@selector(handleCleanUpTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
    }
    
    return self;
}


#pragma mark - Objects managment

- (void)storeTemporaryObject:(id)object {
    
    NSNumber *timestamp = @([NSDate date].timeIntervalSince1970 + kCENMaximumTemporaryStoreTime);
    NSDictionary *objectData = @{
        CETemporaryObjectData.cleanUpDate: timestamp,
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
        
        [self.temporaryObjects enumerateObjectsUsingBlock:^(NSDictionary *data,
                                                            __unused NSUInteger idx,
                                                            __unused BOOL *stop) {
            
            NSNumber *timestamp = data[CETemporaryObjectData.cleanUpDate];
            
            if (timestamp.doubleValue < currentTimestamp) {
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
    [self.temporaryObjects removeAllObjects];
}

#pragma mark -


@end
