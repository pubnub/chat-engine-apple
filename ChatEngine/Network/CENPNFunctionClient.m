/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENPNFunctionClient.h"
#import "CENDictionary.h"
#import "CENConstants.h"


#pragma mark Externs

NSString * const kCEPNFunctionErrorResponseDataKey = @"CEPNFunctionErrorResponseDataKey";


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENPNFunctionClient () <NSURLSessionDelegate>


#pragma mark - Information

@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, strong) dispatch_queue_t processingQueue;
@property (nonatomic, strong, nullable) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;
@property (nonatomic, strong) NSDictionary *functionData;
@property (nonatomic, copy) NSString *endpointURL;


#pragma mark - Initialization and Configuration

- (instancetype)initWithEndpoint:(NSString *)endpoint;


#pragma mark - REST API Calls

- (void)callRouteWithData:(NSDictionary *)data completion:(void(^)(id response, BOOL isError))block;
- (void)callReoute:(NSString *)route
        httpMethod:(NSString *)method
             query:(nullable NSDictionary *)query
          postBody:(nullable NSDictionary *)body
    withCompletion:(void(^)(id response, BOOL isError))block;


#pragma mark - Session constructor

- (void)prepareSessionWithRequestTimeout:(NSTimeInterval)timeout maximumConnections:(NSInteger)maximumConnections;
- (NSURLSessionConfiguration *)configurationWithRequestTimeout:(NSTimeInterval)timeout  maximumConnections:(NSInteger)maximumConnections;
- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration;
- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;
- (NSDictionary *)defaultSessionHeaders;


# pragma mark - Handlers

- (void)handleResponse:(nullable NSHTTPURLResponse *)response
              withData:(nullable NSData *)data
                 error:(nullable NSError *)requestError
         andCompletion:(void(^)(id response, BOOL isError))block;


#pragma mark - Parsers

- (id)serviceResponseData:(nullable NSData *)data ofContentType:(NSString *)contentType;


#pragma mark - Misc

- (NSURLRequest *)requestWithQueryParameters:(NSDictionary *)parameters method:(NSString *)method postBody:(NSDictionary *)body;

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPNFunctionClient


#pragma mark - Initialization and Configuration

+ (instancetype)clientWithEndpoint:(NSString *)endpoint {
    
    return [[self alloc] initWithEndpoint:endpoint];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException format:@"-init not implemented, please use: +clientWithEndpoint:"];
    
    return nil;
}

- (instancetype)initWithEndpoint:(NSString *)endpoint {
    
    if ((self = [super init])) {
        _endpointURL = [endpoint copy];
        _resourceAccessQueue = dispatch_queue_create("com.chatengine.pnfunctions.resource", DISPATCH_QUEUE_CONCURRENT);
        _processingQueue = dispatch_queue_create("com.chatengine.pnfunctions.processing", DISPATCH_QUEUE_CONCURRENT);
        
        [self prepareSessionWithRequestTimeout:kCERequestTimeout maximumConnections:kCEMaximumConnectioncCount];
    }
    
    return self;
}

- (void)setDefaultDataWithGlobalChat:(NSString *)globalChat userUUID:(NSString *)uuid userAuth:(NSString *)authKey {
    
    self.functionData = @{ @"uuid": [uuid copy], @"global": [globalChat copy], @"authKey": [authKey copy] };
}


#pragma mark - REST API call

- (void)callRouteSeries:(NSArray<NSDictionary *> *)series withCompletion:(void(^)(BOOL success, NSArray *responses))block {

    [self callRouteSeries:series responses:[NSMutableArray array] withCompletion:block];
}

- (void)callRouteSeries:(NSArray<NSDictionary *> *)series
              responses:(NSMutableArray *)responses
         withCompletion:(void(^)(BOOL success, NSArray *responses))block {
    
    if (series.count) {
        __weak __typeof__(self) weakSelf = self;
        
        [self callRouteWithData:series.firstObject completion:^(id response, BOOL isError) {
            if (([response isKindOfClass:[NSString class]] && ((NSString *)response).length) || [response isKindOfClass:[NSDictionary class]]) {
//                NSLog(@"\nIS ERROR? %@\nCURRENT: %@\nRESPONSE: '%@'", isError ? @"YES" : @"NO", series.firstObject, response);
            }
            if (!isError) {
                NSArray<NSDictionary *> *seriesToCompete = [series subarrayWithRange:NSMakeRange(1, series.count - 1)];

                if (response) {
                    [responses addObject:response];
                }
                
                if (seriesToCompete.count) {
                    [weakSelf callRouteSeries:seriesToCompete responses:responses withCompletion:block];
                } else {
                    block(YES, responses.count ? responses : nil);
                }
            } else {
                if (response) {
                    [responses addObject:response];
                }
                
                block(NO, responses.count ? responses : nil);
            }
        }];
    }
}

- (void)callRouteWithData:(NSDictionary *)data completion:(void(^)(id response, BOOL isError))block {
    
    [self callReoute:data[@"route"] httpMethod:data[@"method"] query:data[@"query"] postBody:data[@"body"] withCompletion:block];
}

