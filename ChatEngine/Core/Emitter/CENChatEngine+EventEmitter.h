
#import "CENChatEngine.h"


#pragma mark Class forward

@class CENEventEmitter;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client interface for event emitting.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (EventEmitter)


/**
 * @brief  Propagate event data through registered middlewares and emit one \c object behalf.
 * @discussion After passed payload (if any) will complete data processing (and not rejected) \c event will be emitted from
 *             \c object and \b ChatEngine instance which contains it.
 *
 * @param object Reference on object from which event should be emitted along with \b ChatEngine client.
 * @param event  Name of event which should be emitted and for which middlewares should be used.
 * @param ...    Reference on list of arguments which should be passed as payload to emitted event (they will be mapped to
 *               handler block arguments).
 */
- (void)triggerEventLocallyFrom:(CENEventEmitter *)object event:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;
- (void)triggerEventLocallyFrom:(CENEventEmitter *)object
                          event:(NSString *)event
                 withParameters:(NSArray *)parameters
                     completion:(void (^ __nullable)(NSString *, id, BOOL))block;

/**
 * @brief      \c Error emitting.
 * @discussion Depending from configuration this method allow to throw \a exception basing on passed \c error or emitt error
 *             as event using specific name format: \c $.error.<scope> and pass \error as payload for event.
 * @discussion Depending from \c emitter and picked \c flow - error can be emitted from \b ChatEngine client itself or
 *             on behalf of \c emitter (and \b ChatEngine client if \c flow set to \b global).
 *
 * @param error   Reference on error which should be delivered to event handlers or used to raise exception.
 * @param scope   Logical scope for which error has been created.
 * @param emitter Reference on object from which event should be emitted.
 * @param flow    Reference on one of possible flows which described in \b CEExceptionPropagationFlow type.
 */
- (void)throwError:(NSError *)error forScope:(NSString *)scope from:(nullable CENEventEmitter *)emitter propagateFlow:(NSString *)flow;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
