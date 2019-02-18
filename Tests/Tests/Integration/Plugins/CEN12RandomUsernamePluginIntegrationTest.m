/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENRandomUsernamePlugin.h>


#pragma mark Interface declaration

@interface CEN12RandomUsernamePluginIntegrationTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *configuration;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN12RandomUsernamePluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return NO;
}

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateVCRConfigurationFromDefaultConfiguration:configuration];
    
    YHVQueryParametersFilterBlock queryParametersFilter = configuration.queryParametersFilter;
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        queryParametersFilter(request, queryParameters);
        
        if ([queryParameters[@"state"] isKindOfClass:[NSDictionary class]] &&
            (queryParameters[@"state"][@"username"] || queryParameters[@"state"][@"innerAnimal"])) {
            NSMutableDictionary *state = [queryParameters[@"state"] mutableCopy];
            if (state[@"username"]) {
                state[@"username"] = @"ChatEngine";
            } else {
                state[@"innerAnimal"] = @"ChatEngine";
            }
            queryParameters[@"state"] = state;
        }
    };
    
}

- (void)setUp {
    
    [super setUp];
    
    
    if ([self.name rangeOfString:@"WhenConfigurationPassed"].location != NSNotFound) {
        self.configuration = @{ CENRandomUsernameConfiguration.propertyName: @"innerAnimal" };
    }
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"ian"];
}


#pragma mark - Tests

- (void)testRandomName_ShouldAssignNameToDefaultStateKey_WhenConfigurationNotPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            XCTAssertNotNil(user.state[@"username"]);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"ian" usingClient:client1];
        [self connectUser:@"ian" usingClient:client2];
        client1.me.plugin([CENRandomUsernamePlugin class]).configuration(self.configuration).store();
    }];
}

- (void)testRandomName_ShouldAssignNameToCustomStateKey_WhenConfigurationPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineCloneForUser:@"ian"];
    
    [self object:client2 shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *user = emittedEvent.data;
            
            XCTAssertNotNil(user.state[@"innerAnimal"]);
            handler();
        };
    } afterBlock:^{
        [self connectUser:@"ian" usingClient:client1];
        [self connectUser:@"ian" usingClient:client2];
        client1.me.plugin([CENRandomUsernamePlugin class]).configuration(self.configuration).store();
    }];
}

#pragma mark -


@end
