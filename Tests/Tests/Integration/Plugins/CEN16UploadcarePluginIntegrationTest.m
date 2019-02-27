/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENUploadcarePlugin.h>


#pragma mark Constants

static NSString * const kCENUCPublicKey = @"demokey";


#pragma mark - Interface declaration

@interface CEN16UploadcarePluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN16UploadcarePluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateVCRConfigurationFromDefaultConfiguration:configuration];
    
    YHVQueryParametersFilterBlock queryFilter = configuration.queryParametersFilter;
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *query) {
        queryFilter(request, query);
        query[@"pub_key"] = @"demokey";
    };
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = @{ CENUploadcareConfiguration.publicKey: kCENUCPublicKey };
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    [self chatEngineForUser:@"ian"].global.plugin([CENUploadcarePlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENUploadcarePlugin class]).configuration(configuration).store();
}


#pragma mark - Tests :: Share file

- (void)testShare_ShouldSendFileInformation {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"$uploadcare.upload" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *event) {
            CENUploadcareFileInformation *information = ((NSDictionary *)event.data)[CENEventData.data];
            
            XCTAssertTrue([information isKindOfClass:[CENUploadcareFileInformation class]]);
            XCTAssertNotNil(information.url);
            handler();
        };
    } afterBlock:^{
        [CENUploadcarePlugin shareFileWithIdentifier:@"adc41366-0c9b-4837-88db-785d11914fb9" toChat:client1.global];
    }];
}

#pragma mark -


@end
