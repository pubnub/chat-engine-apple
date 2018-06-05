#import "CENSearch.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Chat room history search.
 * @discussion This instance can be used to fetch older events for \c chat for which it has been created.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENSearch (Interface)


#pragma mark - Searching

/**
 * @brief  Perform initial search.
 */
- (void)searchEvents;

/**
 * @brief  Search for older events (if possible).
 */
- (void)searchOlder;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
