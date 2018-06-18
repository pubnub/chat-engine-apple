#import <Foundation/Foundation.h>

@class CENChatEngine;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b PubNub function access class.
 * @discussion \b ChatEngine server-side implemented with \b PubNub Functions. This class provide ability to call particular
 *             endpoints on running \b PubNub Function.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENPNFunctionClient : NSObject


#pragma mark - Information

@property (nonatomic, readonly, copy) NSString *endpointURL;


#pragma mark - Initialization and Configuration

/**
 * @brief      Create and configure \b PubNub Functions access client at specified endpoint.
 * @discussion Client allow to perform series of requests on \b PubNub Function and gather responses.
 *
 * @param endpoint Reference on endpoint which is used to access various \b PubNub Functions in configured account scope.
 *
 * @return Configured and ready to use \b PubNub Functions client.
 */
+ (instancetype)clientWithEndpoint:(NSString *)endpoint;

/**
 * @brief  Instantiation should be done using class method \c +clientWithEndpoint:.
 *
 * @throws \a NSException
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype) __unavailable init;

/**
 * @brief  Set / update default data object which is sent along with every request to \b PubNub Functions.
 *
 * @param globalChat Reference on name of global chat (basically used as namespace).
 * @param uuid       Reference on unique identifier of local user on behalf of which requests will be performed.
 * @param authKey    Reference on local user authentication key which is used to ensure access rights for performed
 *                   operations.
 */
- (void)setDefaultDataWithGlobalChat:(NSString *)globalChat userUUID:(NSString *)uuid userAuth:(NSString *)authKey;


#pragma mark - REST API call

/**
 * @brief      Call set of REST API endpoints one by one.
 * @discussion Call endpoints from passed list one by one. If one of request fails, next REST API call(s) will be cancelled.
 *
 * @param series Reference on list of dictionaries with following keys: route, method, query and body. These keys allow to
 *               configure call to one of REST API routes.
 * @param block  Reference on complection block which will be called at the end of all operations. Block pass two arguments:
 *               \success - whether all operations has been performed successfully or not; \c responses - list of service
 *               response for each of passed API call route.
 */
- (void)callRouteSeries:(NSArray<NSDictionary *> *)series withCompletion:(void(^)(BOOL success, NSArray * __nullable responses))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
