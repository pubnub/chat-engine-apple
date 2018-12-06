/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENEmittedEvent+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENEmittedEvent (Protected)


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize local event representation instance.
 *
 * @param event Full name of emitted event.
 * @param data Object which has been sent along with local \c event for handlers consumption.
 * @param emitter Object which emitted \c event locally.
 *
 * @return Initialed and ready to use local event representation instance.
 */
- (instancetype)initWithName:(NSString *)event
                        data:(nullable id)data
                   emittedBy:(CENEventEmitter *)emitter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENEmittedEvent


#pragma mark - Initialization and Configuration

+ (instancetype)eventWithName:(NSString *)event data:(id)data emittedBy:(CENEventEmitter *)emitter {

    return [[self alloc] initWithName:event data:data emittedBy:emitter];
}

- (instancetype)initWithName:(NSString *)event data:(id)data emittedBy:(CENEventEmitter *)emitter {

    if ((self = [super init])) {
        _emitter = emitter;
        _event = [event copy];
        _data = data;
    }

    return self;
}

#pragma mark -


@end
