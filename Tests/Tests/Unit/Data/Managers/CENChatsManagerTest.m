/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChatsManager.h>
#import <CENChatEngine/CENChat+Private.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatsManagerTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;
@property (nonatomic, nullable, strong) CENChatsManager *manager;
@property (nonatomic, assign) BOOL mockedObjects;

#pragma mark -


@end



@implementation CENChatsManagerTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.throwExceptions = YES;
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    self.manager = [CENChatsManager managerForChatEngine:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
}

- (void)tearDown {
    
    [self.manager destroy];
    self.manager = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShoulThrowException_WhenInstanceCreatedWithNew {
    
    XCTAssertThrowsSpecificNamed([CENChatsManager new], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: createChatWithName

- (void)testCreateChatWithName_ShouldCreateChatWithRandomName_WhenNilPassed {
    
    NSString *expectedGroup = CENChatGroup.custom;
    NSUInteger expectedChatsCount = 1;
    
    CENChat *chat = [self.manager createChatWithName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertNotNil(chat);
    XCTAssertNotNil(chat.name);
    XCTAssertNotNil(chat.channel);
    XCTAssertEqualObjects(chat.group, expectedGroup);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
}

- (void)testCreateChatWithName_ShouldCreateAndConnectChatWithRandomName_WhenNilPassed {
    
    self.mockedObjects = YES;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    CENChat *chatForMock = [self publicChatForMockingWithChatEngine:self.client];
    id chatPartialMock = [self partialMockForObject:chatForMock];
    OCMExpect([(CENChat *)chatPartialMock connectChat]).andDo(^(NSInvocation *invocation) {
        dispatch_semaphore_signal(semaphore);
    });
    id chatClassMock = [self mockForClass:[CENChat class]];
    OCMExpect([self createPrivateChat:NO invocationForClassMock:chatClassMock]).andReturn(chatPartialMock);
    
    [self.manager createChatWithName:nil group:nil private:NO autoConnect:YES metaData:nil];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    OCMVerify(chatPartialMock);
    OCMVerify(chatClassMock);
}

- (void)testCreateChatWithName_ShouldCreateChatWithSpecificName_WhenAllRequiredDataPassed {
    
    NSString *exppectedName = @"TestChat1";
    BOOL expectedIsPrivate = YES;
    
    CENChat *chat = [self.manager createChatWithName:exppectedName group:CENChatGroup.custom private:expectedIsPrivate autoConnect:NO metaData:nil];
    
    XCTAssertEqualObjects(chat.name, exppectedName);
    XCTAssertEqual(chat.isPrivate, expectedIsPrivate);
    XCTAssertEqual(self.manager.chats[chat.channel], chat);
}

- (void)testCreateChatWithName_ShouldReturnExistingChat_WhenRequestedToCreateChatWithSameParameters {
    
    NSUInteger expectedChatsCount = 1;
    NSString *name = @"TestChat2";
    
    CENChat *chat1 = [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    
    XCTAssertEqual(chat1, chat2);
    XCTAssertEqualObjects(chat1.name, chat2.name);
    XCTAssertEqualObjects(chat1.channel, chat2.channel);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
}

- (void)testCreateChatWithName_ShouldReturnDifferentChat_WhenOneOfParametersNotTheSame {
    
    NSUInteger expectedChatsCount = 2;
    NSString *name = @"TestChat3";
    
    CENChat *chat1 = [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager createChatWithName:name group:CENChatGroup.custom private:YES autoConnect:NO metaData:nil];
    
    XCTAssertNotEqual(chat1, chat2);
    XCTAssertEqualObjects(chat1.name, chat2.name);
    XCTAssertNotEqualObjects(chat1.channel, chat2.channel);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
}

- (void)testCreateChatWithName_ShouldCreateGlobalChat_WhenPassedNameAsProvidedForChatEngineConfiguration {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    NSString *expectedGroup = CENChatGroup.system;
    
    [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    
    XCTAssertNotNil(self.manager.global);
    XCTAssertEqualObjects(self.manager.global.name, name);
    XCTAssertNotEqualObjects(self.manager.global.group, expectedGroup);
}


#pragma mark - Tests :: chatWithName

- (void)testChatWithName_ShouldReturnCreatedChat_WhenEarlierCreatedWithSameParameters {
    
    NSString *name = @"TestChat4";
    CENChat *chat1 = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    
    CENChat *chat2 = [self.manager chatWithName:name private:NO];
    
    XCTAssertNotNil(chat2);
    XCTAssertEqualObjects(chat2.name, chat1.name);
    XCTAssertEqualObjects(chat2.channel, chat1.channel);
}

- (void)testChatWithName_ShouldReturnNil_WhenDifferentSetOfParametersUsed {
    
    NSString *name = @"TestChat5";
    [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager chatWithName:name private:YES];
    
    XCTAssertNil(chat2);
}


#pragma mark - Tests :: connectChats

- (void)testConnectChats_ShouldWakeAllSleepingChats_WhenCalled {
    
    self.mockedObjects = YES;
    NSString *globalName = self.client.currentConfiguration.globalChannel;
    NSString *name = @"TestChat6";
    CENChat *globalChat = [self.manager createChatWithName:globalName group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    CENChat *chat = [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSUInteger expectedWakeCount = self.manager.chats.count;
    __block NSUInteger currentWakeCount = 0;
    
    id globalChatPartialMock = [self partialMockForObject:globalChat];
    id chatPartialMock = [self partialMockForObject:chat];
    void(^wakeMockBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        currentWakeCount++;
        
        if (currentWakeCount == expectedWakeCount) {
            dispatch_semaphore_signal(semaphore);
        }
    };
    OCMStub([(CENChat *)globalChatPartialMock wake]).andDo(wakeMockBlock);
    OCMStub([(CENChat *)chatPartialMock wake]).andDo(wakeMockBlock);
    
    [self.manager connectChats];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertEqual(currentWakeCount, expectedWakeCount);
}


#pragma mark - Tests :: disconnectChats

- (void)testDisconnectChats_ShouldPutToSleepAllConnectedChats_WhenCalled {
    
    self.mockedObjects = YES;
    NSString *globalName = self.client.currentConfiguration.globalChannel;
    NSString *name = @"TestChat6";
    CENChat *globalChat = [self.manager createChatWithName:globalName group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    CENChat *chat = [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSUInteger expectedSleepCount = self.manager.chats.count;
    __block NSUInteger currentSleepCount = 0;
    
    id globalChatPartialMock = [self partialMockForObject:globalChat];
    id chatPartialMock = [self partialMockForObject:chat];
    void(^sleepMockBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        currentSleepCount++;
        
        if (currentSleepCount == expectedSleepCount) {
            dispatch_semaphore_signal(semaphore);
        }
    };
    OCMStub([(CENChat *)globalChatPartialMock sleep]).andDo(sleepMockBlock);
    OCMStub([(CENChat *)chatPartialMock sleep]).andDo(sleepMockBlock);
    
    [self.manager disconnectChats];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertEqual(currentSleepCount, expectedSleepCount);
}


#pragma mark - Tests :: removeChat

- (void)testRemoveChat_ShouldRemovePreviouslyCreatedChat_WhenNonGlobalChatPassed {
    
    NSUInteger expectedChatsCountBefore = 1;
    NSUInteger expectedChatsCountAfter = 0;
    NSString *name = @"TestChat9";
    CENChat *chat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertEqual(self.manager.chats.count, expectedChatsCountBefore);
    [self.manager removeChat:chat];
    XCTAssertEqual(self.manager.chats.count, expectedChatsCountAfter);
}

- (void)testRemoveChat_ShouldNotRemoveGlobalChat_WhenGlobalChatPassed {
    
    NSUInteger expectedChatsCount = 0;
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *chat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
    [self.manager removeChat:chat];
    XCTAssertNotNil(self.manager.global);
}


#pragma mark - Tests :: handleChatMessage

- (void)testHandleChatMessage_ShouldEmitEvent {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *expectedChat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    NSString *expectedEvent = @"test-event";
    NSDictionary *expectedPayload = @{ CENEventData.event: expectedEvent };
    
    OCMExpect([(id)self.clientMock triggerEventLocallyFrom:expectedChat event:expectedEvent withParameters:@[expectedPayload] completion:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat message:expectedPayload];
    
    OCMVerifyAll((id)self.clientMock);
}

- (void)testHandleChatMessage_ShouldNotEmitEvent_WhenNilChatPassed {
    
    NSString *expectedEvent = @"test-event";
    NSDictionary *expectedPayload = @{ CENEventData.event: expectedEvent };
    CENChat *expectedChat = nil;
    
    OCMExpect([[(id)self.clientMock reject] triggerEventLocallyFrom:[OCMArg any] event:[OCMArg any] withParameters:[OCMArg any] completion:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat message:expectedPayload];
    
    OCMVerifyAll((id)self.clientMock);
}


#pragma mark - Tests :: handleChatPresenCENEvent

- (void)testHandleChatPresenCENEvent_ShouldHandleUserJoin {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *expectedChat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"join"];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    
    OCMExpect([chatPartialMock handleRemoteUsersJoin:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(chatPartialMock);
}

- (void)testHandleChatPresenCENEvent_ShouldHandleUserLeave {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *expectedChat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"leave"];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    
    OCMExpect([chatPartialMock handleRemoteUsersLeave:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(chatPartialMock);
}

- (void)testHandleChatPresenCENEvent_ShouldHandleUserTimeout {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *expectedChat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"timeout"];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    
    OCMExpect([chatPartialMock handleRemoteUsersDisconnect:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(chatPartialMock);
}

- (void)testHandleChatPresenCENEvent_ShouldHandleUserStateChange {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *expectedChat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"state-change"];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    
    OCMExpect([chatPartialMock handleRemoteUsersStateChange:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(chatPartialMock);
}

- (void)testHandleChatPresenCENEvent_ShouldHandleUserInterval {
    
    NSString *name = self.client.currentConfiguration.globalChannel;
    CENChat *expectedChat = [self.manager createChatWithName:name group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"interval"];
    id chatPartialMock = [self partialMockForObject:expectedChat];
    
    OCMExpect([chatPartialMock handleRemoteUsersJoin:[OCMArg any]]);
    OCMExpect([chatPartialMock handleRemoteUsersLeave:[OCMArg any]]);
    OCMExpect([chatPartialMock handleRemoteUsersDisconnect:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(chatPartialMock);
}

- (void)testHandleChatPresenCENEvent_ShouldNotHandleUserInterval_WhenNilChatPassed {
    
    id usersManagerPartialMock = [self partialMockForObject:self.client.usersManager];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"interval"];
    CENChat *expectedChat = nil;
    
    OCMExpect([[usersManagerPartialMock reject] createUsersWithUUID:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(usersManagerPartialMock);
}


#pragma mark - Tests :: destroy

- (void)testDestroy_ShouldReleaseAllUsedResources_WhenCalled {
    
    NSUInteger expectedChatsCountBefore = 2;
    NSUInteger expectedChatsCountAfter = 0;
    NSString *globalName = self.client.currentConfiguration.globalChannel;
    NSString *name = @"TestChat10";
    [self.manager createChatWithName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    [self.manager createChatWithName:name group:CENChatGroup.custom private:YES autoConnect:NO metaData:nil];
    [self.manager createChatWithName:globalName group:CENChatGroup.custom private:YES autoConnect:NO metaData:nil];
    
    XCTAssertEqual(self.manager.chats.count, expectedChatsCountBefore);
    XCTAssertNotNil(self.manager.global);
    [self.manager destroy];
    XCTAssertNil(self.manager.global);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCountAfter);
    XCTAssertNil(self.manager.chats);
}


#pragma mark - Misc

- (PNPresenceEventResult *)presenceEventWithType:(NSString *)eventType {
    
    NSMutableDictionary *presenceData = [NSMutableDictionary dictionaryWithDictionary:@{ @"timetoken": @123456, @"occupancy": @1 }];
    if ([eventType isEqualToString:@"join"] || [eventType isEqualToString:@"leave"] || [eventType isEqualToString:@"timeout"] ||
        [eventType isEqualToString:@"state-change"]) {
        presenceData[@"uuid"] = @"User1";
        if ([eventType isEqualToString:@"join"] || [eventType isEqualToString:@"state-change"]) {
            presenceData[@"state"] = @{ @"user1": @"state" };
        }
    } else {
        presenceData[@"join"] = @[@"User1"];
        presenceData[@"leave"] = @[@"User2"];
        presenceData[@"timeout"] = @[@"User3"];
    }
    
    NSDictionary *serviceData = @{ @"presenceEvent": eventType, @"presence": presenceData };
    
    PNPresenceEventResult *result = [PNPresenceEventResult objectForOperation:PNSubscribeOperation completedWithTask:nil
                                                                processedData:serviceData processingError:nil];
    
    return result;
    
}

#pragma mark -


@end
