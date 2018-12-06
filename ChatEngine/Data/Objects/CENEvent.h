#import "CENEventEmitter.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief User's message event emitter.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENEvent : CENEventEmitter


#pragma mark - Information

/**
 * @brief Channel name which is used by \b {chat} to deliver emitted event.
 *
 * @ref 2c327569-0d12-40ad-86a3-5b4eea7c5175
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Emitted event name.
 *
 * @ref f3aa511e-b3fa-4712-ada2-bb19f1749fcf
 */
@property (nonatomic, readonly, copy) NSString *event;

/**
 * @brief \b {Chat CENChat} from which user emitted \b {event}.
 *
 * @ref 06468a81-a50c-4571-bf08-b7eae12440b2
 */
@property (nonatomic, readonly, strong) CENChat *chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
