#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief API call builder pattern support.
 *
 * @discussion Class allow to simplify interface variations (list of passed arguments to methods) by
 * providing ability specify each argument as separate chained setter call.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENInterfaceBuilder : NSObject


#pragma mark Initialization and Configuration

/**
 * @brief Instantiation should be done using class method
 * \b [CENInterfaceBuilder builderWithExecutionBlock:].
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - attempt to create instance using \c new.
 *
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype)__unavailable init;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
