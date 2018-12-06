/**
 @brief Reference header for list of error domains and error codes constants.
 
 @author Serhii Mamontov
 @version 0.10.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef CENErrorCodes_h
#define CENErrorCodes_h


#pragma mark Externs

/**
 * @brief Key under which stored \a NSError object composed from \b PubNub Function failure
 * response inside of \c NSError.userInfo emitted with \c $.error.* event.
 */
extern NSString * const kCEPNFunctionErrorResponseDataKey;


#pragma mark - Error domains

/**
 * @brief Error arrived from \b PubNub client API error status.
 */
static NSString * const kCENPNErrorDomain = @"PNErrorDomain";

/**
 * @brief Error arrived from \b {ChatEngine CENChatEngine} API usage.
 */
static NSString * const kCENErrorDomain = @"CENErrorDomain";

/**
 * @brief Error arrived from \b PubNub Function API error messages.
 */
static NSString * const kCENPNFunctionErrorDomain = @"CENPNFunctionErrorDomain";


#pragma mark - General error codes

/**
 * @brief Code of error which can't be identified or not known for current
 * \b {ChatEngine CENChatEngine} version.
 */
static NSInteger const kCENUnknownErrorCode = -1;

/**
 * @brief Used authorization key is empty or has unsupported data type.
 */
static NSInteger const kCENInvalidAuthKeyError = 3000;

/**
 * @brief \b {ChatEngine CENChatEngine} was unable to complete \b {user's CENMe} connection.
 */
static NSInteger const kCENClientNotConnectedError = 3001;


#pragma mark - Chat error codes

/**
 * @brief Attempt to connect to \b {chat CENChat} which already connected.
 */
static NSInteger const kCENChatAlreadyConnectedError = 3002;
/**
 * @brief Attempt to call \b {chat CENChat} methods w/o connecting to it first.
 */
static NSInteger const kCENChatNotConnectedError = 3003;

/**
 * @brief Attempt to use \b {ChatEngine CENChatEngine} method w/o passing valid \b {chat CENChat} to
 * it.
 */
static NSInteger const kCENChatMissingError = 3004;


#pragma mark - PubNub error codes

/**
 * @brief \b PubNub client doesn't have access to requested resources.
 */
static NSInteger const kCENPNAccessDeniedError = 3005;

/**
 * @brief \b PubNub API call timed out.
 */
static NSInteger const kCENPNTimeoutError = 3006;

/**
 * @brief Unable to connect to \b PubNub real-time network because of internet issues.
 */
static NSInteger const kCENPNNetworkIssuesError = 3007;

/**
 * @brief Incomplete \b PubNub API call configuration.
 */
static NSInteger const kCENPNBadRequestError = 3008;

/**
 * @brief Too much data passed to \b PubNub API.
 */
static NSInteger const kCENPNRequestURITooLongError = 3009;

/**
 * @brief Unknown or malformed response received from \b PubNub service.
 */
static NSInteger const kCENPNMalformedResponseError = 3010;


#pragma mark - Publish

/**
 * @brief Attempt to publish unsupported payload to \b {chat CENChat}.
 */
static NSInteger const kCENMalformedPayloadError = 3011;

#endif // CENErrorCodes_h

