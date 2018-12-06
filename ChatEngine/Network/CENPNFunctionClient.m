/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENPNFunctionClient.h"
#import "CENDictionary.h"
#import "CENConstants.h"
#import "CENLogMacro.h"


#pragma mark Externs

/**
 * @brief Key under which stored \a NSError object composed from \b PubNub Function failure
 * response.
 */
NSString * const kCEPNFunctionErrorResponseDataKey = @"CEPNFunctionErrorResponseDataKey";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENPNFunctionClient () <NSURLSessionDelegate>


#pragma mark - Information

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief \b PubNub Function response processing queue.
 */
@property (nonatomic, strong) dispatch_queue_t processingQueue;

/**
 * @brief \b PubNub Function data tasks sending session.
 */
@property (nonatomic, strong, nullable) NSURLSession *session;

/**
 * @brief Data task callback queue.
 */
@property (nonatomic, strong) NSOperationQueue *delegateQueue;

/**
 * @brief \a NSDictionary with data which should be sent with every request.
 */
@property (nonatomic, strong) NSDictionary *functionData;

/**
 * @brief \b {ChatEngine CENChatEngine} \b logger for updates output.
 */
@property (nonatomic, weak) PNLLogger *logger;

@property (nonatomic, copy) NSString *endpointURL;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize \b PubNub Function client.
 *
 * @param endpoint \b PubNub Function location URI.
 * @Param logger \b {ChatEngine CENChatEngine} \b logger for updates output.
 *
 * @return Initialized and ready to use functions client.
 */
- (instancetype)initWithEndpoint:(NSString *)endpoint logger:(PNLLogger *)logger;


#pragma mark - REST API Calls

/**
 * @brief Perform single \b PubNub Function route call.
 *
 * @param data \a NSDictionary with route call configuration.
 * @param block Block / closure which will be called after route request completion and pass service
 *     response or error (if not \c success).
 */
- (void)callRouteWithData:(NSDictionary *)data completion:(void(^)(id response, BOOL isError))block;

/**
 * @brief Perform single \b PubNub Function route call.
 *
 * @param route Name of route which should be called.
 * @param method HTTP method which should be used to pull / push data.
 * @param body \a NSDictionary with data which should be pushed to the \c route.
 * @param block Block / closure which will be called after \c route call request completion and pass
 *     service response or error (if not \c success).
 */
- (void)callRoute:(NSString *)route
       httpMethod:(NSString *)method
            query:(nullable NSDictionary *)query
         postBody:(nullable NSDictionary *)body
   withCompletion:(void(^)(id response, BOOL isError))block;


#pragma mark - Session constructor

/**
 * @brief Prepare \b {session} with pre-defined requests processing configuration.
 *
 * @param timeout Maximum time which data task should wait for response from server before fail.
 * @param maximumConnections Maximum number of simultaneous connections to \b PubNub Functions.
 */
- (void)prepareSessionWithRequestTimeout:(NSTimeInterval)timeout
                      maximumConnections:(NSInteger)maximumConnections;

/**
 * @brief Create and configure \b {session} configuration.
 *
 * @param timeout Maximum time which data task should wait for response from server before fail.
 * @param maximumConnections Maximum number of simultaneous connections to \b PubNub Functions.
 *
 * @return Configured and ready to use configuration object.
 */
- (NSURLSessionConfiguration *)configurationWithRequestTimeout:(NSTimeInterval)timeout
                                            maximumConnections:(NSInteger)maximumConnections;

/**
 * @brief Create and configure \b {session}'s data tasks processing queue.
 *
 * @param configuration \a NSURLSessionConfiguration with information which allow to configure
 *     required queue parameters.
 *
 * @return Configured and ready to use data tasks processing queue.
 */
- (NSOperationQueue *)operationQueueWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 * @brief Create and configure \b PubNub Function data tasks sending session.
 *
 * @param configuration \a NSURLSessionConfiguration with set of options which should be applied on
 *     \b {session}.
 *
 * @return Configured and ready to use data tasks sending session.
 */
