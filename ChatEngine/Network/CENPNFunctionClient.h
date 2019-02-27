#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CENChatEngine, PNLLogger;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b PubNub function access class.
 *
 * @discussion \b {CENChatEngine} server-side implemented with \b PubNub Functions.
 * This class provide ability to call particular endpoints on running \b PubNub Function.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENPNFunctionClient : NSObject


#pragma mark - Information

/**
 * @brief \b PubNub Function location URI.
 */
@property (nonatomic, readonly, copy) NSString *endpointURL;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure \b PubNub Function client.
 *
 * @param endpoint \b PubNub Function location URI.
 * @Param logger \b {CENChatEngine} \b logger for updates output.
 *
 * @return Configured and ready to use functions client.
 */
+ (instancetype)clientWithEndpoint:(NSString *)endpoint logger:(PNLLogger *)logger;

/**
 * @brief Instantiate \b PubNub Function client.
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - attempt to create instance using \c new.
 *
 * @return \c nil.
 */
- (instancetype) __unavailable init;

/**
 * @brief Client's configuration refresh.
 *
 * @param namespace Namespace inside of which \b {chats CENChat} will be created.
 * @param uuid Unique identifier which will be used by \b {local user CENMe}.
 * @param authKey User authentication secret key. Will be sent to authentication backend for
 *     validation. This is usually an access token.
 */
- (void)setWithNamespace:(NSString *)namespace
                userUUID:(NSString *)uuid
                userAuth:(NSString *)authKey;


#pragma mark - REST API call

/**
 * @brief Perform series of requests to \b PubNub Function.
 *
 * @param series \a NSArray with list of route call objects which should be performed one-by-one.
 * @param block Block / closure which will be called at the end of \c series of request completion
 *     and pass service response or error (if not \c success).
 */
- (void)callRouteSeries:(NSArray<NSDictionary *> *)series
         withCompletion:(void(^)(BOOL success, NSArray * __nullable responses))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
