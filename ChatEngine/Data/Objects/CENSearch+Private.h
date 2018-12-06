/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENSearch.h"


#pragma mark Class forward

@class CENChatEngine, CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENSearch (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure \b {chat CENChat} searcher.
 *
 * @param event Name of event to search for.
 * @param chat \b {Chat CENChat} inside of which events search should be performed.
 * @param sender \b {User CENUser} who sent the message.
 * @param limit The maximum number of results to return that match search criteria. Search will
 *     continue operating until it returns this number of results or it reached the end of history.
 *     Limit will be ignored in case if both 'start' and 'end' timetokens has been passed in search
 *     configuration.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 20
 * @param pages The maximum number of history requests which \b {ChatEngine CENChatEngine} will do
 *     automatically to fulfill \c limit requirement.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 10
 * @param count The maximum number of messages which can be fetched with single history request.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 100
 * @param start The timetoken to begin searching between.
 * @param end The timetoken to end searching between.
 * @param chatEngine \b {ChatEngine CENChatEngine} client which will manage this chat instance.
 *
 * @return Configured and ready to use history searcher.
 */
+ (nullable instancetype)searchForEvent:(nullable NSString *)event
                                 inChat:(CENChat *)chat
                                 sentBy:(nullable CENUser *)sender
                              withLimit:(NSInteger)limit
                                  pages:(NSInteger)pages
                                  count:(NSInteger)count
                                  start:(nullable NSNumber *)start
                                    end:(nullable NSNumber *)end
                             chatEngine:(CENChatEngine *)chatEngine;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
