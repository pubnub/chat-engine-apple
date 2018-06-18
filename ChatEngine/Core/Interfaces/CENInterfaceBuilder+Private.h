/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENInterfaceBuilder.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Types

typedef __nullable id(^CEInterfaceCallCompletionBlock)(NSArray<NSString *> *flags, NSDictionary *arguments);


#pragma mark - Private interface declaration

@interface CENInterfaceBuilder (Private)


#pragma mark - Initialization and Configuration

+ (void)copyMethodsFromClasses:(NSArray<Class> *)classes;
+ (instancetype)builderWithExecutionBlock:(CEInterfaceCallCompletionBlock)block;
- (void)setFlag:(NSString *)flag;
- (void)setArgument:(nullable id)argument forParameter:(NSString *)parameter;


#pragma mark - Execution

- (nullable id)performWithReturnValue;
- (void)performWithBlock:(nullable id)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