- (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 * @brief Get default set of headers for each requests sent by \b {session}'s data task.
 *
 * @return \a NSDictionary with \a NSURLRequest headers.
 */
- (NSDictionary *)defaultSessionHeaders;


# pragma mark - Handlers

/**
 * @brief Handle \b PubNub Function response.
 *
 * @param response \a NSHTTPURLResponse with response headers and status code or \c nil in case of
 *     error.
 * @param data Data which has been provided by \b PubNub Function or \c nil in case of error.
 * @param requestError \a NSError with information about what exactly went wrong during request.
 * @param block Block / closure which will be called at the end of response processing and pass
 *     parsed \b PubNub Function response or error (if any).
 */
- (void)handleResponse:(nullable NSHTTPURLResponse *)response
              withData:(nullable NSData *)data
                 error:(nullable NSError *)requestError
         andCompletion:(void(^)(id response, BOOL isError))block;


#pragma mark - Parsers

/**
 * @brief Try extract data returned by \b PubNub Function.
 *
 * @param data Object which has been received from \b PubNub Function response.
 * @param contentType Expected \c data type which should be taken into account to extract response.
 *
 * @return Error instance or \a NSDictionary with received data.
 */
- (id)serviceResponseData:(nullable NSData *)data ofContentType:(NSString *)contentType;


#pragma mark - Misc

/**
 * @brief Create and configure request with set of query parameters and body.
 *
 * @param parameters \a NSDictionary with key / value pairs which should be added as part of query
 *     string or POST body (depending from \c method).
 * @param method HTTP method which should be used to pull / push data.
 * @param body \a NSDictionary with data which should be pushed to \b PubNub Function as part of
 *     query string or POST body (depending from \c method).
 *
 * @return Configured and ready to use request object for \b {session}'s data task.
 */
- (NSURLRequest *)requestWithQueryParameters:(NSDictionary *)parameters
                                      method:(NSString *)method
                                    postBody:(NSDictionary *)body;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPNFunctionClient


#pragma mark - Initialization and Configuration

+ (instancetype)clientWithEndpoint:(NSString *)endpoint logger:(PNLLogger *)logger {
    
    return [[self alloc] initWithEndpoint:endpoint logger:logger];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException
                format:@"-init not implemented, please use: +clientWithEndpoint:"];
    
    return nil;
}

- (instancetype)initWithEndpoint:(NSString *)endpoint logger:(PNLLogger *)logger  {
    
    if ((self = [super init])) {
        _endpointURL = [endpoint copy];
        _logger = logger;
        _resourceAccessQueue = dispatch_queue_create("com.chatengine.pnfunctions.resource",
                                                     DISPATCH_QUEUE_SERIAL);
        _processingQueue = dispatch_queue_create("com.chatengine.pnfunctions.processing",
                                                 DISPATCH_QUEUE_SERIAL);
        
        [self prepareSessionWithRequestTimeout:kCENRequestTimeout
                            maximumConnections:kCENMaximumConnectionCount];
    }
    
    return self;
}

- (void)setWithNamespace:(NSString *)namespace
                userUUID:(NSString *)uuid
                userAuth:(NSString *)authKey {
    
    self.functionData = @{
        @"uuid": [uuid copy],
        @"namespace": [namespace copy],
        @"authKey": [authKey copy]
    };
}


#pragma mark - REST API call

- (void)callRouteSeries:(NSArray<NSDictionary *> *)series
         withCompletion:(void(^)(BOOL success, NSArray *responses))block {

    [self callRouteSeries:series responses:[NSMutableArray array] withCompletion:block];
}

