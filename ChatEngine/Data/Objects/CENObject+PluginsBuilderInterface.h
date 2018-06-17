#import "CENObject.h"


#pragma mark Class forward

@class CENPluginsBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user instance management.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENObject (PluginsBuilderInterface)


#pragma mark - Plugins

/**
 * @brief      Create/remove or check existence of plugin for specified \b ChatEngine object (depending from used builder
 *             commiting function).
 * @discussion Builder block allow to specify \b required field - reference on class (during registration/removal/check) or
 *             identifier (during removal or check).
 * @discussion Available builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Chek proto plugin registered using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * ...
 * if (!self.client.me.plugin([AwesomeChatPlugin class]).exists()) {
 *     // Looks like local user doesn't have plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @discussion Chek plugin registered using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * ...
 * if (!self.client.me.plugin(@"com.chatengine.emoji").exists()) {
 *     // Looks like local user doesn't have plugin with 'com.chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @discussion Register plugin w/o initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class]).store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Register local user plugin with initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class])
 *         .identifier(@"com.awesome.plugin")
 *         .configuration(@{ @"api-key": @"secret" })
 *         .store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Unregister proto plugin using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class]).store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.me.plugin([AwesomeChatPlugin class]).remove();
 * @endcode
 *
 * @discussion Unregister local user plugin using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class]).identifier(@"com.awesome.plugin").store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.me.plugin(@"com.awesome.plugin").remove();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^plugin)(id plugin);


#pragma mark - Extension

/**
 * @brief      Create/remove or check existence of plugin for specified \b ChatEngine object (depending from used builder
 *             commiting function).
 * @discussion Builder block allow to specify \b required field - reference on class or identifier with which extension has
 *             been registered.
 *
 * @discussion Chek proto plugin registered using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * ...
 * if (!self.client.me.plugin([AwesomeChatPlugin class]).exists()) {
 *     // Looks like local user doesn't have plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @discussion Chek proto plugin registered using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * ...
 * if (!self.client.me.plugin(@"com.chatengine.emoji").exists()) {
 *     // Looks like local user doesn't have plugin with 'com.chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @discussion Register proto plugin w/o initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class]).store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Register local user plugin with initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class])
 *         .identifier(@"com.awesome.plugin")
 *         .configuration(@{ @"api-key": @"secret" })
 *         .store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Unregister proto plugin using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class]).store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.me.plugin([AwesomeChatPlugin class]).remove();
 * @endcode
 *
 * @discussion Unregister local user plugin using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     me.plugin([AwesomeChatPlugin class]).identifier(@"com.awesome.plugin").store();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.me.plugin(@"com.awesome.plugin").remove();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENObject * (^extension)(id plugin, void(^block)(id __nullable extension));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
