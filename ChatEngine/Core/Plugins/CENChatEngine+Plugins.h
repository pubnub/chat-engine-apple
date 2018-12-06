#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for \c plugins management.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (Plugins)

/**
 * @brief Check whether there is proto plugin registered for specified \b {ChatEngine CENChatEngine}
 * object type or not.
 *
 * @discussion Check whether proto plugin registered using it's class for \c Chat or not
 * @code
 * // objc fccb32cf-dd1c-4f6f-a5ce-47f0eb35a817
 *
 * if (![self.client hasProtoPlugin:[AwesomeChatPlugin class] forObjectType:@"Chat"]) {
 *     // Looks like 'Chat' objects doesn't have proto plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @param cls Class of plugin (subclass of \b {CEPPlugin}) which should be used for search in
 *     \c type proto plugins list.
 * @param type One of known types: \c Chat, \c User, \c Me or \c Search.
 *
 * @return Whether proto plugin registered or not.
 *
 * @ref df0791d4-92ea-48ad-8ad3-c89f0b1cc179
 */
- (BOOL)hasProtoPlugin:(Class)cls forObjectType:(NSString *)type;

/**
 * @brief Check whether there is proto plugin with \c identifier registered for specified
 * \b {ChatEngine CENChatEngine} object type or not.
 *
 * @discussion Check whether proto plugin registered using it's identifier for \c Chat or not
 * @code
 * // objc 2c947a51-1963-4a1f-9527-bb2d81c5e113
 *
 * if (![self.client hasProtoPluginWithIdentifier:@"chatengine.emoji" forObjectType:@"Chat"]) {
 *     // Looks like 'Chat' objects doesn't have proto plugin with 'chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @param identifier Plugin identifier which has been used during registration.
 * @param type One of known types: \c Chat, \c User, \c Me or \c Search.
 *
 * @return Whether proto plugin registered or not.
 *
 * @ref 0d0e3dd9-c636-4272-a243-f7e51708f486
 */
- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

/**
 * @brief Register proto plugin for specified \b {ChatEngine CENChatEngine} object type.
 *
 * @discussion Register proto plugin class w/o \c configuration for \c Chat
 * @code
 * // objc a9b4d909-f198-4ff6-b125-49bbaa2b4637
 *
 * [self.client registerProtoPlugin:[AwesomeChatPlugin class]
 *                    forObjectType:@"Chat"
 *                    configuration:nil];
 * @endcode
 *
 * @param cls Class of plugin (subclass of \b {CEPPlugin}) which should be registered for object of
 *     \c type.
 * @param configuration Dictionary with configuration for \c plugin.
 * @param type One of known types: \c Chat, \c User, \c Me or \c Search.
 *
 * @ref 41e188a3-f2dc-4f17-a11a-e12ac0a99b8f
 */
- (void)registerProtoPlugin:(Class)cls
          withConfiguration:(nullable NSDictionary *)configuration
              forObjectType:(NSString *)type;

/**
 * @brief Register proto plugin with identifier for specified \b {ChatEngine CENChatEngine} object
 * type.
 *
 * @discussion Register proto plugin with custom \c identifier with \c configuration for \c Chat
 * @code
 * // objc f3f5c385-7d01-4a32-aca5-dfca10d01fd0
 *
 * [self.client registerProtoPlugin:[AwesomeChatPlugin class]
 *                   withIdentifier:@"com.awesome.plugin"
 *                    forObjectType:@"Chat"
 *                    configuration:@{ @"api-key": @"secret" }];
 * @endcode
 *
 * @param cls Class of plugin (subclass of \b {CEPPlugin}) which should be registered for object of
 *     \c type.
 * @param identifier Unique plugin identifier with which plugin will be registered for instance of
 *     \c type object.
 * @param configuration Dictionary with configuration for \c plugin.
 * @param type One of known types: \c Chat, \c User, \c Me or \c Search.
 *
 * @ref 691b3c6f-ff89-4c39-9bd2-d9b493a36dac
 */
- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(nullable NSDictionary *)configuration
              forObjectType:(NSString *)type;

/**
 * @brief Un-register proto plugin from specified \b {ChatEngine CENChatEngine} object type along
 * with already instantiated plugins.
 *
 * @discussion Unregister proto plugin using it's class from \c Chat
 * @code
 * // objc 59bea506-4ef8-4384-94e8-bf4b68c8b82b
 *
 * [self.client unregisterProtoPlugin:[AwesomeChatPlugin class] forObjectType:@"Chat"];
 * @endcode
 *
 * @param cls Class of plugin (subclass of \b {CEPPlugin}) which should be removed.
 * @param type One of known types: \c Chat, \c User, \c Me or \c Search.
 *
 * @ref 77a3d358-3582-477b-918f-84221d7735f7
 */
- (void)unregisterProtoPlugin:(Class)cls forObjectType:(NSString *)type;

/**
 * @brief Un-register proto plugin by it's identifier from specified \b {ChatEngine CENChatEngine}
 * object type along with already instantiated plugins.
 *
 * @discussion Unregister proto plugin using it's identifier from \c Chat
 * @code
 * // objc ae5dbd06-9843-4ca7-a810-a6fc3a5e8d57
 *
 * [self.client unregisterProtoPluginWithIdentifier:@"com.awesome.plugin" forObjectType:@"Chat"];
 * @endcode
 *
 * @param identifier Unique identifier from plugin which should be removed.
 * @param type One of known types: \c Chat, \c User, \c Me or \c Search.
 *
 * @ref e9347636-fb97-475b-a3f2-4591aa9367e3
 */
- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
