/**
 * @ref 036d3be7-603b-42c7-aa46-40106c326725
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+PluginsDeveloper.h>
#import <CENChatEngine/CENObject+Plugins.h>
#import <CENChatEngine/CEPStructures.h>
#import <CENChatEngine/CENStructures.h>
#import <CENChatEngine/CENErrorCodes.h>
#import <CENChatEngine/CEPPlugin.h>
#import <CENChatEngine/CENError.h>


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Developer's interface declaration

@interface CEPPlugin (Developer)


#pragma mark - Information

/**
 * @brief \a NSDictionary which is passed during plugin registration and will be passed by
 * \b {CENChatEngine} during extension and/or middleware instantiation.
 *
 * @ref 353e9a75-8d7a-43c7-85e8-3611dd36caf1
 */
@property (nonatomic, nullable, copy) NSDictionary *configuration;

/**
 * @brief Unique plugin identifier.
 *
 * @ref 83b50e86-be21-496e-8b2d-7f2e0712ca87
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
 *
 * @ref 29410eee-1efc-43ed-b01d-ad35d2647533
 */
- (nullable Class)extensionClassFor:(CENObject *)object;


#pragma mark - Middleware

/**
 * @brief Get middleware class for \b {object CENObject} at specified \c location.
 *
 * @discussion Depending from object type it is possible to setup different middleware for specified
 * \c location. Available locations explained in \b {CEPMiddleware.location}.
 *
 * @param location Location at which middleware expected to be used.
 * @param object \b {Object CENObject} for which middleware at specified \c location requested.
 *
 * @return Middleware class or \c nil in case if plugin doesn't provide middleware for passed
 * \b {object CENObject} at specified \c location.
 *
 * @ref 10021ced-9416-43d8-bbbe-ffc35b3afc36
 */
- (nullable Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object;


#pragma mark - Handlers

/**
 * @brief Handle plugin instantiation completion.
 *
 * @discussion Also, this handler is last place where configuration can be modified (for example
 * default values is set) before it will be passed to \b {extensions CEPExtension} and
 * \b {middleware CEPMiddleware}.
 *
 * @ref 18b95059-c373-44a4-9d3d-56f99feb3b67
 */
- (void)onCreate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
