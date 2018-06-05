#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CENGravatarPluginConfigurationKeys {
    
    /**
     * @brief  Stores reference on name of key under which stored name of key in user's \a state where email addres stored.
     */
    __unsafe_unretained NSString *emailKey;
    
    /**
     * @brief  Stores reference on name of key under which stored name of key in user's \a state where Gravatar URL should be stored.
     */
    __unsafe_unretained NSString *gravatarURLKey;
} CENGravatarPluginConfigurationKeys;

extern CENGravatarPluginConfigurationKeys CENGravatarPluginConfiguration;


/**
 * @brief      \b CENUser gravatar support extension.
 * @discussion This plugin adds the ability to get Gravatars basing on local user \c email address and update his state.
 *
 * @discussion Register plugin which has default key ('email') under which stored user email which should be used for Gravatar resolution:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Me", [CENGravatarPlugin class]).store();
 * @endcode
 *
 * @discussion Register plugin which has custom key under which Gravatar URL should be stored after email resolution:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Me", [CENGravatarPlugin class]).configuration(@{
 *     CENGravatarPluginConfiguration.gravatarURLKey = @"imgURL"
 * });
 * @endcode
 *
 * @discussion Listen for users' state change event:
 * @code
 * self.client.on(@"$.state", ^(CENUser *user) {
 *     if (user.state[@"imgURL"]) {
 *         NSLog(@"'%@' profile image can be downloaded here: %@", user.uuid, user.state[@"imgURL"]);
 *     }
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENGravatarPlugin : CEPPlugin


#pragma mark -


@end
