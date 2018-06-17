#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine temporary objects manager.
 * @discussion \b ChatEngine provide ability to publish event to it's real-time network and in response it return object
 *             which allow to track this process. Object should be stored somewhere, so it won't be released before any
 *             events will be sent to observers - this is main purpose of this manager.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENTemporaryObjectsManager : NSObject


#pragma mark - Objects managment

- (void)storeTemporaryObject:(id)object;


#pragma mark - Clean up

- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
