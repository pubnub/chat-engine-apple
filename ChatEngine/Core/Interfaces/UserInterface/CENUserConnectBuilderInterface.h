#import "CENInterfaceBuilder.h"

#pragma mark Class forward

@class CENChatEngine, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      User connection API interface builder.
 * @discussion Class describe interface which allow to connect \c local user to real-time service.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2017 PubNub, Inc.
 */
@interface CENUserConnectBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief      Specify user's meta data.
 * @discussion Object containing information about this client and publicly available.
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^state)(NSDictionary * __nullable state);

/**
 * @brief      Specify user's authorization key.
 * @discussion This key is used by \b ChatEngine back-end to authorize \c local user with service and provide all required
 *             access rights.
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^authKey)(NSString * __nullable authKey);


#pragma mark - Call

/**
 * @brief  Connect \c local user to real-time service with provided parameters.
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^perform)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
