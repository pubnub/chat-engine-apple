/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENEventEmitter.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENEventEmitter (Private)


#pragma mark - Events emitting

/**
 * @brief Emit specific \c event locally to all listeners.
 *
 * @param event Name of event for which listeners should be notified.
 * @param ... Dynamic list of arguments which should be passed along with emitted event (maximum can
 *     be passed one value terminated by \c nil).
 */
- (void)emitEventLocally:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * @brief Emit specific \c event locally to all listeners.
 *
 * @param event Name of event for which listeners should be notified.
 * @param parameters List of arguments which should be passed along with emitted event.
 */
- (void)emitEventLocally:(NSString *)event withParameters:(NSArray *)parameters;


#pragma mark - Clean up

/**
 * @brief Clean up any resources allocated for events emitting and handling support.
 */
- (void)destruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
