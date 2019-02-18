/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENPushNotificationsExtension.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENPushNotificationsPlugin.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENChatEngine+Private.h>

#if (TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED >= 100000 && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000) || \
    (TARGET_OS_WATCH && __WATCH_OS_VERSION_MIN_REQUIRED >= 30000 && __WATCH_OS_VERSION_MAX_ALLOWED >= 30000) || \
    (TARGET_OS_TV && __TV_OS_VERSION_MIN_REQUIRED >= 100000 && __TV_OS_VERSION_MAX_ALLOWED >= 100000) || \
    (TARGET_OS_OSX && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101200 && __MAC_OS_X_VERSION_MAX_ALLOWED >= 101400)
#define CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE 1
#import <UserNotifications/UserNotifications.h>
#else
#define CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE 0
#endif

#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENEvent+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENPushNotificationsExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENPushNotificationsExtension *extension;
@property (nonatomic, strong) NSData *token;


#pragma mark - Misc

- (void)stubLocalUser;
- (void)stubPublishEventWith:(CENEvent *)event;
- (void)stubPubNubWithStatus:(PNAcknowledgmentStatus *)status;
- (NSNotification *)notificationForEvent:(NSString *)event withID:(NSString *)eventID;
#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
- (UNNotification *)notificationCenterNotificationWithEventID:(NSString *)eventID;
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
- (NSArray<CENChat *> *)listWithChats:(NSUInteger)count;

- (PNAcknowledgmentStatus *)acknowledgmentForOperation:(PNOperationType)type;
- (PNAcknowledgmentStatus *)errorStatusForOperation:(PNOperationType)type withChannels:(NSArray *)channels;


#pragma mark -


@end


#pragma mark - Tests

@implementation CENPushNotificationsExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {

    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];


    XCTAssertTrue([self isObjectMocked:self.client]);

    [self completeChatEngineConfiguration:self.client];
    [self stubLocalUser];
    
    self.token = [@"00000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    
    self.extension = [CENPushNotificationsExtension extensionForObject:self.client.me withIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: enablePushNotifications

- (void)testEnablePushNotifications_ShouldForwardCall {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    
    id extensionMock = [self mockForObject:self.extension];
    id recorded = OCMExpect([extensionMock enable:YES forChats:chats withDeviceToken:self.token completion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.extension enablePushNotifications:YES forChats:chats withDeviceToken:self.token completion:^(NSError * error) { }];
#pragma GCC diagnostic pop
    }];
}


#pragma mark - Tests :: enableForChats

- (void)testEnableForChats_ShouldEnableNotificationsForChats_WhenListOfCENChatPassed {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSArray<NSString *> *channels = [chats valueForKey:@"channel"];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock addPushNotificationsOnChannels:channels withDevicePushToken:self.token
                                                         andCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldEnableNotificationsForChatsSeries_WhenHugeListOfCENChatPassed {
    
    NSArray<CENChat *> *chats = [self listWithChats:400];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    OCMExpect([pubnubMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.token
                                           andCompletion:[OCMArg any]]);
    OCMExpect([pubnubMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.token
                                           andCompletion:[OCMArg any]]);
    
    [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    
    OCMVerifyAll(pubnubMock);
}

- (void)testEnableForChats_ShouldNotEnableNotificationsForChats_WhenEmptyListOfCENChatPassed {

    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:self.token
                                                                  andCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension enable:YES forChats:@[] withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldRegisterPlugin_WhenEnableSuccessful {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNAddPushNotificationsOnChannelsOperation]];
    
    id chatMock = [self mockForObject:chats[10]];
    id recorded = OCMExpect([chatMock registerPlugin:[CENPushNotificationsPlugin class] withIdentifier:self.extension.identifier
                                       configuration:self.extension.configuration]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {}];
    }];
}

