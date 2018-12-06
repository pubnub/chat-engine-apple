/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENObject+Private.h"
#import "CENObject+PluginsPrivate.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENObject+PluginsBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
    #import "CENPluginsBuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

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
    builder = [CENPluginsBuilderInterface builderWithExecutionBlock:^id(NSArray<NSString *> *flags,
                                                                        NSDictionary *arguments) {
        
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

- (void (^)(id plugin, void (^contextBlock)(CEPExtension *extension)))extension {
    
    return ^(id plugin, void (^contextBlock)(CEPExtension *extension)) {
        NSString *identifier = [CEPPlugin isPluginClass:plugin] ? [plugin identifier] : plugin;
        
        [self extensionWithIdentifier:identifier context:contextBlock];
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

- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(NSDictionary *)configuration {

    [self registerPlugin:cls withIdentifier:identifier configuration:configuration firstInList:NO];
}

- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(NSDictionary *)configuration
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

- (void)extensionWithIdentifier:(NSString *)identifier context:(void(^)(id extension))block {
    
    if (!block || ![CEPPlugin isValidIdentifier:identifier] ||
        ![self hasPluginWithIdentifier:identifier]) {
        if (block) {
            block(nil);
        }
        
        return;
    }
        
    [self.chatEngine extensionForObject:self withIdentifier:identifier context:block];
}

#pragma mark -


@end
