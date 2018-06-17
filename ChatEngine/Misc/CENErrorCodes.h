/**
 @brief Reference header for list of error domains and error codes constants.
 
 @author Serhii Mamontov
 @version 0.9.0
 @copyright © 2009-2018 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef CENErrorCodes_h
#define CENErrorCodes_h


#pragma mark - Error domains


static NSString * const kCENPNErrorDomain = @"PNErrorDomain";
static NSString * const kCENErrorDomain = @"CENErrorDomain";
static NSString * const kCENPNFunctionErrorDomain = @"CENPNFunctionErrorDomain";


#pragma mark - General error codes

static NSInteger const kCENUnknownErrorCode = -1;
static NSInteger const kCENClientNotReadyError = 3000;
static NSInteger const kCENClientNotConnectedError = 3001;


#pragma mark - PubNub error codes

static NSInteger const kCENPNAccessDeniedError = 3002;
static NSInteger const kCENPNTimeoutError = 3003;
static NSInteger const kCENPNNetworkIssuesError = 3004;
static NSInteger const kCENPNBadRequestError = 3005;
static NSInteger const kCENPNRequestURITooLongError = 3006;
static NSInteger const kCENPNMalformedResponseError = 3007;


#pragma mark - Publish

static NSInteger const kCENMalformedPayloadError = 3008;

#endif // CENErrorCodes_h