- (void)testEnableForChats_ShouldNotRegisterPlugin_WhenEnableSuccessfulAndPluginAlreadyExists {
    
    NSDictionary *configuration = self.extension.configuration;
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSString *identifier = self.extension.identifier;
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNAddPushNotificationsOnChannelsOperation]];
    
    id chatMock = [self mockForObject:chats[10]];
    OCMStub([chatMock hasPluginWithIdentifier:identifier]).andReturn(YES);
    
    id recorded = OCMExpect([[chatMock reject] registerPlugin:[CENPushNotificationsPlugin class] withIdentifier:identifier
                                                configuration:configuration]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {}];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithOutError_WhenEnableSuccessful {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNAddPushNotificationsOnChannelsOperation]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNil(error);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithError_WhenEnableDidFail {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation withChannels:nil]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], chats);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithMultipleErrorWithChats_WhenEnableDidFail {
    
    NSArray<CENChat *> *chats = [self listWithChats:400];
    NSArray<NSString *> *channels = [chats valueForKey:@"channel"];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation withChannels:channels]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
            XCTAssertEqual(((NSArray *)error.userInfo[kCENNotificationsErrorChatsKey]).count, chats.count * 2);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCallCompleteWithErrorUsingPortionOfChats_WhenEnableDidFailForChatsWithSubsetOfRequested {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSArray<CENChat *> *chats2 = [self listWithChats:20];
    NSArray<NSString *> *channels = [chats valueForKey:@"channel"];
    NSArray<NSString *> *channels2 = [channels arrayByAddingObjectsFromArray:[chats2 valueForKey:@"channel"]];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation withChannels:channels2]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], chats);
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCallCompleteWithErrorWithOutChats_WhenEnableDidFailForDifferentChats {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSArray<CENChat *> *chats2 = [self listWithChats:20];
    NSArray<NSString *> *channels2 = [chats2 valueForKey:@"channel"];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNAddPushNotificationsOnChannelsOperation withChannels:channels2]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:YES forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertNil(error.userInfo[kCENNotificationsErrorChatsKey]);
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldDisableNotificationsForChats_WhenListOfCENChatPassed {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSArray<NSString *> *channels = [chats valueForKey:@"channel"];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock removePushNotificationsFromChannels:channels withDevicePushToken:self.token
                                                              andCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldDisableNotificationsForChatsSeries_WhenHugeListOfCENChatPassed {
    
    NSArray<CENChat *> *chats = [self listWithChats:400];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    OCMExpect([pubnubMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.token
                                                andCompletion:[OCMArg any]]);
    OCMExpect([pubnubMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.token
                                                andCompletion:[OCMArg any]]);
    
    [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    
    OCMVerifyAll(pubnubMock);
}

- (void)testEnableForChats_ShouldNotDisableNotificationsForChats_WhenEmptyListOfCENChatPassed {

    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([[pubnubMock reject] removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:self.token
                                                                       andCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension enable:NO forChats:@[] withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldUnRegisterPlugin_WhenDisableSuccessful {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSString *identifier = self.extension.identifier;
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNRemovePushNotificationsFromChannelsOperation]];
    
    id chatMock = [self mockForObject:chats[10]];
    id recorded = OCMExpect([chatMock unregisterPluginWithIdentifier:identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithOutError_WhenDisableSuccessful {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNRemovePushNotificationsFromChannelsOperation]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNil(error);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithError_WhenDisableDidFail {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNRemovePushNotificationsFromChannelsOperation withChannels:nil]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], chats);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCallCompleteWithErrorUsingPortionOfChats_WhenDisableDidFailForChatsWithSubsetOfRequested {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSArray<CENChat *> *chats2 = [self listWithChats:20];
    NSArray<NSString *> *channels = [chats valueForKey:@"channel"];
    NSArray<NSString *> *channels2 = [channels arrayByAddingObjectsFromArray:[chats2 valueForKey:@"channel"]];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNRemovePushNotificationsFromChannelsOperation
                                                withChannels:channels2]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertEqualObjects(error.userInfo[kCENNotificationsErrorChatsKey], chats);
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCallCompleteWithErrorWithOutChats_WhenDisableDidFailForDifferentChats {
    
    NSArray<CENChat *> *chats = [self listWithChats:20];
    NSArray<CENChat *> *chats2 = [self listWithChats:20];
    NSArray<NSString *> *channels2 = [chats2 valueForKey:@"channel"];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNRemovePushNotificationsFromChannelsOperation
                                                withChannels:channels2]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:chats withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertNil(error.userInfo[kCENNotificationsErrorChatsKey]);
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldDisableAllNotifications {

    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    id recorded = OCMExpect([pubnubMock removeAllPushNotificationsFromDeviceWithPushToken:self.token
                                                                            andCompletion:[OCMArg any]]);
    [self waitForObject:pubnubMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldUnRegisterPlugin_WhenDisableAllSuccessful {
    
    NSArray<CENChat *> *chats = [self listWithChats:5];
    NSString *identifier = self.extension.identifier;
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNRemoveAllPushNotificationsOperation]];
    
    id chatMock = [self mockForObject:chats[2]];
    id recorded = OCMExpect([chatMock unregisterPluginWithIdentifier:identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) { }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithOutError_WhenDisableAllSuccessful {

    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self acknowledgmentForOperation:PNRemoveAllPushNotificationsOperation]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNil(error);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithError_WhenDisableAllDidFail {
    
    NSArray *channels = [[self listWithChats:20] valueForKey:@"channel"];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNRemoveAllPushNotificationsOperation withChannels:channels]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertNotNil(error.userInfo[kCENNotificationsErrorChatsKey]);
            
            handler();
        }];
    }];
}

- (void)testEnableForChats_ShouldCompleteWithErrorWithOutChats_WhenDisableAllDidFailWithOutChannelsInformation {
    
    [self listWithChats:20];
    
    
    [self.client setupPubNubForUserWithUUID:[NSUUID UUID].UUIDString authorizationKey:[NSUUID UUID].UUIDString];
    
    [self stubPubNubWithStatus:[self errorStatusForOperation:PNRemoveAllPushNotificationsOperation withChannels:nil]];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) {
            XCTAssertNotNil(error);
            XCTAssertNil(error.userInfo[kCENNotificationsErrorChatsKey]);
            
            handler();
        }];
    }];
}


