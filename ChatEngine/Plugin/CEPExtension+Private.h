/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CEPExtension+Developer.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CEPExtension (Private)


#pragma mark - Information

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, nullable, weak) CENObject *object;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure extension instance.
 *
 * @param identifier Reference on unique identifier of plugin which provided this extension.
 * @param configuration Reference on dictionary which is passed during plugin registration.
 *
 * @return Configured and ready to use extension instance.
 */
+ (instancetype)extensionWithIdentifier:(NSString *)identifier
                          configuration:(nullable NSDictionary *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
