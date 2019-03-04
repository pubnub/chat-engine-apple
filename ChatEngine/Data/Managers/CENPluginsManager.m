/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENPluginsManager.h"
#import "CEPMiddleware+Developer.h"
#import "CEPExtension+Developer.h"
#import "CEPMiddleware+Private.h"
#import "CENChatEngine+Private.h"
#import "CEPExtension+Private.h"
#import "CEPPlugin+Developer.h"
#import "CEPPlugin+Private.h"
#import "CENObject+Private.h"
#import "CENLogMacro.h"


#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
#pragma mark Structures

/**
 * @brief Typedef structure fields assignment.
 */
CEPluginDataKeys CEPluginData = {
    .objects = @"o",
    .instances = @"i"
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENPluginsManager ()

/**
 * @brief Object which stores list of proto plugins and list of them associated with specific
 * object type.
 */
@property (nonatomic, nullable, strong) NSDictionary<NSString *, NSMutableDictionary *> *protoPlugins;

/**
 * @brief Dictionary of object identifiers mapped to list of middlewares.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSMutableArray *> *middlewares;

/**
 * @brief Dictionary of object identifiers mapped to dictionary where plugin identifiers mapped to
 * extensions.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *extensions;

/**
 * @brief Dictionary with plugin identifier mapped to list of objects for which it instantiated
 * plugins.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSHashTable *> *objects;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief \b {CENChatEngine} which instantiated this manager.
 */
@property (nonatomic, nullable, weak) CENChatEngine *chatEngine;


#pragma mark - Extension

/**
 * @brief Register \b {object CENObject} interface extension using provided plugin.
 *
 * @param plugin Plugin instance which may provide \c object interface extension.
 * @param object \b {Object CENObject} for which extension should be registered.
 */
- (void)registerExtensionFromPlugin:(CEPPlugin *)plugin withObject:(CENObject *)object;

/**
 * @brief Remove \b {object CENObject} interface extension.
 *
 * @param identifier Unique plugin identifier which has been provided during registration.
 * @param object \b {Object CENObject} for which interface should be cleared from extension.
 */
- (void)unregisterExtensionWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object;


#pragma mark - Middleware

/**
 * @brief Find list of middlewares which is able to handle \c event.
 *
 * @param object \b {Object CENObject} for which middlewares should be found.
 * @param location Location name on which middleware expected to handle events.
 * @param event Name of event against which registered middlewares should be checked.
 *
 * @return List of middlewares which can be used to process along with
 */
- (nullable NSArray<CEPMiddleware *> *)middlewaresForObject:(CENObject *)object
                                                 atLocation:(NSString *)location
                                                   forEvent:(NSString *)event;
/**
 * @brief Register \c object data pre-processing middlewares using provided plugin.
 *
 * @param plugin \b {Plugin CEPPlugin} instance which may provide \b {object CENObject} data
 *     pre-processing middlewares.
 * @param object \b {Object CENObject} for which middlewares should be registered.
 * @param shouldBeFirstInList Whether middlewares should be executed prior existing one.
 */
- (void)registerMiddlewaresFromPlugin:(CEPPlugin *)plugin
                            forObject:(CENObject *)object
                          firstInList:(BOOL)shouldBeFirstInList;

/**
 * @brief Remove \c object data pre-processing middlewares.
 *
 * @param identifier Unique plugin identifier which has been used during registration.
 * @param object \b {Object CENObject} for which data pre-processing middlewares should be removed.
 */
- (void)unregisterMiddlewaresWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object;


#pragma mark - Plugins management

/**
 * @brief Register plugin's components for specified \c object.
 *
 * @param plugin \b {Plugin CEPPlugin} instance which contain components which can be registered for
 *     \b {object CENObject}.
 * @param object \b {Object CENObject} for which plugin's components should be registered.
 * @param shouldBeFirstInList Whether components should be executed prior existing one.
 * @param group Plugin components registration completion handler group.
 */
- (void)registerPlugin:(CEPPlugin *)plugin
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
 withRegistrationGroup:(dispatch_group_t)group;

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

    [NSException raise:NSDestinationInvalidException
                format:@"-init not implemented, please use: +managerForChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        _protoPlugins = @{
            CEPluginData.objects: [@{} mutableCopy],
            CEPluginData.instances: [@{} mutableCopy]
        };

        _extensions = [@{} mutableCopy];
        _middlewares = [@{} mutableCopy];
        _objects = [@{} mutableCopy];
        
        NSString *queue = [NSString stringWithFormat:@"com.chatengine.manager.plugins.%p", self];
        _resourceAccessQueue = dispatch_queue_create([queue UTF8String], DISPATCH_QUEUE_SERIAL);
        _chatEngine = chatEngine;
        
        CELogResourceAllocation(self.chatEngine.logger,
            @"<ChatEngine::Manager::Plugins> %p instance allocation", self);
    }
    
    return self;
}


