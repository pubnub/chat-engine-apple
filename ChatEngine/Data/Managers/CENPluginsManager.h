#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CENChatEngine, CENObject;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} plugins manager.
 *
 * @discussion Manager responsible for plugins instantiation and setup for objects for which they
 * has been registered.
 *
 * @ref 6435b762-fe31-4753-9971-965e2daf8b19
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENPluginsManager : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure plugins manager.
 *
 * @param chatEngine \b {CENChatEngine} instance which manage objects for which plugins
 *     should be managed.
 *
 * @return Configured and ready to use plugins manager instance.
 */
+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Instantiate plugins manager.
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - attempt to create instance using \c new.
 *
 * @return \c nil.
 */
- (instancetype) __unavailable init;


#pragma mark - Plugins management

/**
 * @brief Check whether plugin registered for \b {object CENObject} or not.
 *
 * @param identifier Unique plugin identifier.
 * @param object \b {Object CENObject} for which check should be done.
 *
 * @return Whether plugin with specified identifier currently registered for \b {object CENObject}
 * or not.
 */
- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object;

/**
 * @brief Register plugin for specific\b {object CENObject}.
 *
 * @param cls Class of plugin which will provide extension and middleware for \b {object CENObject}.
 * @param identifier Unique plugin identifier under which it should be registered.
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *     \b Default: @{}
 * @param object \b {Object CENObject} for which plugin provides extension and middleware
 *     components.
 * @param shouldBeFirstInList Whether plugin should be pushed first in \c object plugins list.
 * @param block Registration completion block.
 */
- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(nullable dispatch_block_t)block;

/**
 * @brief Unregister plugin from specific \b {object CENObject}.
 *
 * @param object \b {Object CENObject} from which plugin's extension and middleware components will
 *     be removed.
 * @param identifier Unique plugin identifier which has been used during registration.
 */
- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier;

/**
 * @brief Unregister all plugins from specific \b {object CENObject}.
 *
 * @param object \b {Object CENObject} from which all plugins should be removed.
 */
- (void)unregisterAllFromObjects:(CENObject *)object;


#pragma mark - Proto plugins management

/**
 * @brief Check proto plugin registration for specific object \c type.
 *
 * @param identifier Unique plugin identifier.
 * @param type One of \b {CENObjectType} structure fields.
 *
 * @return Whether proto plugin with specified \c identifier registered for objects type or not.
 */
- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

/**
 * @brief Instantiate object's plugins from list of registered proto plugins for object's type.
 *
 * @param object \b {Object CENObject} for which proto plugins should be instantiated and registered.
 * @param block Instantiation and registration completion block.
 */
- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block;

/**
 * @brief Register proto plugin for objects of specific \c type.
 *
 * @param cls Class of plugin which should be registered for all objects of specified \c type.
 * @param identifier Unique plugin identifier under which it should be registered.
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *     \b Default: @{}
 * @param type One of \b {CENObjectType} structure fields.
 */
- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(nullable NSDictionary *)configuration
              forObjectType:(NSString *)type;

/**
 * @brief Unregister proto plugins for specific object \c type along with instantiated plugins.
 *
 * @param identifier Unique plugin identifier which has used during registration.
 * @param type One of \b {CENObjectType} structure fields.
 */
- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;


#pragma mark - Extension

/**
 * @brief Find \c object extension.
 *
 * @param object \b {Object CENObject} for which interface extension should be found.
 * @param identifier Unique plugin identifier which used during registration.
 *
 * @return Registered \c object extension or \c nil.
 */
- (nullable id)extensionForObject:(CENObject *)object withIdentifier:(NSString *)identifier;


#pragma mark - Middleware

/**
 * @brief Run set of middlewares which has been registered for \c object for specific \c event.
 *
 * @param location One of \b {CEPMiddlewareLocations} structure fields.
 * @param event Name of event for which middlewares should be found and run.
 * @param object Object for which plugins registered middlewares.
 * @param payload Object which should be processed by each registered middleware.
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
 * @brief Clean up all used resources.
 *
 * @discussion Clean up any registered proto plugins and plugins which has been registered on
 * \b {CENObject} subclasses till this moment.
 */
- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
