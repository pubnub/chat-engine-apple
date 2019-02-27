/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENUploadcareFileInformation+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENUploadcareFileInformation ()


#pragma mark - Information

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, assign) BOOL isStored;
@property (nonatomic, assign) BOOL isImage;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, nullable, copy) NSString *urlModifiers;
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic, nullable, strong) NSNumber *width;
@property (nonatomic, nullable, strong) NSNumber *height;
@property (nonatomic, nullable, copy) NSString *format;
@property (nonatomic, nullable, strong) NSNumber *latitude;
@property (nonatomic, nullable, strong) NSNumber *longitude;
@property (nonatomic, nullable, copy) NSString *orientation;
@property (nonatomic, nullable, strong) NSDate *date;
@property (nonatomic, nullable, strong) NSArray<NSNumber *> *resolution;


#pragma mark - Initialization and configuration

/**
 * @brief Configure file information representation model.
 *
 * @param payload \b {Uploadcare https://uploadcare.com} Upload API \c file-info response.
 *
 * @return Configured and ready to use model.
 */
- (instancetype)initFromPayload:(NSDictionary *)payload;


#pragma mark - Misc

/**
 * @brief Process base file information from received \b {Uploadcare https://uploadcare.com} Upload
 * API response.
 *
 * @param uploadcareData Data with all information available for file.
 */
- (void)parseBaseFileInformationFrom:(NSDictionary *)uploadcareData;

/**
 * @brief Process image file information from received
 * \b {Uploadcare https://uploadcare.com} Upload API response.
 *
 * @param uploadcareData Data subset with information about original image.
 */
- (void)parseImageFileInformationFrom:(NSDictionary *)uploadcareData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENUploadcareFileInformation


#pragma mark - Initialization and configuration

+ (instancetype)fileInformationFromPayload:(NSDictionary *)payload {
    
    return [[self alloc] initFromPayload:payload];
}

- (instancetype)initFromPayload:(NSDictionary *)payload {
    
    if ((self = [super init])) {
        [self parseBaseFileInformationFrom:payload];
        
        if (payload[@"originalImageInfo"]) {
            [self parseImageFileInformationFrom:payload[@"originalImageInfo"]];
        }
        
    }
    
    return self;
}


#pragma mark - Misc

- (void)parseBaseFileInformationFrom:(NSDictionary *)uploadcareData {
    
    self.uuid = uploadcareData[@"uuid"];
    self.name = uploadcareData[@"name"];
    self.size = uploadcareData[@"size"];
    self.isStored = ((NSNumber *)uploadcareData[@"isStored"]).boolValue;
    self.isImage = ((NSNumber *)uploadcareData[@"isImage"]).boolValue;
    self.url = [NSURL URLWithString:uploadcareData[@"cdnUrl"]];
    self.urlModifiers = uploadcareData[@"cdnUrlModifiers"];
    self.originalURL = [NSURL URLWithString:uploadcareData[@"originalUrl"]];
}

- (void)parseImageFileInformationFrom:(NSDictionary *)uploadcareData {
    
    if (![uploadcareData[@"width"] isEqual:[NSNull null]]) {
        self.width = uploadcareData[@"width"];
    }
    
    if (![uploadcareData[@"height"] isEqual:[NSNull null]]) {
        self.height = uploadcareData[@"height"];
    }

    if (![uploadcareData[@"format"] isEqual:[NSNull null]]) {
        self.format = uploadcareData[@"format"];
    }
    
    if (![uploadcareData[@"datetime_original"] isEqual:[NSNull null]]) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        
        self.date = [formatter dateFromString:uploadcareData[@"datetime_original"]];
    }
    
    if (![uploadcareData[@"geo_location"] isEqual:[NSNull null]]) {
        NSDictionary *geoInformation = uploadcareData[@"geo_location"];
        
        self.latitude = geoInformation[@"latitude"];
        self.longitude = geoInformation[@"longitude"];
    }
    
    if (![uploadcareData[@"orientation"] isEqual:[NSNull null]]) {
        self.orientation = uploadcareData[@"orientation"];
    }
    
    if (![uploadcareData[@"dpi"] isEqual:[NSNull null]]) {
        self.resolution = uploadcareData[@"dpi"];
    }
}

#pragma mark -


@end
