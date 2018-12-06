/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENMarkdownMiddleware.h>
#import <CENChatEngine/CENMarkdownPlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENMarkdownPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENMarkdownPlugin *plugin;

#pragma mark -

@end


#pragma mark - Tests

@implementation CENMarkdownPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    self.plugin = [CENMarkdownPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENMarkdownPlugin.identifier, @"com.chatengine.plugin.markdown");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.plugin.configuration[CENMarkdownConfiguration.events];
    
    
    XCTAssertNotNil(events);
    XCTAssertTrue([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldNotAddEvent_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENMarkdownConfiguration.events: @[@"custom"] };
    CENMarkdownPlugin *plugin = [CENMarkdownPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = plugin.configuration[CENMarkdownConfiguration.events];
    
    XCTAssertNotNil(events);
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertFalse([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldReplaceMiddlewareDefaultEvents_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENMarkdownConfiguration.events: @[@"custom"] };
    [CENMarkdownPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = CENMarkdownMiddleware.events;
    
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENMarkdownMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenCENChatInstancePassedForUnexpectedLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:chat];
    XCTAssertNil(middlewareClass);
}

#pragma mark -


@end
