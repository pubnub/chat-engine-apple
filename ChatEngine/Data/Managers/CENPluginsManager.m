/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENPluginsManager.h"
#import "CEPPlugablePropertyStorage+Private.h"
#import "CEPMiddleware+Developer.h"
#import "CENObject+PluginsPrivate.h"
#import "CEPExtension+Developer.h"
#import "CEPMiddleware+Private.h"
#import "CENChatEngine+Private.h"
#import "CEPExtension+Private.h"
#import "CEPPlugin+Developer.h"
#import "CEPPlugin+Private.h"
#import "CENObject+Private.h"
#import "CENLogMacro.h"


#pragma mark Structures

CEPluginDataKeys CEPluginData = {
    .objects = @"o",
    .instances = @"i",
    .referencesCount = @"rc",
    .extensions = @"e",
    .middlewares = @"m"
};


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENPluginsManager ()

@property (nonatomic, strong) NSDictionary<NSString *, NSMutableDictionary *> *protoPlugins;
@property (nonatomic, strong) NSDictionary<NSString *, NSMutableDictionary *> *middlewares;
@property (nonatomic, strong) NSDictionary<NSString *, NSMutableDictionary *> *extensions;
@property (nonatomic, strong) NSDictionary<NSString *, NSMutableDictionary *> *objects;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, nullable, weak) CENChatEngine *chatEngine;


#pragma mark - Extension

- (nullable CEPExtension *)extensionWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;
- (BOOL)hasExtensionFromPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object;
- (void)registerExtensionFromPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object withRegistrationGroup:(dispatch_group_t)group;
- (BOOL)unregisterExtensionWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object;
- (void)reuseExtension:(CEPExtension *)extension forObject:(CENObject *)object withRegistrationGroup:(dispatch_group_t)group;
- (void)useExtension:(CEPExtension *)extension withObject:(CENObject *)object context:(void(^)(id extension))block;
- (void)prepareDataForExtension:(CEPExtension *)extension toUseWithObject:(CENObject *)object;


#pragma mark - Middleware

- (nullable NSArray<CEPMiddleware *> *)middlewaresWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;
- (BOOL)hasMiddlewareFromPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object;
- (nullable NSArray<NSString *> *)middlewareIdentifiersAtLocation:(NSString *)location forObject:(CENObject *)object;
- (nullable NSArray<CEPMiddleware *> *)middlewaresWithIdentifiers:(NSArray<NSString *> *)identifiers
                                                         forEvent:(NSString *)event
                                                           object:(CENObject *)object;
- (void)registerMiddlewaresFromPlugin:(CEPPlugin *)plugin
                            forObject:(CENObject *)object
                          firstInList:(BOOL)shouldBeFirstInList
                withRegistrationGroup:(dispatch_group_t)group;
- (BOOL)unregisterMiddlewaresWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object;
- (void)reuseMiddlewares:(NSArray<CEPMiddleware *> *)middlewares
               forObject:(CENObject *)object
             firstInList:(BOOL)shouldBeFirstInList
   withRegistrationGroup:(dispatch_group_t)group;
- (void)useMiddleware:(CEPMiddleware *)middleware withObject:(CENObject *)object context:(void(^)(CEPMiddleware *middleware))block;
- (void)useMiddleware:(CEPMiddleware *)middleware
           withObject:(CENObject *)object
              onQueue:(BOOL)shouldUseQueue
              context:(void(^)(CEPMiddleware *middleware))block;
- (void)prepareDataForMiddleware:(CEPMiddleware *)middleware toUseWithObject:(CENObject *)object;


#pragma mark - Plugins management

- (BOOL)registerProto:(BOOL)isProto
               plugin:(CEPPlugin *)plugin
            forObject:(CENObject *)object
          firstInList:(BOOL)shouldBeFirstInList
withRegistrationGroup:(dispatch_group_t)group;


#pragma mark - Proto plugins management

- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPluginsManager


#pragma mark - Initialization and Configuration

