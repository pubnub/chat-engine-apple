/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CEPPlugin+Developer.h"


#pragma mark Class forward

@class CEPMiddleware, CEPExtension, CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CEPPlugin (Private)


#pragma mark - Information

@property (nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure plugin instance.
 *
 * @param identifier Unique plugin identifier under which it should be registered.
 *     \b Default: Plugin default identifier
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *     \b Default: @{}
 *
 * @return Configured and ready to use plugin instance.
 */
+ (instancetype)pluginWithIdentifier:(nullable NSString *)identifier
                       configuration:(nullable NSDictionary *)configuration;


#pragma mark - Misc

/**
 * @brief Check whether passed value can be used as plugin identifier or not.
 *
 * @param identifier Value which should be checked.
 *
 * @return Whether passed identifier can be used by plugin or not.
 */
+ (BOOL)isValidIdentifier:(NSString *)identifier;

/**
 * @brief Check whether passed value is one of allowed \b {object CENObject} type.
 *
 * @param type Value which should be checked.
 *
 * @return Whether passed type is one of: Chat, User, Me or Search.
 */
+ (BOOL)isValidObjectType:(NSString *)type;

/**
 * @brief Check whether passed value can be associated with plugin or not.
 *
 * @param object Instance which should be checked.
 *
 * @return Whether passed object can be used to register plugin on it or not.
 *
 * @since 0.9.3
 */
+ (BOOL)isValidObject:(CENObject *)object;

/**
 * @brief Check whether passed value can be used as plugin's configuration or not.
 *
 * @param configuration Instance which should be checked.
 *
 * @return Whether passed object can be used by plugin as configuration or not.
 *
 * @since 0.9.3
 */
+ (BOOL)isValidConfiguration:(NSDictionary *)configuration;

/**
 * @brief Check whether passed class can be used by \b {CENChatEngine} as object's
 * plugin.
 *
 * @param cls Class which should be checked on compatibility with plugin requirements.
 *
 * @return Whether passed class can be used as plugin or not.
 */
+ (BOOL)isPluginClass:(Class)cls;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