#pragma mark - Extension

- (void)registerExtensionFromPlugin:(CEPPlugin *)plugin withObject:(CENObject *)object {

    NSDictionary *configuration = plugin.configuration;
    Class cls = [plugin extensionClassFor:object];
    NSString *identifier = plugin.identifier;

    CEPExtension *extension = [cls extensionForObject:object
                                       withIdentifier:identifier
                                        configuration:configuration];
    
    if (!extension) {
        return;
    }
    
    if (!self.extensions[object.identifier]) {
        self.extensions[object.identifier] = [NSMutableDictionary new];
    }

    self.extensions[object.identifier][identifier] = extension;
    [extension onCreate];
}

- (void)unregisterExtensionWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object {

    CEPExtension *extension = self.extensions[object.identifier][identifier];
    
    if (!extension) {
        return;
    }

    [self.extensions[object.identifier] removeObjectForKey:identifier];

    [extension onDestruct];
}


- (id)extensionForObject:(CENObject *)object withIdentifier:(NSString *)identifier {

    __block id extension = nil;

    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObject:object]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    dispatch_sync(self.resourceAccessQueue, ^{
        extension = self.extensions[object.identifier][identifier];
    });

    return extension;
}


#pragma mark - Middleware

- (NSArray<CEPMiddleware *> *)middlewaresForObject:(CENObject *)object
                                        atLocation:(NSString *)location
                                          forEvent:(NSString *)event {

    NSMutableArray<CEPMiddleware *> *objectMiddlewares = self.middlewares[object.identifier];
    NSMutableArray<CEPMiddleware *> *targetMiddlewares = [NSMutableArray new];

    for (CEPMiddleware *middleware in objectMiddlewares) {
        NSString *middlewareLocation = [[middleware class] location];

        if ([middlewareLocation isEqual:location] && [middleware registeredForEvent:event]) {
            [targetMiddlewares addObject:middleware];
        }
    }
    
    return targetMiddlewares.count ? targetMiddlewares : nil;
}

- (void)registerMiddlewaresFromPlugin:(CEPPlugin *)plugin
                            forObject:(CENObject *)object
                          firstInList:(BOOL)shouldBeFirstInList {
    
    NSMutableArray<CEPMiddleware *> *middlewares = [NSMutableArray new];

    for (NSString *location in CEPMiddleware.locations) {
        Class cls = [plugin middlewareClassForLocation:location object:object];
        
        if (!cls) {
            continue;
        }

        CEPMiddleware *middleware = [cls middlewareForObject:object
                                              withIdentifier:plugin.identifier
                                               configuration:plugin.configuration];
        [middlewares addObject:middleware];
    }
    
    if (!middlewares.count) {
        return;
    }
    
    if (!self.middlewares[object.identifier]) {
        self.middlewares[object.identifier] = [NSMutableArray new];
    }
    
    for (CEPMiddleware *middleware in middlewares) {
        if (shouldBeFirstInList) {
            [self.middlewares[object.identifier] insertObject:middleware atIndex:0];
        } else {
            [self.middlewares[object.identifier] addObject:middleware];
        }

        [middleware onCreate];
    }
}

- (void)unregisterMiddlewaresWithIdentifier:(NSString *)identifier fromObject:(CENObject *)object {

    NSMutableArray<CEPMiddleware *> *objectMiddlewares = self.middlewares[object.identifier];
    NSMutableArray<CEPMiddleware *> *middlewaresForRemoval = [NSMutableArray new];

    for (CEPMiddleware *middleware in objectMiddlewares) {
        if ([middleware.identifier isEqualToString:identifier]) {
            [middlewaresForRemoval addObject:middleware];
        }
    }

    [objectMiddlewares removeObjectsInArray:middlewaresForRemoval];
    [middlewaresForRemoval makeObjectsPerformSelector:@selector(onDestruct)];
}