#pragma mark - Tests :: markNotificationAsSeen

- (void)testMarkNotificationAsSeen_ShouldForwardCall {
    
    NSNotification *notification = [self notificationForEvent:@"message" withID:[NSUUID UUID].UUIDString];
    
    id extensionMock = [self mockForObject:self.extension];
    id recorded = OCMExpect([extensionMock markAsSeen:notification withCompletion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.extension markNotificationAsSeen:notification withCompletion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}


#pragma mark - Tests :: markAsSeen

- (void)testMarkNotificationAsSeen_ShouldCallCompletionBlock_WhenUpdateEmitted {

    NSNotification *notification = [self notificationForEvent:@"message" withID:[NSUUID UUID].UUIDString];
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAsSeen:notification withCompletion:^(NSError *error) {
            XCTAssertNil(error);
            handler();
        }];
    } afterBlock:^{
        [event emitEventLocally:@"$.emitted" withParameters:@[@{ @"event": @"published" }]];
    }];
}

- (void)testMarkNotificationAsSeen_ShouldCallCompletionBlock_WhenEventIsMissing {
    
    NSNotification *notification = [self notificationForEvent:nil withID:[NSUUID UUID].UUIDString];
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAsSeen:notification withCompletion:^(NSError *error) {
            XCTAssertNil(error);
            handler();
        }];
    } afterBlock:^{
        [event emitEventLocally:@"$.emitted" withParameters:@[@{ @"event": @"published" }]];
    }];
}

- (void)testMarkNotificationAsSeen_ShouldNotCallCompletionBlock_WhenCalledForOwnEvent {
 
    NSNotification *notification = [self notificationForEvent:@"$notifications.seen"
                                                       withID:[NSUUID UUID].UUIDString];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAsSeen:notification withCompletion:^(NSError *error) {
            handler();
        }];
    }];
}

- (void)testMarkNotificationAsSeen_ShouldNotCallCompletionBlock_WhenEventIDIsEmpty {
    
    NSNotification *notification = [self notificationForEvent:@"message" withID:@""];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAsSeen:notification withCompletion:^(NSError *error) {
            handler();
        }];
    }];
}

- (void)testMarkNotificationAsSeen_ShouldNotCallCompletionBlock_WhenEventIDIsNil {
    
    NSNotification *notification = [self notificationForEvent:@"message" withID:nil];
    
    
    [self waitToNotCompleteIn:self.falseTestCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAsSeen:notification withCompletion:^(NSError *error) {
            handler();
        }];
    }];
}

