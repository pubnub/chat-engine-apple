/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CEPMiddleware.h"
#import <CENChatEngine/CENErrorCodes.h>
#import "CENObject+PluginsDeveloper.h"
#import "CEPStructures.h"
#import "CENStructures.h"
#import "CENError.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Developer's interface declaration

@interface CEPMiddleware (Developer)


#pragma mark - Information

/**
 * @brief \a NSDictionary which is passed during plugin registration and contain extension required
 * configuration information.
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *configuration;

/**
 * @brief \a NSArray of event names for which middleware should be used.
 *
 * @discussion List may consist from exact event names or use paths with wildcard (*) or handle all
 * events by passing only '*' in returned list.
 */
@property (class, nonatomic, readonly, strong) NSArray<NSString *> *events;

/**
 * @brief \b {Object CENObject} for which middleware has been associated.
 *
 * @since 0.10.0
 */
@property (nonatomic, nullable, readonly, weak) CENObject *object;

/**
 * @brief Middleware installation location.
 *
 * @discussion Middleware will be called each time when data will pass through specified
 * location. Available locations described in \b {CEPMiddlewareLocation} structure.
 */
@property (class, nonatomic, readonly, strong) NSString *location;

/**
 * @brief Unique identifier of plugin which instantiated this middleware.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief Replace pre-defined by \c events class property list of events on which middleware should
 * be used.
 *
 * @discussion This method is useful for cases, when plugin allow to configure list of events on
 * which it should trigger middleware.
 *
 * @param events \a NSArray of event names for which middleware should be used.
 */
+ (void)replaceEventsWith:(NSArray<NSString *> *)events;


#pragma mark - Call

/**
 * @brief Run middleware's code which will update \c data as it required by it's logic.
 *
 * @discussion When multiple middleware(s) process same event, \c data is output of previous
 * middleware and after processing/update will be sent to next one.
 *
 * @param event Name of event for which middleware should adjust \c data content.
 * @param data \a NSMutableDictionary which contain information about event and result of previous
 *     middlewares execution.
 * @param block Payload processing completion block which pass information on whether middleware
 *     rejected received (causes further processing termination) data or not.
 */
- (void)runForEvent:(NSString *)event
           withData:(NSMutableDictionary *)data
         completion:(void(^)(BOOL rejected))block;


#pragma mark - Handlers

/**
 * @brief Handle middleware instantiation and registration completion for specific
 * \b {object CENObject}.
 */
- (void)onCreate;

/**
 * @brief Handle middleware destruction and unregister from specific \b {object CENObject}.
 */
- (void)onDestruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
