/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEmittedEvent.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENEmittedEvent (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure local event representation instance.
 *
 * @param event Full name of emitted event.
 * @param data Object which has been sent along with local \c event for handlers consumption.
 * @param emitter Object which emitted \c event locally.
 *
 * @return Configured and ready to use local event representation instance.
 */
+ (instancetype)eventWithName:(NSString *)event
                         data:(nullable id)data
                    emittedBy:(CENEventEmitter *)emitter;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
