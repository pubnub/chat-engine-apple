
#import "CENChatEngine.h"


#pragma mark Class forward

@class CENEventEmitter;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for event emitting.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (EventEmitter)


#pragma mark - Events emitting

/**
 * @brief Emit specified event with data pre-processing (middlewares if any).
 *
 * @param object \b {Emitter CENEventEmitter} subclass from which with pre-processed data will be
 *     emitted.
 * @param event Name of event which should be emitted after data pre-processing.
 * @param ... List of additional parameters (which include event payload) which should be sent along
 *     with emitted event.
 */
- (void)triggerEventLocallyFrom:(CENEventEmitter *)object
                          event:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;
/**
 * @brief Emit specified \c event with data pre-processing (middlewares if any).
 *
 * @param object \b {Emitter CENEventEmitter} subclass from which with pre-processed data will be
 *     emitted.
 * @param event Name of event which should be emitted after data pre-processing.
 * @param parameters List of additional parameters (which include event payload) which should be
 *     sent along with emitted event.
 * @param block Block which will be called after payload will be emitted with event after
 *     pre-processed by middlewares.
 */
- (void)triggerEventLocallyFrom:(CENEventEmitter *)object
                          event:(NSString *)event
                 withParameters:(NSArray *)parameters
                     completion:(void (^ __nullable)(NSString *, id, BOOL))block;


#pragma mark - Exception throwing

/**
 * @brief Throw exception if \b {CENConfiguration.throwExceptions} is set to \c YES and emit error
 * for specified \c scope.
 *
 * @param error \a NSError instance which contain information for user to describe error.
 * @param scope Scope which generated \c error.
 * @param emitter \b {Emitter CENEventEmitter} subclass from which error should be emitted.
 * @param flow One of \b {CEExceptionPropagationFlow} fields which describe how event should be
 *     distributed.
 */
- (void)throwError:(NSError *)error
          forScope:(NSString *)scope
              from:(nullable CENEventEmitter *)emitter
     propagateFlow:(NSString *)flow;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
