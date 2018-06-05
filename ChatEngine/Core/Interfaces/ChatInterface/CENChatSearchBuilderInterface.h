#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENSearch, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Chat's events search API interface builder.
 * @discussion Class describe interface which allow to search through chat's history for specific event(s) or all depending
 *             from passed configuration.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2017 PubNub, Inc.
 */
@interface CENChatSearchBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief      Specify name of event to search for.
 * @discussion Limit search to specific event type. All event(s) will be returned in case if this parameter is not part of
 *             \b CENSearch build call or set to \c nil.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^event)(NSString * __nullable event);

/**
 * @brief      Specify \b CENUser instance who sent the message.
 * @discussion Limit search to event(s) which has been sent by specified \c sender.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^sender)(CENUser * __nullable sender);

/**
 * @brief      Specify how many events should be returned in total.
 * @discussion Created search instance will search for specified amount of events. \b 0 or below mean that there is no limit.
 *             Limit will be ignored in case if both \c start and \c end timetokens has been passed to search configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^limit)(NSInteger limit);

/**
 * @brief      Specify how many search request can be sent.
 * @discussion Maximum number of search request which can be performed to reach specified search end criteria: limit. \b 0 or
 *             below will set to default value: \b 10.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^pages)(NSInteger pages);

/**
 * @brief      Specify how many events can be fetched with single search request.
 * @discussion Maximum number of events returned with single search request. \b 0 or below will set to default value: \b 100.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^count)(NSInteger count);

/**
 * @brief  Specify timetoken to begin searching between.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^start)(NSNumber * __nullable start);

/**
 * @brief  Specify timetoken to end searching between.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^end)(NSNumber * __nullable end);


#pragma mark - Call

/**
 * @brief      Create events searching instance.
 * @discussion Returned instance can be used to iterate through history of published events.
 */
@property (nonatomic, readonly, strong) CENSearch * (^create)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