- (void)callRouteSeries:(NSArray<NSDictionary *> *)series
              responses:(NSMutableArray *)responses
         withCompletion:(void(^)(BOOL success, NSArray *responses))block {
    
    if (series.count) {
        __weak __typeof__(self) weakSelf = self;
        
        [self callRouteWithData:series.firstObject completion:^(id response, BOOL isError) {
            if (isError) {
                CELogRequestError(self.logger,
                    @"<ChatEngine::Request> Failed with error: %@", response);
            } else {
                CELogResponse(self.logger, @"<ChatEngine::Response> Received response for route: "
                    "%@\n%@", series.firstObject, response);
            }

            if (!isError) {
                NSRange range = NSMakeRange(1, series.count - 1);
                NSArray<NSDictionary *> *seriesToCompete = [series subarrayWithRange:range];

                if (response) {
                    [responses addObject:response];
                }
                
                if (seriesToCompete.count) {
                    [weakSelf callRouteSeries:seriesToCompete
                                    responses:responses
                               withCompletion:block];
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

- (void)callRouteWithData:(NSDictionary *)data
               completion:(void(^)(id response, BOOL isError))block {
    
    [self callRoute:data[@"route"]
         httpMethod:data[@"method"]
              query:data[@"query"]
           postBody:data[@"body"]
     withCompletion:block];
}

- (void)callRoute:(NSString *)route
       httpMethod:(NSString *)method
            query:(nullable NSDictionary *)query
         postBody:(nullable NSDictionary *)body
   withCompletion:(void(^)(id response, BOOL isError))block {
    
    method = method.lowercaseString;
    NSMutableDictionary *queryParameters = [@{ @"route": route } mutableCopy];
    [queryParameters addEntriesFromDictionary:query];
    NSMutableDictionary *httpBody = [self.functionData mutableCopy];
    BOOL hasPOSTBody = httpBody.count > 0;
    [httpBody addEntriesFromDictionary:body];
    
    if ([method isEqualToString:@"get"] || [method isEqualToString:@"delete"]) {
        hasPOSTBody = NO;
        [queryParameters addEntriesFromDictionary:httpBody];
    }
    
    NSURLRequest *request = [self requestWithQueryParameters:queryParameters
                                                      method:method
                                                    postBody:(hasPOSTBody ? httpBody : nil)];
    
    dispatch_async(self.resourceAccessQueue, ^{
        __weak __typeof__(self) weakSelf = self;
        CELogRequest(self.logger, @"<ChatEngine::Request> %@ %@%@",
            request.HTTPMethod.uppercaseString, request.URL.absoluteString,
            hasPOSTBody ? [@[@"\nHTTP body: ", httpBody] componentsJoinedByString:@""] : @"");
        
        [[self.session dataTaskWithRequest:request
                         completionHandler:^(NSData *data, NSURLResponse
                                             *urlResponse,
                                             NSError *error) {
                             
            [weakSelf handleResponse:(NSHTTPURLResponse *)urlResponse
                            withData:data
                               error:error
                       andCompletion:block];
        }] resume];
    });
}


# pragma mark - Handlers

- (void)handleResponse:(NSHTTPURLResponse *)response
              withData:(NSData *)data
                 error:(NSError *)error
         andCompletion:(void(^)(id response, BOOL isError))block {
    
    dispatch_async(self.processingQueue, ^{
        if (!response) {
            block(error, error != nil);

            return;
        }

        NSInteger statusCode = response.statusCode;
        id processed = [self serviceResponseData:data
                                   ofContentType:response.allHeaderFields[@"Content-Type"]];

        if (statusCode >= 400 && ![processed isKindOfClass:[NSError class]]) {
            NSMutableDictionary *responseData = [@{
                @"statusCode": @(response.statusCode)
            } mutableCopy];
            responseData[@"information"] = processed;
            NSString *description = (statusCode ? @"PubNub Function error"
                                                : @"ChatEngine client error");
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: description,
                kCEPNFunctionErrorResponseDataKey: responseData
            };

            NSInteger code = statusCode >= 500 ? NSURLErrorBadServerResponse : NSURLErrorBadURL;

            if (statusCode == 403) {
                code = NSURLErrorUserAuthenticationRequired;
            }

            processed = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:userInfo];
        }

        block(error ?: processed, error != nil || [processed isKindOfClass:[NSError class]]);
    });
}


#pragma mark - Parsers

- (id)serviceResponseData:(NSData *)data ofContentType:(NSString *)contentType {
    
    id processedData = nil;
    NSError *error = nil;
    
    if (data) {
        processedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
            processedData = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
        } else if ([contentType rangeOfString:@"text/html"].location != NSNotFound) {
            NSRegularExpressionOptions option = NSRegularExpressionCaseInsensitive;
            NSString *pattern = @"<title>(.*)</title>";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                   options:option
                                                                                     error:&error];
            NSRange matchRange = NSMakeRange(0, ((NSString *)processedData).length);
            NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:processedData
                                                                      options:0
                                                                        range:matchRange];
            
            if (matches.count) {
                matchRange = [matches.firstObject rangeAtIndex:1];
                processedData = [(NSString *)processedData substringWithRange:matchRange];
            }
        }
    }
    
    return error ?: processedData;
}


#pragma mark - Session constructor

- (void)prepareSessionWithRequestTimeout:(NSTimeInterval)timeout
                      maximumConnections:(NSInteger)maximumConnections {
    
    NSURLSessionConfiguration *config = [self configurationWithRequestTimeout:timeout
                                                           maximumConnections:maximumConnections];
    _delegateQueue = [self operationQueueWithConfiguration:config];
    _session = [self sessionWithConfiguration:config];
}

- (NSURLSessionConfiguration *)configurationWithRequestTimeout:(NSTimeInterval)timeout
                                            maximumConnections:(NSInteger)maximumConnections {
    
    NSURLSessionConfiguration *configuration = nil;
    configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
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
    
    return [NSURLSession sessionWithConfiguration:configuration
                                         delegate:self
                                    delegateQueue:_delegateQueue];
}

- (NSDictionary *)defaultSessionHeaders {
    
    return @{
        @"Accept": @"*/*",
        @"Accept-Encoding": @"gzip,deflate",
        @"Connection": @"keep-alive"
    };
}


#pragma mark - Misc

- (NSURLRequest *)requestWithQueryParameters:(NSDictionary *)parameters
                                      method:(NSString *)method
                                    postBody:(NSDictionary *)body {
    
    NSString *endpoint = self.endpointURL;
    
    if (parameters.count) {
        NSString *queryString = [CENDictionary queryStringFrom:parameters];
        endpoint = [endpoint stringByAppendingFormat:@"?%@", queryString];
    }
    
    NSURL *endpointURI = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:endpointURI];
    httpRequest.HTTPMethod = method;
    
    dispatch_barrier_sync(self.resourceAccessQueue, ^{
        httpRequest.cachePolicy = self.session.configuration.requestCachePolicy;
        httpRequest.allHTTPHeaderFields = self.session.configuration.HTTPAdditionalHeaders;
    });
    
    if (body && ![method isEqualToString:@"get"] && ![method isEqualToString:@"delete"]) {
        NSMutableDictionary *allHeaders = [httpRequest.allHTTPHeaderFields mutableCopy];
        NSError *error = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:body
                                                           options:(NSJSONWritingOptions)0
                                                             error:&error];
        
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
