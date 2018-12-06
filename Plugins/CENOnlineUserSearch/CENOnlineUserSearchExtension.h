#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} interface extension for online \b {users CENUser} search support.
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENOnlineUserSearchExtension : CEPExtension


#pragma mark - Search

/**
 * @brief Search for \b {users CENUser} using search criteria.
 *
 * @code
 * // objc
 * self.chat.extension([CENOnlineUserSearchPlugin class],
 *                     ^(CENOnlineUserSearchExtension *extension) {
 
 *     [extension searchFor:@"bob" inChat:self.chat  withCompletion:^(NSArray<CENUser *> *users) {
 *         NSLog(@"Found %@ users which has 'bob' in their UUID or state", @(users.count));
 *     }];
 * });
 * @endcode
 *
 * @param criteria Value which should be used to filter out online users.
 * @param block Block / closure which will be called at the end of search and pass list of
 *     \b {users CENUser} which conform to search criteria.
 */
- (void)searchFor:(NSString *)criteria withCompletion:(void(^)(NSArray<CENUser *> *users))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
