/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENInterfaceBuilder+Private.h"
#import <objc/runtime.h>


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENInterfaceBuilder ()


#pragma mark - Properties

@property (nonatomic, strong) NSMutableArray<NSString *> *flags;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *arguments;
@property (nonatomic, strong) CEInterfaceCallCompletionBlock executionBlock;


#pragma mark - Initialization and Configuration

- (instancetype)initWithExecutionBlock:(CEInterfaceCallCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENInterfaceBuilder


#pragma mark - Initialization and Configuration

+ (void)copyMethodsFromClasses:(NSArray<Class> *)classes {
    
    unsigned int methodsCount = 0;
    
    for (NSUInteger classIdx = 0; classIdx < classes.count; classIdx++) {
        Method *methods = class_copyMethodList(classes[classIdx], &methodsCount);
        
        for (unsigned int methodIdx = 0; methodIdx < methodsCount; methodIdx++) {
            Method method = methods[methodIdx];
            SEL selector = method_getName(method);
            
            if (!class_getInstanceMethod(self, selector)) {
                IMP implementation = method_getImplementation(method);
                
                class_addMethod(self, selector, implementation, method_getTypeEncoding(method));
            }
        }
        free(methods);
    }
}

+ (instancetype)builderWithExecutionBlock:(CEInterfaceCallCompletionBlock)block {
    
    if (!block) {
        [NSException raise:NSInternalInconsistencyException format:@"%@ instance can't be created w/o execution block", NSStringFromClass(self)];
    }
    
    return [[self alloc] initWithExecutionBlock:block];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException format:@"-init not implemented, please use: +builderWithExecutionBlock:"];
    
    return nil;
}

- (instancetype)initWithExecutionBlock:(CEInterfaceCallCompletionBlock)block {
    
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