- (void)callReoute:(NSString *)route
        httpMethod:(NSString *)method
             query:(NSDictionary *)query
          postBody:(NSDictionary *)body
    withCompletion:(void(^)(id response, BOOL isError))block {
    
    method = method.lowercaseString;
    NSMutableDictionary *queryParameters = [@{ @"route": route } mutableCopy];
    [queryParameters addEntriesFromDictionary:query];
    NSMutableDictionary *httpBody = [self.functionData mutableCopy];
    [httpBody addEntriesFromDictionary:body];
    
    if ([method isEqualToString:@"get"] || [method isEqualToString:@"delete"]) {
        [queryParameters addEntriesFromDictionary:httpBody];
    }
    
    NSURLRequest *request = [self requestWithQueryParameters:queryParameters method:method postBody:httpBody];
    dispatch_async(self.resourceAccessQueue, ^{
        __weak __typeof__(self) weakSelf = self;
        
        [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
            if (error.code == NSURLErrorTimedOut) {
                NSLog(@"\nREQUEST TIMEOUT\nURL: %@\nHTTP METHOD: %@\nQUERY: %@\nBODY: %@", request.URL, method.uppercaseString, query, body);
            } else if (error || ((NSHTTPURLResponse *)urlResponse).statusCode >= 400) {
//                NSLog(@"\nURL: %@\nHTTP METHOD: %@\nQUERY: %@\nBODY: %@\nRESPONSE: %@",
//                      request.URL, method.uppercaseString, query, body, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            
            [weakSelf handleResponse:(NSHTTPURLResponse *)urlResponse withData:data error:error andCompletion:block];
        }] resume] ;
    });
}


# pragma mark - Handlers

- (void)handleResponse:(NSHTTPURLResponse *)response
              withData:(NSData *)data
                 error:(NSError *)error
         andCompletion:(void(^)(id response, BOOL isError))block {
    
    dispatch_async(self.processingQueue, ^{
        if (response) {
            id processedData = [self serviceResponseData:data ofContentType:response.allHeaderFields[@"Content-Type"]];
            
            if (response.statusCode >= 400 && ![processedData isKindOfClass:[NSError class]]) {
                NSMutableDictionary *responseData = [@{ @"statusCode": @(response.statusCode) } mutableCopy];
                responseData[@"information"] = processedData;
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: response.statusCode >= 500 ? @"PubNub Function error" : @"ChatEngine client error",
                    kCEPNFunctionErrorResponseDataKey: responseData
                };
                NSInteger code = response.statusCode >= 500 ? NSURLErrorBadServerResponse : NSURLErrorBadURL;
                if (response.statusCode == 403) {
                    code = NSURLErrorUserAuthenticationRequired;
                }
                processedData = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:userInfo];
            }
            
            block(error ?: processedData, error != nil || [processedData isKindOfClass:[NSError class]]);
        } else {
            block(error, error != nil);
        }
    });
}


#pragma mark - Parsers

- (id)serviceResponseData:(NSData *)data ofContentType:(NSString *)contentType {
    
    id processedData = nil;
    NSError *error = nil;
    
    if (data) {
        processedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
            processedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        } else if ([contentType rangeOfString:@"text/html"].location != NSNotFound) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<title>(.*)</title>"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSRange matchRange = NSMakeRange(0, ((NSString *)processedData).length);
            NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:processedData options:0 range:matchRange];
            
            if (matches.count) {
                processedData = [(NSString *)processedData substringWithRange:[matches.firstObject rangeAtIndex:1]];
            }
        }
    }
    
    return error ?: processedData;
}


#pragma mark - Session constructor

- (void)prepareSessionWithRequestTimeout:(NSTimeInterval)timeout maximumConnections:(NSInteger)maximumConnections {
    
    NSURLSessionConfiguration *config = [self configurationWithRequestTimeout:timeout maximumConnections:maximumConnections];
    _delegateQueue = [self operationQueueWithConfiguration:config];
    _session = [self sessionWithConfiguration:config];
}

- (NSURLSessionConfiguration *)configurationWithRequestTimeout:(NSTimeInterval)timeout maximumConnections:(NSInteger)maximumConnections {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.URLCache = nil;
    configuration.HTTPAdditionalHeaders = [self defaultSessionHeaders];
    configuration.HTTPShouldUsePipelining = YES;
    configuration.timeoutIntervalForRequest = timeout;
    configuration.HTTPMaximumConnectionsPerHost = maximumConnections;
    
    return configuration;
}

- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration {
    
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = configuration.HTTPMaximumConnectionsPerHost;
    
    return queue;
}

- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    
    return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_delegateQueue];
}

- (NSDictionary *)defaultSessionHeaders {
    
    return @{ @"Accept": @"*/*", @"Accept-Encoding": @"gzip,deflate", @"Connection": @"keep-alive" };
}


#pragma mark - Misc

- (NSURLRequest *)requestWithQueryParameters:(NSDictionary *)parameters method:(NSString *)method postBody:(NSDictionary *)body {
    
    NSString *endpoint = self.endpointURL;
    
    if (parameters.count) {
        endpoint = [endpoint stringByAppendingFormat:@"?%@", [CENDictionary queryStringFrom:parameters]];
    }
    
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    httpRequest.HTTPMethod = method;
    
    dispatch_barrier_sync(self.resourceAccessQueue, ^{
        httpRequest.cachePolicy = self.session.configuration.requestCachePolicy;
        httpRequest.allHTTPHeaderFields = self.session.configuration.HTTPAdditionalHeaders;
    });
    
    if (body && ![method isEqualToString:@"get"] && ![method isEqualToString:@"delete"]) {
        NSMutableDictionary *allHeaders = [httpRequest.allHTTPHeaderFields mutableCopy];
        NSError *error = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:body options:(NSJSONWritingOptions)0 error:&error];
        
        if (!error && postData) {
            [allHeaders addEntriesFromDictionary:@{
                @"Content-Type": @"application/json;charset=UTF-8",
                @"Content-Length": @(postData.length).stringValue
            }];
        }
        
        httpRequest.allHTTPHeaderFields = allHeaders;
        [httpRequest setHTTPBody:postData];
    }
    
    return httpRequest;
}

#pragma mark -


@end
