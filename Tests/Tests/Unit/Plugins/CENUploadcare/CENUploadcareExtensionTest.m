/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUploadcareExtension.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUploadcarePlugin.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUploadcareExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENUploadcareExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;


#pragma mark - Misc

- (NSHTTPURLResponse *)responseWithContentType:(NSString *)contentType;
- (NSDictionary *)normalizedFileInformation;
- (NSDictionary *)fileInformation;
- (id)mockedSession;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUploadcareExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    

    self.chat = [self publicChatWithChatEngine:self.client];
    
    NSDictionary *configuration = @{ CENUploadcareConfiguration.publicKey: @"1234567890" };
    self.extension = [CENUploadcareExtension extensionForObject:self.chat withIdentifier:@"test"
                                                  configuration:configuration];
}


#pragma mark - Tests :: shareFileWithIdentifier

- (void)testShareFileWithIdentifier_ShouldRequestInfo {
    
    id sessionMock = [self mockedSession];
    id recorded = OCMExpect([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]);
    [self waitForObject:sessionMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9"];
    }];
}

- (void)testShare_ShouldCreateProperRequest {
    
    NSString *publicKey = self.extension.configuration[CENUploadcareConfiguration.publicKey];
    NSString *expectedIdentifier = @"adc41366-0c9b-4837-88db-785d11914fb9";
    NSString *expectedURL = [NSString stringWithFormat:@"https://upload.uploadcare.com/info/?pub_key=%@&file_id=%@",
                             publicKey, expectedIdentifier];
    
    
    id sessionMock = [self mockedSession];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
            NSURLRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            
            XCTAssertEqualObjects(request.URL.absoluteString, expectedURL);
            handler();
        });
    } afterBlock:^{
        [self.extension shareFileWithIdentifier:expectedIdentifier];
    }];
}

- (void)testShare_ShouldEmitEventWithFileInformation_WhenRequestSuccess {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:[self fileInformation] options:(NSJSONWritingOptions)0
                                                             error:nil];
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(responseData, response, nil);
    });
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$uploadcare.upload" withData:[self normalizedFileInformation]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9"];
    }];
}

- (void)testShare_ShouldNotEmitEventWithFileInformation_WhenRequestDidFail {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(nil, response, [NSError errorWithDomain:@"Test" code:-1000 userInfo:nil]);
    });
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$uploadcare.upload" withData:[self normalizedFileInformation]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9"];
    }];
}

- (void)testShare_ShouldNotEmitEventWithFileInformation_WhenDataOfUnknownContentTypeReceived {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"text/plain"];
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:[self fileInformation] options:(NSJSONWritingOptions)0
                                                             error:nil];
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(responseData, response, nil);
    });
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$uploadcare.upload" withData:[self normalizedFileInformation]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9"];
    }];
}

- (void)testShare_ShouldNotEmitEventWithFileInformation_WhenNoDataReceived {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block(nil, response, nil);
    });
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$uploadcare.upload" withData:[self normalizedFileInformation]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9"];
    }];
}

- (void)testShare_ShouldNotEmitEventWithFileInformation_WhenEmptyDataReceived {
    
    NSHTTPURLResponse *response = [self responseWithContentType:@"application/json"];
    
    id sessionMock = [self mockedSession];
    OCMStub([sessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSData *, NSURLResponse *, NSError *) = [self objectForInvocation:invocation argumentAtIndex:2];
        block([NSData new], response, nil);
    });
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$uploadcare.upload" withData:[self normalizedFileInformation]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9"];
    }];
}


#pragma mark - Misc

- (NSHTTPURLResponse *)responseWithContentType:(NSString *)contentType {
    
    NSURL *url = [NSURL URLWithString:@"https://upload.uploadcare.com/info/"];
    
    return [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:nil
                                     headerFields:@{ @"Content-Type": contentType }];
}

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

- (NSDictionary *)fileInformation {
    
    return @{
        @"is_stored": @YES,
        @"done": @(2134543),
        @"file_id": @"adc41366-0c9b-4837-88db-785d11914fb9",
        @"total": @(2134543),
        @"size": @(2134543),
        @"uuid": @"adc41366-0c9b-4837-88db-785d11914fb9",
        @"is_image": @YES,
        @"filename": @"IMG_0679.jpg",
        @"is_ready": @YES,
        @"original_filename": @"IMG_0679.jpg",
        @"image_info": @{
            @"color_mode": @"RGB",
            @"format": @"JPEG",
            @"height": @(2448),
            @"width": @(3264),
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

- (id)mockedSession {
    
    NSURLSession *session = [NSURLSession sharedSession];
    id sessionMock = [self mockForObject:session];
    
    id sessionClassMock = [self mockForObject:[NSURLSession class]];
    OCMStub([sessionClassMock sessionWithConfiguration:[OCMArg any]]).andReturn(session);
    
    return sessionMock;
}

#pragma mark -


@end
