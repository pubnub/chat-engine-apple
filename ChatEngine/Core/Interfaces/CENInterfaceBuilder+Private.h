/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENInterfaceBuilder.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types

/**
 * @brief Builder execution block which is used to pass user-provided flags and arguments.
 *
 * @param flags List of enabled flags.
 * @param \a NSDictionary with key / value pairs which has been configured by user during builder
 *     methods usages.
 */
typedef __nullable id (^CENInterfaceCallCompletionBlock)(NSArray<NSString *> *flags,
                                                         NSDictionary *arguments);


#pragma mark - Private interface declaration

@interface CENInterfaceBuilder (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief Create and API access builder.
 *
 * @param block Block which will be called when user confirm API call with configured options.
 *
 * @throws \a NSInternalInconsistencyException exception in following cases:
 * - block not provided.
 *
 * @return Configured and ready to use API access builder.
 */
+ (instancetype)builderWithExecutionBlock:(CENInterfaceCallCompletionBlock)block;

/**
 * @brief Enable specified \c flag for API call.
 *
 * @discussion Method can be used during builder initialization to help identify method from API
 * group which should be called.
 *
 * @param flag Reference on \c flag which should be set for API call.
 */
- (void)setFlag:(NSString *)flag;

/**
 * @brief Set provided \c argument for API call \c parameter.
 *
 * @discussion Method can be used during builder initialization to provide required parameters for
 * constructed API call.
 *
 * @param argument Argument which should be set for \c parameter.
 * @param parameter Name of parameter for which value should be set.
 */
- (void)setArgument:(nullable id)argument forParameter:(NSString *)parameter;


#pragma mark - Execution

/**
 * @brief Execute configured API call.
 *
 * @discussion Try to use user-provided information to execute target API.
 *
 * @return API execution results.
 */
- (nullable id)performWithReturnValue;

/**
 * @brief Execute configured API call.
 *
 * @discussion Try to use user-provided information to execute target API.
 *
 * @param block API execution completion block to which \b {CENChatEngine} client will
 * pass results.
 */
- (void)performWithBlock:(nullable id)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
