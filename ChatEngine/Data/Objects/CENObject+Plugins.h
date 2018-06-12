#import "CENObject.h"


#pragma mark Clas forward

@class CEPExtension;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b CENObject interface for \c plugins management.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENObject (Plugins)


#pragma mark - Plugins

/**
 * @brief  Check whether there is plugin with specified class already registered for object or not.
 *
 * @discussion Chek plugin registered using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * ...
 * if (![self.client.me hasPlugin:[AwesomeChatPlugin class]) {
 *     // Looks like local user doesn't have plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @param cls Reference on plugin class (subclass of \b CEPPlugin) which should be used for check.
 *
 * @return \c YES in case if plugin with same class already registered for object.
 */
- (BOOL)hasPlugin:(Class)cls;

/**
 * @brief  Check whether there is plugin with specified identifier already registered for object or not.
 *
 * @discussion Chek plugin registered using it's identifier:
 *
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * ...
 * if (![self.client.me hasPluginWithIdentifier:@"com.chatengine.emoji") {
 *     // Looks like local user doesn't have plugin with 'com.chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @param identifier Reference on plugin unique identifier which should be used for check.
 *
 * @return \c YES in case if plugin with same identifier already registered for object.
 */
- (BOOL)hasPluginWithIdentifier:(NSString *)identifier;

/**
 * @brief  Register plugin for specified \b ChatEngine object type.
 *
 * @discussion Register plugin w/o initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me registerPlugin:[AwesomeChatPlugin class] withConfiguration:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param cls           Reference on plugin class (subclass of \b CEPPlugin) which should be registered.
 * @param configuration Reference on dictionary which contain plugin configuration and will be passed to bundled extensions
 *                      and middlewares during instantiation.
 */
- (void)registerPlugin:(Class)cls withConfiguration:(nullable NSDictionary *)configuration;

/**
 * @brief      Register plugin with custom identifier for specified \b ChatEngine object.
 *
 * @discussion Register plugin with initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me registerPlugin:[AwesomeChatPlugin class]
 *         withIdentifier:@"com.awesome.plugin"
 *          configuration:@{ @"api-key": @"secret" }];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param cls           Reference on plugin class (subclass of \b CEPPlugin) which should be registered.
 * @param identifier    Reference on plugin unique identifier with which plugin will be registered.
 * @param configuration Reference on dictionary which contain plugin configuration and will be passed to bundled extensions
 *                      and middlewares during instantiation.
 */
- (void)registerPlugin:(Class)cls withIdentifier:(NSString *)identifier configuration:(nullable NSDictionary *)configuration;

/**
 * @brief      Un-register plugin from specified \b ChatEngine object.
 *
 * @discussion Unregister plugin using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me registerPlugin:[AwesomeChatPlugin class] withConfiguration:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * ...
 * [self.client.me unregisterPlugin:[AwesomeChatPlugin class]];
 * @endcode
 *
 * @param cls Reference on plugin class (subclass of \b CEPPlugin) which should be un-registered.
 */
- (void)unregisterPlugin:(Class)cls;

/**
 * @brief      Un-register plugin with custom identifier from specified \b ChatEngine object.
 *
 * @discussion Unregister proto plugin using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me registerPlugin:[AwesomeChatPlugin class]
 *         withIdentifier:@"com.awesome.plugin"
 *          configuration:@{ @"api-key": @"secret" }];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * ...
 * [self.client.me unregisterPluginWithIdentifier:@"com.awesome.plugin"];
 * @endcode
 *
 * @param identifier Reference on plugin unique identifier which should be used to find and remove plugin.
 */
- (void)unregisterPluginWithIdentifier:(NSString *)identifier;


#pragma mark - Extension

/**
 * @brief      Retrieve reference on extension for specified plugin class.
 * @discussion Retrieve reference on previously registered object extension using class of plugin which has been used to
 *             register it.
 * @discussion Requested extension can be used only within execution context block. Extension state and methods can be
 *             accessed only within execution context block.
 *
 * @discussion Use previously registered extension by it's plugin class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [self.client.global registerPlugin:[AwesomeChatPlugin class] withConfiguration:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * ...
 * [self.client.global extension:[AwesomeChatPlugin class] withContext:^(AwesomeChatExtension *extension) {
 *
 *     // Use extension's methods within provided execution context.
 * }];
 * @endcode
 *
 * @param cls   Reference on plugin class (subclass of \b CEPPlugin) which provides requested extension.
 * @param block Reference on extension execution context block. Block pass one argument - reference on extension instance
 *              which can be used.
 */
- (void)extension:(Class)cls withContext:(void(^)(id __nullable extension))block;

/**
 * @brief      Retrieve reference on extension by it's unique identifier.
 * @discussion Retrieve reference on previously registered object extension using identifier which has been used during
 *             registration.
 * @discussion Requested extension can be used only within execution context block. Extension state and methods can be
 *             accessed only within execution context block.
 *
 * @discussion Use previously registered extension using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [self.client.global registerPlugin:[AwesomeChatPlugin class] withConfiguration:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * ...
 * [self.client.global extensionWithIdentifier:@"com.awesome.plugin" withContext:^(AwesomeChatExtension *extension) {
 *
 *     // Use extension's methods within provided execution context.
 * }];
 *
 * @param identifier Reference on unique identifier which has been provided during plugin registration.
 * @param block      Reference on extension execution context block. Block pass one argument - reference on extension
 *                   instance which can be used.
 */
- (void)extensionWithIdentifier:(NSString *)identifier context:(void(^)(id __nullable extension))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
