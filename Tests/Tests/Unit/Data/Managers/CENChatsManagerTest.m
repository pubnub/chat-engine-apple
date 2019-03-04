/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatsManagerTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENChatsManager *manager;


#pragma mark - Misc

- (PNPresenceEventResult *)presenceEventWithType:(NSString *)eventType;

#pragma mark -


@end



@implementation CENChatsManagerTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.manager = [CENChatsManager managerForChatEngine:self.client];

    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client chatsManager]).andReturn(self.manager);
}

- (void)tearDown {
    
    self.manager = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldThrowException_WhenInstanceCreatedWithNew {
    
    XCTAssertThrowsSpecificNamed([CENChatsManager new], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: createChatWithName

- (void)testCreateChatWithName_ShouldCreateChatWithRandomName_WhenNilPassed {
    
    NSString *expectedGroup = CENChatGroup.custom;
    NSUInteger expectedChatsCount = 1;
    
    
    CENChat *chat = [self.manager createGlobalChat:NO withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertNotNil(chat);
    XCTAssertNotNil(chat.name);
    XCTAssertNotNil(chat.channel);
    XCTAssertEqualObjects(chat.group, expectedGroup);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
}

- (void)testCreateChatWithName_ShouldCreateAndConnectChatWithRandomName_WhenNilPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id classMock = [self mockForObject:[CENChat class]];
    OCMStub([self createPrivateChat:NO invocationForClassMock:classMock]).andReturn(chatMock);
    
    id recorded = OCMExpect([chatMock connectChat]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager createGlobalChat:NO withName:nil group:nil private:NO autoConnect:YES metaData:nil];
    }];
}

- (void)testCreateChatWithName_ShouldCreateChatWithSpecificName_WhenAllRequiredDataPassed {
    
    NSString *expectedName = @"TestChat1";
    BOOL expectedIsPrivate = YES;
    
    
    CENChat *chat = [self.manager createGlobalChat:NO withName:expectedName group:nil private:expectedIsPrivate autoConnect:NO
                                          metaData:nil];
    
    XCTAssertEqualObjects(chat.name, expectedName);
    XCTAssertEqual(chat.isPrivate, expectedIsPrivate);
    XCTAssertEqual(self.manager.chats[chat.channel], chat);
}

- (void)testCreateChatWithName_ShouldReturnExistingChat_WhenRequestedToCreateChatWithSameParameters {
    
    NSUInteger expectedChatsCount = 1;
    NSString *name = @"TestChat2";
    __block CENChat *chat2 = nil;
    
    
    CENChat *chat1 = [self.manager createGlobalChat:NO withName:name group:nil private:NO autoConnect:NO metaData:nil];
    
    id classMock = [self mockForObject:[CENChat class]];
    id recorded = OCMExpect([self createPrivateChat:NO invocationForClassMock:[classMock reject]]);
    [self waitForObject:classMock recordedInvocationNotCall:recorded afterBlock:^{
        chat2 = [self.manager createGlobalChat:NO withName:name group:CENChatGroup.custom private:NO autoConnect:NO metaData:nil];
    }];
    
    
    XCTAssertEqual(chat1, chat2);
    XCTAssertEqualObjects(chat1.name, chat2.name);
    XCTAssertEqualObjects(chat1.channel, chat2.channel);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
}

- (void)testCreateChatWithName_ShouldReturnDifferentChat_WhenOneOfParametersNotTheSame {
    
    NSUInteger expectedChatsCount = 2;
    NSString *name = @"TestChat3";
    
    
    CENChat *chat1 = [self.manager createGlobalChat:NO withName:name group:nil private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager createGlobalChat:NO withName:name group:nil private:YES autoConnect:NO metaData:nil];
    
    XCTAssertNotEqual(chat1, chat2);
    XCTAssertEqualObjects(chat1.name, chat2.name);
    XCTAssertNotEqualObjects(chat1.channel, chat2.channel);
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
}

- (void)testCreateChatWithName_ShouldCreateGlobalChat {
    
    NSString *expectedName = [NSUUID UUID].UUIDString;
    NSString *expectedGroup = CENChatGroup.system;

    
    [self.manager createGlobalChat:YES withName:expectedName group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertNotNil(self.manager.global);
    XCTAssertEqualObjects(self.manager.global.name, expectedName);
    XCTAssertNotEqualObjects(self.manager.global.group, expectedGroup);
}


#pragma mark - Tests :: chatWithName

- (void)testChatWithName_ShouldReturnCreatedChat_WhenEarlierCreatedWithSameParameters {
    
    NSString *name = @"TestChat4";
    
    
    CENChat *chat1 = [self.manager createGlobalChat:NO withName:name group:nil private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager chatWithName:name private:NO];
    
    XCTAssertNotNil(chat2);
    XCTAssertEqualObjects(chat2.name, chat1.name);
    XCTAssertEqualObjects(chat2.channel, chat1.channel);
}

- (void)testChatWithName_ShouldReturnGlobal_WhenEarlierCreatedWithSameParameters {
    
    NSString *name = @"TestChat4";
    
    
    [self.manager createGlobalChat:YES withName:name group:nil private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager chatWithName:name private:NO];
    
    XCTAssertNotNil(chat2);
    XCTAssertEqualObjects(chat2.name, self.client.global.name);
    XCTAssertEqualObjects(chat2.channel, self.client.global.channel);
}

- (void)testChatWithName_ShouldReturnNil_WhenDifferentSetOfParametersUsed {
    
    NSString *name = @"TestChat5";
    
    
    [self.manager createGlobalChat:NO withName:name group:nil private:NO autoConnect:NO metaData:nil];
    CENChat *chat2 = [self.manager chatWithName:name private:YES];
    
    XCTAssertNil(chat2);
}


#pragma mark - Tests :: connectChats

- (void)testConnectChats_ShouldWakeGlobalChat {
    
    [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    id chatMock = [self mockForObject:self.client.global];
    OCMStub([chatMock asleep]).andReturn(YES);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        OCMStub([self.client handshakeChatAccess:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
            CENChat *awakenChat = [self objectForInvocation:invocation argumentAtIndex:1];
            
            if ([awakenChat.channel isEqualToString:self.client.global.channel]) {
                handler();
            }
        });
    } afterBlock:^{
        [self.manager connectChats];
    }];
}

- (void)testConnectChats_ShouldWakeNonGlobalChats {
    
    CENChat *chat = [self.manager createGlobalChat:NO withName:nil group:nil private:NO autoConnect:NO metaData:nil];

    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock asleep]).andReturn(YES);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        OCMStub([self.client handshakeChatAccess:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
            CENChat *awakenChat = [self objectForInvocation:invocation argumentAtIndex:1];
            
            if ([awakenChat.channel isEqualToString:chat.channel]) {
                handler();
            }
        });
    } afterBlock:^{
        [self.manager connectChats];
    }];
}


