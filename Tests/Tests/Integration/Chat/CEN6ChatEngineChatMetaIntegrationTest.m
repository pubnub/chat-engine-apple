/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENDefines.h>
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CEN6ChatEngineChatMetaIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *testedChatName;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CEN6ChatEngineChatMetaIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

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
        NSString *bodyString = [[NSString alloc] initWithData:responseBodyFilter(request, response, data)
                                                     encoding:NSUTF8StringEncoding];
        bodyString = [[bodyString componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
        
        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    YHVPathFilterBlock pathFilter = configuration.pathFilter;
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        return [[pathFilter(request) componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
    };
    
    YHVQueryParametersFilterBlock queryFilter = configuration.queryParametersFilter;
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        if (queryFilter) {
            queryFilter(request, queryParameters);
        }
        
        for (NSString *parameter in [queryParameters.allKeys copy]) {
            __block id value = queryParameters[parameter];
            
            if ([value isKindOfClass:[NSString class]] &&
                [(NSString *)value rangeOfString:@"chat-tester-"].location != NSNotFound) {
                
                value = [[(NSString *)value componentsSeparatedByString:self.testedChatName] componentsJoinedByString:@"chat-tester"];
            }
            
            queryParameters[parameter] = value;
        }
    };
}

- (void)setUp {
    
    [super setUp];

    
    NSString *testedChatName = [@[@"chat-tester", [NSUUID UUID].UUIDString] componentsJoinedByString:@"-"];
    self.testedChatName = YHVVCR.cassette.isNewCassette ? testedChatName : @"chat-tester";
    
    [self setupChatEngineForUser:@"ian"];
}

- (void)testMeta_ShouldUpdateChatMeta_WhenChatCreatedWithMeta {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    NSDictionary *expected = @{ @"works": @YES };
    
    
    CENChat *chat = client.Chat().name(self.testedChatName).meta(expected).autoConnect(NO).create();
    CENWeakify(chat);
    
    [self object:chat shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        CENStrongify(chat);
        
        return ^(CENEmittedEvent *emittedEvent) {
            XCTAssertEqualObjects(chat.meta, expected);
            handler();
        };
    } afterBlock:^{
        chat.connect();
    }];
}

#pragma mark -


@end
