/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENInterfaceBuilder+Private.h"
#import <objc/runtime.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENInterfaceBuilder ()


#pragma mark - Properties

/**
 * @brief List of user-configured API call flags.
 *
 * @discussion Usually stores flags which allow to identify API type (if there is group of API
 * available for single endpoint). Flags also used in cased when default state should be adjusted.
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *flags;

/**
 * @brief \a NSDictionary with key / value pairs which should be passed to API.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *arguments;

/**
 * @brief Block which will be called in response \c -performWithBlock: method call.
 */
@property (nonatomic, strong) CENInterfaceCallCompletionBlock executionBlock;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize API access builder.
 *
 * @param block Block which will be called when user confirm API call with configured options.
 *
 * @return Initialized and ready to use API access builder.
 */
- (instancetype)initWithExecutionBlock:(CENInterfaceCallCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENInterfaceBuilder


#pragma mark - Initialization and Configuration

+ (instancetype)builderWithExecutionBlock:(CENInterfaceCallCompletionBlock)block {
    
    if (!block) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%@ instance can't be created w/o execution block",
                           NSStringFromClass(self)];
    }
    
    return [[self alloc] initWithExecutionBlock:block];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException
                format:@"-init not implemented, please use: +builderWithExecutionBlock:"];
    
    return nil;
}

- (instancetype)initWithExecutionBlock:(CENInterfaceCallCompletionBlock)block {
    
    if ((self = [super init])) {
        _flags = [NSMutableArray new];
        _arguments = [NSMutableDictionary new];
        _executionBlock = [block copy];
    }
    
    return self;
}

- (void)setFlag:(NSString *)flag {
    
    if ([flag isKindOfClass:[NSString class]]) {
        [self.flags addObject:flag];
    }
}

- (void)setArgument:(id)argument forParameter:(NSString *)parameter {
    
    if (parameter) {
        self.arguments[parameter] = argument;
    }
}

- (id)performWithReturnValue {
    
    return self.executionBlock(self.flags, self.arguments);
}

- (void)performWithBlock:(id)block {
    
    self.arguments[@"block"] = block;
    self.executionBlock(self.flags, self.arguments);
}

#pragma mark -


@end