+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine {
    
    return [[self alloc] initWithChatEngine:chatEngine];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException format:@"-init not implemented, please use: +managerForChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        
        _objects = @{
            CEPluginData.objects: [NSMutableDictionary new],
            CEPluginData.extensions: [NSMutableDictionary new],
            CEPluginData.middlewares: [NSMutableDictionary new]
        };
        
        _protoPlugins = @{
            CEPluginData.objects: [NSMutableDictionary new],
            CEPluginData.instances: [NSMutableDictionary new],
            CEPluginData.referencesCount: [NSMutableDictionary new]
        };
        
        _extensions = @{
            CEPluginData.instances: [NSMutableDictionary new],
            CEPluginData.referencesCount: [NSMutableDictionary new]
        };
        
        _middlewares = @{
            CEPluginData.instances: [NSMutableDictionary new],
            CEPluginData.referencesCount: [NSMutableDictionary new]
        };
        
        NSString *resourceQueueIdentifier = [NSString stringWithFormat:@"com.chatengine.manager.plugins.%p", self];
        _resourceAccessQueue = dispatch_queue_create([resourceQueueIdentifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _chatEngine = chatEngine;
        
        CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::Manager::Plugins> %p instance allocation", self);
    }
    
    return self;
}


#pragma mark - Extension

- (CEPExtension *)extensionWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    return self.extensions[CEPluginData.instances][type.lowercaseString][identifier];
}

- (BOOL)hasExtensionFromPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    
    return [self.objects[CEPluginData.extensions][objectType][plugin.identifier] containsObject:object];
}

- (void)registerExtensionFromPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object withRegistrationGroup:(dispatch_group_t)group {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    Class cls = [plugin extensionClassFor:object];
    NSString *identifier = plugin.identifier;
    CEPExtension *extension = [cls extensionWithIdentifier:identifier configuration:plugin.configuration];
    
    if (!extension) {
        return;
    }
    
    if (!self.extensions[CEPluginData.instances][objectType]) {
        self.extensions[CEPluginData.instances][objectType] = [NSMutableDictionary new];
        self.extensions[CEPluginData.referencesCount][objectType] = [NSMutableDictionary new];
    }
    
    self.extensions[CEPluginData.referencesCount][objectType][identifier] = @0;
    self.extensions[CEPluginData.instances][objectType][identifier] = extension;

    [self reuseExtension:extension forObject:object withRegistrationGroup:group];
}

- (BOOL)unregisterExtensionWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    BOOL extensionExistsForObject = [self.objects[CEPluginData.extensions][objectType][identifier] containsObject:object];
    
    if (!extensionExistsForObject) {
        return extensionExistsForObject;
    }
    
    CEPExtension *extension = self.extensions[CEPluginData.instances][objectType][identifier];
    NSMutableDictionary<NSString *, NSNumber *> *refs = self.extensions[CEPluginData.referencesCount][objectType];
    
    if (refs[identifier].unsignedIntegerValue > 0) {
        refs[identifier] = @(refs[identifier].unsignedIntegerValue - 1);
    }
    
    if (refs[identifier].unsignedIntegerValue == 0) {
        [self.extensions[CEPluginData.referencesCount][objectType] removeObjectForKey:identifier];
        [self.extensions[CEPluginData.instances][objectType] removeObjectForKey:identifier];
    }
    
    [self.objects[CEPluginData.extensions][objectType][identifier] removeObject:object];
    [self.objects[CEPluginData.objects][object.identifier][CEPluginData.extensions] removeObject:identifier];
    
    if (!((NSHashTable *)self.objects[CEPluginData.extensions][objectType][identifier]).count) {
        [self.objects[CEPluginData.extensions][objectType] removeObjectForKey:identifier];
    }
    
    [self extensionForObject:object withIdentifier:identifier context:^(CEPExtension *objectExtension) {
        [objectExtension onDestruct];
        
        [object invalidateExtensionProperties:extension];
    }];
    
    return extensionExistsForObject;
}

- (void)reuseExtension:(CEPExtension *)extension forObject:(CENObject *)object withRegistrationGroup:(dispatch_group_t)group {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    NSString *identifier = extension.identifier;
    
    if (!extension) {
        return;
    }
    
    [self prepareDataForExtension:extension toUseWithObject:object];
    
    // Store reference from extension to object which will be used later to unregister.
    [self.objects[CEPluginData.extensions][objectType][identifier] addObject:object];
    
    // Store reference on from object to plugin identifier for faster check what it registered.
    [self.objects[CEPluginData.objects][object.identifier][CEPluginData.extensions] addObject:identifier];

    NSMutableDictionary<NSString *, NSNumber *> *refs = self.extensions[CEPluginData.referencesCount][objectType];
    refs[identifier] = @(refs[identifier].unsignedIntegerValue + 1);
    
    dispatch_group_enter(group);
    [self useExtension:extension withObject:object context:^(CEPExtension *extensionInContext) {
        [extensionInContext onCreate];
        dispatch_group_leave(group);
    }];
}