- (void)testMarkNotificationAsSeen_ShouldCallCompletionBlockWithError_WhenUpdateEmitErrored {
    
    NSNotification *notification = [self notificationForEvent:@"message" withID:[NSUUID UUID].UUIDString];
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:1000 userInfo:nil];
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAsSeen:notification withCompletion:^(NSError *error) {
            XCTAssertNotNil(error);
            handler();
        }];
    } afterBlock:^{
        [event emitEventLocally:@"$.error.emitter" withParameters:@[error]];
    }];
}

#if TARGET_OS_IOS || TARGET_OS_TV
- (void)testMarkNotificationAsSeen_ShouldStartBackgroundTask_WhenApplicationInBackground {
    
    NSNotification *notification = [self notificationForEvent:@"test" withID:[NSUUID UUID].UUIDString];
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
    id centerMock = [self mockForObject:[UNUserNotificationCenter class]];
    OCMStub([centerMock currentNotificationCenter]).andReturn(nil);
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
    
    id applicationMock = [self mockForObject:[UIApplication sharedApplication]];
    OCMStub([applicationMock applicationState]).andReturn(UIApplicationStateBackground);
    
    OCMExpect([applicationMock beginBackgroundTaskWithExpirationHandler:[OCMArg any]]);
    [self.extension markAsSeen:notification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitBackgroundnTaskStart" completionFor:self.delayedCheck];
    
    OCMVerifyAll(applicationMock);
}

- (void)testMarkNotificationAsSeen_ShouldEndBackgroundTask_WhenApplicationInBackground {
    
    NSNotification *notification = [self notificationForEvent:@"test" withID:[NSUUID UUID].UUIDString];
    UIBackgroundTaskIdentifier identifier = 100;
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
    id centerMock = [self mockForObject:[UNUserNotificationCenter currentNotificationCenter]];
    OCMStub([centerMock getDeliveredNotificationsWithCompletionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSArray<UNNotification *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        block(@[]);
    });
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
    
    id applicationMock = [self mockForObject:[UIApplication sharedApplication]];
    OCMStub([applicationMock applicationState]).andReturn(UIApplicationStateBackground);
    OCMStub([applicationMock beginBackgroundTaskWithExpirationHandler:[OCMArg any]]).andReturn(identifier);
    
    OCMExpect([applicationMock endBackgroundTask:identifier]);
    [self.extension markAsSeen:notification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitBackgroundnTaskEnd" completionFor:self.delayedCheck];
    
    OCMVerifyAll(applicationMock);
}

- (void)testMarkNotificationAsSeen_ShouldEndBackgroundTaskByTimeout_WhenDeliveredNotificationsNotCalledInTime {
    
    NSNotification *notification = [self notificationForEvent:@"test" withID:[NSUUID UUID].UUIDString];
    UIBackgroundTaskIdentifier identifier = 100;
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
    id centerMock = [self mockForObject:[UNUserNotificationCenter currentNotificationCenter]];
    OCMStub([centerMock getDeliveredNotificationsWithCompletionHandler:[OCMArg any]]).andDo(nil);
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
    
    id applicationMock = [self mockForObject:[UIApplication sharedApplication]];
    
    OCMStub([applicationMock applicationState]).andReturn(UIApplicationStateBackground);
    OCMStub([applicationMock beginBackgroundTaskWithExpirationHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:1];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), queue, ^{
            block();
        });
    }).andReturn(identifier);
    
    OCMExpect([applicationMock endBackgroundTask:identifier]);
    [self.extension markAsSeen:notification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitBackgroundnTaskEndByTimeout" completionFor:self.delayedCheck];
    
    OCMVerifyAll(applicationMock);
}
#endif // TARGET_OS_IOS || TARGET_OS_TV


