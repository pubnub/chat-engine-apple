/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+Plugins.h"


#pragma mark Class forward

@class CEPExtension, CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENChatEngine (PluginsPrivate)


#pragma mark - Object plugins

/**
 * @brief Check whether plugin which specified \c identifier registered for \b {object CENObject} or
 * not.
 *
 * @param identifier Plugin identifier which has been used during registration.
 * @param object \b {Object CENObject} for which lookup table should be used.
 *
 * @return Whether plugin registered or not.
 */
- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object;

/**
 * @brief Try to register plugin by it's class for \b {object CENObject}.
 *
 * @param cls Class of plugin which will provide extension and middleware for \b {object CENObject}.
 * @param identifier Unique plugin identifier under which it should be registered.
 * @param configuration Dictionary with configuration for \c plugin.
 * @param object \b {Object CENObject} for which interface extension and middlewares should be
 *     added.
 * @param shouldBeFirstInList Whether plugin should be pushed first in \b {object CENObject} plugins
 *     list.
 * @param block Registration completion handler block.
 */
- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(nullable dispatch_block_t)block;

/**
 * @brief Restore \b {object CENObject} interface and remove all middlewares for plugin with
 * specified \c identifier.
 *
 * @param object \b {Object CENObject} for which plugin should be removed along with it's
 *     components.
 * @param identifier Plugin identifier which has been used during registration.
 */
- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier;

/**
 * @brief Restore \b {object CENObject} interface and remove all middlewares for all plugins.
 *
 * @param object \b {Object CENObject} for which plugins should be removed along with their
 *     components.
 */
- (void)unregisterAllPluginsFromObjects:(CENObject *)object;


#pragma mark - Proto plugins

/**
 * @brief Setup plugins from proto in case if any of them registered for \b {object's CENObject}
 * type.
 *
 * @param object \b {Object CENObject} for which proto plugins should be found and instantiated.
 * @param block Plugins registration completion block.
 */
- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block;


#pragma mark - Extension

/**
 * @brief Find extension for \b {object CENObject}.
 *
 * @param object \b {Object CENObject} for which interface extension should be found.
 * @param identifier Unique plugin identifier which used during registration.
 *
 * @return Registered \c object extension or \c nil.
 */
- (nullable id)extensionForObject:(CENObject *)object withIdentifier:(NSString *)identifier;


#pragma mark - Middleware

/**
 * @brief Execute all middlewares which has been registered for \b {object CENObject} and able to
 * handle data from specified \c event.
 *
 * @param location One of \b {CEPMiddlewareLocations} structure fields.
 * @param event Name of event for which middlewares should be found and run.
 * @param object \b {Object CENObject} for which plugins registered middlewares.
 * @param payload \a NSDictionary which should be processed by each registered middleware.
 * @param block Middlewares run completion handler which pass whether any middleware rejected
 *     payload final payload or final payload in other case.
 */
- (void)runMiddlewaresAtLocation:(NSString *)location
                        forEvent:(NSString *)event
                          object:(CENObject *)object
                     withPayload:(NSDictionary *)payload
                      completion:(void(^)(BOOL rejected, NSMutableDictionary *data))block;


#pragma mark - Clean up

/**
 * @brief \b {CENChatEngine} instance destroy clean up method to remove any existing
 * extensions and middlewares.
 */
- (void)destroyPlugins;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
