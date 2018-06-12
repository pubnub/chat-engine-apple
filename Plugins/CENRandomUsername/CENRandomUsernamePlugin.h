#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CENRandomUsernameConfigurationKeys {
    
    /**
     * @brief      Stores reference on name of key under which stored name of property to which username should be stored.
     */
    __unsafe_unretained NSString *propertyName;
} CENRandomUsernameConfigurationKeys;

extern CENRandomUsernameConfigurationKeys CENRandomUsernameConfiguration;


/**
 * @brief      \b CENMe extension to provide random names.
 * @discussion This plugin adds randomly generated username to \b CENMe instance's state.
 *
 * @discussion  Register plugin which has default property name ('uuid') to which generated username will be stored:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Me", [CENRandomUsernamePlugin class]).store();
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     NSLog(@"Username: %@", me.state[@"username"]);
 * });
 * @endcode
 *
 * @discussion Register plugin which has custom property name to which generated username will be stored:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Me", [CENRandomUsernamePlugin class]).configuration(@{
 *     CENRandomUsernameConfiguration.propertyName = @"innerAnimal"
 * });
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     NSLog(@"Username: %@", me.state[@"innerAnimal"]);
 * });
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENRandomUsernamePlugin : CEPPlugin

@end