#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
- (void)testMarkNotificationAsSeen_ShouldHideNotification_WhenEventIDPassed {
    
    NSString *eventIdentifier = [NSUUID UUID].UUIDString;
    NSNotification *receivedNotification = [self notificationForEvent:@"test" withID:eventIdentifier];
    UNNotification *notification = [self notificationCenterNotificationWithEventID:eventIdentifier];
    
    
    id centerMock = [self mockForObject:[UNUserNotificationCenter currentNotificationCenter]];
    OCMStub([centerMock getDeliveredNotificationsWithCompletionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSArray<UNNotification *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        block(@[notification]);
    });
    
    OCMExpect([centerMock removeDeliveredNotificationsWithIdentifiers:@[notification.request.identifier]]);
    
    [self.extension markAsSeen:receivedNotification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitNotificationHide" completionFor:self.delayedCheck];
    
    OCMVerifyAll(centerMock);
}

- (void)testMarkNotificationAsSeen_ShouldNotHideNotifications_WhenNotificationRepresentEventWithDifferentID {
    
    NSNotification *receivedNotification = [self notificationForEvent:@"test" withID:[NSUUID UUID].UUIDString];
    UNNotification *notification = [self notificationCenterNotificationWithEventID:[NSUUID UUID].UUIDString];
    
    
    id centerMock = [self mockForObject:[UNUserNotificationCenter currentNotificationCenter]];
    OCMStub([centerMock getDeliveredNotificationsWithCompletionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSArray<UNNotification *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        block(@[notification]);
    });
    
    OCMExpect([centerMock removeDeliveredNotificationsWithIdentifiers:@[]]);
    
    [self.extension markAsSeen:receivedNotification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitNotificationNotHide" completionFor:self.delayedCheck];
    
    OCMVerifyAll(centerMock);
}
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE


#pragma mark - Tests :: markAllNotificationAsSeenWithCompletion

- (void)testMarkAllNotificationAsSeenWithCompletion_ShouldForwardCall {
    
    id extensionMock = [self mockForObject:self.extension];
    id recorded = OCMExpect([extensionMock markAllAsSeenWithCompletion:[OCMArg any]]);
    [self waitForObject:extensionMock recordedInvocationCall:recorded afterBlock:^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.extension markAllNotificationAsSeenWithCompletion:^(NSError *error) { }];
#pragma GCC diagnostic pop
    }];
}


#pragma mark - Tests :: markAllAsSeenWithCompletion

- (void)testMarkAllNotificationAsSeenWithCompletion_ShouldCallCompletionBlock_WhenUpdateEmitted {
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAllAsSeenWithCompletion:^(NSError *error) {
            XCTAssertNil(error);
            handler();
        }];
    } afterBlock:^{
        [event emitEventLocally:@"$.emitted" withParameters:@[@{ @"event": @"published" }]];
    }];
}

- (void)testMarkAllNotificationAsSeenWithCompletion_ShouldCallCompletionBlockWithError_WhenUpdateEmitErrored {
    
    NSError *expected = [NSError errorWithDomain:NSURLErrorDomain code:1000 userInfo:nil];
    
    
    CENEvent *event = [CENEvent eventWithName:@"test" chat:self.client.me.direct chatEngine:self.client];
    [self stubPublishEventWith:event];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.extension markAllAsSeenWithCompletion:^(NSError *error) {
            XCTAssertNotNil(error);
            handler();
        }];
    } afterBlock:^{
        [event emitEventLocally:@"$.error.emitter" withParameters:@[expected]];
    }];
}

