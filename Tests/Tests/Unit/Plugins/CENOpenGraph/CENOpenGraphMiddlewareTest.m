/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENOpenGraphMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Private.h>
#import <CENChatEngine/CENOpenGraphPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENOpenGraphMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENOpenGraphMiddleware *middleware;


#pragma mark - Misc

- (NSHTTPURLResponse *)responseWithContentType:(NSString *)contentType;
- (id)mockedSession;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENOpenGraphMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = @{
        CENOpenGraphConfiguration.events: @[@"message"],
        CENOpenGraphConfiguration.messageKey: @"text",
        CENOpenGraphConfiguration.openGraphKey: @"openGraph",
        CENOpenGraphConfiguration.appID: @"5c125ff42d5b840d00a16b4f"
    };

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    self.middleware = [CENOpenGraphMiddleware middlewareForObject:chat withIdentifier:@"test" configuration:configuration];
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENOpenGraphMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENOpenGraphMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: OpenGraph

- (void)testOpenGraph_ShouldFetchOpenGraphData_WhenEmittedMessageContainsLink {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there! Check this link https://pubnub.com" }
    } mutableCopy];
    
    
    id sessionMock = [self mockedSession];
    id recorded = OCMExpect([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse(rejected);
        }];
    }];
}

- (void)testOpenGraph_ShouldNotFetchOpenGraphData_WhenEmittedEventHasNonNSStringMessage {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @{ @"hello": @"there!" } }
    } mutableCopy];
    
    
    id sessionMock = [self mockedSession];
    id recorded = OCMExpect([[sessionMock reject] dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testOpenGraph_ShouldNotFetchOpenGraphData_WhenEmittedEventDoesntHaveMessage {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user
    } mutableCopy];
    
    
    id sessionMock = [self mockedSession];
    id recorded = OCMExpect([[sessionMock reject] dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testOpenGraph_ShouldNotFetchOpenGraphData_WhenEmittedEventDoesntHaveLinkInMessage {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there!" }
    } mutableCopy];
    
    
    id sessionMock = [self mockedSession];
    id recorded = OCMExpect([[sessionMock reject] dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]);
    [self waitForObject:sessionMock recordedInvocationNotCall:recorded afterBlock:^{
                 
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testOpenGraph_ShouldAddOpenGraphForDefaultKey_WhenEmittedMessageContainsLink {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there! Check this link https://pubnub.com" }
    } mutableCopy];
    
    NSDictionary *openGraphResponse = @{
        @"title": @"Test title",
        @"description": @"Test description",
        @"url": @"https://pubnub.com",
        @"image": @"https://pubnub.com"
    };
    
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        
        NSDictionary *responseJSON = @{ @"hybridGraph": openGraphResponse };
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseJSON options:(NSJSONWritingOptions)0 error:nil];
        
        block(responseData, response, nil);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertNotNil(payload[CENEventData.data][@"openGraph"]);
            handler();
        }];
    }];
}

- (void)testOpenGraph_ShouldNotModifyPayload_WhenRequestDidFail {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there! Check this link https://pubnub.com" }
    } mutableCopy];
    NSDictionary *expectedPayload = [payload copy];
    
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(nil, response, [NSError errorWithDomain:@"Test" code:-1000 userInfo:nil]);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload, expectedPayload);
            handler();
        }];
    }];
}

- (void)testOpenGraph_ShouldNotModifyPayload_WhenDataOfUnknownContentTypeReceived {
    
    NSDictionary *openGraphData = @{ @"hybridGraph": @{ @"url": @"https://pubnub.com" } };
    NSHTTPURLResponse *response = [self responseWithContentType:@"text/plain"];
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:openGraphData options:(NSJSONWritingOptions)0
                                                             error:nil];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there! Check this link https://pubnub.com" }
    } mutableCopy];
    NSDictionary *expectedPayload = [payload copy];
    
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(responseData, response, nil);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload, expectedPayload);
            handler();
        }];
    }];
}

- (void)testOpenGraph_ShouldNotModifyPayload_WhenNoDataReceived {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there! Check this link https://pubnub.com" }
    } mutableCopy];
    NSDictionary *expectedPayload = [payload copy];
    
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(nil, response, nil);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload, expectedPayload);
            handler();
        }];
    }];
}

- (void)testOpenGraph_ShouldNotModifyPayload_WhenEmptyDataReceived {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [@{
        CENEventData.event: @"message",
        CENEventData.chat: chat,
        CENEventData.sender: user,
        CENEventData.data: @{ @"text": @"Hello there! Check this link https://pubnub.com" }
    } mutableCopy];
    NSDictionary *expectedPayload = [payload copy];
    
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block([NSData new], response, nil);
    });
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload, expectedPayload);
            handler();
        }];
    }];
}


#pragma mark - Misc

- (NSHTTPURLResponse *)responseWithContentType:(NSString *)contentType {
    
    NSURL *url = [NSURL URLWithString:@"https://pubnub.com"];
    
    return [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:nil
                                     headerFields:@{ @"Content-Type": contentType }];
}

- (id)mockedSession {
    
    NSURLSession *session = [NSURLSession sharedSession];
    id sessionMock = [self mockForObject:session];
    
    id sessionClassMock = [self mockForObject:[NSURLSession class]];
    OCMStub([sessionClassMock sessionWithConfiguration:[OCMArg any]]).andReturn(sessionMock);
    
    return sessionMock;
}

#pragma mark -


@end
