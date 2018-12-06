#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CENEventEmitter;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Local \b {ChatEngine CENChatEngine} emitted events representation.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENEmittedEvent : NSObject


#pragma mark - Information

/**
 * Object which emitted \b {event} locally.
 *
 * @ref fb7de903-cff2-4ad5-a308-365ef3f28106
 */
@property (nonatomic, readonly, strong) id emitter;

/**
 * Full name of emitted event.
 *
 * @ref f68e4cbe-2692-49db-ae69-3eaa34545531
 */
@property (nonatomic, readonly, copy) NSString *event;

/**
 * Object which has been sent along with local \b {event} for handlers consumption.
 *
 * @ref 56b44eb1-13b8-47d7-9aac-ce920551d865
 */
@property (nonatomic, nullable, readonly, strong) id data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
