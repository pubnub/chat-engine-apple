#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \b {local user CENMe} connection
 * management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (Connection)


#pragma mark Information

/**
 * @brief Whether \b {CENChatEngine} client is ready to use or not.
 *
 * @discussion \b {$.ready} event will be emitted when \b {CENChatEngine} client is
 * ready.
 *
 * @ref 08765c0c-c8f7-4076-8dc5-4c48d171c920
 */
@property (nonatomic, readonly, getter = isReady, assign) BOOL ready NS_SWIFT_NAME(ready);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
