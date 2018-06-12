#import "CENObject.h"


#pragma mark Class forward

@class CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Chat room history search.
 * @discussion This instance can be used to fetch older events for \c chat for which it has been created.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENSearch : CENObject


#pragma mark - Information

/**
 * @brief Stores reference on timetoken to begin searching between.
 */
@property (nonatomic, readonly, nullable, strong) NSNumber *start;

/**
 * @brief Stores reference on name of event to search for.
 */
@property (nonatomic, readonly, nullable, strong) CENUser *sender;

/**
 * @brief Stores reference on timetoken to end searching between.
 */
@property (nonatomic, readonly, nullable, strong) NSNumber *end;

/**
 * @brief Stores reference on name of event to search for.
 */
@property (nonatomic, readonly, nullable, copy) NSString *event;

/**
 * @brief  Stores maximum number of results to return that match search criteria. Search will continue operating until it
 *         returns this number of results or it reached the end of history.
 */
@property (nonatomic, readonly, assign) NSInteger limit;

/**
 * @brief  Stores maximum number of search queries which can be done to reach specified end conditions: limit.
 */
@property (nonatomic, readonly, assign) NSInteger pages;

/**
 * @brief  Stores maximum number of events which can be fetched with single gistory request.
 */
@property (nonatomic, readonly, assign) NSInteger count;

/**
 * @brief  Stores whether there is potentially more events available for fetch.
 */
@property (nonatomic, readonly, assign) BOOL hasMore;

/**
 * @brief  Stores reference on chat for which search has been performed.
 */
@property (nonatomic, readonly, strong) CENChat *chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
