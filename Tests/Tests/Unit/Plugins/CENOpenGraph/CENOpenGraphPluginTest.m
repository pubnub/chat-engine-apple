/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENOpenGraphMiddleware.h>
#import <CENChatEngine/CENOpenGraphPlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENOpenGraphPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENOpenGraphPlugin *plugin;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENOpenGraphPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.plugin = [CENOpenGraphPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
    XCTAssertEqualObjects(CENOpenGraphPlugin.identifier, @"com.chatengine.plugin.opengraph");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.plugin.configuration[CENOpenGraphConfiguration.events];
    
    
    XCTAssertNotNil(events);
    XCTAssertTrue([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldNotAddEvent_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENOpenGraphConfiguration.events: @[@"custom"] };
    CENOpenGraphPlugin *plugin = [CENOpenGraphPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = plugin.configuration[CENOpenGraphConfiguration.events];
    
    XCTAssertNotNil(events);
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertFalse([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldReplaceMiddlewareDefaultEvents_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENOpenGraphConfiguration.events: @[@"custom"] };
    [CENOpenGraphPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = CENOpenGraphMiddleware.events;
    
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideOnMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENOpenGraphMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideOnMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

#pragma mark -


@end
