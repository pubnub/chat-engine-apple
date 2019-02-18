/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENErrorCodes.h>
#import <PubNub/PNResult+Private.h>
#import <PubNub/PNStatus+Private.h>
#import <CENChatEngine/CENError.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>


@interface CENErrorTest : XCTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CENErrorTest


#pragma mark - Tests :: errorFromPubNubStatus

- (void)testErrorFromPubNubStatus_ShouldCreateNSErrorWithAccessDeniedCode_WhenStatusWithAccessDeniedCategoryPassed {
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNAccessDeniedCategory]];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqual(error.code, kCENPNAccessDeniedError);
    XCTAssertEqualObjects(error.localizedDescription, [self informationForCategory:PNAccessDeniedCategory]);
}

- (void)testErrorFromPubNubStatus_ShouldCreateNSErrorWithTimeoutCode_WhenStatusWithTimeoutCategoryPassed {
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNTimeoutCategory]];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqual(error.code, kCENPNTimeoutError);
    XCTAssertEqualObjects(error.localizedDescription, [self informationForCategory:PNTimeoutCategory]);
}

- (void)testErrorFromPubNubStatus_ShouldCreateNSErrorWithNetworkIssueCode_WhenStatusWithNetworkIssueCategoryPassed {
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNNetworkIssuesCategory]];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqual(error.code, kCENPNNetworkIssuesError);
    XCTAssertEqualObjects(error.localizedDescription, [self informationForCategory:PNNetworkIssuesCategory]);
}

- (void)testErrorFromPubNubStatus_ShouldCreateNSErrorWithBadRequestCode_WhenStatusWithBadRequestCategoryPassed {
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNBadRequestCategory]];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqual(error.code, kCENPNBadRequestError);
    XCTAssertEqualObjects(error.localizedDescription, [self informationForCategory:PNBadRequestCategory]);
}

- (void)testErrorFromPubNubStatus_ShouldCreateNSErrorWithRequestURITooLongCode_WhenStatusWithTooLongURICategoryPassed {
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNRequestURITooLongCategory]];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqual(error.code, kCENPNRequestURITooLongError);
    XCTAssertEqualObjects(error.localizedDescription, [self informationForCategory:PNRequestURITooLongCategory]);
}

- (void)testErrorFromPubNubStatus_ShouldCreateNSErrorWithMalformedResponseCode_WhenStatusMalformedResponseCategoryPassed {
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNMalformedResponseCategory]];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqual(error.code, kCENPNMalformedResponseError);
    XCTAssertEqualObjects(error.localizedDescription, [self informationForCategory:PNMalformedResponseCategory]);
}


#pragma mark - Tests :: errorFromPubNubStatusWithDescription

- (void)testErrorFromPubNubStatusWithDescription_ShouldCreateErrorWithCustomDescription {
    
    NSString *expected = @"Some test description";
    
    NSError *error = [CENError errorFromPubNubStatus:[self errorStatusWithCategory:PNMalformedResponseCategory]
                                     withDescription:expected];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqualObjects(error.localizedDescription, expected);
}


#pragma mark - Tests :: errorFromPubNubStatusWithUserInfo

- (void)testErrorFromPubNubStatusWithUserInfo_ShouldCreateErrorWithDefaultDescription_WhenInformationIsMissing {
    
    NSString *expected = @"Unknown error";
    PNErrorStatus *status = nil;
    
    NSError *error = [CENError errorFromPubNubStatus:status withUserInfo:@{}];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNErrorDomain);
    XCTAssertEqualObjects(error.localizedDescription, expected);
}


#pragma mark - Tests :: errorFromPubNubFunctionError

- (void)testErrorFromPubNubFunctionError_ShouldCreateNSErrorWithAccessDeniedCode_WhenHTTPAuthenticationRequiredErrorPassed {
    
    NSString *expected = @"User not authorized";
    
    NSError *httpError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUserAuthenticationRequired userInfo:nil];
    NSError *error = [CENError errorFromPubNubFunctionError:@[httpError] withDescription:expected];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNFunctionErrorDomain);
    XCTAssertEqual(error.code, kCENPNAccessDeniedError);
    XCTAssertEqualObjects(error.localizedDescription, expected);
    XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], httpError);
}

