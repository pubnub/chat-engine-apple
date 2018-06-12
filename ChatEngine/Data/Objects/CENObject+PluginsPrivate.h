/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENObject+Plugins.h"


#pragma mark Class forward

@class CEPMiddleware, CEPExtension;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENObject (PluginsPrivate)


#pragma mark - Information

@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *extensionsData;
@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *middlewareData;


#pragma mark - Plugins

- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
           firstInList:(BOOL)shouldBeFirstInList;


#pragma mark - Extension

/**
 * @brief  Retrieve reference on storage which used by \c extension to store data from properties in it.
 *
 * @param extension Reference on extension instance for which properties storage has been requested.
 *
 * @return Previously created or new properties storage.
 */
- (NSMutableDictionary *)propertiesStorageForExtension:(CEPExtension *)extension;

/**
 * @brief  Clean up storage which has been used by extension to store it's property values.
 *
 * @param extension Reference on extension for which data should be removed.
 */
- (void)invalidateExtensionProperties:(CEPExtension *)extension;


#pragma mark - Middleware

/**
 * @brief  Retrieve reference on storage which used by \c middleware to store data from properties in it.
 *
 * @param middleware Reference on middleware instance for which properties storage has been requested.
 *
 * @return Previously created or new properties storage.
 */
- (NSMutableDictionary *)propertiesStorageForMiddleware:(CEPMiddleware *)middleware;

/**
 * @brief  Clean up storage which has been used by middleware to store it's property values.
 *
 * @param middleware Reference on middleware for which data should be removed.
 */
- (void)invalidateMiddlewareProperties:(CEPMiddleware *)middleware;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
