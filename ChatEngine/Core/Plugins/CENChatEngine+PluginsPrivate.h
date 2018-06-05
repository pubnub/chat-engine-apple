/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Plugins.h"


#pragma mark Class forward

@class CEPExtension, CENObject;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENChatEngine (PluginsPrivate)


#pragma mark - Object plugins

- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object;
- (BOOL)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(nullable dispatch_block_t)block;
- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier;
- (void)unregisterAllPluginsFromObjects:(CENObject *)object;


#pragma mark - Proto plugins

- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;
- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block;


#pragma mark - Extension

- (void)extensionForObject:(CENObject *)object
            withIdentifier:(NSString *)identifier
                   context:(void(^)(id __nullable extension))block;


#pragma mark - Middleware

- (void)runMiddlewaresAtLocation:(NSString *)location
                        forEvent:(NSString *)event
                          object:(CENObject *)object
                     withPayload:(NSDictionary *)payload
                      completion:(void(^)(BOOL rejected, NSMutableDictionary *data))block;


#pragma mark - Clean up

- (void)destroyPlugins;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
