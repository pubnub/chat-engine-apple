/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUploadcareFileInformation+Private.h>
#import <XCTest/XCTest.h>


@interface CENUploadcareFileInformationTest : XCTestCase


#pragma mark - Misc

- (NSDictionary *)normalizedFileInformation;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUploadcareFileInformationTest


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldParseBaseInformation {
    
    NSDictionary *payload = [self normalizedFileInformation];
    CENUploadcareFileInformation *info = [CENUploadcareFileInformation fileInformationFromPayload:payload];
    
    XCTAssertEqualObjects(info.uuid, payload[@"uuid"]);
    XCTAssertEqualObjects(info.name, payload[@"name"]);
    XCTAssertEqualObjects(info.size, payload[@"size"]);
    XCTAssertTrue(info.isStored);
    XCTAssertTrue(info.isImage);
    XCTAssertEqualObjects(info.url, [NSURL URLWithString:payload[@"cdnUrl"]]);
    XCTAssertEqualObjects(info.originalURL, [NSURL URLWithString:payload[@"originalUrl"]]);
    XCTAssertNil(info.urlModifiers);
}

- (void)testConstructor_ShouldParseOriginalImageInformation {
    
    NSDictionary *payload = [self normalizedFileInformation];
    CENUploadcareFileInformation *info = [CENUploadcareFileInformation fileInformationFromPayload:payload];
    payload = payload[@"originalImageInfo"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1434398756];
    
    XCTAssertEqualObjects(info.width, payload[@"width"]);
    XCTAssertEqualObjects(info.height, payload[@"height"]);
    XCTAssertEqualObjects(info.format, payload[@"format"]);
    XCTAssertEqualObjects(info.longitude, payload[@"geo_location"][@"longitude"]);
    XCTAssertEqualObjects(info.latitude, payload[@"geo_location"][@"latitude"]);
    XCTAssertEqualObjects(info.date, date);
    XCTAssertEqualObjects(info.orientation, payload[@"orientation"]);
    XCTAssertEqualObjects(info.resolution, payload[@"dpi"]);
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
