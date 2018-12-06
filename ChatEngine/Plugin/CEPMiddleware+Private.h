/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CEPMiddleware+Developer.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CEPMiddleware (Private)


#pragma mark - Information

/**
 * @brief \a NSArray with middleware available installation locations.
 */
@property (class, nonatomic, readonly, copy) NSArray<NSString *> *locations;

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, nullable, weak) CENObject *object;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure middleware instance.
 *
 * @param identifier Reference on unique identifier of plugin which provided this middleware.
 * @param configuration Reference on dictionary which is passed during plugin registration.
 *
 * @return Configured and ready to use plugin instance.
 */
+ (instancetype)middlewareWithIdentifier:(NSString *)identifier
                           configuration:(nullable NSDictionary *)configuration;


#pragma mark - Events

/**
 * @brief Check whether middleware can be launched for \c event or not.
 *
 * @param event Name of event against which middleware should be checked.
 *
 * @return Whether middleware can be launched or not.
 */
- (BOOL)registeredForEvent:(NSString *)event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
