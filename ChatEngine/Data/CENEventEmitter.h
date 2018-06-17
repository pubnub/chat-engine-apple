#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Events signalling.
 * @discussion This class provide interface to subscribe and emit events for it's subclasses.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENEventEmitter : NSObject


#pragma mark - Information

/**
 * @brief      Stores reference on block which can be used to get list of events.
 * @discussion Gets list of events for which emitter has registered handlers.
 *
 * @discussion Block return list of event names.
 */
@property (nonatomic, readonly, strong) NSArray<NSString *> *eventNames;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
