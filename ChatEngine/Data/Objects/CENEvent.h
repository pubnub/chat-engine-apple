#import "CENEventEmitter.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Emitted event representation.
 * @discussion This model allow to represent emitted event and track it's progress.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENEvent : CENEventEmitter


#pragma mark - Information

/**
 * @brief  Stores reference on actual channel name which is used by \c chat to deliver emitted event.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief  Stores reference on emitted event name.
 */
@property (nonatomic, readonly, copy) NSString *event;

/**
 * @brief  Stores reference on \b ChatEngine chat instance which has been used to emit event.
 */
@property (nonatomic, readonly, strong) CENChat *chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
