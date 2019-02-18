/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import "CENUploadcareExtension.h"
#import "CENUploadcarePlugin.h"


#pragma mark Protected interface declaration

@interface CENUploadcareExtension ()


#pragma mark - Information


#pragma mark - Uploadcare

/**
 * @brief Create and configure \a NSURLSession instance which will be used to perform Uploadcore API
 * access requests.
 *
 * @return Configured and ready to use \a NSURLSession.
 */
- (NSURLSession *)uploadcareAPIAccessSession;

/**
 * @brief Create and configure \a NSURLRequest to send data to
 * \b {Uploadcare https://uploadcare.com}.
 *
 * @param url URI with API against which request should be created.
 * @param session \a NSURLSession which will build data task for this request.
 *
 * @return Configured and ready to use \a NSURLRequest.
 */
- (NSURLRequest *)uploadcareAPIRequestWithURL:(NSURL *)url forSession:(NSURLSession *)session;

/**
 * @brief Request information for file from \b {Uploadcare https://uploadcare.com} Upload API.
 *
 * @param identifier Unique identifier of file uploaded to Uploadcare.
 * @param block Result download completion handler block which pass service response in case of
 *     success.
 */
- (void)downloadInformationForFile:(NSString *)identifier
                        completion:(void(^)(NSDictionary * __nullable))block;


#pragma mark - Misc

/**
 * @brief Compose \c $uploadcare.upload event payload with file information received from
 * \b {Uploadcare https://uploadcare.com} Upload API.
 *
 * @param fileInformation b {Uploadcare https://uploadcare.com} Upload API response with raw file
 *     information.
 *
 * @return \a NSDictionary with same structure as has been described for
 * \b {JavaScript widget https://uploadcare.com/docs/api_reference/javascript/v2/#file-info}.
 */
- (NSDictionary *)eventPayloadFromFileInformation:(NSDictionary *)fileInformation;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENUploadcareExtension


#pragma mark - File share

- (void)shareFileWithIdentifier:(NSString *)identifier {
    
    [self downloadInformationForFile:identifier completion:^(NSDictionary *fileInformation) {
        if (!fileInformation) {
            return;
        }
        
        NSDictionary *payload = [self eventPayloadFromFileInformation:fileInformation];
        CENChat *chat = (CENChat *)self.object;
        
        [chat emitEvent:@"$uploadcare.upload" withData:payload];
    }];
}

- (void)downloadInformationForFile:(NSString *)identifier
                        completion:(void(^)(NSDictionary *))block {
    
    NSString *key = self.configuration[CENUploadcareConfiguration.publicKey];
    NSString *uploadcareURL = @"https://upload.uploadcare.com/info/";
    NSString *query = [@[@"pub_key=", key, @"&file_id=", identifier] componentsJoinedByString:@""];
    NSString *apiURL = [@[uploadcareURL, query] componentsJoinedByString:@"?"];
    NSURLSession *session = [self uploadcareAPIAccessSession];
    NSURLRequest *request = [self uploadcareAPIRequestWithURL:[NSURL URLWithString:apiURL]
                                                   forSession:session];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *contentType = httpResponse.allHeaderFields[@"Content-Type"];
        NSDictionary *fileInformation = nil;

        if (error || !data) {
            NSLog(@"Unable to get information about '%@': %@", identifier, error);
        } else if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
            NSJSONReadingOptions options = NSJSONReadingAllowFragments;
            NSError *parseError = nil;

            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:options
                                                                           error:&parseError];

            if (error || !responseData) {
                NSLog(@"Unable to parse uploadcare.com response: %@", error);
            } else {
                fileInformation = responseData;
            }
        }

        block(fileInformation);
    }] resume];
}


#pragma mark - Uploadcare

- (NSURLSession *)uploadcareAPIAccessSession {
    
    NSURLSessionConfiguration *configuration = nil;
    configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.URLCache = nil;
    configuration.HTTPShouldUsePipelining = YES;
    
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (NSURLRequest *)uploadcareAPIRequestWithURL:(NSURL *)url forSession:(NSURLSession *)session {
    
    NSURLSessionConfiguration *configuration = session.configuration;
    
    return [NSURLRequest requestWithURL:url
                            cachePolicy:configuration.requestCachePolicy
                        timeoutInterval:configuration.timeoutIntervalForRequest];
}


#pragma mark - Misc

- (NSDictionary *)eventPayloadFromFileInformation:(NSDictionary *)fileInformation {
    
    NSString *cdnBase = @"https://ucarecdn.com";
    NSMutableDictionary *payload = [@{ @"isStored": fileInformation[@"is_stored"] } mutableCopy];
    
    if (![fileInformation[@"uuid"] isEqual:[NSNull null]]) {
        payload[@"uuid"] = fileInformation[@"uuid"];
        payload[@"originalUrl"] = [@[cdnBase, payload[@"uuid"], @""] componentsJoinedByString:@"/"];
        payload[@"cdnUrl"] = payload[@"originalUrl"];
    }
    
    if (![fileInformation[@"original_filename"] isEqual:[NSNull null]]) {
        payload[@"name"] = fileInformation[@"original_filename"];
    }
    
    if (![fileInformation[@"size"] isEqual:[NSNull null]]) {
        payload[@"size"] = fileInformation[@"size"];
    }
    
    if (![fileInformation[@"is_image"] isEqual:[NSNull null]]) {
        payload[@"isImage"] = fileInformation[@"is_image"];
    }
    
    if (![fileInformation[@"image_info"] isEqual:[NSNull null]]) {
        NSDictionary *information = fileInformation[@"image_info"];
        NSMutableDictionary *imageInfo = [NSMutableDictionary new];
        
        if (![information[@"width"] isEqual:[NSNull null]]) {
            imageInfo[@"width"] = information[@"width"];
            imageInfo[@"height"] = information[@"height"];
        }
        
        if (![information[@"format"] isEqual:[NSNull null]]) {
            imageInfo[@"format"] = information[@"format"];
        }
        
        if (![information[@"datetime_original"] isEqual:[NSNull null]]) {
            imageInfo[@"datetime_original"] = information[@"datetime_original"];
        }
        
        if (![information[@"geo_location"] isEqual:[NSNull null]]) {
            imageInfo[@"geo_location"] = information[@"geo_location"];
        }
        
        if (![information[@"orientation"] isEqual:[NSNull null]]) {
            imageInfo[@"orientation"] = information[@"orientation"];
        }
        
        if (![information[@"dpi"] isEqual:[NSNull null]]) {
            imageInfo[@"dpi"] = information[@"dpi"];
        }
        
        payload[@"originalImageInfo"] = imageInfo;
    }
    
    
    return payload;
}

#pragma mark -


@end
