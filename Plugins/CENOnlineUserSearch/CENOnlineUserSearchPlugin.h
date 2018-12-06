#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 */
typedef struct CENOnlineUserSearchConfigurationKeys {
    /**
     * @brief Whether case-sensitive search should be used or not.
     *
     * \b Default: \c NO
     */
    __unsafe_unretained NSString *caseSensitive;
    
    /**
     * @brief Name of property which should be used in search.
     *
     * @discussion It is possible to use \b {user CENUser} properties and also key-path for \c state
     * property.
     *
     * \b Default: \c uuid
     */
    __unsafe_unretained NSString *propertyName;
    /**
     * @brief \b {Chat CENChat} from which state will be used to perform search.
     *
     * \b Default: \b {CENChatEngine.global}
     */
    __unsafe_unretained NSString *chat;
} CENOnlineUserSearchConfigurationKeys;

extern CENOnlineUserSearchConfigurationKeys CENOnlineUserSearchConfiguration;


#pragma mark - Class forward

@class CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} extension to search online users.
 *
 * @discussion This plugin adds the ability to get list of users which conform to search criteria by
 * performing full-text search on property.
 *
 * @discussion Setup with default configuration:
 * @code
 * // objc
 * self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).store();
 * @endcode
 *
 * @discussion Setup with custom property name which should be used for search:
 * @code
 * // objc
 * self.client.connect(@"ChatEngine").perform();
 *
 * self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).configuration(@{
 *     CENOnlineUserSearchConfiguration.propertyName = @"state.firstName",
 *     CENOnlineUserSearchConfiguration.chat = self.chat
 * }).store();
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENOnlineUserSearchPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Search for \b {user CENUser} using provided search criteria to look up for online users.
 *
 * @code
 * // objc
 * [CENOnlineUserSearchPlugin search:@"bob" inChat:chat withCompletion:^(NSArray<CENUser *> *users){
 *     NSLog(@"Found %@ users which has 'bob' in their UUID or state", @(users.count));
 * }];
 * @endcode
 *
 * @param criteria String which should be checked in property specified under
 *     \b {CENOnlineUserSearchConfiguration.propertyName} key.
 * @param chat \b {Chat CENChat} for which search should be done.
 * @param block Block / closure which will be called at the end of search and pass list of
 *     \b {users CENUser} which conform to search criteria.
 */
+ (void)search:(NSString *)criteria
            inChat:(CENChat *)chat
    withCompletion:(void(^)(NSArray<CENUser *> *))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