#pragma mark - Tests :: resetConnection

- (void)testResetConnection_ShouldResetHasConnectedFlag {
    
    [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    
    id chatMock = [self mockForObject:self.client.global];
    id recorded = OCMExpect([chatMock resetConnection]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager resetChatsConnection];
    }];
}


#pragma mark - Tests :: disconnectChats

- (void)testDisconnectChats_ShouldPutToSleepGlobalConnectedChat_WhenCalled {
    
    [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    
    id chatMock = [self mockForObject:self.client.global];
    id recorded = OCMExpect([chatMock sleep]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager disconnectChats];
    }];
}

- (void)testDisconnectChats_ShouldPutToSleepNonGlobalConnectedChat_WhenCalled {
    
    CENChat *chat = [self.manager createGlobalChat:NO withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock sleep]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager disconnectChats];
    }];
}


#pragma mark - Tests :: removeChat

- (void)testRemoveChat_ShouldRemovePreviouslyCreatedChat_WhenNonGlobalChatPassed {
    
    NSUInteger expectedChatsCountBefore = 1;
    NSUInteger expectedChatsCountAfter = 0;
    
    
    CENChat *chat = [self.manager createGlobalChat:NO withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertEqual(self.manager.chats.count, expectedChatsCountBefore);
    [self.manager removeChat:chat];
    XCTAssertEqual(self.manager.chats.count, expectedChatsCountAfter);
}

- (void)testRemoveChat_ShouldNotRemoveGlobalChat_WhenGlobalChatPassed {
    
    NSUInteger expectedChatsCount = 0;
    
    
    CENChat *chat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    
    XCTAssertEqual(self.manager.chats.count, expectedChatsCount);
    [self.manager removeChat:chat];
    XCTAssertNotNil(self.manager.global);
}


#pragma mark - Tests :: handleChatMessage

- (void)testHandleChatMessage_ShouldEmitEvent {
    
    CENChat *expectedChat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    NSString *expectedEvent = @"test-event";
    NSDictionary *expectedPayload = @{ CENEventData.event: expectedEvent };
    
    OCMExpect([(id)self.client triggerEventLocallyFrom:expectedChat event:expectedEvent withParameters:@[expectedPayload]
                                            completion:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat message:expectedPayload];
    
    OCMVerifyAll((id)self.client);
}

- (void)testHandleChatMessage_ShouldNotEmitEvent_WhenNilChatPassed {
    
    NSString *expectedEvent = @"test-event";
    NSDictionary *expectedPayload = @{ CENEventData.event: expectedEvent };
    CENChat *expectedChat = nil;
    
    OCMExpect([[(id)self.client reject] triggerEventLocallyFrom:[OCMArg any] event:[OCMArg any] withParameters:[OCMArg any]
                                                     completion:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat message:expectedPayload];
    
    OCMVerifyAll((id)self.client);
}


#pragma mark - Tests :: handleChatPresenceEvent

- (void)testHandleChatPresenceEvent_ShouldHandleUserJoin {
    
    CENChat *expectedChat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"join"];
    
    
    id chatMock = [self mockForObject:expectedChat];
    id recorded = OCMExpect([chatMock handleRemoteUsersJoin:[OCMArg any] withStates:[OCMArg any] onStateChange:NO]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager handleChat:expectedChat presenceEvent:presence.data];
    }];
}

