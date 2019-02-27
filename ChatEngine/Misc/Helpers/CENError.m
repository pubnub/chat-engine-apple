/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENError.h"
#import <PubNub/PubNub.h>
#import "CENErrorCodes.h"


#pragma mark Protected interface declaration

@interface CENError ()


#pragma mark - Misc

/**
 * @brief Get error code from \b PubNub status error \c category.
 *
 * @param status \b PubNub error status object with \c category which should be used to determine
 *     error code.
 *
 * @return Error code which conform to \c category from CENErrorCodes header.
 */
+ (NSInteger)errorCodeFromPubNubStatus:(PNErrorStatus *)status;

/**
 * @brief Get error code from \b PubNub Function error.
 *
 * @param error \a NSError which has been created during request to \b PubNub Functions.
 *
 * @return Error code which conform to \c category from \b {CENErrorCodes}.
 */
+ (NSInteger)errorCodeFromPubNubFunctionError:(NSError *)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENError


#pragma mark - PubNub

+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status {
    
    return [self errorFromPubNubStatus:status withUserInfo:@{ }];
}

+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status withDescription:(NSString *)description {
    
    return [self errorFromPubNubStatus:status
                          withUserInfo:@{ NSLocalizedDescriptionKey: description }];
    
}

+ (NSError *)errorFromPubNubStatus:(PNErrorStatus *)status withUserInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *errorInformation = [@{
        NSLocalizedDescriptionKey: (status.errorData.information ?: @"Unknown error")
    } mutableCopy];
    [errorInformation addEntriesFromDictionary:userInfo];
    
    return [NSError errorWithDomain:kCENPNErrorDomain
                               code:[self errorCodeFromPubNubStatus:status]
                           userInfo:errorInformation];
}

+ (NSError *)errorFromPubNubFunctionError:(NSArray *)responses
                          withDescription:(NSString *)description {
    
    NSError *functionError = nil;
    
    for (id response in responses) {
        if ([response isKindOfClass:[NSError class]]) {
            functionError = response;
            
            break;
        }
    }
    
    if (!functionError) {
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: @"Unknown error" };
        functionError = [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorUnknown
                                        userInfo:errorInformation];
    }
    
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: description,
        NSUnderlyingErrorKey: functionError
    };
    
    return [NSError errorWithDomain:kCENPNFunctionErrorDomain
                               code:[self errorCodeFromPubNubFunctionError:functionError]
                           userInfo:userInfo];
}


#pragma mark - Misc

+ (NSInteger)errorCodeFromPubNubStatus:(PNErrorStatus *)status {
    
    NSInteger code;
    
    switch (status.category) {
        case PNAccessDeniedCategory:
            code = kCENPNAccessDeniedError;
            break;
        case PNTimeoutCategory:
            code = kCENPNTimeoutError;
            break;
        case PNNetworkIssuesCategory:
            code = kCENPNNetworkIssuesError;
            break;
        case PNBadRequestCategory:
            code = kCENPNBadRequestError;
            break;
        case PNRequestURITooLongCategory:
            code = kCENPNRequestURITooLongError;
            break;
        case PNMalformedResponseCategory:
            code = kCENPNMalformedResponseError;
            break;
        default:
            code = kCENUnknownErrorCode;
            break;
    }
    
    return code;
}

+ (NSInteger)errorCodeFromPubNubFunctionError:(NSError *)error {
    
    NSInteger code;
    
    switch (error.code) {
        case NSURLErrorUserAuthenticationRequired:
            code = kCENPNAccessDeniedError;
            break;
        case NSURLErrorBadServerResponse:
            code = kCENPNMalformedResponseError;
            break;
        case NSURLErrorBadURL:
            code = kCENPNBadRequestError;
            break;
        default:
            code = kCENUnknownErrorCode;
            break;
    }
    
    return code;
}

#pragma mark -


@end