- (void)runMiddlewaresAtLocation:(NSString *)location
                        forEvent:(NSString *)event
                          object:(CENObject *)object
                     withPayload:(NSDictionary *)payload
                      completion:(void(^)(BOOL rejected, NSMutableDictionary *data))block {

    if (![CEPMiddleware.locations containsObject:location] || ![CEPPlugin isValidObject:object] ||
        ![event isKindOfClass:[NSString class]] || !event.length ||
        ![payload isKindOfClass:[NSDictionary class]] || !block) {
        
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    NSMutableDictionary *payloadForMiddlewares = [payload mutableCopy];
    __block NSArray<CEPMiddleware *> *middlewares = nil;
    __block NSUInteger currentMiddlewareIdx = 0;

    dispatch_sync(self.resourceAccessQueue, ^{
        middlewares = [self middlewaresForObject:object atLocation:location forEvent:event];
    });
    
    if (!middlewares.count) {
        block(NO, payloadForMiddlewares);
        
        return;
    }
    
    void(^runMiddleware)(NSMutableDictionary *, void(^)(BOOL));
    runMiddleware = ^(NSMutableDictionary *processedPayload, void(^next)(BOOL)) {
        [middlewares[currentMiddlewareIdx] runForEvent:event
                                              withData:processedPayload
                                            completion:next];
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


#pragma mark - Plugins management

- (BOOL)hasPluginWithIdentifier:(NSString *)identifier forObject:(CENObject *)object {

    __block BOOL hasPlugin = NO;

    if (![CEPPlugin isValidObject:object] || ![CEPPlugin isValidIdentifier:identifier]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }

    dispatch_sync(self.resourceAccessQueue, ^{
        hasPlugin = self.extensions[object.identifier][identifier] != nil;
        NSMutableArray<CEPMiddleware *> *middlewares = self.middlewares[object.identifier];
        
        for (CEPMiddleware *middleware in middlewares) {
            hasPlugin = hasPlugin ?: [middleware.identifier isEqual:identifier];

            if (hasPlugin) {
                break;
            }
        }
    });
    
    return hasPlugin;
}

- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(NSDictionary *)configuration
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
            completion:(dispatch_block_t)block {

    configuration = configuration ?: @{};
    block = block ?: ^{};

    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidIdentifier:identifier] ||
        ![CEPPlugin isValidObject:object] || ![CEPPlugin isValidConfiguration:configuration]) {

        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    CEPPlugin *plugin = [cls pluginWithIdentifier:identifier configuration:configuration];
    dispatch_group_t group = dispatch_group_create();

    [self registerPlugin:plugin
               forObject:object
             firstInList:shouldBeFirstInList
   withRegistrationGroup:group];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_notify(group, queue, block);
}

- (void)registerPlugin:(CEPPlugin *)plugin
             forObject:(CENObject *)object
           firstInList:(BOOL)shouldBeFirstInList
 withRegistrationGroup:(dispatch_group_t)group {

    // Remove components of previous plugin registered under same identifier.
    [self unregisterObjects:object pluginWithIdentifier:plugin.identifier];

    dispatch_group_enter(group);
    dispatch_async(self.resourceAccessQueue, ^{
        [self registerExtensionFromPlugin:plugin withObject:object];
        [self registerMiddlewaresFromPlugin:plugin
                                  forObject:object
                                firstInList:shouldBeFirstInList];
        dispatch_group_leave(group);
    });
}

- (void)unregisterObjects:(CENObject *)object pluginWithIdentifier:(NSString *)identifier {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObject:object]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        [self unregisterExtensionWithIdentifier:identifier fromObject:object];
        [self unregisterMiddlewaresWithIdentifier:identifier fromObject:object];
    });
}

- (void)unregisterAllFromObjects:(CENObject *)object {
    
    if (![CEPPlugin isValidObject:object]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    NSMutableSet<NSString *> *objectPlugins = [NSMutableSet new];
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSArray<CEPExtension *> *extensions = self.extensions[object.identifier].allValues;
        NSArray<CEPMiddleware *> *middlewares = self.middlewares[object.identifier];
        NSString *identifierProperty = @"identifier";

        [objectPlugins addObjectsFromArray:[extensions valueForKey:identifierProperty]];
        [objectPlugins addObjectsFromArray:[middlewares valueForKey:identifierProperty]];
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
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSArray<NSString *> *identifiers = self.protoPlugins[CEPluginData.objects][objectType];

        registered = [identifiers containsObject:identifier];
    });
    
    return registered;
}

