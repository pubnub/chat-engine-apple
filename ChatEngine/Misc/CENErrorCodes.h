/**
 @brief Reference header for list of error domains and error codes constants.
 
 @author Serhii Mamontov
 @version 0.9.13
 @copyright © 2009-2018 PubNub, Inc.
 */
#import <Foundation/Foundation.h>


#ifndef CENErrorCodes_h
#define CENErrorCodes_h


#pragma mark - Error domains


static NSString * const kCEPNErrorDomain = @"PNErrorDomain";
static NSString * const kCEErrorDomain = @"CEErrorDomain";
static NSString * const kCEPNFunctionErrorDomain = @"CEPNFunctionErrorDomain";


#pragma mark - General error codes

static NSInteger const kCEUnknownErrorCode = -1;
static NSInteger const kCEClientNotReadyError = 3000;
static NSInteger const kCEClientNotConnectedError = 3001;


#pragma mark - Function

static NSInteger const kCEPNAuthorizationError = 3002;
static NSInteger const kCEPNAPresenceLeaveError = 3003;


#pragma mark - Presence

static NSInteger const kCEChannelPresenceAuditError = 3004;


#pragma mark - Session

static NSInteger const kCEChannelGroupAuditError = 3005;
static NSInteger const kCEAPIUnacceptableParameters = 3006;


#pragma mark - Publish

static NSInteger const kCEEmptyMessageError = 3007;
static NSInteger const kCEPublishError = 3008;

static NSInteger const kCEMalformedPayloadError = 3009;

#endif // CENErrorCodes_h

