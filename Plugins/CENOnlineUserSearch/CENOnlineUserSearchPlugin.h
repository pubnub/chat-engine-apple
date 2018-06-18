#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CENOnlineUserSearchConfigurationKeys {
    
    /**
     * @brief      Stores reference on name of key under which stored name of property which should be used in search.
     * @discussion It is possible to use CENUser properties and also key-path for \c state property.
     */
    __unsafe_unretained NSString *propertyName;
    
    /**
     * @brief  Stores reference on name of key under which stored whether case-sensitive search should be used or not.
     */
    __unsafe_unretained NSString *caseSensitive;
} CENOnlineUserSearchConfigurationKeys;

extern CENOnlineUserSearchConfigurationKeys CENOnlineUserSearchConfiguration;


#pragma mark - Class forward

@class CENChat, CENUser;


/**
 * @brief      \b CENChat extension to search online users.
 * @discussion This plugin adds the ability to get list of users which conform to search criteria.
 *
 * @discussion Register plugin which has default property name ('uuid') which should be used for search:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).store();
 * @endcode
 *
 * @discussion Register plugin which has custom property name which should be used for search:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [CENOnlineUserSearchPlugin class]).configuration(@{
 *     CENOnlineUserSearchConfiguration.propertyName = @"state.firstName"
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENOnlineUserSearchPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief      Search for user.
 * @discussion Use provided search criteria to look up for online users.
 *
 * @discussion \b Example:
 * @code
 * [CENOnlineUserSearchPlugin search:@"bob" inChat:chat withCompletion:^(NSArray<CENUser *> *users) {
 *     NSLog(@"Found %@ users which has 'bob' in their UUID", @(users.count));
 * }];
 * @endcode
 *
 * @param criteria Reference on string which should be checked in property specified under \c CENOnlineUserSearchConfiguration.propertyName key.
 * @param chat     Reference on \c chat instance for which search should be done.
 * @param block    Reference on search completion block. Block pass only one argument - list of users which conform to search \c criteria.
 */
+ (void)search:(NSString *)criteria inChat:(CENChat *)chat withCompletion:(void(^)(NSArray<CENUser *> *))block;

#pragma mark -


@end
