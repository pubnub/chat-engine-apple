#import <CENChatEngine/CEPPlugin.h>
#import "CENRandomUsernameExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 78a6a659-8235-4105-b179-ce3b8feac515
 */
typedef struct CENRandomUsernameConfigurationKeys {
    /**
     * @brief Key or key-path where username should be stored.
     *
     * \b Default: \c username
     *
     * @ref b10e73fe-22c2-4583-b48c-229641db16b9
     */
    __unsafe_unretained NSString *propertyName;
} CENRandomUsernameConfigurationKeys;

extern CENRandomUsernameConfigurationKeys CENRandomUsernameConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} extension to provide random names.
 *
 * @discussion Plugin allow automatically generate random user name for \b {local user CENMe}.
 *
 * @note Plugin should be registered on \b {local user CENMe} instance after
 * \b {CENChatEngine} connection (can't be used as proto plugin).
 *
 * @discussion Setup with default configuration
 * @code
 * // objc daa03e8e-a710-4d2d-a7b8-6c96dfa5cffe
 *
 * self.client.me.plugin([CENRandomUsernamePlugin class]).store();
 *
 * // Then when it will be required, user's random name can be received.
 * NSLog(@"Username: %@", self.client.me.state[@"username"]);
 * @endcode
 *
 * @discussion Setup with custom property name to which generated username will be stored
 * @code
 * // objc 28998cf5-6bbf-4b8a-acb6-91b017f8f4d4
 *
 * self.client.me.plugin([CENRandomUsernamePlugin class]).configuration(@{
 *     CENRandomUsernameConfiguration.propertyName: @"innerAnimal"
 * }).store();
 *
 * // Then when it will be required, user's random name can be received.
 * NSLog(@"Username: %@", self.client.me.state[@"innerAnimal"]);
 * @endcode
 *
 * @ref b53b0c07-a3b9-4892-9b2a-4f6f3144350d
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENRandomUsernamePlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