- (void)extensionForObject:(CENObject *)object withIdentifier:(NSString *)identifier context:(void(^)(id extension))block {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]] || !block) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
        
        return;
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSString *objectType = [[object class] objectType].lowercaseString;
        
        if ([self.objects[CEPluginData.extensions][objectType][identifier] containsObject:object]) {
            CEPExtension *extension = [self extensionWithIdentifier:identifier forObjectType:objectType];
            
            [self useExtension:extension withObject:object context:block];
        } else {
            block(nil);
        }
    });
}

- (void)useExtension:(CEPExtension *)extension withObject:(CENObject *)object context:(void(^)(id extension))block {
    
    extension.storage = [object propertiesStorageForExtension:extension];
    extension.object = object;
    
    block(extension);
    
    extension.storage = nil;
    extension.object = nil;
}

- (void)prepareDataForExtension:(CEPExtension *)extension toUseWithObject:(CENObject *)object {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    NSString *identifier = extension.identifier;
    
    if (!self.objects[CEPluginData.extensions][objectType]) {
        self.objects[CEPluginData.extensions][objectType] = [NSMutableDictionary new];
    }
    
    if (!self.objects[CEPluginData.extensions][objectType][identifier]) {
        self.objects[CEPluginData.extensions][objectType][identifier] = [NSHashTable weakObjectsHashTable];
    }
    
    if (!self.objects[CEPluginData.objects][object.identifier]) {
        self.objects[CEPluginData.objects][object.identifier] = @{
            CEPluginData.extensions: [NSMutableSet new],
            CEPluginData.middlewares: [NSMutableArray new]
        };
    }
}


#pragma mark - Middleware

- (NSArray<CEPMiddleware *> *)middlewaresWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    NSString *targetMiddlewareIdentifierPrefix = [identifier stringByAppendingString:@"."];
    NSMutableArray<CEPMiddleware *> *middlewares = [NSMutableArray new];
    NSString *objectType = type.lowercaseString;
    
    for (NSString *middlewareIdentifier in self.middlewares[CEPluginData.instances][objectType]) {
        if ([middlewareIdentifier hasPrefix:targetMiddlewareIdentifierPrefix]) {
            [middlewares addObject:self.middlewares[CEPluginData.instances][objectType][middlewareIdentifier]];
        }
    }
    
    return middlewares.count ? middlewares : nil;
}

- (BOOL)hasMiddlewareFromPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    BOOL middlewareHasBeenFound = NO;
    
    for (NSString *location in CEPMiddleware.locations) {
        NSString *identifier = [@[plugin.identifier, location] componentsJoinedByString:@"."];
        middlewareHasBeenFound = [self.objects[CEPluginData.middlewares][objectType][identifier] containsObject:object];
        
        if (middlewareHasBeenFound) {
            break;
        }
    }
    
    return middlewareHasBeenFound;
}

- (NSArray<NSString *> *)middlewareIdentifiersAtLocation:(NSString *)location forObject:(CENObject *)object {
    
    NSArray<NSString *> *storedIdentifiers = self.objects[CEPluginData.objects][object.identifier][CEPluginData.middlewares];
    NSString *locationSuffix = [@"." stringByAppendingString:location.lowercaseString];
    NSMutableArray<NSString *> *identifiers = [NSMutableArray new];
    
    for (NSString *identifier in storedIdentifiers) {
        if ([identifier hasSuffix:locationSuffix]) {
            [identifiers addObject:identifier];
        }
    }
    
    return identifiers.count ? identifiers : nil;
}

- (NSArray<CEPMiddleware *> *)middlewaresWithIdentifiers:(NSArray<NSString *> *)identifiers
                                                forEvent:(NSString *)event
                                                  object:(CENObject *)object {
    
    NSMutableArray<CEPMiddleware *> *middlewares = [NSMutableArray new];
    NSString *objectType = [[object class] objectType].lowercaseString;
    
    for (NSString *identifier in identifiers) {
        CEPMiddleware *middleware = self.middlewares[CEPluginData.instances][objectType][identifier];
        
        if (middleware && [middleware registeredForEvent:event]) {
            [middlewares addObject:middleware];
        }
    }
    
    return middlewares.count ? middlewares : nil;
}

