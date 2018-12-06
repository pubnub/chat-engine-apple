#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENSearch, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat's CENChat} events search API access builder.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
@interface CENChatSearchBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief Searched event name addition block.
 *
 * @param event Name of event to search for.
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^event)(NSString * __nullable event);

/**
 * @brief Event sender addition block.
 *
 * @param sender \b {User CENUser} who sent the message.
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^sender)(CENUser * __nullable sender);

/**
 * @brief Search limit addition block.
 *
 * @param limit The maximum number of results to return that match search criteria. Search will
 *     continue operating until it returns this number of results or it reached the end of history.
 *     Limit will be ignored in case if both 'start' and 'end' timetokens has been passed in search
 *     configuration.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 20
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^limit)(NSInteger limit);

/**
 * @brief Maximum searched pages addition block.
 *
 * @param pages The maximum number of history requests which \b {ChatEngine CENChatEngine} will do
 * automatically to fulfill \b {limit} requirement.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 10
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^pages)(NSInteger pages);

/**
 * @brief Maximum events per request addition block.
 *
 * @param count The maximum number of messages which can be fetched with single history request.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 100
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^count)(NSInteger count);

/**
 * @brief Search interval start timetoken addition block.
 *
 * @param start The timetoken to begin searching between.
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^start)(NSNumber * __nullable start);

/**
 * @brief Search interval end timetoken addition block.
 *
 * @param end The timetoken to end searching between.
 *
 * @return Builder instance which allow to complete events searching call configuration.
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^end)(NSNumber * __nullable end);


#pragma mark - Call

/**
 * @brief Create events \b {searcher CENSearch} using specified parameters.

 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain event.sender.limit.pages.count.start.end.create
 *
 * @discussion Search for specific event from \b {local user CENMe}
 * @code
 * // objc 643490dc-1019-4830-bf87-950e46493f9f
 *
 * self.chat.search().event(@"my-custom-event").sender(self.client.me).limit(20).create()
 *     .search()
 *     .on(@"my-custom-event", ^(CENEmittedEvent *event) {
 *         NSLog(@"This is an old event!: %@", event.data);
 *     })
 *     .on(@"$.search.finish", ^(CENEmittedEvent *event) {
 *         NSLog(@"We have all our results!");
 *     });
 * @endcode
 *
 * @discussion Search for all events
 * @code
 * // objc eba2b098-1b22-450f-951f-f7869ab32137
 *
 * self.chat.search().create()
 *     .search()
 *     .on(@"my-custom-event", ^(CENEmittedEvent *event) {
 *         NSLog(@"This is an old event!: %@", event.data);
 *     })
 *     .on(@"$.search.finish", ^(CENEmittedEvent *event) {
 *         NSLog(@"We have all our results!");
 *     });
 * @endcode
 *
 * @return \b {Chat CENChat} events \b {searcher CENSearch} instance.
 *
 * @ref 8638be94-e114-4beb-9eb8-1b25c80d8c42
 */
@property (nonatomic, readonly, strong) CENSearch * (^create)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
