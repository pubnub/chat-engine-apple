/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSearch.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Standard interface declaration

@interface CENSearch (Interface)


#pragma mark - Searching

/**
 * @brief Perform initial search.
 *
 * @discussion Make initial search call
 * @code
 * // objc ce884f00-c7ff-40dd-87ea-7f73df6f0202
 *
 * CENSearch *search = [self.client.global searchEvent:@"announcement" fromUser:nil withLimit:10
 *                                               pages:0 count:100 start:nil end:nil];
 *
 * [search searchEvents];
 * @endcode
 *
 * @ref 5f5c8359-31f3-410a-9265-b326314dbe5e
 */
- (void)searchEvents;

/**
 * @brief Search for older events (if possible).
 *
 * @discussion Make initial search call
 * @code
 * // objc ddd1467e-7d7b-4c05-8e7b-f17e0e99c641
 *
 * CENSearch *search = [self.client.global searchEvent:@"announcement" fromUser:nil withLimit:10
 *                                               pages:0 count:100 start:nil end:nil];
 *
 * [search handleEventOnce:(@"$.search.pause" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle search pause because any of specified limits has been reached.
 *     [search searchOlder];
 * });
 *
 * [search searchEvents];
 * @endcode
 *
 * @ref 773459ef-4c30-46b2-9324-c5f34ae9f3a3
 */
- (void)searchOlder;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
