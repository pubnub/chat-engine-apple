#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for communication with \b PubNub real-time
 * network.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (PubNub)


#pragma mark - Information

/**
 * @brief \b PubNub client instance, the networking infrastructure that powers the realtime
 * communication between \b {users CENUser} in \b {chats CENChat}.
 *
 * @ref cbb641c8-2819-4864-8a17-d74c0511d18e
 */
@property (nonatomic, nullable, readonly, strong) PubNub *pubnub;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
