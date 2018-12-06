#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} temporary objects manager which maintain objects like
 * \b {searcher CENSearch} and \b {event emitter CENEvent} while their action won't be completed.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENTemporaryObjectsManager : NSObject


#pragma mark Objects managment

/**
 * @brief Place \c object into temporary storage which will be flushed after configured delay.
 *
 * @param object Object instance which should be kept longer w/o release.
 */
- (void)storeTemporaryObject:(id)object;


#pragma mark - Clean up

/**
 * @brief Clean up all used resources.
 *
 * @discussion Clean up temporary storage and all resources allocated to support it.
 */
- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
