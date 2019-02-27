/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENOpenGraphMiddleware.h"
#import "CENOpenGraphPlugin.h"


#pragma mark Protected interface declaration

@interface CENOpenGraphMiddleware ()


#pragma mark - Information

/**
 * @brief Links data type detector.
 */
@property (class, nonatomic, readonly, strong) NSDataDetector *linksDetector;

/**
 * @brief Set of characters which shouldn't be percent-encoded.
 */
@property (class, nonatomic, readonly, strong) NSCharacterSet *allowedCharSet;


#pragma mark - OpenGraph

/**
 * @brief Create and configure \a NSURLSession instance which will be used to perform OpenGraph API
 * access requests.
 *
 * @return Configured and ready to use \a NSURLSession.
 */
- (NSURLSession *)openGraphAPIAccessSession;

/**
 * @brief Create and configure \a NSURLRequest to send data to
 * \b {opengraph.io https://www.opengraph.io}.
 *
 * @param url URI with API against which request should be created.
 * @param session \a NSURLSession which will build data task for this request.
 *
 * @return Configured and ready to use \a NSURLRequest.
 */
- (NSURLRequest *)openGraphAPIRequestWithURL:(NSURL *)url forSession:(NSURLSession *)session;

/**
 * @brief Try to fetch OpenGraph information about object at specified URL.
 *
 * @param url URL of object for which OpenGraph data should be fetched.
 * @param block Block / closure which will be called at the end of URL request and pass OpenGraph
 *     object if available.
 */
- (void)downloadOpenGraphForURL:(NSString *)url
                 withCompletion:(void(^)(NSDictionary * __nullable openGraphData))block;


#pragma mark - Misc

/**
 * @brief Add percent encoding to URL.
 *
 * @param url String on which encoding should be applied.
 *
 * @return Percent-encoded URL which can be used with OpenGraph API.
 */
- (NSString *)percentEncodedURL:(NSString *)url;

/**
 * @brief Map OpenGraph data from opengraph.io using plugin's data keys.
 *
 * @param data Object returned by opengraph.io API.
 *
 * @return \a NSDictionary with mapped OpenGraph data.
 */
- (NSDictionary *)openGraphPayloadFrom:(NSDictionary *)data;

/**
 * @brief Update value in \c dictionary.
 *
 * @param value Object which should be stored at specified location.
 * @param keyPath Key or path to location where \c value should be stored.
 * @param dictionary \a NSMutableDictionary with mutable content which should be modified.
 */
- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary;

/**
 * @brief Create mutable copy from \a NSDictionary by replacing other \a NSDictionary values in it
 * with \a NSMutableDictionary.
 *
 * @param dictionary \a NSDictionary from which deep mutable copy should be created.
 *
 * @return Mutable dictionary with mutable content.
 */
- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENOpenGraphMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}

+ (NSDataDetector *)linksDetector {
    
    static NSDataDetector *_sharedDetector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    });
    
    return _sharedDetector;
}

+ (NSCharacterSet *)allowedCharSet {
    
    static NSCharacterSet *_sharedCharSet;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedCharSet = [NSCharacterSet alphanumericCharacterSet];
    });
    
    return _sharedCharSet;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    NSString *openGraphKey = self.configuration[CENOpenGraphConfiguration.openGraphKey];
    NSString *messageKey = self.configuration[CENOpenGraphConfiguration.messageKey];
    NSString *message = [(NSDictionary *)data[CENEventData.data] valueForKeyPath:messageKey];
    
    if (![message isKindOfClass:[NSString class]] || !message.length) {
        block(NO);
        return;
    }
    
    NSDataDetector *linksDetector = [self class].linksDetector;
    NSRange searchRange = NSMakeRange(0, message.length);
    NSTextCheckingResult *match = [linksDetector firstMatchInString:message
                                                            options:0
                                                              range:searchRange];
    
    if (match) {
        [self downloadOpenGraphForURL:[message substringWithRange:match.range]
                       withCompletion:^(NSDictionary *openGraphData) {
                           
            if (!openGraphData) {
                block(NO);
                return;
            }
            
            NSDictionary *parsedOpenGraphData = [self openGraphPayloadFrom:openGraphData];
            NSMutableDictionary *payloadData = nil;
            payloadData = [self dictionaryDeepMutableFrom:data[CENEventData.data]];
            
            [self setValue:parsedOpenGraphData forKeyPath:openGraphKey inDictionary:payloadData];
            data[CENEventData.data] = [payloadData copy];
            
            block(NO);
        }];
    } else {
        block(NO);
    }
}


