/**
 * @ref 9a1ef67b-57ab-43ac-8756-5dfbe5c3b80a
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CEPMiddleware.h"
#import <CENChatEngine/CENChatEngine+PluginsDeveloper.h>
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
 *
 * @ref e4e2cdc3-4ac2-4c4c-a817-2e2188f9efe6
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *configuration;

/**
 * @brief \a NSArray of event names for which middleware should be used.
 *
 * @discussion List may consist from exact event names or use paths with wildcard (*) or handle all
 * events by passing only '*' in returned list.
 *
 * @ref 88e9dfd4-d220-40f7-979d-6d5570d76b82
 */
@property (class, nonatomic, readonly, strong) NSArray<NSString *> *events;

/**
 * @brief \b {Object CENObject} subclass instance for which middleware has been associated.
 *
 * @since 0.9.3
 *
 * @ref d25d3466-bd98-47c3-969e-db2abcc25806
 */
@property (nonatomic, nullable, readonly, weak) CENObject *object;

/**
 * @brief Middleware installation location.
 *
 * @discussion Middleware will be called each time when data will pass through specified
 * location. Available locations (each is field inside of \c CEPMiddlewareLocation typedef struct):
 * - \c emit - location which is triggered when \b {CENChatEngine} is about to send any name of
 *   emitted event data to \b PubNub real-time network
 * - \c on - location which is triggered when \b {CENChatEngine} receive any data from \b PubNub
 *   real-time network
 *
 * @ref 2bde74ae-8ff4-4de8-bd12-13690db1e3e4
 */
@property (class, nonatomic, readonly, strong) NSString *location;

/**
 * @brief Unique identifier of plugin which instantiated this middleware.
 *
 * @ref 78be8d34-2d41-42b0-9ced-65eeaccb1f9d
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
 *
 * @ref 9b26b53a-558c-4d4e-b914-c6bc6b99b97f
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
 *     middleware execution.
 * @param block Payload processing completion block / closure which pass information on whether
 *     middleware rejected received (causes further processing termination) data or not.
 *
 * @ref c051797c-e0d0-401d-9ead-eff647bb3b96
 */
- (void)runForEvent:(NSString *)event
           withData:(NSMutableDictionary *)data
         completion:(void(^)(BOOL rejected))block;


#pragma mark - Handlers

/**
 * @brief Handle middleware instantiation and registration completion for specific
 * \b {object}.
 *
 * @ref 3977ce1e-4a7b-4260-a2a2-c8b55f5fd424
 */
- (void)onCreate;

/**
 * @brief Handle middleware destruction and unregister from specific \b {object}.
 *
 * @ref 4cf9382c-3939-45c0-b354-726630362d1d
 */
- (void)onDestruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
