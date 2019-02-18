#import <CENChatEngine/CEPExtension.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for \c seen functionality support.
 *
 * @ref 90df3fc5-dae3-42b1-ac2a-3f96b2646ee4
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENEventStatusExtension : CEPExtension


#pragma mark - Seen

/**
 * @brief Mark particular event as \c read and notify other \b {chat CENChat} participants.
 *
 * @discussion Mark event as seen
 * @code
 * // objc 1eb31734-0c68-45fe-adf5-fac4815175ad
 *
 * CENEventStatusExtension *extension = self.chat.extension([CENEventStatusPlugin class]);
 * [extension readEvent:payload];
 * @endcode
 *
 * @param event \a NSDictionary with event data which has been received from \b {chat CENChat}.
 *
 * @ref ba8cbc5b-142f-4539-b141-728ae8530370
 */
- (void)readEvent:(NSDictionary *)event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
