#import "CENObject.h"


#pragma mark Class forward

@class CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} room history search.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENSearch : CENObject


#pragma mark - Information

/**
 * @brief The timetoken to begin searching between.
 *
 * @ref 071eea70-8b0e-424e-964b-e0407642f888
 */
@property (nonatomic, readonly, nullable, strong) NSNumber *start;

/**
 * @brief \b {User CENUser} who sent the message.
 *
 * @ref 61427812-e460-4bfa-aca2-e15055c08eed
 */
@property (nonatomic, readonly, nullable, strong) CENUser *sender;

/**
 * @brief The timetoken to end searching between.
 *
 * @ref ef538ff2-1928-4abb-bbdf-4065537b87ae
 */
@property (nonatomic, readonly, nullable, strong) NSNumber *end;

/**
 * @brief Name of event to search for.
 *
 * @ref 1b4b49ec-45c8-4fd5-b258-e9c75e0ccb35
 */
@property (nonatomic, readonly, nullable, copy) NSString *event;

/**
 * @brief The maximum number of results to return that match search criteria.
 *
 * @discussion Search will continue operating until it returns this number of results or it reached
 * the end of history.
 * Limit will be ignored in case if both 'start' and 'end' timetokens has been passed in search
 * configuration.
 *
 * @ref 2bed684a-55d5-4978-933d-7e98d765cade
 */
@property (nonatomic, readonly, assign) NSInteger limit;

/**
 * @brief The maximum number of history requests which \b {ChatEngine CENChatEngine} will do
 * automatically to fulfill \b {limit} requirement.
 *
 * @ref 77ce489c-cb39-40a5-bed8-4f06a3448450
 */
@property (nonatomic, readonly, assign) NSInteger pages;

/**
 * @brief The maximum number of messages which can be fetched with single history request.
 *
 * @ref bf83d5f5-eaa6-4cfc-9bd4-520338f96ec6
 */
@property (nonatomic, readonly, assign) NSInteger count;

/**
 * @brief Whether there is potentially more events available for fetch.
 *
 * @ref df4be79e-675e-4112-8575-78d7f424cc3e
 */
@property (nonatomic, readonly, assign) BOOL hasMore;

/**
 * @brief \b {Chat CENChat} for which search has been performed.
 *
 * @ref c7d6784d-f5b9-4e25-bbb4-cc9d8789b2c9
 */
@property (nonatomic, readonly, strong) CENChat *chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
