/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CEPPlugin+Private.h"
#import "CENPrivateStructures.h"
#import "CENEvent.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CEPPlugin ()


#pragma mark - Information

@property (nonatomic, copy) NSDictionary *configuration;
@property (nonatomic, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize plugin instance.
 *
 * @param identifier Unique plugin identifier under which it should be registered.
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *
 * @return Initialized and ready to use plugin instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                     configuration:(NSDictionary *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CEPPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    NSAssert(0, @"%s should be implemented by subclass", __PRETTY_FUNCTION__);
    
    return nil;
}


#pragma mark - Initialization and Configuration

+ (instancetype)pluginWithIdentifier:(NSString *)identifier
                       configuration:(NSDictionary *)configuration {

    configuration = configuration ?: @{};

    if (![configuration isKindOfClass:[NSDictionary class]]) {
        configuration = @{};
    }
    
    return [[self alloc] initWithIdentifier:(identifier ?: [self identifier])
                              configuration:configuration];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                     configuration:(NSDictionary *)configuration {
    
    if ((self = [super init])) {
        _configuration = [configuration copy];
        _identifier = [identifier copy];
        
        [self onCreate];
    }
    
    return self;
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)__unused object {
    
    return nil;
}


#pragma mark - Middleware

- (nullable Class)middlewareClassForLocation:(NSString *)__unused location
                                      object:(CENObject *)__unused object {
    
    return nil;
}


#pragma mark - Handlers

- (void)onCreate {
    
    // Default implementation does nothing.
}


#pragma mark - Misc

+ (BOOL)isValidIdentifier:(NSString *)identifier {
    
    return [identifier isKindOfClass:[NSString class]] && identifier.length;
}

+ (BOOL)isValidObjectType:(NSString *)type {
    
    static NSArray<NSString *> *_types;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _types = @[CENObjectType.chat, CENObjectType.user, CENObjectType.me, CENObjectType.search,
                   CENObjectType.event];
    });
    
    return [_types containsObject:type.lowercaseString];
}

+ (BOOL)isValidObject:(CENObject *)object {

    return [object isKindOfClass:[CENObject class]] || [object isKindOfClass:[CENEvent class]];
}

+ (BOOL)isValidConfiguration:(NSDictionary *)configuration {

    return [configuration isKindOfClass:[NSDictionary class]];
}

+ (BOOL)isPluginClass:(Class)cls {
    
    return cls && [[cls superclass] isEqual:[CEPPlugin class]];
}

#pragma mark -


@end
