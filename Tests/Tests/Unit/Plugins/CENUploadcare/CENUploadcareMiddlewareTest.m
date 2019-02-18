/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUploadcareFileInformation.h>
#import <CENChatEngine/CENUploadcareMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUploadcareMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENUploadcareMiddleware *middleware;
@property (nonatomic, nullable, strong) id middlewareMock;


#pragma mark - Misc

- (NSDictionary *)normalizedFileInformation;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUploadcareMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.middleware = [CENUploadcareMiddleware new];
    self.middlewareMock = [self mockForObject:self.middleware];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENUploadcareMiddleware.events, @[@"$uploadcare.upload"]);
}

- (void)testLocation_ShouldBeSetToEmit {
    
    XCTAssertEqualObjects(CENUploadcareMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: Call

- (void)testCall_ShouldWrapNSDictionaryToObject {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: [self normalizedFileInformation] } mutableCopy];
    [self.middleware runForEvent:@"$uploadcare.upload" withData:payload completion:^(BOOL rejected) {
        XCTAssertFalse(rejected);
    }];
    
    XCTAssertTrue([payload[CENEventData.data] isKindOfClass:[CENUploadcareFileInformation class]]);
}

- (void)testCall_ShouldNotWrapNSDictionaryToObject_WhenNonNSDictionaryPayloadDataPassed {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @2010 } mutableCopy];
    [self.middleware runForEvent:@"$uploadcare.upload" withData:payload completion:^(BOOL rejected) {
        XCTAssertFalse(rejected);
    }];
    
    XCTAssertFalse([payload[CENEventData.data] isKindOfClass:[CENUploadcareFileInformation class]]);
}


#pragma mark - Misc

- (NSDictionary *)normalizedFileInformation {
    
    return @{
        @"uuid": @"adc41366-0c9b-4837-88db-785d11914fb9",
        @"name": @"IMG_0679.jpg",
        @"size": @(2134543),
        @"isStored": @YES,
        @"isImage": @YES,
        @"cdnUrl": @"https://ucarecdn.com/adc41366-0c9b-4837-88db-785d11914fb9/",
        @"originalUrl": @"https://ucarecdn.com/adc41366-0c9b-4837-88db-785d11914fb9/",
        @"originalImageInfo": @{
            @"width": @(3264),
            @"height": @(2448),
            @"format": @"JPEG",
            @"geo_location": @{
                @"longitude": @(48.46485833333334),
                @"latitude": @(35.04743333333333),
            },
            @"datetime_original": @"2015-06-15T20:05:56",
            @"orientation": @"landscape",
            @"dpi": @[@(72), @(72)]
        }
    };
}

#pragma mark -


@end
