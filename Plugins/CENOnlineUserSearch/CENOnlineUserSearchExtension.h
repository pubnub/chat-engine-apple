#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for online \b {users CENUser} search support.
 *
 * @ref ff4785df-509d-44a3-84d3-c1045f1567f5
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENOnlineUserSearchExtension : CEPExtension


#pragma mark - Search

/**
 * @brief Search for \b {users CENUser} using search criteria.
 *
 * @discussion Search for \b {users CENUser} basing on their \b {CENUser.uuid} property
 * @code
 * // objc dd06ebf8-7917-47a0-8a2a-8a91702672f1
 *
 * CENOnlineUserSearchExtension *extension = self.chat.extension([CENOnlineUserSearchPlugin class]];
 * NSArray<CENUser *> *users = [extension usersMatchingCriteria:@"bob"];
 * NSLog(@"Found %@ users which has 'bob' in their UUID or state", @(users.count));
 * @endcode
 *
 * @param criteria Value which should be used to filter out online users.
 *
 * @return List of b {users CENUser} which conform to search criteria.
 *
 * @since 0.0.2
 *
 * @ref 1642efcd-b75e-4bb6-81f4-5a59c6424d70
 */
- (NSArray<CENUser *> *)usersMatchingCriteria:(NSString *)criteria;

/**
 * @brief Search for \b {users CENUser} using search criteria.
 *
 * @discussion Search for \b {users CENUser} basing on their \b {CENUser.uuid} property
 * @code
 * // objc f797baa3-706f-4260-a215-5e6a1f50eea4
 *
 * CENOnlineUserSearchExtension *extension = self.chat.extension([CENOnlineUserSearchPlugin class]];
 * [extension searchFor:@"bob" inChat:self.chat  withCompletion:^(NSArray<CENUser *> *users) {
 *     NSLog(@"Found %@ users which has 'bob' in their UUID or state", @(users.count));
 * });
 * @endcode
 *
 * @param criteria Value which should be used to filter out online users.
 * @param block Block / closure which will be called at the end of search and pass list of
 *     \b {users CENUser} which conform to search criteria.
 *
 * @deprecated 0.0.2
 *
 * @ref 7d10ab44-f107-4b76-b801-f50038dc9530
 */
- (void)searchFor:(NSString *)criteria withCompletion:(void(^)(NSArray<CENUser *> *users))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-usersMatchingCriteria: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
