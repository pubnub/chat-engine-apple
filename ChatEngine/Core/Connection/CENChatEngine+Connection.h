#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user's connection management.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Connection)


#pragma mark - Information

/**
 * @brief  Stores whether \b ChatEngine client connected and ready to use or not.
 */
@property (nonatomic, readonly, getter = isReady, assign) BOOL ready NS_SWIFT_NAME(ready);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
