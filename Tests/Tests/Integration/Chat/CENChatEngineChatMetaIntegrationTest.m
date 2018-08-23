/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineChatMetaIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *testedChatName;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineChatMetaIntegrationTest


#pragma mark - Setup / Tear down

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateVCRConfigurationFromDefaultConfiguration:configuration];
    
    YHVPostBodyFilterBlock postBodyFilter = configuration.postBodyFilter;
    configuration.postBodyFilter = ^NSData * (NSURLRequest *request, NSData *body) {
        NSString *bodyString = [[NSString alloc] initWithData:postBodyFilter(request, body) encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
        
        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    YHVResponseBodyFilterBlock responseBodyFilter = configuration.responseBodyFilter;
    configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        NSString *bodyString = [[NSString alloc] initWithData:responseBodyFilter(request, response, data) encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
        
        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    YHVPathFilterBlock pathFilter = configuration.pathFilter;
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        return [[pathFilter(request) componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
    };
}

- (void)setUp {
    
    [super setUp];
    
    self.testedChatName = [@[@"chat-tester", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    
    [self setupChatEngineWithGlobal:@"global" forUser:@"ian" synchronization:NO meta:YES state:@{ @"works": @YES }];
}

- (void)testMeta_ShouldUpdateChatMeta_WhenChatCreatedWithMeta {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSDictionary *expected = @{ @"works": @YES };
    __block BOOL handlerCalled = NO;
    
    CENChat *chat = client.Chat().name(self.testedChatName).meta(expected).create();
    chat.once(@"$.connected", ^{
        handlerCalled = YES;
        
        XCTAssertEqualObjects(chat.meta, expected);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