- (void)registerMiddlewaresFromPlugin:(CEPPlugin *)plugin
                            forObject:(CENObject *)object
                          firstInList:(BOOL)shouldBeFirstInList
                withRegistrationGroup:(dispatch_group_t)group {
    
    NSMutableArray<CEPMiddleware *> *middlewares = [NSMutableArray new];
    NSString *objectType = [[object class] objectType].lowercaseString;
    
    for (NSString *location in CEPMiddleware.locations) {
        Class cls = [plugin middlewareClassForLocation:location object:object];
        
        if (cls) {
            [middlewares addObject:[cls middlewareWithIdentifier:plugin.identifier configuration:plugin.configuration]];
        }
    };
    
    if (!middlewares.count) {
        return;
    }
    
    if (!self.middlewares[CEPluginData.instances][objectType]) {
        self.middlewares[CEPluginData.instances][objectType] = [NSMutableDictionary new];
        self.middlewares[CEPluginData.referencesCount][objectType] = [NSMutableDictionary new];
    }
    
    for (CEPMiddleware *middleware in middlewares) {
        NSString *identifier = [@[middleware.identifier, [[middleware class] location]] componentsJoinedByString:@"."];
        self.middlewares[CEPluginData.referencesCount][objectType][identifier] = @0;
        self.middlewares[CEPluginData.instances][objectType][identifier] = middleware;
    }
    
    [self reuseMiddlewares:middlewares forObject:object firstInList:shouldBeFirstInList withRegistrationGroup:group];
}

- (BOOL)unregisterMiddlewaresWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object {
    
    NSString *targetMiddlewareIdentifierPrefix = [identifier stringByAppendingString:@"."];
    NSMutableArray<NSString *> *middlewareIdentifiersForObject = [NSMutableArray new];
    NSString *objectType = [[object class] objectType].lowercaseString;
    
    NSArray<NSString *> *identifiers = ((NSDictionary *)self.middlewares[CEPluginData.instances][objectType]).allKeys;
    for (NSString *middlewareIdentifier in identifiers) {
        if (![middlewareIdentifier hasPrefix:targetMiddlewareIdentifierPrefix]) {
            continue;
        }
        
        if ([self.objects[CEPluginData.middlewares][objectType][middlewareIdentifier] containsObject:object]) {
            [middlewareIdentifiersForObject addObject:middlewareIdentifier];
        }
    }
    
    if (!middlewareIdentifiersForObject.count) {
        return NO;
    }
    
    for (NSString *middlewareIdentifier in middlewareIdentifiersForObject) {
        
        CEPMiddleware *middleware = self.middlewares[CEPluginData.instances][objectType][middlewareIdentifier];
        NSMutableDictionary<NSString *, NSNumber *> *refs = self.middlewares[CEPluginData.referencesCount][objectType];
        
        if (refs[middlewareIdentifier].unsignedIntegerValue > 0) {
            refs[middlewareIdentifier] = @(refs[middlewareIdentifier].unsignedIntegerValue - 1);
        }
        
        if (refs[middlewareIdentifier].unsignedIntegerValue == 0) {
            [self.middlewares[CEPluginData.referencesCount][objectType] removeObjectForKey:middlewareIdentifier];
            [self.middlewares[CEPluginData.instances][objectType] removeObjectForKey:middlewareIdentifier];
        }
        
        [self.objects[CEPluginData.middlewares][objectType][middlewareIdentifier] removeObject:object];
        [self.objects[CEPluginData.objects][object.identifier][CEPluginData.middlewares] removeObject:middlewareIdentifier];
        
        if (!((NSHashTable *)self.objects[CEPluginData.middlewares][objectType][middlewareIdentifier]).count) {
            [self.objects[CEPluginData.middlewares][objectType] removeObjectForKey:middlewareIdentifier];
        }
        
        [self useMiddleware:middleware withObject:object onQueue:NO context:^(CEPMiddleware *objectMiddleware) {
            [objectMiddleware onDestruct];
            
            [object invalidateMiddlewareProperties:middleware];
        }];
    }
    
    return YES;
}

- (void)reuseMiddlewares:(NSArray<CEPMiddleware *> *)middlewares
               forObject:(CENObject *)object
             firstInList:(BOOL)shouldBeFirstInList
   withRegistrationGroup:(dispatch_group_t)group {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    
    dispatch_group_enter(group);
    for (CEPMiddleware *middleware in middlewares) {
        NSString *identifier = [@[middleware.identifier, [[middleware class] location]] componentsJoinedByString:@"."];
        
        [self prepareDataForMiddleware:middleware toUseWithObject:object];
        
        // Store reference from middleware to object which will be used later to unregister.
        [self.objects[CEPluginData.middlewares][objectType][identifier] addObject:object];
        
        // Store reference on from object to plugin identifier for faster check what it registered.
        NSMutableArray *orderedMiddlewareIdentifiers = self.objects[CEPluginData.objects][object.identifier][CEPluginData.middlewares];
        if (shouldBeFirstInList) {
            [orderedMiddlewareIdentifiers insertObject:identifier atIndex:0];
        } else {
            [orderedMiddlewareIdentifiers addObject:identifier];
        }
        
        NSMutableDictionary<NSString *, NSNumber *> *refs = self.middlewares[CEPluginData.referencesCount][objectType];
        refs[identifier] = @(refs[identifier].unsignedIntegerValue + 1);
        
        [self useMiddleware:middleware withObject:object onQueue:NO context:^(CEPMiddleware *middlewareInContext) {
            [middlewareInContext onCreate];
        }];
    }
    
    dispatch_group_leave(group);
}

