/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPushNotificationsMiddleware.h>
#import <CENChatEngine/CENPushNotificationsExtension.h>
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#if TARGET_OS_IOS || TARGET_OS_WATCH
#import <UserNotifications/UserNotifications.h>
#endif
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENPushNotificationsPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENPushNotificationsPlugin *plugin;
@property (nonatomic, nullable, strong) NSData *token;


#pragma mark - Misc

- (void)stubLocalUser;


#pragma mark -


@end


#pragma mark - Tests

@implementation CENPushNotificationsPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    self.token = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    self.plugin = [CENPushNotificationsPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENPushNotificationsPlugin.identifier, @"com.chatengine.plugin.push-notifications");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.plugin.configuration[CENPushNotificationsConfiguration.events];
    
    
    XCTAssertNotNil(events);
    XCTAssertTrue([events containsObject:@"$notifications.seen"]);
}

- (void)testConfiguration_ShouldAddEvent_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENPushNotificationsConfiguration.events: @[@"custom"] };
    CENPushNotificationsPlugin *plugin = [CENPushNotificationsPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = plugin.configuration[CENPushNotificationsConfiguration.events];
    
    XCTAssertNotNil(events);
    XCTAssertEqual(events.count, 2);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertTrue([events containsObject:@"$notifications.seen"]);
}

- (void)testConfiguration_ShouldReplaceMiddlewareDefaultEvents_WhenConfigurationWithEventsPassed {
    
    NSDictionary *configuration = @{ CENPushNotificationsConfiguration.events: @[@"custom"] };
    [CENPushNotificationsPlugin pluginWithIdentifier:@"test" configuration:configuration];
    
    
    NSArray<NSString *> *events = CENPushNotificationsMiddleware.events;
    
    XCTAssertEqual(events.count, 2);
    XCTAssertTrue([events containsObject:@"custom"]);
    XCTAssertTrue([events containsObject:@"$notifications.seen"]);
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENMeInstancePassed {
    
    [self stubLocalUser];
    
    Class extensionClass = [self.plugin extensionClassFor:self.client.me];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENPushNotificationsExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENMeInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENPushNotificationsMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:(id)@2010];
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenCENChatInstancePassedForUnexpectedLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: Enable Notifications

- (void)testEnablePushNotificationsForChats_ShouldForwardCall {
    
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    
    
    id pluginMock = [self mockForObject:[CENPushNotificationsPlugin class]];
    id recorded = OCMExpect([pluginMock enableForChats:chats withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENPushNotificationsPlugin enablePushNotificationsForChats:chats withDeviceToken:self.token
                                                         completion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}

- (void)testEnableForChats_ShouldCallExtensionMethod_WhenDeviceTokenAndChatsListPassed {
    
    self.usesMockedObjects = YES;
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    OCMStub([userMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(CENPushNotificationsExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(extension);
        });
    
    id extensionMock = [self mockForObject:extension];
    id recorded = OCMExpect([extensionMock enable:YES forChats:chats withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldNotCallExtension_WhenDeviceTokenNotPassed {
    
    self.usesMockedObjects = YES;
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    NSData *token = nil;
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:chats withDeviceToken:token completion:nil];
    }];
}

- (void)testEnableForChats_ShouldNotCallExtension_WhenEmptyDeviceTokenPassed {
    
    self.usesMockedObjects = YES;
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    NSData *token = [NSData new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:chats withDeviceToken:token completion:nil];
    }];
}

- (void)testEnableForChats_ShouldNotCallExtension_WhenChatsListNotPassed {
    
    NSArray<CENChat *> *chats = nil;
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:chats withDeviceToken:self.token completion:nil];
    }];
}

- (void)testEnableForChats_ShouldNotCallExtension_WhenEmptyChatsListPassed {
    
    NSArray<CENChat *> *chats = [NSArray new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin enableForChats:chats withDeviceToken:self.token completion:nil];
    }];
}


#pragma mark - Tests :: Disable Notifications

- (void)testDisablePushNotificationsForChats_ShouldForwardCall {
    
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    
    
    id pluginMock = [self mockForObject:[CENPushNotificationsPlugin class]];
    id recorded = OCMExpect([pluginMock disableForChats:chats withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENPushNotificationsPlugin disablePushNotificationsForChats:chats withDeviceToken:self.token
                                                          completion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}

- (void)testDisableForChats_ShouldCallExtensionMethod_WhenDeviceTokenAndChatsListPassed {
    
    self.usesMockedObjects = YES;
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    OCMStub([userMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(CENPushNotificationsExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(extension);
        });
    
    id extensionMock = [self mockForObject:extension];
    id recorded = OCMExpect([extensionMock enable:NO forChats:chats withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableForChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testDisableForChats_ShouldNotCallExtension_WhenDeviceTokenNotPassed {
    
    self.usesMockedObjects = YES;
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    NSData *token = nil;
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableForChats:chats withDeviceToken:token completion:nil];
    }];
}

- (void)testDisableForChats_ShouldNotCallExtension_WhenEmptyDeviceTokenPassed {
    
    self.usesMockedObjects = YES;
    NSArray<CENChat *> *chats = @[self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    NSData *token = [NSData new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableForChats:chats withDeviceToken:token completion:nil];
    }];
}

- (void)testDisableForChats_ShouldNotCallExtension_WhenChatsListNotPassed {
    
    NSArray<CENChat *> *chats = nil;
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableForChats:chats withDeviceToken:self.token completion:nil];
    }];
}

