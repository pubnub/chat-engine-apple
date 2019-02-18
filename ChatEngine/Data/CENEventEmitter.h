#import <Foundation/Foundation.h>
#import "CENStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Events signalling.
 *
 * @discussion Provides interface to subscribe and emit events for it's subclasses.
 *
 * @ref 5c70b850-8e2a-46e5-8a19-cfbf4591c11f
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENEventEmitter : NSObject


#pragma mark Information

/**
 * @brief List of event names on which object has registered handler block.
 *
 * @ref ba33c082-1d5f-4dda-b877-2cde8b48ba2e
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *eventNames;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
