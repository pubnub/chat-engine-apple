/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPushNotificationsMiddleware.h>
#import <CENChatEngine/CENPushNotificationsExtension.h>
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENPushNotificationsPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine<PNObjectEventListener> *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;

@property (nonatomic, nullable, strong) CENPushNotificationsPlugin *defaultPlugin;
@property (nonatomic, nullable, strong) NSData *defaultToken;


#pragma mark -


@end


@implementation CENPushNotificationsPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    self.defaultToken = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    self.defaultPlugin = [CENPushNotificationsPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    self.client = (CENChatEngine<PNObjectEventListener> *)[self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
    OCMStub([self.clientMock createDirectChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#write.#direct").autoConnect(NO).create());
    OCMStub([self.clientMock createFeedChatForUser:[OCMArg any]])
        .andReturn(self.clientMock.Chat().name(@"chat-engine#user#tester#read.#feed").autoConnect(NO).create());
    OCMStub([self.clientMock me]).andReturn([CENMe userWithUUID:@"tester" state:@{} chatEngine:self.clientMock]);
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertIdentifier {
    
    XCTAssertEqualObjects(CENPushNotificationsPlugin.identifier, @"com.chatengine.plugin.push-notifications");
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldAddEvent_WhenNilConfigurationPassed {
    
    NSArray<NSString *> *events = self.defaultPlugin.configuration[CENPushNotificationsConfiguration.events];
    
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
    
    Class extensionClass = [self.defaultPlugin extensionClassFor:self.client.me];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENPushNotificationsExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENMeInstancePassed {
    
    Class extensionClass = [self.defaultPlugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideMiddleware_WhenCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.defaultPlugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:self.client.me.direct];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENPushNotificationsMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenNonCENChatInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.defaultPlugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:(id)@2010];
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenCENChatInstancePassedForUnexpectedLocation {
    
    Class middlewareClass = [self.defaultPlugin middlewareClassForLocation:CEPMiddlewareLocation.on object:self.client.me.direct];
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: Enable Notifications

- (void)testEnableNotifications_ShouldCallExtension_WhenDeviceTokenAndChatsListPassed {
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:@[self.client.me.direct] withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testEnableNotifications_ShouldCallExtensionMethod_WhenDeviceTokenAndChatsListPassed {
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    NSArray<CENChat *> *expectedChats = @[self.client.me.direct];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) { };
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    id extensionPartialMock = [self partialMockForObject:extension];
    
    OCMStub([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENPushNotificationsExtension *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        block(extension);
    });
    
    OCMExpect([extension enablePushNotifications:YES forChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    OCMVerifyAll(extensionPartialMock);
}

- (void)testEnableNotifications_ShouldNotCallExtension_WhenDeviceTokenNotPassed {
    
    NSData *token = nil;
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:@[self.client.me.direct] withDeviceToken:token completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testEnableNotifications_ShouldNotCallExtension_WhenEmptyDeviceTokenPassed {
    
    NSData *token = [NSData new];
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:@[self.client.me.direct] withDeviceToken:token completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testEnableNotifications_ShouldNotCallExtension_WhenChatsListNotPassed {
    
    NSArray<CENChat *> *chats = nil;
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:chats withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testEnableNotifications_ShouldNotCallExtension_WhenEmptyChatsListPassed {
    
    NSArray<CENChat *> *chats = [NSArray new];
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin enablePushNotificationsForChats:chats withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}


#pragma mark - Tests :: Disable Notifications

- (void)testDisableNotifications_ShouldCallExtension_WhenDeviceTokenAndChatsListPassed {
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:@[self.client.me.direct] withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testDisableNotifications_ShouldCallExtensionMethod_WhenDeviceTokenAndChatsListPassed {
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    NSArray<CENChat *> *expectedChats = @[self.client.me.direct];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    id extensionPartialMock = [self partialMockForObject:extension];
    
    OCMStub([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENPushNotificationsExtension *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        block(extension);
    });
    
    OCMExpect([extension enablePushNotifications:NO forChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:expectedChats withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    OCMVerifyAll(extensionPartialMock);
}

- (void)testDisableNotifications_ShouldNotCallExtension_WhenDeviceTokenNotPassed {
    
    NSData *token = nil;
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:@[self.client.me.direct] withDeviceToken:token completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testDisableNotifications_ShouldNotCallExtension_WhenEmptyDeviceTokenPassed {
    
    NSData *token = [NSData new];
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:@[self.client.me.direct] withDeviceToken:token completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testDisableNotifications_ShouldNotCallExtension_WhenChatsListNotPassed {
    
    NSArray<CENChat *> *chats = nil;
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:chats withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testDisableNotifications_ShouldNotCallExtension_WhenEmptyChatsListPassed {
    
    NSArray<CENChat *> *chats = [NSArray new];
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disablePushNotificationsForChats:chats withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}


#pragma mark - Tests :: Disable All Notifications


- (void)testDisableAllNotifications_ShouldCallExtension_WhenDeviceTokenAndChatsListPassed {
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:self.client.me withDeviceToken:self.defaultToken completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testDisableAllNotifications_ShouldCallExtensionMethod_WhenDeviceTokenAndChatsListPassed {
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    id extensionPartialMock = [self partialMockForObject:extension];
    
    OCMStub([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENPushNotificationsExtension *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        block(extension);
    });
    
    OCMExpect([extension enablePushNotifications:NO forChats:nil withDeviceToken:self.defaultToken completion:completionHandler]);
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:self.client.me withDeviceToken:self.defaultToken completion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    OCMVerifyAll(extensionPartialMock);
}


- (void)testDisableAllNotifications_ShouldNotCallExtension_WhenDeviceTokenNotPassed {
    
    NSData *token = nil;
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:self.client.me withDeviceToken:token completion:nil];
    
    OCMVerifyAll(mePartialMock);
}

- (void)testDisableAllNotifications_ShouldNotCallExtension_WhenEmptyDeviceTokenPassed {
    
    NSData *token = [NSData new];
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    OCMExpect([[mePartialMock reject] extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]);
    
    [CENPushNotificationsPlugin disableAllPushNotificationsForUser:self.client.me withDeviceToken:token completion:nil];
    
    OCMVerifyAll(mePartialMock);
}


#pragma mark - Tests :: Mark Notifications As Seen

- (void)testMarkNotificationAsSeen_ShouldCallExtensionMethod {
    
    NSNotification *expectedNotification = [NSNotification notificationWithName:@"Test" object:@"PubNub"];
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    id extensionPartialMock = [self partialMockForObject:extension];
    
    OCMStub([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENPushNotificationsExtension *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        block(extension);
    });
    
    OCMExpect([extension markNotificationAsSeen:expectedNotification withCompletion:completionHandler]);
    
    [CENPushNotificationsPlugin markNotificationAsSeen:expectedNotification forUser:self.client.me withCompletion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    OCMVerifyAll(extensionPartialMock);
}


#pragma mark - Tests :: Mark All Notifications As Seen

- (void)testMarkAllNotificationAsSeen_ShouldCallExtensionMethod {
    
    CENPushNotificationsExtension *extension = [CENPushNotificationsExtension new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    void(^completionHandler)(NSError *) = ^(NSError *error) {};
    
    id mePartialMock = [self partialMockForObject:self.client.me];
    id extensionPartialMock = [self partialMockForObject:extension];
    
    OCMStub([mePartialMock extensionWithIdentifier:CENPushNotificationsPlugin.identifier context:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(CENPushNotificationsExtension *) = nil;
        [invocation getArgument:&block atIndex:3];
        
        block(extension);
    });
    
    OCMExpect([extension markAllNotificationAsSeenWithCompletion:completionHandler]);
    
    [CENPushNotificationsPlugin markAllNotificationAsSeenForUser:self.client.me withCompletion:completionHandler];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
    OCMVerifyAll(extensionPartialMock);
}

#pragma mark -


@end
