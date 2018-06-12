/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPMiddleware.h"
#import "CENObject+PluginsDeveloper.h"
#import "CEPStructures.h"
#import "CENStructures.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Developer's interface declaration

@interface CEPMiddleware (Developer)


#pragma mark - Information

/**
 * @brief  Stores reference on dictionary which is passed during plugin registration and may contain
 *         middleware configuration information.
 */
@property (nonatomic, nullable, readonly, weak) NSDictionary *configuration;

/**
 * @brief      List of event names for which middleware should be used.
 * @discussion List may consist from exact event names or use paths with wildcard (*) or handle all events by passing only '*'
 *             in returned list.
 */
@property (class, nonatomic, readonly, strong) NSArray<NSString *> *events;

/**
 * @brief      Stores reference on middleware installation location.
 * @discussion Middleware will be called each time when data will pass through specified location. Available locations
 *             described in \b CEPMiddlewareLocation structure.
 */
@property (class, nonatomic, readonly, strong) NSString *location;

/**
 * @brief  Stores reference on unique identifier of plugin which instantiated this middleware.
 */
@property (nonatomic, readonly, strong) NSString *identifier;


#pragma mark - Call

/**
 * @brief      Run middleware's code which will update \c data as it required by it's logic.
 * @discussion When multiple middleware(s) process same event, \c data is output of previous middleware and after
 *             processing/update will be sent to next one.
 *
 * @param event Reference on name of event for which middleware should adjust \c data content.
 * @param data  Reference on dictionary which contain information about event and result of previous middlewares execution.
 * @param block Reference on processing completion block. Block pass only one argument - whether middleware reject received
 *              data and it's processing should be stopped.
 */
- (void)runForEvent:(NSString *)event withData:(NSMutableDictionary *)data completion:(void(^)(BOOL rejected))block;


#pragma mark - Handlers

/**
 * @brief      Handle middleware instantiation and registration completion for specific \b CENObject.
 * @discussion Method will be called on plugin within it's execution context (all state information can be used right in this
 *             method w/o starting new context).
 */
- (void)onCreate;

/**
 * @brief      Handle middleware destruction and unregister from specific \b CENObject.
 * @discussion Method will be called on plugin within it's execution context (all state information can be used right in this
 *             method w/o starting new context) right before middleware will be completelly removed from object.
 */
- (void)onDestruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
