/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPPlugin+Developer.h"


#pragma mark Class forward

@class CEPMiddleware, CEPExtension, CENObject;


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CEPPlugin (Private)


#pragma mark - Information

/**
 * @brief Stores reference on identifier with which plugin instance actually has been registered.
 */
@property (nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configure plugin instance.
 *
 * @param identifier    Reference on unique plugin identifier which will override identifer provided by class.
 * @param configuration Reference on dictionary which is passed during plugin registration and will be passed by
 *                      \b ChatEngine during extension and/or middleware instantiation.
 *
 * @return Configured and ready to use plugin instance.
 */
+ (instancetype)pluginWithIdentifier:(nullable NSString *)identifier configuration:(nullable NSDictionary *)configuration;


#pragma mark - Misc

/**
 * @brief  Check whether passed value can be used as plugin identifier or not.
 *
 * @param identifier Reference on value which should be checked.
 *
 * @retrun \c YES in case if not empty string has been provided.
 */
+ (BOOL)isValidIdentifier:(NSString *)identifier;

/**
 * @brief  Check whether passed value is one of allowed \c ChatEngine object types.
 *
 * @param type Reference on value which should be checked.
 *
 * @retrun \c YES in case if passed value is one of: Chat, User, Me or Search.
 */
+ (BOOL)isValidObjectType:(NSString *)type;

/**
 * @brief  Check whether passed class can be used by \b ChatEngine as object's plugin.
 *
 * @param cls Reference on class which should be checked on compatibility with plugin requirements.
 *
 * @retrun \c YES in case if passed class can be used as plugin.
 */
+ (BOOL)isPluginClass:(Class)cls;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
