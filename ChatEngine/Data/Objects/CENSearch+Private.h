/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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
 * @param pages The maximum number of history requests which \b {CENChatEngine} will do
 *     automatically to fulfill \c limit requirement.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 10
 * @param count The maximum number of messages which can be fetched with single history request.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 100
 * @param start The timetoken to begin searching between.
 * @param end The timetoken to end searching between.
 * @param chatEngine \b {CENChatEngine} client which will manage this chat instance.
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


#pragma mark - State

/**
 * @brief Restore state for any event \b {sender CENUser}.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
 *
 * @param chat \b {Chat CENChat} from which state for users should be retrieved.
 *     Pass \c nil to use \b {CENChatEngine.global} chat.
 *
 * @since 0.9.3
 *
 * @ref 86ca770e-0d35-4786-9983-e5d63f024308
 */
- (void)restoreStateForChat:(nullable CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
