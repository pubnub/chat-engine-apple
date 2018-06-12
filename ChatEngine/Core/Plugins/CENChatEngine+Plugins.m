/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+PluginsPrivate.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENChatEngine+PluginsBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
    #import "CENPluginsBuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+Private.h"
#import "CENPrivateStructures.h"
#import "CEPPlugin+Private.h"
#import "CENObject+Private.h"


#pragma mark Interface implementation

@implementation CENChatEngine (Plugins)


#pragma mark - Plugins

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENPluginsBuilderInterface * (^)(NSString *object, id plugin))proto {
    
    CENPluginsBuilderInterface *builder;
    builder = [CENPluginsBuilderInterface builderWithExecutionBlock:^id(NSArray<NSString *> *flags, NSDictionary *arguments) {
        id result = nil;
        NSString *object = arguments[@"object"];
        id plugin = arguments[@"plugin"];
        NSString *identifier = arguments[NSStringFromSelector(@selector(identifier))];
        NSDictionary *configuration = arguments[NSStringFromSelector(@selector(configuration))];
        if ([CEPPlugin isPluginClass:plugin]) {
            identifier = identifier ?: [plugin identifier];
        } else if (!identifier) {
            identifier = plugin;
        }
        
        if ([flags containsObject:NSStringFromSelector(@selector(store))]) {
            [self registerProtoPlugin:plugin withIdentifier:identifier configuration:configuration forObjectType:object];
        } else if ([flags containsObject:NSStringFromSelector(@selector(remove))]) {
            [self unregisterProtoPluginWithIdentifier:identifier forObjectType:object];
        } else if ([flags containsObject:NSStringFromSelector(@selector(exists))]) {
            result = @([self hasProtoPluginWithIdentifier:identifier forObjectType:object]);
        }
        
        return result;
    }];
    
    return ^CENPluginsBuilderInterface * (NSString *object, id plugin) {
        [builder setArgument:object forParameter:@"object"];
        [builder setArgument:plugin forParameter:@"plugin"];
        
        return builder;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE


#pragma mark - Object plugins

- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]]) {
        return NO;
    }
    
    return [self.pluginsManager hasPluginWithIdentifier:identifier forObject:object];
}

- (BOOL)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(dispatch_block_t)block {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]]) {
        return NO;
    }
    
    return [self.pluginsManager registerPlugin:cls
                                withIdentifier:identifier
                                 configuration:configuration
                                     forObject:object
                                   firstInList:shouldBeFirstInList
                                    completion:block];
}

- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]]) {
        return;
    }
    
    [self.pluginsManager unregisterObjects:object pluginWithIdentifier:identifier];
}

- (void)unregisterAllPluginsFromObjects:(CENObject *)object {
    
    if (![object isKindOfClass:[CENObject class]]) {
        return;
    }
    
    [self.pluginsManager unregisterAllFromObjects:object];
}


#pragma mark - Proto plugins

- (BOOL)hasProtoPlugin:(Class)cls forObjectType:(NSString *)type {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidObjectType:type]) {
        return NO;
    }
    
    return [self hasProtoPluginWithIdentifier:[cls identifier] forObjectType:type];
}

- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:type]) {
        return NO;
    }
    
    return [self.pluginsManager hasProtoPluginWithIdentifier:identifier forObjectType:type];
}

- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block {
    
    [self.pluginsManager setupProtoPluginsForObject:object withCompletion:block];
}

- (void)registerProtoPlugin:(Class)cls withConfiguration:(NSDictionary *)configuration forObjectType:(NSString *)type {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidObjectType:type]) {
        return;
    }
    
    [self registerProtoPlugin:cls withIdentifier:[cls identifier] configuration:configuration forObjectType:type];
}

- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(NSDictionary *)configuration
              forObjectType:(NSString *)type {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:type]) {
        return;
    }
    
    [self.pluginsManager registerProtoPlugin:cls withIdentifier:identifier configuration:configuration forObjectType:type];
}

- (void)unregisterProtoPlugin:(Class)cls forObjectType:(NSString *)type {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidObjectType:type]) {
        return;
    }
    
    [self unregisterProtoPluginWithIdentifier:[cls identifier] forObjectType:type];
}

- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:type]) {
        return;
    }
    
    [self.pluginsManager unregisterProtoPluginWithIdentifier:identifier forObjectType:type];
}


#pragma mark - Extension

- (void)extensionForObject:(CENObject *)object withIdentifier:(NSString *)identifier context:(void(^)(id extension))block {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]] || !block) {
        return;
    }
    
    [self.pluginsManager extensionForObject:object withIdentifier:identifier context:block];
}


#pragma mark - Middleware

- (void)runMiddlewaresAtLocation:(NSString *)location
                        forEvent:(NSString *)event
                          object:(CENObject *)object
                     withPayload:(NSDictionary *)payload
                      completion:(void(^)(BOOL rejected, NSMutableDictionary *data))block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.pluginsManager runMiddlewaresAtLocation:location forEvent:event object:object withPayload:payload completion:block];
    });
}


#pragma mark - Clean up

- (void)destroyPlugins {
    
    [self.pluginsManager destroy];
}

#pragma mark -


@end
