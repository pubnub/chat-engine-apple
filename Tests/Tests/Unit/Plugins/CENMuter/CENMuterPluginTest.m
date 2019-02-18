/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENMuterMiddleware.h>
#import <CENChatEngine/CENMuterExtension.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENMuterPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENMuterPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENMuterPlugin *plugin;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENMuterPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    
    self.plugin = [CENMuterPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHaveProperIdentifier {
    
    XCTAssertEqualObjects(CENMuterPlugin.identifier, @"com.chatengine.plugin.muter");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.plugin.configuration[CENMuterConfiguration.events];
    
    
    XCTAssertNotNil(events);
    XCTAssertTrue([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldNotAddEvent_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENMuterConfiguration.events: @[@"custom"] };
    CENMuterPlugin *plugin = [CENMuterPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = plugin.configuration[CENMuterConfiguration.events];
    
    XCTAssertNotNil(events);
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertFalse([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldReplaceMiddlewareDefaultEvents_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENMuterConfiguration.events: @[@"custom"] };
    [CENMuterPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = CENMuterMiddleware.events;
    
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideOnMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENMuterMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideOnMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:[self publicChatWithChatEngine:self.client]];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENMuterExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: muteUser

- (void)testMuteUser_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENMuterPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENMuterPlugin muteUser:user inChat:chat];
    }];
}

- (void)testMuteUser_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENMuterExtension *extension = [CENMuterExtension extensionForObject:chat withIdentifier:@"test" configuration:nil];
    CENUser *expected = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock muteUser:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENMuterPlugin muteUser:expected inChat:chat];
    }];
}


#pragma mark - Tests :: unmuteUser

- (void)testUnmuteUser_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENMuterPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENMuterPlugin unmuteUser:user inChat:chat];
    }];
}

- (void)testUnmuteUser_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENMuterExtension *extension = [CENMuterExtension extensionForObject:chat withIdentifier:@"test" configuration:nil];
    CENUser *expected = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock unmuteUser:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENMuterPlugin unmuteUser:expected inChat:chat];
    }];
}


#pragma mark - Tests :: isMutedUser

- (void)testIsMutedUser_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENMuterPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENMuterPlugin isMutedUser:user inChat:chat];
    }];
}

- (void)testIsMutedUser_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENMuterExtension *extension = [CENMuterExtension extensionForObject:chat withIdentifier:@"test" configuration:nil];
    CENUser *expected = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock isMutedUser:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENMuterPlugin isMutedUser:expected inChat:chat];
    }];
}

#pragma mark -


@end
