/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CEPPlugin.h"
#import <CENChatEngine/CEPStructures.h>
#import <CENChatEngine/CENStructures.h>
#import <CENChatEngine/CENErrorCodes.h>
#import "CENObject+Plugins.h"
#import "CENError.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Developer's interface declaration

@interface CEPPlugin (Developer)


#pragma mark - Information

/**
 * @brief \a NSDictionary which is passed during plugin registration and will be passed by
 * \b {ChatEngine CENChatEngine} during extension and/or middleware instantiation.
 */
@property (nonatomic, nullable, copy) NSDictionary *configuration;

/**
 * @brief Unique plugin identifier.
 */
@property (class, nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Extension

/**
 * @brief Get interface extension class for \b {object CENObject}.
 *
 * @discussion Depending from object type it is possible to setup different extensions by passing
 * corresponding class in response.
 *
 * @param object \b {Object CENObject} for which interface extension requested.
 *
 * @return Interface extension class or \c nil in case if plugin doesn't provide one for passed
 * \b {object CENObject}.
 */
- (nullable Class)extensionClassFor:(CENObject *)object;


#pragma mark - Middleware

/**
 * @brief Get middleware class for \b {object CENObject} at specified \c location.
 *
 * @discussion Depending from object type it is possible to setup different middleware for specified
 * \c location. Available locations described in \b {CEPMiddlewareLocation} structure.
 *
 * @param location Location at which middleware expected to be used.
 * @param object \b {Object CENObject} for which middleware at specified \c location requested.
 *
 * @return Middleware class or \c nil in case if plugin doesn't provide middleware for passed
 * \b {object CENObject} at specified \c location.
 */
- (nullable Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object;


#pragma mark - Handlers

/**
 * @brief Handle plugin instantiation completion.
 */
- (void)onCreate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