- (void)setupProtoPluginsForObject:(CENObject *)object withCompletion:(dispatch_block_t)block {
    
    if (![CEPPlugin isValidObject:object]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }
    
    NSMutableArray<CEPPlugin *> *plugins = [NSMutableArray new];
    NSString *objectType = [[object class] objectType].lowercaseString;
    dispatch_group_t group = dispatch_group_create();

    dispatch_sync(self.resourceAccessQueue, ^{
        NSArray *pluginIdentifiers = self.protoPlugins[CEPluginData.objects][objectType];
        
        for (NSString *identifier in pluginIdentifiers) {
            CEPPlugin *plugin = self.protoPlugins[CEPluginData.instances][identifier];

            [plugins addObject:plugin];

            if (!self.objects[plugin.identifier]) {
                self.objects[plugin.identifier] = [NSHashTable weakObjectsHashTable];
            }

            if (![self.objects[plugin.identifier] containsObject:object]) {
                [self.objects[plugin.identifier] addObject:object];
            }
        }
    });
    
    for (CEPPlugin *plugin in plugins) {
        [self registerPlugin:plugin forObject:object firstInList:NO withRegistrationGroup:group];
    }

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_notify(group, queue, block);
}

- (void)registerProtoPlugin:(Class)cls
             withIdentifier:(NSString *)identifier
              configuration:(NSDictionary *)configuration
              forObjectType:(NSString *)type {

    configuration = configuration ?: @{};

    if (![CEPPlugin isPluginClass:cls] || ![CEPPlugin isValidIdentifier:identifier] ||
        ![CEPPlugin isValidObjectType:type] || ![CEPPlugin isValidConfiguration:configuration]) {
        
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }

    NSString *objectType = type.lowercaseString;

    // Remove previous proto plugin with same identifier along with all instantiated components.
    [self unregisterProtoPluginWithIdentifier:identifier forObjectType:type];

    dispatch_async(self.resourceAccessQueue, ^{
        if (!self.protoPlugins[CEPluginData.objects][objectType]) {
            self.protoPlugins[CEPluginData.objects][objectType] = [NSMutableArray array];
        }

        CEPPlugin * plugin = [cls pluginWithIdentifier:identifier configuration:configuration];
        self.protoPlugins[CEPluginData.instances][identifier] = plugin;

        [self.protoPlugins[CEPluginData.objects][objectType] addObject:identifier];
    });
}

- (void)unregisterProtoPluginWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type {
    
    if (![CEPPlugin isValidIdentifier:identifier] || ![CEPPlugin isValidObjectType:type]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Parameters is empty or has unexpected data type."];
    }

    __block NSHashTable<CENObject *> *objectsWithProto = nil;
    NSString *objectType = type.lowercaseString;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        objectsWithProto = self.objects[identifier];

        [self.objects removeObjectForKey:identifier];

        [self.protoPlugins[CEPluginData.objects][objectType] removeObject:identifier];
        [self.protoPlugins[CEPluginData.instances] removeObjectForKey:identifier];
    });

    for (CENObject *object in objectsWithProto) {
        [self unregisterObjects:object pluginWithIdentifier:identifier];
    }
}


#pragma mark - Clean up

- (void)destroy {

    dispatch_sync(self.resourceAccessQueue, ^{
        for (NSString *identifier in self.extensions) {
            NSArray<CEPExtension *> *extensions = self.extensions[identifier].allValues;

            [extensions makeObjectsPerformSelector:@selector(onDestruct)];
        }

        for (NSString *identifier in self.middlewares) {
            NSArray<CEPMiddleware *> *middlewares = self.middlewares[identifier];

            [middlewares makeObjectsPerformSelector:@selector(onDestruct)];
        }

        self.protoPlugins = nil;
        self.extensions = nil;
        self.middlewares = nil;
        self.objects = nil;
    });
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger,
        @"<ChatEngine::Manager::Plugins> %p instance deallocation", self);
}

#pragma mark -


@end

#pragma clang diagnostic pop