- (void)testHandleChatPresenceEvent_ShouldHandleUserLeave {
    
    CENChat *expectedChat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"leave"];
    
    
    id chatMock = [self mockForObject:expectedChat];
    id recorded = OCMExpect([chatMock handleRemoteUsersLeave:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager handleChat:expectedChat presenceEvent:presence.data];
    }];
}

- (void)testHandleChatPresenceEvent_ShouldHandleUserTimeout {
    
    CENChat *expectedChat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"timeout"];
    
    
    id chatMock = [self mockForObject:expectedChat];
    id recorded = OCMExpect([chatMock handleRemoteUsersDisconnect:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager handleChat:expectedChat presenceEvent:presence.data];
    }];
}

- (void)testHandleChatPresenceEvent_ShouldHandleUserStateChange {
    
    CENChat *expectedChat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"state-change"];
    
    
    id chatMock = [self mockForObject:expectedChat];
    OCMExpect([chatMock handleRemoteUsersJoin:[OCMArg any] withStates:[OCMArg any] onStateChange:YES]);
    OCMExpect([chatMock handleRemoteUsers:[OCMArg any] stateChange:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerify(chatMock);
}

- (void)testHandleChatPresenceEvent_ShouldHandleUserInterval {
    
    CENChat *expectedChat = [self.manager createGlobalChat:YES withName:nil group:nil private:NO autoConnect:NO metaData:nil];
    PNPresenceEventResult *presence = [self presenceEventWithType:@"interval"];
    
    
    id chatMock = [self mockForObject:expectedChat];
    OCMExpect([chatMock handleRemoteUsersJoin:[OCMArg any] withStates:[OCMArg any] onStateChange:NO]);
    OCMExpect([chatMock handleRemoteUsersLeave:[OCMArg any]]);
    OCMExpect([chatMock handleRemoteUsersDisconnect:[OCMArg any]]);
    
    [self.manager handleChat:expectedChat presenceEvent:presence.data];
    
    OCMVerifyAll(chatMock);
}

- (void)testHandleChatPresenceEvent_ShouldNotHandleUserInterval_WhenNilChatPassed {
    
    PNPresenceEventResult *presence = [self presenceEventWithType:@"interval"];
    CENUsersManager *usersManager = [CENUsersManager managerForChatEngine:self.client];
    CENChat *expectedChat = nil;
    
    
    OCMStub([self.client usersManager]).andReturn(usersManager);
    
    id managerMock = [self mockForObject:usersManager];
    id recorded = OCMExpect([[managerMock reject] createUsersWithUUID:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.manager handleChat:expectedChat presenceEvent:presence.data];
    }];
}


#pragma mark - Tests :: destroy

- (void)testDestroy_ShouldReleaseAllUsedResources_WhenCalled {
    
    NSUInteger expectedChatsCountBefore = 2;
    NSUInteger expectedChatsCountAfter = 0;
    
    
    [self.manager createGlobalChat:NO withName:@"Chat1" group:nil private:NO autoConnect:NO metaData:nil];
    [self.manager createGlobalChat:NO withName:@"Chat2" group:nil private:YES autoConnect:NO metaData:nil];
    [self.manager createGlobalChat:YES withName:nil group:nil private:YES autoConnect:NO metaData:nil];
    
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
