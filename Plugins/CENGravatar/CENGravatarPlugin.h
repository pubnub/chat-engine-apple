#import <CENChatEngine/CEPPlugin.h>
#import "CENGravatarExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 69f4c496-f5da-47f2-ab81-15422d762b5e
 */
typedef struct CENGravatarPluginConfigurationKeys {
    /**
     * @brief Key or key-path in user's \b {CENMe.state} where email address is stored.
     *
     * \b Default: \c email
     *
     * @ref 743d8363-67e2-4e90-9390-badc5c18dadc
     */
    __unsafe_unretained NSString *emailKey;
    
    /**
     * @brief Key or key-path in user's \b {CENMe.state} where Gravatar URL should be stored.
     *
     * \b Default: \c gravatar
     *
     * @ref bfa717cc-7269-46a7-9d8b-42dc20b4db0d
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
 * \b {CENChatEngine} connection (can't be used as proto plugin).
 *
 * @discussion Setup with default configuration
 * @code
 * // objc 1f5b7934-9644-4f94-a346-7906d3e871f3
 *
 * self.client.me.plugin([CENGravatarPlugin class]).store();
 *
 * self.client.on(@"$.state", ^(CENEmittedEvent *event) {
 *     CENUser *user = event.data;
 *
 *     if (user.state[@"gravatar"])) {
 *         // Update user's icon in users list.
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom keys
 * @code
 * // objc 3424f7c1-7eda-45a4-914c-63c9a2f6077b
 *
 * self.client.me.plugin([CENGravatarPlugin class]).configuration(@{
 *     CENGravatarPluginConfiguration.gravatarURLKey = @"profile.imgURL",
 *     CENGravatarPluginConfiguration.emailKey = @"contacts.email"
 * }).store();
 *
 * self.client.on(@"$.state", ^(CENEmittedEvent *event) {
 *     CENUser *user = event.data;
 *
 *     if ([user.state valueForKeyPath:@"profile.imgURL"]) {
 *         // Update user's icon in users list.
 *     }
 * });
 * @endcode
 *
 * @ref 9461a980-ff9c-42bd-87cd-d6a46b26f11d
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENGravatarPlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
