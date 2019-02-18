/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CEPExtension+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CEPExtension ()


#pragma mark Informaiton

@property (nonatomic, nullable, copy) NSDictionary *configuration;
@property (nonatomic, nullable, weak) CENObject *object;
@property (nonatomic, copy) NSString *identifier;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize extension instance.
 *
 * @param object \b {Object CENObject} for which extended interface will be created.
 * @param identifier Reference on unique identifier of plugin which provided this extension.
 * @param configuration Reference on dictionary which is passed during plugin registration.
 *
 * @return Initialized and ready to use extension instance.
 */
- (instancetype)initForObject:(CENObject *)object
               withIdentifier:(NSString *)identifier
                configuration:(nullable NSDictionary *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CEPExtension


#pragma mark - Initialization and Configuration

+ (instancetype)extensionForObject:(CENObject *)object
                    withIdentifier:(NSString *)identifier
                     configuration:(nullable NSDictionary *)configuration {
    
    if (![object isKindOfClass:[CENObject class]] || ![identifier isKindOfClass:[NSString class]] ||
        !identifier.length) {

        return nil;
    }
    
    if (!configuration || ![configuration isKindOfClass:[NSDictionary class]]) {
        configuration = @{};
    }
    
    return [[self alloc] initForObject:object
                        withIdentifier:identifier
                         configuration:configuration];
}

- (instancetype)initForObject:(CENObject *)object
               withIdentifier:(NSString *)identifier
                configuration:(NSDictionary *)configuration {
    
    if ((self = [super init])) {
        _configuration = configuration;
        _identifier = identifier;
        _object = object;
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

#pragma mark -


@end
