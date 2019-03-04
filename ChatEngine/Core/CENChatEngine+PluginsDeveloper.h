/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Developer interface declaration

@interface CENChatEngine (PluginsDeveloper)


#pragma mark - Events emitting

/**
 * @brief Emit specified event with data pre-processing (middlewares if any).
 *
 * @param object \b {Emitter CENEventEmitter} subclass from which with pre-processed data will be
 *     emitted.
 * @param event Name of event which should be emitted after data pre-processing.
 * @param ... List of additional parameters (which include event payload) which should be sent along
 *     with emitted event.
 *
 * @ref ce818eac-22ed-413d-ac41-ba20260f4041
 */
- (void)triggerEventLocallyFrom:(CENEventEmitter *)object
                          event:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
