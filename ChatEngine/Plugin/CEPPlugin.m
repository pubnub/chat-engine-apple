/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPPlugin+Private.h"
#import "CENObject+PluginsDeveloper.h"
#import "CEPMiddleware+Private.h"
#import "CENPrivateStructures.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CEPPlugin ()


#pragma mark - Information

/**
 * @brief Stores reference on dictionary which is passed during plugin registration and will be passed by \b ChatEngine
 *        during extension and/or middleware instantiation.
 */
@property (nonatomic, copy) NSDictionary *configuration;

/**
 * @brief Stores reference on default plugin identifier.
 */
@property (nonatomic, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief      Initialize plugin instance.
 * @discussion Plugin instance will be created right after registration method call. Extension and middleware will be
 *             installed on instantiation of object of specified type (which used during registration).
 *
 * @param identifier    Reference on unique plugin identifier which will override identifer provided by class.
 * @param configuration Reference on dictionary which is passed during plugin registration and will be passed by
 *                      \b ChatEngine during extension and/or middleware instantiation.
 *
 * @return Initialized and ready to use plugin instance.
 */
- (instancetype)initWithIdentifier:(nullable NSString *)identifier configuration:(nullable NSDictionary *)configuration;

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

+ (instancetype)pluginWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {
    
    if (!configuration || ![configuration isKindOfClass:[NSDictionary class]]) {
        configuration = @{};
    }
    
    return [[self alloc] initWithIdentifier:(identifier ?: [self identifier]) configuration:configuration];
}

- (instancetype)initWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {
    
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

- (nullable Class)middlewareClassForLocation:(NSString *)__unused location object:(CENObject *)__unused object {
    
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
    
    return [@[CENObjectType.chat, CENObjectType.user, CENObjectType.me, CENObjectType.search] containsObject:type.lowercaseString];
}

+ (BOOL)isPluginClass:(Class)cls {
    
    return cls && [[cls superclass] isEqual:[CEPPlugin class]];
}


#pragma mark -


@end
