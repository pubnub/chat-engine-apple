/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENEventStatusEmitMiddleware.h>
#import <CENChatEngine/CENEventStatusOnMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENEventStatusExtension.h>
#import <CENChatEngine/CENEventStatusPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENEventStatusPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEventStatusPlugin *plugin;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENEventStatusPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.plugin = [CENEventStatusPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
    XCTAssertEqualObjects(CENEventStatusPlugin.identifier, @"com.chatengine.plugin.event-status");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.plugin.configuration[CENEventStatusConfiguration.events];
    
    
    XCTAssertNotNil(events);
    XCTAssertTrue([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldNotAddEvent_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENEventStatusConfiguration.events: @[@"custom"] };
    CENEventStatusPlugin *plugin = [CENEventStatusPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = plugin.configuration[CENEventStatusConfiguration.events];
    
    XCTAssertNotNil(events);
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertFalse([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldReplaceMiddlewareDefaultEvents_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENEventStatusConfiguration.events: @[@"custom"] };
    [CENEventStatusPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *emitEvents = CENEventStatusEmitMiddleware.events;
    NSArray<NSString *> *onEvents = CENEventStatusOnMiddleware.events;
    
    XCTAssertEqual(onEvents.count, 2);
    XCTAssertTrue([onEvents containsObject:@"custom"]);
    XCTAssertTrue([onEvents containsObject:@"$.emitted"]);
    XCTAssertEqual(emitEvents.count, 1);
    XCTAssertTrue([emitEvents containsObject:@"custom"]);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideOnMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENEventStatusOnMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideOnMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldProvideEmitMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENEventStatusEmitMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideEmitMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:[self publicChatWithChatEngine:self.client]];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENEventStatusExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: Read

- (void)testRead_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENEventStatusPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENEventStatusPlugin readEvent:@{} inChat:chat];
    }];
}

- (void)testRead_ShouldCallExtensionMethod {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEventStatusExtension *extension = [CENEventStatusExtension extensionForObject:chat withIdentifier:@"test"
                                                                       configuration:self.plugin.configuration];
    NSDictionary *expected = @{ @"test": @"payload" };
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock readEvent:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENEventStatusPlugin readEvent:expected inChat:chatMock];
    }];
}

#pragma mark -


@end