- (void)useMiddleware:(CEPMiddleware *)middleware
           withObject:(CENObject *)object
              onQueue:(BOOL)shouldUseQueue
              context:(void(^)(CEPMiddleware *middleware))block {
    
    if (shouldUseQueue) {
        dispatch_async(self.resourceAccessQueue, ^{
            [self useMiddleware:middleware withObject:object context:block];
        });
    } else {
        [self useMiddleware:middleware withObject:object context:block];
    }
}

- (void)useMiddleware:(CEPMiddleware *)middleware withObject:(CENObject *)object context:(void(^)(CEPMiddleware *middleware))block {
    
    middleware.storage = [object propertiesStorageForMiddleware:middleware];
    
    block(middleware);
    
    middleware.storage = nil;
}

- (void)runMiddlewaresAtLocation:(NSString *)location
                        forEvent:(NSString *)event
                          object:(CENObject *)object
                     withPayload:(NSDictionary *)payload
                      completion:(void(^)(BOOL rejected, NSMutableDictionary *data))block {

    if (![CEPMiddleware.locations containsObject:location] || ![event isKindOfClass:[NSString class]] || !event.length ||
        ![object isKindOfClass:[CENObject class]] || !block) {
        
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
        return;
    }
    
    __block NSArray<CEPMiddleware *> *middlewares = nil;
    __block NSArray<NSString *> *identifiers = nil;
    __block NSUInteger currentMiddlewareIdx = 0;
    NSMutableDictionary *payloadForMiddlewares = [payload mutableCopy];
    
    dispatch_sync(self.resourceAccessQueue, ^{
        identifiers = [self middlewareIdentifiersAtLocation:location forObject:object];
        middlewares = [self middlewaresWithIdentifiers:identifiers forEvent:event object:object];
    });
    
    if (!middlewares.count) {
        block(NO, payloadForMiddlewares);
        
        return;
    }
    
    void(^runMiddleware)(NSMutableDictionary *, void(^)(BOOL)) = ^(NSMutableDictionary *processedPayload, void(^next)(BOOL)) {
        [self useMiddleware:middlewares[currentMiddlewareIdx] withObject:object onQueue:YES context:^(CEPMiddleware *middleware) {
            [middleware runForEvent:event withData:processedPayload completion:next];
        }];
    };
    
    __block __weak void(^weakNextMiddlewareEnqueue)(BOOL);
    void(^nextMiddlewareEnqueue)(BOOL);
    weakNextMiddlewareEnqueue = nextMiddlewareEnqueue = ^(BOOL rejected) {
        currentMiddlewareIdx++;
        
        if (rejected || currentMiddlewareIdx >= middlewares.count) {
            block(rejected, rejected ? nil : payloadForMiddlewares);
        } else {
            runMiddleware(payloadForMiddlewares, weakNextMiddlewareEnqueue);
        }
    };
    
    runMiddleware(payloadForMiddlewares, nextMiddlewareEnqueue);
}

- (void)prepareDataForMiddleware:(CEPMiddleware *)middleware toUseWithObject:(CENObject *)object {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    NSString *identifier = [@[middleware.identifier, [[middleware class] location]] componentsJoinedByString:@"."];
    
    if (!self.objects[CEPluginData.middlewares][objectType]) {
        self.objects[CEPluginData.middlewares][objectType] = [NSMutableDictionary new];
    }
    
    if (!self.objects[CEPluginData.middlewares][objectType][identifier]) {
        self.objects[CEPluginData.middlewares][objectType][identifier] = [NSHashTable weakObjectsHashTable];
    }
    
    if (!self.objects[CEPluginData.objects][object.identifier]) {
        self.objects[CEPluginData.objects][object.identifier] = @{
            CEPluginData.extensions: [NSMutableSet new],
            CEPluginData.middlewares: [NSMutableArray new]
        };
    }
}


#pragma mark - Plugins management

- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object {
    
    if (![object isKindOfClass:[CENObject class]] || ![CEPPlugin isValidIdentifier:identifier]) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
    }
    
    __block BOOL hasRegisteredPlugin = NO;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSDictionary *registeredComponents = self.objects[CEPluginData.objects][object.identifier];
        hasRegisteredPlugin = [registeredComponents[CEPluginData.extensions] containsObject:identifier];
        NSString *targetMiddlewareIdentifierPrefix = [identifier stringByAppendingString:@"."];
        
        for (NSString *middlewareIdentifier in registeredComponents[CEPluginData.middlewares]) {
            hasRegisteredPlugin = hasRegisteredPlugin || [middlewareIdentifier hasPrefix:targetMiddlewareIdentifierPrefix];
            
            if (hasRegisteredPlugin) {
                break;
            }
        }
    });
    
    return hasRegisteredPlugin;
}

- (BOOL)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(dispatch_block_t)block {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]] ||
        (configuration && ![configuration isKindOfClass:[NSDictionary class]])) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
        
        return NO;
    }
    
    dispatch_group_t registrationGroup = dispatch_group_create();
    configuration = configuration ?: @{};
    __block BOOL protoPlugin = NO;
    __block CEPPlugin *plugin;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        if ([self hasProtoPluginWithIdentifier:identifier configuration:configuration]) {
            plugin = self.protoPlugins[CEPluginData.instances][identifier];
            protoPlugin = YES;
        } else {
            plugin = [cls pluginWithIdentifier:identifier configuration:configuration];
        }
    });
    
    BOOL willRegsiter = [self registerProto:protoPlugin
                                     plugin:plugin
                                  forObject:object
                                firstInList:shouldBeFirstInList
                      withRegistrationGroup:registrationGroup];
    
    dispatch_group_notify(registrationGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), (block ?: ^{}));
    
    return willRegsiter;
}

- (BOOL)registerProto:(BOOL)isProto
               plugin:(CEPPlugin *)plugin
            forObject:(CENObject *)object
          firstInList:(BOOL)shouldBeFirstInList
withRegistrationGroup:(dispatch_group_t)group {
    
    NSString *objectType = [[object class] objectType].lowercaseString;
    __block NSArray<CEPMiddleware *> *middlewares = nil;
    __block BOOL middlewaresRegisteredForObject = NO;
    __block BOOL extensionRegisteredForObject = NO;
    __block CEPExtension *extension = nil;
    __block BOOL instancesCreated = NO;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        extension = [self extensionWithIdentifier:plugin.identifier forObjectType:objectType];
        middlewares = [self middlewaresWithIdentifier:plugin.identifier forObjectType:objectType];
        instancesCreated = extension != nil || middlewares.count;
        
        if (instancesCreated) {
            middlewaresRegisteredForObject = [self hasMiddlewareFromPlugin:plugin forObject:object];
            extensionRegisteredForObject = [self hasExtensionFromPlugin:plugin forObject:object];
        }
    });
    
    BOOL shouldRegister = !middlewaresRegisteredForObject && !extensionRegisteredForObject;
    
    if (instancesCreated) {
        NSDictionary *middlewareConfiguration = middlewares.firstObject.configuration;
        BOOL extensionConfigurationSame = [extension.configuration isEqualToDictionary:plugin.configuration];
        BOOL middlewareConfigurationSame = [middlewareConfiguration isEqualToDictionary:plugin.configuration];
        
        if ((extension && !extensionConfigurationSame) || (middlewares.firstObject && !middlewareConfigurationSame)) {
            shouldRegister = NO;
        }
    }
    
    dispatch_group_enter(group);
    dispatch_async(self.resourceAccessQueue, ^{
        if (!instancesCreated) {
            [self registerExtensionFromPlugin:plugin forObject:object withRegistrationGroup:group];
            [self registerMiddlewaresFromPlugin:plugin forObject:object firstInList:shouldBeFirstInList withRegistrationGroup:group];
        } else if (shouldRegister) {
            [self reuseExtension:extension forObject:object withRegistrationGroup:group];
            [self reuseMiddlewares:middlewares forObject:object firstInList:shouldBeFirstInList withRegistrationGroup:group];
        }
        
        if (isProto) {
            NSString *identifier = plugin.identifier;
            NSMutableDictionary<NSString *, NSNumber *> *refs = self.protoPlugins[CEPluginData.referencesCount];
            
            refs[identifier] = @(refs[identifier].unsignedIntegerValue + 1);
        }
        
        dispatch_group_leave(group);
    });
    
    return shouldRegister;
}

- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![object isKindOfClass:[CENObject class]]) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        BOOL anyExtensionRemoved = [self unregisterExtensionWithIdentifier:identifier fromObject:object];
        BOOL anyMiddlewareRemoved = [self unregisterMiddlewaresWithIdentifier:identifier fromObject:object];
        
        if (anyExtensionRemoved || anyMiddlewareRemoved) {
            if (self.protoPlugins[CEPluginData.referencesCount][identifier]) {
                NSMutableDictionary<NSString *, NSNumber *> *refs = self.protoPlugins[CEPluginData.referencesCount];
                
                if (refs[identifier].unsignedIntegerValue > 0) {
                    refs[identifier] = @(refs[identifier].unsignedIntegerValue - 1);
                }
            }
            
            NSDictionary *registeredComponents = self.objects[CEPluginData.objects][object.identifier];
            if (!((NSMutableSet *)registeredComponents[CEPluginData.extensions]).count &&
                !((NSMutableArray *)registeredComponents[CEPluginData.middlewares]).count) {
                
                [self.objects[CEPluginData.objects] removeObjectForKey:object.identifier];
            }
        }
    });
}

- (void)unregisterAllFromObjects:(CENObject *)object {
    
    if (![object isKindOfClass:[CENObject class]]) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
    }
    
    NSMutableSet<NSString *> *objectPlugins = [NSMutableSet new];
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSDictionary *registeredComponents = self.objects[CEPluginData.objects][object.identifier];
        [objectPlugins unionSet:registeredComponents[CEPluginData.extensions]];
        
        NSMutableSet *middlewareIdentifiers = [NSMutableSet new];
        for (NSString *identifier in registeredComponents[CEPluginData.middlewares]) {
            NSString *middlewareIdentifier = identifier;
            
            for (NSString *middlewareLocation in CEPMiddleware.locations) {
                NSString *locationSuffix = [@"." stringByAppendingString:middlewareLocation];
                middlewareIdentifier = [middlewareIdentifier stringByReplacingOccurrencesOfString:locationSuffix withString:@""];
            }
            
            [middlewareIdentifiers addObject:middlewareIdentifier];
        }
        
        [objectPlugins unionSet:middlewareIdentifiers];
    });
    
    for (NSString *identifier in objectPlugins) {
        [self unregisterObjects:object pluginWithIdentifier:identifier];
    }
}



#pragma mark - Proto plugins management

- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    __block BOOL registered = NO;
    NSString *objectType = type.lowercaseString;
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:objectType]) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
        
        return NO;
    }
    
    dispatch_sync(self.resourceAccessQueue, ^{
        registered = [self.protoPlugins[CEPluginData.objects][objectType] containsObject:identifier];
    });
    
    return registered;
}

- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {
    
    configuration = configuration ?: @{};
    CEPPlugin *plugin = self.protoPlugins[CEPluginData.instances][identifier];
    
    return plugin && [plugin.configuration isEqualToDictionary:configuration];
}

- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block {
    
    if (![object isKindOfClass:[CENObject class]]) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
        
        return;
    }
    
    NSMutableArray<CEPPlugin *> *plugins = [NSMutableArray new];
    NSString *objectType = [[object class] objectType].lowercaseString;
    dispatch_group_t registrationGroup = dispatch_group_create();
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSArray<NSString *> *pluginIdentifiers = self.protoPlugins[CEPluginData.objects][objectType];
        
        for (NSString *identifier in pluginIdentifiers) {
            CEPPlugin *plugin = self.protoPlugins[CEPluginData.instances][identifier];
            
            if (plugin) {
                [plugins addObject:plugin];
            }
        }
    });
    
    for (CEPPlugin *plugin in plugins) {
        [self registerProto:YES plugin:plugin forObject:object firstInList:NO withRegistrationGroup:registrationGroup];
    }
    
    dispatch_group_notify(registrationGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(NSDictionary *)configuration
              forObjectType:(NSString *)type {
    
    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:type] ||
        (configuration && ![configuration isKindOfClass:[NSDictionary class]])) {
        
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
    }
    
    NSString *objectType = type.lowercaseString;
    configuration = configuration ?: @{};
    
    dispatch_sync(self.resourceAccessQueue, ^{
        if (!self.protoPlugins[CEPluginData.objects][objectType]) {
            self.protoPlugins[CEPluginData.objects][objectType] = [NSMutableArray array];
        }
        
        if (!self.protoPlugins[CEPluginData.instances][identifier]) {
            CEPPlugin *plugin = [cls pluginWithIdentifier:identifier configuration:configuration];
            
            if (plugin) {
                self.protoPlugins[CEPluginData.instances][identifier] = plugin;
                self.protoPlugins[CEPluginData.referencesCount][identifier] = @0;
            }
        }
        
        [self.protoPlugins[CEPluginData.objects][objectType] addObject:identifier];
    });
}

- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:type]) {
        [NSException raise:NSInvalidArgumentException format:@"Parameters is empty or has unexpected data type."];
    }
    
    NSHashTable<CENObject *> *registeredForObjects = [NSHashTable weakObjectsHashTable];
    NSString *objectType = type.lowercaseString;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSMutableDictionary *middlewaresForType = self.objects[CEPluginData.middlewares][objectType];
        NSString *targetMiddlewareIdentifierPrefix = [identifier stringByAppendingString:@"."];
        
        for (NSString *middlewareIdentifier in middlewaresForType) {
            if ([middlewareIdentifier hasPrefix:targetMiddlewareIdentifierPrefix]) {
                [registeredForObjects unionHashTable:middlewaresForType[middlewareIdentifier]];
            }
        }
        
        [registeredForObjects unionHashTable:self.objects[CEPluginData.extensions][objectType][identifier]];
    });
    
    for (CENObject *object in registeredForObjects) {
        [self unregisterObjects:object pluginWithIdentifier:identifier];
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary<NSString *, NSNumber *> *refs = self.protoPlugins[CEPluginData.referencesCount];
        
        [self.protoPlugins[CEPluginData.objects] removeObjectForKey:objectType];
        
        /**
         * Completely uninstall proto plugin if it has been unregistered for all kind of object
         * types.
         */
        if (refs[identifier].unsignedIntegerValue == 0) {
            [self.protoPlugins[CEPluginData.referencesCount] removeObjectForKey:identifier];
            [self.protoPlugins[CEPluginData.instances] removeObjectForKey:identifier];
        }
    });
}


#pragma mark - Clean up

- (void)destroy {
    
    NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *pluginsToRemove = [NSMutableDictionary new];
    NSHashTable<CENObject *> *objects = [NSHashTable weakObjectsHashTable];
    void(^storePluginIdentifier)(NSString *, NSString *) = ^(NSString *type, NSString *identifier) {
        if (!pluginsToRemove[type]) {
            pluginsToRemove[type] = [NSMutableSet new];
        }
        
        [pluginsToRemove[type] addObject:identifier];
    };
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSDictionary<NSString *, NSDictionary<NSString *, NSHashTable *> *> *extensions = self.objects[CEPluginData.extensions];
        NSDictionary<NSString *, NSDictionary<NSString *, NSHashTable *> *> *middlewares = self.objects[CEPluginData.middlewares];
        
        [extensions enumerateKeysAndObjectsUsingBlock:^(NSString *type,
                                                        NSDictionary<NSString *,NSHashTable *> *extensionsObjectMap,
                                                        __unused BOOL *stop) {
            
            [extensionsObjectMap enumerateKeysAndObjectsUsingBlock:^(NSString *identifier,
                                                                     NSHashTable *mappedObjects,
                                                                     __unused BOOL *stopExtensionsEnumerator) {
                
                storePluginIdentifier(type, identifier);
                [objects unionHashTable:mappedObjects];
            }];
        }];
        [middlewares enumerateKeysAndObjectsUsingBlock:^(NSString *type,
                                                         NSDictionary<NSString *,NSHashTable *> *middlewaresObjectMap,
                                                         __unused BOOL *stop) {
            
            [middlewaresObjectMap enumerateKeysAndObjectsUsingBlock:^(NSString *identifier,
                                                                      NSHashTable *mappedObjects,
                                                                      __unused BOOL *stopMiddlewaresEnumerator) {
                
                storePluginIdentifier(type, [identifier componentsSeparatedByString:@"."].firstObject);
                [objects unionHashTable:mappedObjects];
            }];
        }];
        
    });
    
    [objects.allObjects enumerateObjectsUsingBlock:^(CENObject *object, __unused NSUInteger idx, __unused BOOL *stop) {
        [self unregisterAllFromObjects:object];
    }];
    
    [pluginsToRemove enumerateKeysAndObjectsUsingBlock:^(NSString *type, NSMutableSet<NSString *> *plugins, __unused BOOL *stop) {
        [plugins enumerateObjectsUsingBlock:^(NSString *identifier, __unused BOOL *stopPluginsEnumerator) {
            [self unregisterProtoPluginWithIdentifier:identifier forObjectType:type];
        }];
    }];
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::Manager::Plugins> %p instance deallocation", self);
}

#pragma mark -


@end