#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
- (void)testMarkNotificationAsSeen_ShouldHideAllNotifications_WhenAllIDPassedPassed {
    
    NSNotification *receivedNotification = [self notificationForEvent:@"test" withID:@"all"];
    UNNotification *notification = [self notificationCenterNotificationWithEventID:[NSUUID UUID].UUIDString];
    
    
    id centerMock = [self mockForObject:[UNUserNotificationCenter currentNotificationCenter]];
    OCMStub([centerMock getDeliveredNotificationsWithCompletionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSArray<UNNotification *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        block(@[notification]);
    });
    
    OCMExpect([centerMock removeDeliveredNotificationsWithIdentifiers:@[notification.request.identifier]]);
    
    [self.extension markAsSeen:receivedNotification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitAllNotificationsHide" completionFor:self.delayedCheck];
    
    OCMVerifyAll(centerMock);
}

- (void)testMarkNotificationAsSeen_ShouldNotHideNonCENChatNotifications_WhenAllIDPassedPassed {
    
    NSNotification *receivedNotification = [self notificationForEvent:@"test" withID:@"all"];
    UNNotification *notification = [self notificationCenterNotificationWithEventID:nil];
    
    
    id centerMock = [self mockForObject:[UNUserNotificationCenter currentNotificationCenter]];
    OCMStub([centerMock getDeliveredNotificationsWithCompletionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void(^block)(NSArray<UNNotification *> *) = [self objectForInvocation:invocation argumentAtIndex:1];
        block(@[notification]);
    });
    
    OCMExpect([centerMock removeDeliveredNotificationsWithIdentifiers:@[]]);
    
    [self.extension markAsSeen:receivedNotification withCompletion:^(NSError *error) {}];
    
    [self waitTask:@"waitAllNotificationsNotHide" completionFor:self.delayedCheck];
    
    OCMVerifyAll(centerMock);
}
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE

#pragma mark - Misc

- (void)stubLocalUser {
    
    self.usesMockedObjects = YES;
    CENChatEngine *client = self.client;
    
    [self stubChatConnection];
    
    CENMe *user = [CENMe userWithUUID:[NSUUID UUID].UUIDString state:@{} chatEngine:client];
    OCMStub([client me]).andReturn(user);
}

- (void)stubPublishEventWith:(CENEvent *)event {
    
    self.usesMockedObjects = YES;
    CENChatEngine *client = self.client;
    
    OCMStub([client publishToChat:[OCMArg any] eventWithName:[OCMArg any] data:[OCMArg any]]).andReturn(event);
    OCMStub([client publishStorable:YES event:event toChannel:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]])
        .andDo(nil);
}

- (NSNotification *)notificationForEvent:(NSString *)event withID:(NSString *)eventID {
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    if (eventID) {
        payload[CENEventData.eventID] = eventID;
    }
    
    if (event) {
        payload[CENEventData.event] = event;
    }
    
    return [NSNotification notificationWithName:@"TestNotification" object:self userInfo:@{ @"cepayload": payload }];
}


#if CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE
- (UNNotification *)notificationCenterNotificationWithEventID:(NSString *)eventID {
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.userInfo = eventID ? @{ @"cepayload": @{ CENEventData.eventID: eventID } } : @{};
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString content:content
                                                                          trigger:nil];
    UNNotification *notification = [UNNotification new];
    
    id notificationMock = [self mockForObject:notification];
    OCMStub([notificationMock request]).andReturn(request);
    
    return notification;
}
#endif // CEN_TESTS_NOTIFICATION_CENTER_AVAILABLE

- (void)stubPubNubWithStatus:(PNAcknowledgmentStatus *)status {
    
    id pubnubMock = [self mockForObject:self.client.pubnub];
    
    OCMStub([pubnubMock addPushNotificationsOnChannels:[OCMArg any] withDevicePushToken:[OCMArg any] andCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNPushNotificationsStateModificationCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:3];
            block(status);
        });
    
    OCMStub([pubnubMock removePushNotificationsFromChannels:[OCMArg any] withDevicePushToken:[OCMArg any]
                                              andCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNPushNotificationsStateModificationCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:3];
            block(status);
        });
    
    OCMStub([pubnubMock removeAllPushNotificationsFromDeviceWithPushToken:[OCMArg any] andCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNPushNotificationsStateModificationCompletionBlock block = [self objectForInvocation:invocation argumentAtIndex:2];
            block(status);
        });
}

- (NSArray<CENChat *> *)listWithChats:(NSUInteger)count {
    
    NSMutableArray *chats = [NSMutableArray new];
    
    for (NSUInteger chatN = 0; chatN < count; chatN++) {
        [chats addObject:self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create()];
    }
    
    return chats;
}

- (PNAcknowledgmentStatus *)acknowledgmentForOperation:(PNOperationType)type {

    return [PNAcknowledgmentStatus objectForOperation:type completedWithTask:nil processedData:@{} processingError:nil];
}

- (PNAcknowledgmentStatus *)errorStatusForOperation:(PNOperationType)type withChannels:(NSArray *)channels {
    
    NSMutableDictionary *serviceData = [@{ @"information": @"Test error", @"status": @403 } mutableCopy];
    
    if (channels.count) {
        serviceData[@"channels"] = channels;
    }
    
    return (id)[PNErrorStatus objectForOperation:type completedWithTask:nil processedData:serviceData processingError:nil];
}

#pragma mark -


@end
