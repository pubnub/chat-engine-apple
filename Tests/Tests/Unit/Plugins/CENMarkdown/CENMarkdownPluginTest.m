/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENMarkdownMiddleware.h>
#import <CENChatEngine/CENMarkdownPlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENSearch+Private.h>
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

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
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

- (void)testConfiguration_ShouldAddMessage_WhenNilConfigurationPassed {
    
    NSString *messageKey = self.plugin.configuration[CENMarkdownConfiguration.messageKey];
    
    
    XCTAssertNotNil(messageKey);
    XCTAssertEqualObjects(messageKey, @"text");
}

- (void)testConfiguration_ShouldNotAddMessage_WhenConfigurationWithMessageKeyPassed {
    
    NSDictionary *configuration = @{ CENMarkdownConfiguration.messageKey: @"message" };
    CENMarkdownPlugin *plugin = [CENMarkdownPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    NSString *messageKey = plugin.configuration[CENMarkdownConfiguration.messageKey];
    
    
    XCTAssertNotNil(messageKey);
    XCTAssertEqualObjects(messageKey, configuration[CENMarkdownConfiguration.messageKey]);
}

- (void)testConfiguration_ShouldAddParsedMessage_WhenNilConfigurationPassed {
    
    NSString *parsedMessageKey = self.plugin.configuration[CENMarkdownConfiguration.parsedMessageKey];
    NSString *messageKey = self.plugin.configuration[CENMarkdownConfiguration.messageKey];
    
    
    XCTAssertNotNil(parsedMessageKey);
    XCTAssertEqualObjects(parsedMessageKey, messageKey);
    XCTAssertEqualObjects(parsedMessageKey, @"text");
}

- (void)testConfiguration_ShouldNotAddParsedMessage_WhenConfigurationWithParsedMessageKeyPassed {
    
    NSDictionary *configuration = @{ CENMarkdownConfiguration.parsedMessageKey: @"message" };
    CENMarkdownPlugin *plugin = [CENMarkdownPlugin pluginWithIdentifier:@"test" configuration:configuration];
    NSString *messageKey = plugin.configuration[CENMarkdownConfiguration.messageKey];
    
    NSString *parsedMessageKey = plugin.configuration[CENMarkdownConfiguration.parsedMessageKey];
    
    
    XCTAssertNotNil(parsedMessageKey);
    XCTAssertEqualObjects(parsedMessageKey, configuration[CENMarkdownConfiguration.parsedMessageKey]);
    XCTAssertNotEqualObjects(parsedMessageKey, messageKey);
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

- (void)testMiddleware_ShouldProvideMiddleware_WhenCENSearchInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENSearch *search = [CENSearch searchForEvent:@"event" inChat:chat sentBy:user withLimit:0
                                            pages:0 count:100 start:nil end:nil chatEngine:self.client];
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:search];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENMarkdownMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenNonCENSearchInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenCENSearchInstancePassedForUnexpectedLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENSearch *search = [CENSearch searchForEvent:@"event" inChat:chat sentBy:user withLimit:0
                                            pages:0 count:100 start:nil end:nil chatEngine:self.client];
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:search];
    XCTAssertNil(middlewareClass);
}

#pragma mark -


@end
