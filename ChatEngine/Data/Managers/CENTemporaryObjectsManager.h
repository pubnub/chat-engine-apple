#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} temporary objects manager which maintain objects like
 * \b {searcher CENSearch} and \b {event emitter CENEvent} while their action won't be completed.
 *
 * @ref b302cf95-788f-4dbd-96a2-987cc33e771e
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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
