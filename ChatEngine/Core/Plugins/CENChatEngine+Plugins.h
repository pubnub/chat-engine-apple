#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c plugins management.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Plugins)


#pragma mark - Plugins

/**
 * @brief  Check whether there is proto plugin registered for specified \b ChatEngine object type or not.
 *
 * @discussion Chek proto plugin registered using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * if (![self.client hasProtoPlugin:[AwesomeChatPlugin class] forObjectType:@"Chat"]) {
 *     // Looks like 'Chat' objects doesn't have proto plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @param cls  Reference on plugin class (subclass of \b CEPPlugin) which should be used for search in \c type proto plugins
 *             list.
 * @param type Reference on one of known types: Chat, User, Me or Search.
 */
- (BOOL)hasProtoPlugin:(Class)cls forObjectType:(NSString *)type;

/**
 * @brief  Check whether there is proto plugin with \c identifier registered for specified \b ChatEngine object type or not.
 *
 * @discussion Chek proto plugin registered using it's identifier:
 *
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * if (![self.client hasProtoPluginWithIdentifier:@"com.chatengine.emoji" forObjectType:@"Chat"]) {
 *     // Looks like 'Chat' objects doesn't have proto plugin with 'com.chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @param identifier Reference on plugin unique identifier which should be used for search in \c type proto plugins list.
 * @param type       Reference on one of known types: Chat, User, Me or Search.
 */
- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

/**
 * @brief      Register proto plugin for specified \b ChatEngine object type.
 * @discussion Registered proto plugins will be applied to objects of specified type when they will be created.
 *
 * @discussion Register proto plugin w/o initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client registerProtoPlugin:[AwesomeChatPlugin class] forObjectType:@"Chat" configuration:nil];
 * @endcode
 *
 * @param cls           Reference on plugin class (subclass of \b CEPPlugin) which should be called, when new object of
 *                      \c type will be created.
 * @param configuration Reference on dictionary which can be used to pass configuration to \c plugin during instantiation
 *                      process.
 * @param type          Reference on one of known types: Chat, User, Me or Search.
 */
- (void)registerProtoPlugin:(Class)cls withConfiguration:(nullable NSDictionary *)configuration forObjectType:(NSString *)type;

/**
 * @brief      Register proto plugin with identifier for specified \b ChatEngine object type.
 * @discussion Registered proto plugins will be applied to objects of specified type when they will be created.
 *
 * @discussion Register proto plugin with initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client registerProtoPlugin:[AwesomeChatPlugin class]
 *                   withIdentifier:@"com.awesome.plugin"
 *                    forObjectType:@"Chat"
 *                    configuration:@{ @"api-key": @"secret" }];
 * @endcode
 *
 * @param cls           Reference on plugin class (subclass of \b CEPPlugin) which should be called, when new object of
 *                      \c type will be created.
 * @param identifier    Reference on plugin unique identifier with which plugin will be registered for instance of \c type
 *                      object.
 * @param configuration Reference on dictionary which can be used to pass configuration to \c plugin during instantiation
 *                      process.
 * @param type          Reference on one of known types: Chat, User, Me or Search.
 */
- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(nullable NSDictionary *)configuration
              forObjectType:(NSString *)type;

/**
 * @brief  Un-register proto plugin for specified \b ChatEngine object type.
 *
 * @discussion Unregister proto plugin using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * [self.client unregisterProtoPlugin:[AwesomeChatPlugin class] forObjectType:@"Chat"];
 * @endcode
 *
 * @param cls  Reference on plugin class (subclass of \b CEPPlugin) which should be called, when new object of \c type will
 *             be created.
 * @param type Reference on one of known types: Chat, User, Me or Search.
 */
- (void)unregisterProtoPlugin:(Class)cls forObjectType:(NSString *)type;

/**
 * @brief  Un-register proto plugin by it's identifier for specified \b ChatEngine object type.
 *
 * @discussion Unregister proto plugin using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * [self.client unregisterProtoPluginWithIdentifier:@"com.awesome.plugin" forObjectType:@"Chat"];
 * @endcode
 *
 * @param identifier Reference on plugin unique identifier which should be used to find and remove plugin from \c type object
 *                   plugins list.
 * @param type       Reference on one of known types: Chat, User, Me or Search.
 */
- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
