#import "CENInterfaceBuilder.h"

#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      User instance creation/audition API interface builder.
 * @discussion Class describe interface which allow to create new \c CENUser instances or retrieve previously created.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2017 PubNub, Inc.
 */
@interface CENUserBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief      Specify dictionary which may contain additional information about \c user and publicly available from
 *             \b ChatEngine network.
 * @discussion User's m\b ChatEngine network.etadata publicly available for all chat participants.
 */
@property (nonatomic, readonly, strong) CENUserBuilderInterface * (^state)(NSDictionary * __nullable state);


#pragma mark - Call

/**
 * @brief      Create new user instance using passed parameters.
 * @discussion If \b CENUser with same parameters exists, it will be returned instead of new instance. Newly created instances
 *             are stored within \b ChatEngine and can be requested later with \c get method or using \b CENChatEngine
 *             property called 'users'.
 */
@property (nonatomic, readonly, strong) CENUser * (^create)(void);

/**
 * @brief  Search for user instance basing on passed parameters.
 */
@property (nonatomic, readonly, strong) CENUser * __nullable (^get)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
