#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 */
typedef struct CENRandomUsernameConfigurationKeys {
    /**
     * @brief Key or key-path where username should be stored.
     *
     * \b Default: \c username
     */
    __unsafe_unretained NSString *propertyName;
    
    /**
     * @brief \b {Chat CENChat} which will store user's username information.
     *
     * \b Default: \b {CENChatEngine.global}
     */
    __unsafe_unretained NSString *chat;
} CENRandomUsernameConfigurationKeys;

extern CENRandomUsernameConfigurationKeys CENRandomUsernameConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} extension to provide random names.
 *
 * @discussion Plugin allow automatically generate random user name for \b {local user CENMe}.
 *
 * @note Plugin should be registered on \b {local user CENMe} instance after
 * \b {ChatEngine CENChatEngine} connection (can't be used as proto plugin).
 *
 * @discussion Setup with default configuration:
 * @code
 * // objc
 * self.client.connect(@"ChatEngine").perform();
 *
 * self.client.me.plugin([CENRandomUsernamePlugin class]).store();
 *
 * // Then when it will be required, user's random name can be received.
 * NSLog(@"Username: %@", self.client.me.state(nil)[@"username"]);
 * @endcode
 *
 * @discussion Setup with custom property name to which generated username will be stored:
 * @code
 * // objc
 * self.client.connect(@"ChatEngine").perform();
 *
 * self.client.me.plugin([CENRandomUsernamePlugin class]).configuration(@{
 *     CENRandomUsernameConfiguration.propertyName = @"innerAnimal",
 *     CENRandomUsernameConfiguration.chat = self.chat
 * });
 *
 * // Then when it will be required, user's random name can be received.
 * NSLog(@"Username: %@", self.client.me.state(self.chat)[@"innerAnimal"]);
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENRandomUsernamePlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
