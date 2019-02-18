/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *args) {
        NSDictionary *configuration = args[NSStringFromSelector(@selector(configuration))];
        NSString *identifier = args[NSStringFromSelector(@selector(identifier))];
        id plugin = args[@"plugin"];
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
    };
    
    CENPluginsBuilderInterface *builder;
    builder = [CENPluginsBuilderInterface builderWithExecutionBlock:block];
    
    return ^CENPluginsBuilderInterface * (id plugin) {
        [builder setArgument:plugin forParameter:@"plugin"];
        return builder;
    };
}

- (id (^)(id plugin))extension {
    
    return ^(id plugin) {
        NSString *identifier = [CEPPlugin isPluginClass:plugin] ? [plugin identifier] : plugin;
        
        return [self extensionWithIdentifier:identifier];
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
    
    [self.chatEngine unregisterObjects:self pluginWithIdentifier:identifier];
}


#pragma mark - Extension

- (id)extension:(Class)cls {

    id extension = nil;

    if ([CEPPlugin isPluginClass:cls]) {
        extension = [self extensionWithIdentifier:[cls identifier]];
    }
        
    return extension;
}

- (id)extensionWithIdentifier:(NSString *)identifier {

    return [self.chatEngine extensionForObject:self withIdentifier:identifier];
}

#pragma mark -


@end
