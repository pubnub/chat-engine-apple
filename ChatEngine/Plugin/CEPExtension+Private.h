/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CEPExtension+Developer.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CEPExtension (Private)


#pragma mark - Information

@property (nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure extension instance.
 *
 * @param object \b {Object CENObject} for which extended interface will be created.
 * @param identifier Unique identifier of plugin which provided this extension.
 * @param configuration \a NSDictionary which is passed during plugin registration.
 *
 * @return Configured and ready to use extension instance.
 */
+ (instancetype)extensionForObject:(CENObject *)object
                    withIdentifier:(NSString *)identifier
                     configuration:(nullable NSDictionary *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