#pragma mark - OpenGraph

- (NSURLSession *)openGraphAPIAccessSession {
    
    NSURLSessionConfiguration *configuration = nil;
    configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.URLCache = nil;
    configuration.HTTPShouldUsePipelining = YES;
    
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (NSURLRequest *)openGraphAPIRequestWithURL:(NSURL *)url forSession:(NSURLSession *)session {
    
    NSURLSessionConfiguration *configuration = session.configuration;
    
    return [NSURLRequest requestWithURL:url
                            cachePolicy:configuration.requestCachePolicy
                        timeoutInterval:configuration.timeoutIntervalForRequest];
}

- (void)downloadOpenGraphForURL:(NSString *)url
                 withCompletion:(void(^)(NSDictionary *openGraphData))block {
    
    NSString *originalURL = [url copy];
    url = [self percentEncodedURL:url];
    NSString *graphURL = @"https://opengraph.io/api/1.1/site/";
    NSString *appID = self.configuration[CENOpenGraphConfiguration.appID];
    NSString *apiURL = [@[graphURL, url, @"?app_id=", appID] componentsJoinedByString:@""];
    NSURLSession *session = [self openGraphAPIAccessSession];
    NSURLRequest *request = [self openGraphAPIRequestWithURL:[NSURL URLWithString:apiURL]
                                                  forSession:session];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *contentType = httpResponse.allHeaderFields[@"Content-Type"];
        NSDictionary *openGraphData = nil;

        if (error || !data) {
            NSLog(@"Unable to download OpenGraph data for object at %@", originalURL);
        } else if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
            NSJSONReadingOptions options = NSJSONReadingAllowFragments;
            NSError *parseError = nil;

            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:options
                                                                           error:&parseError];

            if (error || !responseData) {
                NSLog(@"Unable to parse opengraph.io response: %@", error);
            } else {
                openGraphData = responseData[@"hybridGraph"];
            }
        }

        block(openGraphData);
    }] resume];
}


#pragma mark - Misc

- (NSString *)percentEncodedURL:(NSString *)url {
    
    NSString *encodedURL = [url stringByRemovingPercentEncoding];
    
    if ([encodedURL isEqualToString:url]) {
        NSCharacterSet *allowedCharSet = [self class].allowedCharSet;
        encodedURL = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharSet];
    } else {
        encodedURL = url;
    }
    
    return encodedURL;
}

- (NSDictionary *)openGraphPayloadFrom:(NSDictionary *)data {
    
    NSMutableDictionary *openGraph = [NSMutableDictionary new];
    
    if (data[@"title"]) {
        openGraph[CENOpenGraphData.title] = data[@"title"];
    }
    
    if (data[@"description"]) {
        openGraph[CENOpenGraphData.description] = data[@"description"];
    }
    
    if (data[@"url"]) {
        openGraph[CENOpenGraphData.url] = data[@"url"];
    }
    
    if (data[@"image"]) {
        openGraph[CENOpenGraphData.image] = data[@"image"];
    }
    
    return openGraph;
}

- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary {
    
    NSArray<NSString *> *pathComponents = [keyPath componentsSeparatedByString:@"."];
    
    if (pathComponents.count > 1) {
        NSRange pathSubRange = NSMakeRange(0, pathComponents.count - 1);
        NSArray *pathSubComponents = [pathComponents subarrayWithRange:pathSubRange];
        NSMutableDictionary *currentRoot = dictionary;
        
        for (NSString *key in pathSubComponents) {
            if (!currentRoot[key]) {
                currentRoot[key] = [NSMutableDictionary new];
            }
            
            currentRoot = currentRoot[key];
        }
        
        [currentRoot setValue:value forKeyPath:pathComponents.lastObject];
    } else {
        [dictionary setValue:value forKeyPath:keyPath];
    }
}

- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary {
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    for (NSString *key in dictionary) {
        if ([dictionary[key] isKindOfClass:[NSDictionary class]]) {
            mutable[key] = [self dictionaryDeepMutableFrom:dictionary[key]];
        }
    }
    
    return mutable;
}

#pragma mark -


@end
