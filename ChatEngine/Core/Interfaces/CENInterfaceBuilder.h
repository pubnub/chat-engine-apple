#import <Foundation/Foundation.h>


/**
 * @brief      API interface builder pattern support class.
 * @discussion Class allow to simplify interface variations (list of passed arguments to methods) by providing ability
 *             specify each argument as separate chained setter call.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENInterfaceBuilder : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief  Instantiation should be done using class method \c +builderWithExecutionBlock:.
 *
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype)__unavailable init;

#pragma mark -


@end
