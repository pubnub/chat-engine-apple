/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
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
 * @brief   Stores reference on dictionary which is passed during plugin registration and will be passed by \b ChatEngine
 *          during extension and/or middleware instantiation.
 * @warning Don't change configuration after \c onCreate has been called.
 */
@property (nonatomic, nullable, copy) NSDictionary *configuration;

/**
 * @brief Stores reference on default plugin identifier.
 */
@property (class, nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Extension

/**
 * @brief      Retrieve reference on \c object's interface extension class.
 * @discussion Depending from object type it is possible to setup different extensions by passing corresponding class in
 *             response.
 *
 * @param object Reference on \b ChatEngine object for which interface extension requested.
 *
 * @return Reference on interface extension class or \c nil in case if plugin doesn't provide interface extension for passed
 *         \c object.
 */
- (nullable Class)extensionClassFor:(CENObject *)object;


#pragma mark - Middleware

/**
 * @brief      Retrieve reference on middleware for \c object at specified \c location.
 * @discussion Depending from object type it is possible to setup different middleware for specified \c location. Available
 *             locations described in \b CEPMiddlewareLocation structure.
 *
 * @param location Reference on one of middleware mount locations described in \b CEPMiddlewareLocation structure.
 * @param object   Reference on \b ChatEngine object for which middleware at specified \c location requested.
 *
 * @return Reference on middleware class or \c nil in case if plugin doesn't provide middleware for passed \c object at
 *         specified \c location.
 */
- (nullable Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object;


#pragma mark - Handlers

/**
 * @brief      Handle plugin instantiation completion.
 * @discussion This is last point where plugin may complete it's configuration (set default values for example).
 */
- (void)onCreate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
