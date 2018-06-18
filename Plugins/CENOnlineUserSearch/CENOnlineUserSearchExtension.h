#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b CENChat online search extension.
 * @discussion Plugin workhorse which use passed configuration to perform search of online users when it will be requested.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENOnlineUserSearchExtension : CEPExtension


#pragma mark - Search

/**
 * @brief      Search for users using search criteria.
 * @discussion Plugin will search for users using name of property and check whether it's content partially march to search criteria or not.
 *
 * @param criteria Reference on value which should be used to filter out online users.
 * @param block    Reference on search completion block. Block pass only one argument - list of users which conform to search \c criteria.
 */
- (void)searchFor:(NSString *)criteria withCompletion:(void(^)(NSArray<CENUser *> *users))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
