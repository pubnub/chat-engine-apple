/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPExtension+Private.h"
#import "CEPPlugablePropertyStorage+Private.h"
#import "CENObject.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CEPExtension ()


#pragma mark Informaiton

/**
 * @brief  Stores reference on dictionary which is passed during plugin registration and contain extension required
 *         configuration information.
 */
@property (nonatomic, nullable, weak) NSDictionary *configuration;

/**
 * @brief Stores reference on object for which extended interface has been provided.
 */
@property (nonatomic, nullable, weak) CENObject *object;

/**
 * @brief  Stores reference on unique identifier of plugin which instantiated this extension.
 */
@property (nonatomic, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief  Initialize extension instance.
 *
 * @param identifier    Reference on unique identifier of plugin which provided this extension.
 * @param configuration Reference on dictionary which is passed during plugin registration.
 *
 * @return Initialized and ready to use extension instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier configuration:(nullable NSDictionary *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CEPExtension


#pragma mark - Initialization and Configuration

+ (instancetype)extensionWithIdentifier:(NSString *)identifier configuration:(nullable NSDictionary *)configuration {
    
    if (![identifier isKindOfClass:[NSString class]] || !identifier.length) {
        return nil;
    }
    
    if (configuration && ![configuration isKindOfClass:[NSDictionary class]]) {
        configuration = @{};
    }
    
    return [[self alloc] initWithIdentifier:identifier configuration:configuration ?: @{}];
}

- (instancetype)initWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {
    
    if ((self = [super init])) {
        self.configuration = configuration;
        self.identifier = identifier;
    }
    
    return self;
}


#pragma mark - Handlers

- (void)onCreate {
    
    // Default implementation doesn't do anything. 
}

- (void)onDestruct {
    
    // Default implementation doesn't do anything.
}


#pragma mark - Properties bind

+ (NSArray<NSString *> *)nonbindableProperties {
    
    return @[@"configuration", @"", @"identifier", @"object"];
}

#pragma mark -


@end
