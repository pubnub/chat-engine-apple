#import "CENInterfaceBuilder.h"

#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {User CENUser} creation / audition API access builder.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
@interface CENUserBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief \b {User's CENUser} global state addition block.
 *
 * @param state \a NSDictionary with \c user's information synchronized between all clients of the
 *     chat.
 *     To use this parameter \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration.
 *     \b Default: \c @{}
 *
 * @return Builder instance which allow to complete users management call configuration.
 */
@property (nonatomic, readonly, strong) CENUserBuilderInterface * (^state)(NSDictionary *state);


#pragma mark - Call

/**
 * @brief Create new \b {user CENUser} using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @warning If specified user never used \b {ChatEngine CENChatEngine} client, further manipulation
 * with instance may fail.
 *
 * @chain state.create
 *
 * @discussion Create user w/o state
 * @code
 * // objc 163ed912-6ccb-4455-adcc-a800115e0ffe
 *
 * CENUser *user = self.client.User(@"ChatEngineUser").create();
 * @endcode
 *
 * @discussion Create user w/ state
 * @code
 * // objc 146a891a-3d6f-46ce-b3ce-f9a5bde1e573
 *
 * CENUser *user = self.client.User(@"ChatEngineUser").state(@{ @"name": @"PubNub" }).create();
 * @endcode
 *
 * @return Configured and ready to use \b {user CENUser} instance.
 *
 * @ref 50cd442e-2aee-4ce7-bbd6-68ea40c42bca
 */
@property (nonatomic, readonly, strong) CENUser * (^create)(void);

/**
 * @brief Search for user instance basing on passed parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain get
 *
 * @discussion Retrieve previously created / online user
 * @code
 * // objc e734dc26-a698-4932-824f-6d77c45ef40d
 *
 * CENUser *user = self.client.User(@"ChatEngineUser").get();
 * @endcode
 *
 * @return Previously created \b {user CENUser} instance or \c nil in case if it doesn't exists.
 *
 * @ref e6f42c44-c5eb-4da2-8ad3-a0faac1e521f
 */
@property (nonatomic, readonly, strong) CENUser * __nullable (^get)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
