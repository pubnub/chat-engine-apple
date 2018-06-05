/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENEventEmitter.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENEventEmitter (Private)


#pragma mark - Events emitting

/**
 * @brief      Emit specified \c event with passed variadic list of arguments.
 * @discussion This method is able to handle up to \b 5 parameters forwarding to handling \c block.
 *
 * @param event Reference on name of event which should be emitted.
 */
- (void)emitEventLocally:(NSString *)event, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * @brief      Emit specified \c event with passed list of \c parameters.
 * @discussion This method is able to handle up to \b 5 parameters forwarding to handling \c block.
 *
 * @param event      Reference on name of event which should be emitted.
 * @param parameters Reference on list of parameters which should be passed to handling block.
 */
- (void)emitEventLocally:(NSString *)event withParameters:(NSArray *)parameters;


#pragma mark - Clean up

- (void)destruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
