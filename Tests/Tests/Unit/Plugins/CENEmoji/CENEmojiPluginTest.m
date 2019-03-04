/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENEmojiEmitMiddleware.h>
#import <CENChatEngine/CENEmojiOnMiddleware.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENEmojiExtension.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENSearch+Private.h>
#import <CENChatEngine/CENEmojiPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENEmojiPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEmojiPlugin *plugin;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENEmojiPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"NativeEnabled"].location != NSNotFound) {
        configuration = @{ CENEmojiConfiguration.useNative: @YES };
    }
    
    self.plugin = [CENEmojiPlugin pluginWithIdentifier:@"test" configuration:configuration];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
    XCTAssertEqualObjects(CENEmojiPlugin.identifier, @"com.chatengine.plugin.emoji");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.plugin.configuration[CENEmojiConfiguration.events];
    
    
    XCTAssertNotNil(events);
    XCTAssertTrue([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldNotAddEvent_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENEmojiConfiguration.events: @[@"custom"] };
    CENEmojiPlugin *plugin = [CENEmojiPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = plugin.configuration[CENEmojiConfiguration.events];
    
    XCTAssertNotNil(events);
    XCTAssertEqual(events.count, 1);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertFalse([events containsObject:@"message"]);
}

- (void)testConfiguration_ShouldReplaceMiddlewareDefaultEvents_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENEmojiConfiguration.events: @[@"custom"] };
    [CENEmojiPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *onEvents = CENEmojiOnMiddleware.events;
    NSArray<NSString *> *emitEvents = CENEmojiOnMiddleware.events;
    
    XCTAssertEqual(onEvents.count, 1);
    XCTAssertTrue([onEvents containsObject:@"custom"]);
    XCTAssertEqual(emitEvents.count, 1);
    XCTAssertTrue([emitEvents containsObject:@"custom"]);
}

- (void)testConfiguration_ShouldSetEmojiURL_WhenNilConfigurationPassed {
    
    NSString *expected = @"https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis";
    
    
    NSString *emojiURL = self.plugin.configuration[CENEmojiConfiguration.emojiURL];
    
    XCTAssertNotNil(emojiURL);
    XCTAssertEqualObjects(emojiURL, expected);
}

- (void)testConfiguration_ShouldNotSetEmojiURL_WhenConfigurationWithURLPassed {
    
    NSString *expected = @"https://pubnub.com";
    NSDictionary *configuration = @{ CENEmojiConfiguration.emojiURL: expected };
    CENEmojiPlugin *plugin = [CENEmojiPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSString *emojiURL = plugin.configuration[CENEmojiConfiguration.emojiURL];
    
    XCTAssertNotNil(emojiURL);
    XCTAssertEqualObjects(emojiURL, expected);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideOnMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENEmojiOnMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideOnMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldProvideOnMiddleware_WhenCENSearchInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENSearch *search = [CENSearch searchForEvent:@"event" inChat:chat sentBy:user withLimit:0
                                            pages:0 count:100 start:nil end:nil chatEngine:self.client];
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:search];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENEmojiOnMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideOnMiddleware_WhenNonCENSearchInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldProvideEmitMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENEmojiEmitMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideEmitMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:[self publicChatWithChatEngine:self.client]];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENEmojiExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: emojiFrom

- (void)testEmojiFrom_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENEmojiPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENEmojiPlugin emojiFrom:@":smile:" usingChat:chat];
    }];
}

- (void)testEmojiFrom_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    NSString *expected = @":smile:";
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock emojiFrom:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENEmojiPlugin emojiFrom:expected usingChat:chatMock];
    }];
}

- (void)testEmojiFrom_ShouldReturnURL_WhenDefaultConfigurationUsed {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    NSString *expected = @"https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis/smile.png";
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSString *emoji = [CENEmojiPlugin emojiFrom:@":smile:" usingChat:chatMock];
        
        XCTAssertEqualObjects(emoji, expected);
        handler();
    }];
}

- (void)testEmojiFrom_ShouldNotReturnURL_WhenDefaultConfigurationUsed {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSString *emoji = [CENEmojiPlugin emojiFrom:@":testsmile:" usingChat:chatMock];
        
        XCTAssertNil(emoji);
        handler();
    }];
}

- (void)testEmojiFrom_ShouldReturnURL_WhenNativeEnabledConfigurationUsed {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    NSString *expected = @"😤";
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSString *emoji = [CENEmojiPlugin emojiFrom:@":triumph:" usingChat:chatMock];
        
        XCTAssertEqualObjects(emoji, expected);
        handler();
    }];
}

- (void)testEmojiFrom_ShouldNotReturnURL_WhenNativeEnabledConfigurationUsed {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSString *emoji = [CENEmojiPlugin emojiFrom:@":testsmile:" usingChat:chatMock];
        
        XCTAssertNil(emoji);
        handler();
    }];
}


#pragma mark - Tests :: emojiWithName

- (void)testEmojiWithName_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENEmojiPlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENEmojiPlugin emojiWithName:@":smil" usingChat:chat];
    }];
}

- (void)testEmojiWithName_ShouldCallExtensionMethod {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    NSString *expected = @":smil";
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([extensionMock emojiWithName:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENEmojiPlugin emojiWithName:expected usingChat:chat];
    }];
}

- (void)testEmojiWithName_ShouldReturnURL_WhenDefaultConfigurationUsed {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    NSArray *expected = @[@":smile:", @":smiley:", @":smiling_imp:", @":smiley_cat:", @":smile_cat:"];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<NSString *> *emoji = [CENEmojiPlugin emojiWithName:@":smil" usingChat:chat];
        
        XCTAssertEqualObjects([emoji sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)],
                              [expected sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]);
        handler();
    }];
}

- (void)testEmojiWithName_ShouldNotReturnURL_WhenDefaultConfigurationUsed {

    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENEmojiExtension *extension = [CENEmojiExtension extensionForObject:chat withIdentifier:@"test"
                                                           configuration:self.plugin.configuration];
    NSArray *expected = @[];
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        NSArray<NSString *> *emoji = [CENEmojiPlugin emojiWithName:@":testsm" usingChat:chat];
        XCTAssertEqualObjects(emoji, expected);
        handler();
    }];
}

#pragma mark -


@end
