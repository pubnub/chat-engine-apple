/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPMiddleware+Developer.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CEPMiddleware (Private)


#pragma mark - Information

/**
 * @brief  Stores reference on list of available middleware installation locations.
 */
@property (class, nonatomic, readonly, copy) NSArray<NSString *> *locations;

/**
 * @brief  Stores reference on unique identifier of plugin which instantiated this middleware.
 */
@property (nonatomic, readonly, strong) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configure middleware instance.
 *
 * @param identifier    Reference on unique identifier of plugin which provided this middleware.
 * @param configuration Reference on dictionary which is passed during plugin registration.
 *
 * @return Configured and ready to use plugin instance.
 */
+ (instancetype)middlewareWithIdentifier:(NSString *)identifier configuration:(nullable NSDictionary *)configuration;


#pragma mark - Events

- (BOOL)registeredForEvent:(NSString *)event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
