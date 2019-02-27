/**
 * @brief Reference header for list of error domains and error codes constants.
 *
 * @ref 8f4a9f32-0a40-43ef-a19c-0bbde5f9d312
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef CENErrorCodes_h
#define CENErrorCodes_h


#pragma mark Externs

/**
 * @brief Key under which stored \a NSError object composed from \b PubNub Function failure
 * response inside of \c NSError.userInfo emitted with \c $.error.* event.
 *
 * @ref 2266335b-1d96-4cc1-a831-b34d76d0586d
 */
extern NSString * const kCEPNFunctionErrorResponseDataKey;


#pragma mark - Error domains

/**
 * @brief Error arrived from \b PubNub client API error status.
 *
 * @ref 1afd42d4-3e8c-4630-aaa5-863a4b5a59b9
 */
static NSString * const kCENPNErrorDomain = @"PNErrorDomain";

/**
 * @brief Error arrived from \b {CENChatEngine} API usage.
 *
 * @ref 3e283a74-7ce2-446b-bca1-8ee797ec8509
 */
static NSString * const kCENErrorDomain = @"CENErrorDomain";

/**
 * @brief Error arrived from \b PubNub Function API error messages.
 *
 * @ref e7b6f910-948f-4e80-89a2-e2aa10de0af4
 */
static NSString * const kCENPNFunctionErrorDomain = @"CENPNFunctionErrorDomain";


#pragma mark - General error codes

/**
 * @brief Code of error which can't be identified or not known for current
 * \b {CENChatEngine} version.
 *
 * @ref f676a131-a9f7-452d-97b2-4c88a40df4a0
 */
static NSInteger const kCENUnknownErrorCode = -1;
static NSInteger const kCENClientNotReadyError = 3000;

/**
 * @brief \b {CENChatEngine} was unable to complete \b {user's CENMe} connection.
 *
 * @ref 101b6f2c-71fc-4019-9cfb-24b1d5d5d69f
 */
static NSInteger const kCENClientNotConnectedError = 3001;


#pragma mark - Chat error codes

/**
 * @brief Attempt to connect to \b {chat CENChat} which already connected.
 *
 * @ref 0518fb30-1880-4b60-b431-b4d2f86b0c81
 */
static NSInteger const kCENChatAlreadyConnectedError = 3002;
/**
 * @brief Attempt to call \b {chat CENChat} methods w/o connecting to it first.
 *
 * @ref 630c6ab0-e7f7-47a6-a668-49602fffa3c9
 */
static NSInteger const kCENChatNotConnectedError = 3003;

/**
 * @brief Attempt to use \b {CENChatEngine} method w/o passing valid \b {chat CENChat} to
 * it.
 *
 * @ref bc2d70c5-b237-46d7-8278-ed1ea08b93bc
 */
static NSInteger const kCENChatMissingError = 3004;


#pragma mark - PubNub error codes

/**
 * @brief \b PubNub client doesn't have access to requested resources.
 *
 * @ref d7b76a3c-ec58-425c-9ea6-6f259853b931
 */
static NSInteger const kCENPNAccessDeniedError = 3005;

/**
 * @brief \b PubNub API call timed out.
 *
 * @ref 709a1abc-fccc-4460-86aa-1e20792ef8ba
 */
static NSInteger const kCENPNTimeoutError = 3006;

/**
 * @brief Unable to connect to \b PubNub real-time network because of internet issues.
 *
 * @ref 67d9c772-7314-480b-9532-fe4c46e2a9f2
 */
static NSInteger const kCENPNNetworkIssuesError = 3007;

/**
 * @brief Incomplete \b PubNub API call configuration.
 *
 * @ref 33f64c31-fd83-40d5-970e-045acafad36e
 */
static NSInteger const kCENPNBadRequestError = 3008;

/**
 * @brief Too much data passed to \b PubNub API.
 *
 * @ref e51d16b1-442b-4113-8050-9045b6dfaaf0
 */
static NSInteger const kCENPNRequestURITooLongError = 3009;

/**
 * @brief Unknown or malformed response received from \b PubNub service.
 *
 * @ref f1486147-ca13-4ff3-a4c0-03f247e8ba45
 */
static NSInteger const kCENPNMalformedResponseError = 3010;


#pragma mark - Publish

/**
 * @brief Attempt to publish unsupported payload to \b {chat CENChat}.
 *
 * @ref 22ba99ba-0667-4338-bfea-a70cc57ba4a1
 */
static NSInteger const kCENMalformedPayloadError = 3011;

#endif // CENErrorCodes_h