- (void)testErrorFromPubNubFunctionError_ShouldCreateNSErrorMalformedResponseCode_WhenHTTPBadServerResponseErrorPassed {
    
    NSString *expected = @"Malformed server response";
    
    
    NSError *httpError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil];
    NSError *error = [CENError errorFromPubNubFunctionError:@[httpError] withDescription:expected];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNFunctionErrorDomain);
    XCTAssertEqual(error.code, kCENPNMalformedResponseError);
    XCTAssertEqualObjects(error.localizedDescription, expected);
    XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], httpError);
}

- (void)testErrorFromPubNubFunctionError_ShouldCreateNSErrorBadRequestCode_WhenHTTPBadURLErrorPassed {
    
    NSString *expected = @"Too long URI";
    
    NSError *httpError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    NSError *error = [CENError errorFromPubNubFunctionError:@[httpError] withDescription:expected];
    
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kCENPNFunctionErrorDomain);
    XCTAssertEqual(error.code, kCENPNBadRequestError);
    XCTAssertEqualObjects(error.localizedDescription, expected);
    XCTAssertEqualObjects(error.userInfo[NSUnderlyingErrorKey], httpError);
}

- (void)testErrorFromPubNubFunctionError_ShouldCreateDefaultError_WhenPubNubFunctionsResponseListEmpty {
    
    NSString *expected = @"Unknown error";
    
    NSError *error = [CENError errorFromPubNubFunctionError:@[] withDescription:expected];
    NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
    
    XCTAssertNotNil(error);
    XCTAssertNotNil(underlyingError);
    XCTAssertEqualObjects(error.domain, kCENPNFunctionErrorDomain);
    XCTAssertEqualObjects(underlyingError.domain, NSURLErrorDomain);
    XCTAssertEqual(error.code, kCENUnknownErrorCode);
    XCTAssertEqual(underlyingError.code, NSURLErrorUnknown);
    XCTAssertEqualObjects(error.localizedDescription, expected);
    XCTAssertEqualObjects(underlyingError.localizedDescription, expected);
}


#pragma mark - Misc

- (PNErrorStatus *)errorStatusWithCategory:(PNStatusCategory)category {
    
    NSMutableDictionary *processedData = [@{ @"channels": @[] } mutableCopy];
    processedData[@"information"] = [self informationForCategory:category];
    processedData[@"status"] = [self statusForCategory:category];
    
    PNErrorStatus *status = [PNErrorStatus objectForOperation:PNSubscribeOperation completedWithTask:nil
                                                processedData:processedData processingError:nil];
    status.category = category;
    
    return status;
}

- (NSString *)informationForCategory:(PNStatusCategory)category {
    
    NSDictionary *information = @{
        @(PNAccessDeniedCategory).stringValue: @"Access denied",
        @(PNTimeoutCategory).stringValue: @"Request timeout",
        @(PNNetworkIssuesCategory).stringValue: @"Network issues",
        @(PNBadRequestCategory).stringValue: @"Bad request",
        @(PNRequestURITooLongCategory).stringValue: @"URI is too long",
        @(PNMalformedResponseCategory).stringValue: @"Malformed response",
    };
    
    return information[@(category).stringValue];
}

- (NSNumber *)statusForCategory:(PNStatusCategory)category {
    
    NSDictionary *status = @{
        @(PNAccessDeniedCategory).stringValue: @403,
        @(PNTimeoutCategory).stringValue: @501,
        @(PNNetworkIssuesCategory).stringValue: @502,
        @(PNBadRequestCategory).stringValue: @503,
        @(PNRequestURITooLongCategory).stringValue: @504,
        @(PNMalformedResponseCategory).stringValue: @500,
    };
    
    return status[@(category).stringValue];
}

#pragma mark -


@end
