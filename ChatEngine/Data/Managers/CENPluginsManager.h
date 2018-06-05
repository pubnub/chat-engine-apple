#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CEPMiddleware, CEPExtension, CENChatEngine, CENObject;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine plugins manager.
 * @discussion Manager responsible for plugins instantiation and setup for objects for which they has been registered.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENPluginsManager : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configured new users manager instance.
 *
 * @param chatEngine Reference on \b ChatEngine instance to which users will be bound.
 *
 * @return Configured and ready to use manager.
 */
+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief  Instantiation should be done using class method \c +managerForChatEngine:.
 *
 * @throws \a NSException
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype) __unavailable init;


#pragma mark - Plugins management

- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object;
- (BOOL)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(nullable dispatch_block_t)block;
- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier;
- (void)unregisterAllFromObjects:(CENObject *)object;


#pragma mark - Proto plugins management

- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;
- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block;
- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(nullable NSDictionary *)configuration
              forObjectType:(NSString *)type;
- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;


#pragma mark - Extension

- (void)extensionForObject:(CENObject *)object withIdentifier:(NSString *)identifier context:(void(^)(id __nullable extension))block;


#pragma mark - Middleware

- (void)runMiddlewaresAtLocation:(NSString *)location
                        forEvent:(NSString *)event
                          object:(CENObject *)object
                     withPayload:(NSDictionary *)payload
                      completion:(void(^)(BOOL rejected, NSMutableDictionary *data))block;


#pragma mark - Clean up

- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