- (void)testDisableForChats_ShouldNotCallExtension_WhenEmptyChatsListPassed {
    
    NSArray<CENChat *> *chats = [NSArray new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableForChats:chats withDeviceToken:self.token completion:nil];
    }];
}


#pragma mark - Tests :: Disable All Notifications

- (void)testDisableAllForUser_ShouldForwardCall {
    
    [self stubLocalUser];
    CENMe *me = self.client.me;
    
    id pluginMock = [self mockForObject:[CENPushNotificationsPlugin class]];
    id recorded = OCMExpect([pluginMock disableAllForUser:me withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENPushNotificationsPlugin disableAllPushNotificationsForUser:me withDeviceToken:self.token
                                                            completion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}

- (void)testDisableAllForUser_ShouldCallExtensionMethod_WhenDeviceTokenAndChatsListPassed {
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    
    
    [self stubLocalUser];
    CENMe *me = self.client.me;
    
    id userMock = [self mockForObject:self.client.me];
    OCMStub([userMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(CENPushNotificationsExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(extension);
        });
    
    id extensionMock = [self mockForObject:extension];
    id recorded = OCMExpect([extensionMock enable:NO forChats:nil withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableAllForUser:me withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}


- (void)testDisableAllForUser_ShouldNotCallExtension_WhenDeviceTokenNotPassed {
    
    NSData *token = nil;
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableAllForUser:self.client.me withDeviceToken:token completion:nil];
    }];
}

- (void)testDisableAllForUser_ShouldNotCallExtension_WhenEmptyDeviceTokenPassed {
    
    NSData *token = [NSData new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    id recorded = OCMExpect([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin disableAllForUser:self.client.me withDeviceToken:token completion:nil];
    }];
}


#pragma mark - Tests :: Mark Notifications As Seen

- (void)testMarkNotificationAsSeen_ShouldForwardCall {
    
    NSNotification *notification = [NSNotification notificationWithName:@"Test" object:@"PubNub"];
    
    
    [self stubLocalUser];
    CENMe *me = self.client.me;
    
    id pluginMock = [self mockForObject:[CENPushNotificationsPlugin class]];
    id recorded = OCMExpect([pluginMock markAsSeen:notification forUser:me withCompletion:[OCMArg any]]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENPushNotificationsPlugin markNotificationAsSeen:notification forUser:me withCompletion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}

- (void)testMarkAsSeen_ShouldCallExtensionMethod {
    
    NSNotification *notification = [NSNotification notificationWithName:@"Test" object:@"PubNub"];
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    OCMStub([userMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(CENPushNotificationsExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(extension);
        });
    
    id extensionMock = [self mockForObject:extension];
    id recorded = OCMExpect([extensionMock markAsSeen:notification withCompletion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin markAsSeen:notification forUser:self.client.me withCompletion:^(NSError *error) { }];
    }];
}

- (void)testMarkAsSeen_ShouldNotCallExtensionMethod_WhenNonCENMePassed {
    
    NSNotification *notification = [NSNotification notificationWithName:@"Test" object:@"PubNub"];
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id userMock = [self mockForObject:user];
    id recorded = OCMStub([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin markAsSeen:notification forUser:(id)user withCompletion:^(NSError *error) { }];
    }];
}


#pragma mark - Tests :: Mark All Notifications As Seen

- (void)testMarkAllNotificationAsSeen_ShouldForwardCall {

    [self stubLocalUser];
    CENMe *me = self.client.me;
    
    id pluginMock = [self mockForObject:[CENPushNotificationsPlugin class]];
    id recorded = OCMExpect([pluginMock markAllAsSeenForUser:me withCompletion:[OCMArg any]]);
    [self waitForObject:pluginMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [CENPushNotificationsPlugin markAllNotificationAsSeenForUser:me withCompletion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}

- (void)testMarkAllAsSeen_ShouldCallExtensionMethod {
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    
    
    [self stubLocalUser];
    
    id userMock = [self mockForObject:self.client.me];
    OCMStub([userMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^block)(CENPushNotificationsExtension *) = [self objectForInvocation:invocation argumentAtIndex:2];
            block(extension);
        });
    
    id extensionMock = [self mockForObject:extension];
    id recorded = OCMExpect([extensionMock markAllAsSeenWithCompletion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin markAllAsSeenForUser:self.client.me withCompletion:^(NSError *error) { }];
    }];
}

- (void)testMarkAllAsSeen_ShouldNotCallExtensionMethod_WhenNonCENMePassed {
    
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    
    
    id userMock = [self mockForObject:user];
    id recorded = OCMStub([[userMock reject] extensionWithIdentifier:[OCMArg any] context:[OCMArg any]]);
    [self waitForObject:userMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [CENPushNotificationsPlugin markAllAsSeenForUser:(id)user withCompletion:^(NSError *error) { }];
    }];
}


#pragma mark - Misc

- (void)stubLocalUser {
    
    self.usesMockedObjects = YES;
    CENChatEngine *client = self.client;
    
    [self stubChatConnection];
    
    CENMe *user = [CENMe userWithUUID:[NSUUID UUID].UUIDString state:@{} chatEngine:client];
    OCMStub([client me]).andReturn(user);
}

#pragma mark -


@end
