#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Events signalling.
 *
 * @discussion Provides interface to subscribe and emit events for it's subclasses.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENEventEmitter : NSObject


#pragma mark Information

/**
 * @brief List of event names on which object has registered handler block.
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *eventNames;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
