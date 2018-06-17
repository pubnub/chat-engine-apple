#import "CENChatEngine.h"


/**
 * @brief  \b ChatEngine interface for communication with \b PubNub real-time network.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (PubNub)


#pragma mark - Information

/**
 * @brief  Stores reference on \b PubNub client instance which is used to access live data-stream and use it for chat(s) and
 *         messaging.
 */
@property (nonatomic, nullable, readonly, strong) PubNub *pubnub;

#pragma mark -


@end
