#import <CENChatEngine/CEPPlugin.h>
#import "CENOnlineUserSearchExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref a434dcd7-9550-4bcc-8acb-ca1f2edd661a
 */
typedef struct CENOnlineUserSearchConfigurationKeys {
    /**
     * @brief Boolean which specify whether case-sensitive search should be used or not.
     *
     * \b Default: \c NO
     *
     * @ref 667e5f80-f85c-4ca9-9e3e-6aad9fa63cae
     */
    __unsafe_unretained NSString *caseSensitive;
    
    /**
     * @brief Name of property which should be used in search.
     *
     * @discussion It is possible to use \b {CENUser.uuid} and also key-path for \b {CENUser.state}
     * property.
     *
     * \b Default: \c uuid
     *
     * @ref a10fb38a-10fb-4ff1-aea4-a2f68067c224
     */
    __unsafe_unretained NSString *propertyName;
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
 * @discussion Setup with default configuration
 * @code
 * // objc d11861e2-47d5-4a19-8cd0-8e9edb529c41
 *
 * self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).store();
 * @endcode
 *
 * @discussion Setup with custom property name which should be used for search
 * @code
 * // objc 2537d6a4-946e-4e87-ab20-dfa47977557a
 *
 * self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).configuration(@{
 *     CENOnlineUserSearchConfiguration.propertyName: @"state.firstName"
 * }).store();
 * @endcode
 *
 * @ref f670e867-1c71-480e-bbd3-50af24a66a7f
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENOnlineUserSearchPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Search for \b {users CENUser} using provided search criteria to look up for online users.
 *
 * @discussion Search for \b {users CENUser} basing on their \b {CENUser.uuid} property
 * @code
 * // objc 2689cd9e-b456-4928-9d1b-1b1b64224be4
 *
 * NSArray<CENUser *> *users = [CENOnlineUserSearchPlugin search:@"bob" inChat:chat];
 * NSLog(@"Found %@ users which has 'bob' in their UUID or state", @(users.count));
 * @endcode
 *
 * @param criteria String which should be checked in property specified under
 *     \b {CENOnlineUserSearchConfiguration.propertyName} key.
 * @param chat \b {Chat CENChat} for which search should be done.
 *
 * @return List of \b {users CENUser} which conform to search criteria.
 *
 * @since 0.0.2
 *
 * @ref dd93d344-b615-4a40-b64d-a495978b1f51
 */
+ (NSArray<CENUser *> *)search:(NSString *)criteria inChat:(CENChat *)chat;

/**
 * @brief Search for \b {user CENUser} using provided search criteria to look up for online users.
 *
 * @discussion Search for \b {users CENUser} basing on their \b {CENUser.uuid} property
 * @code
 * // objc 91883fb5-e61a-4c92-b3ec-69589c1ff367
 *
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
 *
 * @deprecated 0.0.2
 *
 * @ref 27ebcdf5-90ed-4d99-8c0d-5bd9a74d1229
 */
+ (void)search:(NSString *)criteria
            inChat:(CENChat *)chat
    withCompletion:(void(^)(NSArray<CENUser *> *))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "+search:inChat: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
