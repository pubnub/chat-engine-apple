/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENObject+Private.h"
#import "CENObject+PluginsPrivate.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENObject+PluginsBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
    #import "CENPluginsBuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CEPPlugablePropertyStorage+Private.h"
#import "CENChatEngine+PluginsPrivate.h"
#import "CEPMiddleware+Private.h"
#import "CEPExtension+Private.h"
#import "CEPPlugin+Private.h"


#pragma mark Interface implementation

@implementation CENObject (Plugins)


#pragma mark - Plugins

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENPluginsBuilderInterface * (^)(id plugin))plugin {
    
    CENPluginsBuilderInterface *builder;
    builder = [CENPluginsBuilderInterface builderWithExecutionBlock:^id(NSArray<NSString *> *flags, NSDictionary *arguments) {
        NSDictionary *configuration = arguments[NSStringFromSelector(@selector(configuration))];
        NSString *identifier = arguments[NSStringFromSelector(@selector(identifier))];
        id plugin = arguments[@"plugin"];
        id result = nil;
        
        if ([CEPPlugin isPluginClass:plugin]) {
            identifier = identifier ?: [plugin identifier];
        } else if (!identifier) {
            identifier = plugin;
        }
        
        if ([flags containsObject:NSStringFromSelector(@selector(store))]) {
            [self registerPlugin:plugin withIdentifier:identifier configuration:configuration];
        } else if ([flags containsObject:NSStringFromSelector(@selector(remove))]) {
            [self unregisterPluginWithIdentifier:identifier];
        } else if ([flags containsObject:NSStringFromSelector(@selector(exists))]) {
            result = @([self hasPluginWithIdentifier:identifier]);
        }
        
        return result;
    }];
    
    return ^CENPluginsBuilderInterface * (id plugin) {
        [builder setArgument:plugin forParameter:@"plugin"];
        
        return builder;
    };
}

- (CENObject * (^)(id plugin, void (^contextBlock)(CEPExtension *extension)))extension {
    
    return ^CENObject * (id plugin, void (^contextBlock)(CEPExtension *extension)) {
        NSString *identifier = nil;
        
        if ([CEPPlugin isPluginClass:plugin]) {
            identifier = [plugin identifier];
        } else  {
            identifier = plugin;
        }
        
        [self extensionWithIdentifier:identifier context:contextBlock];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (BOOL)hasPlugin:(Class)cls {
    
    if (![CEPPlugin isPluginClass:cls]) {
        return NO;
    }
    
    return [self hasPluginWithIdentifier:[cls identifier]];
}

- (BOOL)hasPluginWithIdentifier:(NSString *)identifier {
    
    if (![CEPPlugin isValidIdentifier:identifier]) {
        return NO;
    }
    
    return [self.chatEngine hasPluginWithIdentifier:identifier forObject:self];
}

- (void)registerPlugin:(Class)cls withConfiguration:(NSDictionary *)configuration {
    
    if (![CEPPlugin isPluginClass:cls]) {
        return;
    }
    
    [self registerPlugin:cls withIdentifier:[cls identifier] configuration:configuration];
}

- (void)registerPlugin:(Class)cls withIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {

    [self registerPlugin:cls withIdentifier:identifier configuration:configuration firstInList:NO];
}

- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
           firstInList:(BOOL)shouldBeFirstInList {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isPluginClass:cls]) {
        return;
    }
    
    [self.chatEngine registerPlugin:cls
                     withIdentifier:identifier
                      configuration:configuration
                          forObject:self
                        firstInList:shouldBeFirstInList
                         completion:nil];
}

- (void)unregisterPlugin:(Class)cls {
    
    if (![CEPPlugin isPluginClass:cls]) {
        return;
    }
    
    [self unregisterPluginWithIdentifier:[cls identifier]];
}

- (void)unregisterPluginWithIdentifier:(NSString *)identifier {
    
    if (![CEPPlugin isValidIdentifier:identifier]) {
        return;
    }
    
    [self.chatEngine unregisterObjects:self pluginWithIdentifier:identifier];
}


#pragma mark - Extension

- (void)extension:(Class)cls withContext:(void(^)(id extension))block {
    
    if (![CEPPlugin isPluginClass:cls]) {
        if (block) {
            block(nil);
        }
        return;
    }
        
    [self extensionWithIdentifier:[cls identifier] context:block];
}

- (void)extensionWithIdentifier:(NSString *)identifier context:(void(^)(id extension))block; {
    
    if (block) {
        if (![CEPPlugin isValidIdentifier:identifier] || ![self hasPluginWithIdentifier:identifier]) {
            block(nil);
            return;
        }
        
        [self.chatEngine extensionForObject:self withIdentifier:identifier context:block];
    }
}

- (NSMutableDictionary *)propertiesStorageForExtension:(CEPExtension *)extension {
    
    __block NSMutableDictionary *propertiesStorage = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        if (!self.extensionsData[extension.identifier]) {
            self.extensionsData[extension.identifier] = [CEPExtension newStorageForProperties];
        }
        
        propertiesStorage = self.extensionsData[extension.identifier];
    });
    
    return propertiesStorage;
}

- (void)invalidateExtensionProperties:(CEPExtension *)extension {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *storage = self.extensionsData[extension.identifier];
        
        [storage enumerateKeysAndObjectsUsingBlock:^(__unused NSString *property, id value, __unused BOOL *stop) {
            if ([value isKindOfClass:[NSTimer class]] && ((NSTimer *)value).isValid) {
                [(NSTimer *)value invalidate];
            }
        }];
        
        [storage removeAllObjects];
        [self.extensionsData removeObjectForKey:extension.identifier];
    });
}


#pragma mark - Middleware

- (NSMutableDictionary *)propertiesStorageForMiddleware:(CEPMiddleware *)middleware {
    
    __block NSMutableDictionary *propertiesStorage = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSString *identifier = [@[middleware.identifier, [[middleware class] location]] componentsJoinedByString:@"."];
        
        if (!self.middlewareData[identifier]) {
            self.middlewareData[identifier] = [CEPMiddleware newStorageForProperties];
        }
        
        propertiesStorage = self.middlewareData[identifier];
    });
    
    return propertiesStorage;
}

- (void)invalidateMiddlewareProperties:(CEPMiddleware *)middleware {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSString *identifier = [@[middleware.identifier, [[middleware class] location]] componentsJoinedByString:@"."];
        NSMutableDictionary *storage = self.middlewareData[identifier];
        
        [storage enumerateKeysAndObjectsUsingBlock:^(__unused NSString *property, id value, __unused BOOL *stop) {
            if ([value isKindOfClass:[NSTimer class]] && ((NSTimer *)value).isValid) {
                [(NSTimer *)value invalidate];
            }
        }];
        
        [storage removeAllObjects];
        [self.middlewareData removeObjectForKey:identifier];
    });
}

#pragma mark -


@end
