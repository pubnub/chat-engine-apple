/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENUploadcareFileInformation+Private.h"
#import "CENUploadcareMiddleware.h"


@implementation CENUploadcareMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    return @[@"$uploadcare.upload"];
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    NSDictionary *uploadcarePayload = data[CENEventData.data];
    if (![uploadcarePayload isKindOfClass:[NSDictionary class]]) {
        block(NO);
        return;
    }
    
    CENUploadcareFileInformation *information = nil;
    information = [CENUploadcareFileInformation fileInformationFromPayload:uploadcarePayload];
    data[CENEventData.data] = information;
    
    block(NO);
}

#pragma mark -


@end
