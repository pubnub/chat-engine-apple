#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 */
typedef struct CENGravatarPluginConfigurationKeys {
    /**
     * @brief \b {Chat CENChat} which will store user's gravatar information.
     *
     * \b Default: \b {CENChatEngine.global}
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief Key or key-path in user's \b {CENMe.state} where email address is stored.
     *
     * \b Default: \c email
     */
    __unsafe_unretained NSString *emailKey;
    
    /**
     * @brief Key or key-path in user's \b {CENMe.state} where Gravatar URL should be stored.
     *
     * \b Default: \c gravatar
     */
    __unsafe_unretained NSString *gravatarURLKey;
} CENGravatarPluginConfigurationKeys;

extern CENGravatarPluginConfigurationKeys CENGravatarPluginConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} email gravatar plugin.
 *
 * @discussion Plugin allow automatically generate Gravatar URI using \b {local user CENMe}
 * \c email.
 *
 * @note Plugin should be registered on \b {local user CENMe} instance after
 * \b {ChatEngine CENChatEngine} connection (can't be used as proto plugin).
 *
 * @discussion Setup with default configuration:
 * @code
 * // objc
 * self.client.connect(@"ChatEngine").perform();
 *
 * self.client.me.plugin([CENGravatarPlugin class]).store();
 *
 * self.client.on(@"$.state", ^(CENEmittedEvent *event) {
 *     CENUser *user = event.data;
 *
 *     if (user.state(nil)[@"gravatar"])) {
 *         // Update user's icon in users list.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom keys and \b {chat CENChat}:
 * @code
 * // objc
 * self.client.connect(@"ChatEngine").perform();
 *
 * self.client.me.plugin(@"Me", [CENGravatarPlugin class]).configuration(@{
 *     CENGravatarPluginConfiguration.gravatarURLKey = @"profile.imgURL",
 *     CENGravatarPluginConfiguration.emailKey = @"contacts.email",
 *     CENGravatarPluginConfiguration.chat = self.chat
 * }).store();
 *
 * self.client.on(@"$.state", ^(CENEmittedEvent *event) {
 *     CENUser *user = event.data;
 *
 *     if (user.state(self.chat)[@"profile"][@"imgURL"])) {
 *         // Update user's icon in users list.
 *     }
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENGravatarPlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
