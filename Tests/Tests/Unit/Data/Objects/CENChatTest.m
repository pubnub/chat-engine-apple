/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENStateRestoreAugmentationPlugin.h>
#import <CENChatEngine/CENSenderAugmentationPlugin.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+EventEmitter.h>
#import <CENChatEngine/CENChatEngine+UserPrivate.h>
#import <CENChatEngine/CENChatAugmentationPlugin.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENChat+BuilderInterface.h>
#import <CENChatEngine/CENEventEmitter+Private.h>
#import <CENChatEngine/CENChatEngine+Publish.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/CENStructures.h>
#import <PubNub/PNResult+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENChatTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *privateChatMeta;
@property (nonatomic, strong) NSDictionary *publicChatMeta;
@property (nonatomic, strong) NSString *systemChatName;
@property (nonatomic, strong) NSString *chatNamespace;
@property (nonatomic, strong) NSString *chatName;


#pragma mark - Misc

- (CENChat *)privateCustomChat:(BOOL)isPrivate withName:(NSString *)name meta:(NSDictionary *)meta;
- (CENChat *)privateSystemChat:(BOOL)isPrivate withName:(NSString *)name meta:(NSDictionary *)meta;
- (CENChat *)privateChat:(BOOL)isPrivate withName:(NSString *)name group:(NSString *)group
                    meta:(NSDictionary *)meta;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENChatTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return [name rangeOfString:@"ShouldThrow"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    self.privateChatMeta = @{ @"chat": @"private" };
    self.publicChatMeta = @{ @"chat": @"public" };
    self.systemChatName = @"system-chat";
    self.chatNamespace = @"test-group";
    self.chatName = @"test-channel";
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreatePrivate_WhenAllRequiredDataPassed {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    
    
    XCTAssertNotNil(chat);
    XCTAssertTrue(chat.isPrivate);
    XCTAssertEqualObjects(chat.name, self.chatName);
    XCTAssertFalse(chat.connected);
    XCTAssertEqualObjects(chat.group, CENChatGroup.custom);
    XCTAssertNotNil(chat.users);
    XCTAssertEqual(chat.users.count, 0);
}

- (void)testConstructor_ShouldCreatePublic_WhenAllRequiredDataPassed {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    
    
    XCTAssertNotNil(chat);
    XCTAssertFalse(chat.isPrivate);
    XCTAssertEqualObjects(chat.name, self.chatName);
    XCTAssertFalse(chat.connected);
    XCTAssertEqualObjects(chat.group, CENChatGroup.custom);
    XCTAssertNotNil(chat.users);
    XCTAssertEqual(chat.users.count, 0);
}

- (void)testConstructor_ShouldCreateWithEmptyMeta_WhenNilMetaPassed {
    
    NSDictionary *meta = nil;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:meta];
    
    
    XCTAssertNotNil([chat dictionaryRepresentation][CENChatData.meta]);
    XCTAssertEqual(((NSDictionary *)[chat dictionaryRepresentation][CENChatData.meta]).count, 0);
}

- (void)testConstructor_ShouldNotCreate_WhenNilNamePassed {
    
    NSString *name = nil;
    CENChat *chat = [self privateCustomChat:NO withName:name meta:@{}];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyNamePassed {
    
    NSString *name = @"";
    CENChat *chat = [self privateCustomChat:NO withName:name meta:@{}];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringNamePassed {
    
    NSString *name = (id)@2010;
    CENChat *chat = [self privateCustomChat:NO withName:name meta:@{}];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenNilNamespacePassed {
    
    NSString *nspace = nil;
    CENChat *chat = [CENChat chatWithName:@"test" namespace:nspace group:CENChatGroup.custom
                                  private:NO metaData:@{} chatEngine:self.client];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyNamespacePassed {
    
    NSString *nspace = @"";
    CENChat *chat = [CENChat chatWithName:@"test" namespace:nspace group:CENChatGroup.custom
                                  private:NO metaData:@{} chatEngine:self.client];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringNamespacePassed {
    
    NSString *nspace = (id)@2010;
    CENChat *chat = [CENChat chatWithName:@"test" namespace:nspace group:CENChatGroup.custom
                                  private:NO metaData:@{} chatEngine:self.client];
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenNilGroupPassed {
    
    NSString *group = nil;
    CENChat *chat = [self privateChat:NO withName:@"test" group:group meta:@{}];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenEmptyGroupPassed {
    
    NSString *group = @"";
    CENChat *chat = [self publicChatFromGroup:group withChatEngine:self.client];
    
 
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenNonNSStringGroupPassed {
    
    NSString *group = (id)@2010;
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:group
                                  private:NO metaData:@{} chatEngine:self.client];
 
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldNotCreate_WhenUnknownGroupPassed {
    
    NSString *group = @"PubNub";
 
    XCTAssertNil([self publicChatFromGroup:group withChatEngine:self.client]);
}

- (void)testConstructor_ShouldNotCreate_WhenNonChatEngineInstancePassed {
    
    CENChatEngine *client = (id)@2010;
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom
                                  private:NO metaData:@{} chatEngine:client];
    
    
    XCTAssertNil(chat);
}

- (void)testConstructor_ShouldListenSystemLeave {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:@{}];
    
    
    XCTAssertTrue([chat.eventNames containsObject:@"$.system.leave"]);
}

- (void)testConstructor_ShouldRegisterAugmentationPlugins {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:@{}];
    
    
    XCTAssertTrue(chat.plugin([CENChatAugmentationPlugin class]).exists());
    XCTAssertTrue(chat.plugin([CENSenderAugmentationPlugin class]).exists());
}


#pragma mark - Tests :: objectType

- (void)testObjectType_ShouldBeChat {
    
    XCTAssertEqualObjects([CENChat objectType], CENObjectType.chat);
}


#pragma mark - Tests :: defaultStateChat

- (void)testDefaultStateChat_ShouldReturnSelf {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:@{}];
    
    
    XCTAssertEqualObjects([chat defaultStateChat], chat);
}


#pragma mark - Tests :: identifier

- (void)testIdentifier_ShouldBeEqualToChatChannel {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:@{}];
    
    XCTAssertEqualObjects(chat.identifier, chat.channel);
}


#pragma mark - Tests :: isPrivate

- (void)testIsPrivate_ShouldReturnTrue_WhenPrivateChatChannelPassed {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:@{}];
    
    
    XCTAssertTrue([CENChat isPrivate:chat.channel]);
}

- (void)testIsPrivate_ShouldReturnFalse_WhenPublicChatChannelPassed {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:@{}];
    
    
    XCTAssertFalse([CENChat isPrivate:chat.channel]);
}

- (void)testIsPrivate_ShouldReturnFalse_WhenMalformedChannelNamePassed {
    
    XCTAssertFalse([CENChat isPrivate:@"test-channel"]);
}


#pragma mark - Tests :: objectify

- (void)testDictionaryRepresentation_ShouldCreatePrivateChatRepresentation {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *representation = @{
        CENChatData.channel: [CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:YES],
        CENChatData.group: CENChatGroup.custom,
        CENChatData.private: @(YES),
        CENChatData.meta: self.privateChatMeta
    };
 
    
    XCTAssertEqualObjects(chat.objectify(), representation);
}

- (void)testDictionaryRepresentation_ShouldCreatePublicChatRepresentation {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    NSDictionary *representation = @{
        CENChatData.channel: [CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:NO],
        CENChatData.group: CENChatGroup.custom,
        CENChatData.private: @(NO),
        CENChatData.meta: self.publicChatMeta
    };
    
 
    XCTAssertEqualObjects(chat.objectify(), representation);
}


#pragma mark - Tests :: internalNameFor

- (void)testInternalNameFor_ShouldCreateChannel_WhenNameForPrivateChatPassed {
    
    NSString *expectedChannel = [@[ self.chatNamespace, @"chat", @"private.", self.chatName ] componentsJoinedByString:@"#"];
    
    
    XCTAssertEqualObjects([CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:YES], expectedChannel);
}

- (void)testInternalNameFor_ShouldCreateChannel_WhenNameForPublicChatPassed {
    
    NSString *expectedChannel = [@[ self.chatNamespace, @"chat", @"public.", self.chatName ] componentsJoinedByString:@"#"];
    
    
    XCTAssertEqualObjects([CENChat internalNameFor:self.chatName inNamespace:self.chatNamespace private:NO], expectedChannel);
}

- (void)testInternalNameFor_ShouldReturnChannelname_WhenChannelNameIncludeNamespace {
    
    NSString *expectedChannel = [@[ self.chatNamespace, @"chat", @"private.", self.chatName ] componentsJoinedByString:@"#"];
    
    
    XCTAssertEqualObjects([CENChat internalNameFor:expectedChannel inNamespace:self.chatNamespace private:NO], expectedChannel);
}


#pragma mark - Tests :: sleep

- (void)testSleep_ShouldSleep_WhenConnectedAndNotAsleep {
    
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    id recorded = OCMExpect([chatMock emitEventLocally:@"$.disconnected" withParameters:@[]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [chat sleep];
    }];
}

- (void)testSleep_ShouldNotSleep_WhenNotConnected {
    
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(NO);
    
    id recorded = OCMExpect([[chatMock reject] emitEventLocally:@"$.disconnected" withParameters:@[]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        XCTAssertNoThrow([chat sleep]);
    }];
}


#pragma mark - Tests :: wake

- (void)testWake_ShouldWake_WhenAsleepAndNoHandshakeError {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    

    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    
    OCMStub([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
        
        block();
        OCMStub([(CENChat *)chatMock connected]).andReturn(NO);
    });
    
    id recorded = OCMStub([chatMock emitEventLocally:@"$.connected" withParameters:@[]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [chat wake];
    }];
}

- (void)testWake_ShouldWake_WhenAsleepAndSystemGroup {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChat:YES withName:[NSUUID UUID].UUIDString group:CENChatGroup.system meta:nil];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    OCMStub([(CENChat *)chatMock hasConnected]).andReturn(YES);
    
    id recorded = OCMStub([chatMock emitEventLocally:@"$.connected" withParameters:@[]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        [chat wake];
    }];
}

- (void)testWake_ShouldRefreshParticipantsList_WhenOneSecondDelayWillComplete {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    
    
    OCMStub([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        CENChat *chatFromInvocation = [self objectForInvocation:invocation argumentAtIndex:1];
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(chatFromInvocation, chat);
        block();
    });
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    
    id recorded = OCMExpect([chatMock fetchParticipants]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [chat wake];
    }];
}

- (void)testWake_ShouldNotRefreshParticipantsList_WhenChatDisconnectsDuringDelay {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    
    OCMStub([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        CENChat *chatFromInvocation = [self objectForInvocation:invocation argumentAtIndex:1];
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(chatFromInvocation, chat);
        OCMStub([(CENChat *)chatMock connected]).andReturn(NO);
        block();
    });
    
    id recorded = OCMExpect([(CENChat *)[chatMock reject] fetchParticipants]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:2.f afterBlock:^{
        [chat wake];
    }];
}

- (void)testWake_ShouldNotRefreshParticipantsList_WhenSystemChatPassed {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateSystemChat:YES withName:self.chatName meta:@{}];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    
    OCMStub([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        CENChat *chatFromInvocation = [self objectForInvocation:invocation argumentAtIndex:1];
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
        
        XCTAssertEqualObjects(chatFromInvocation, chat);
        block();
    });
    
    id recorded = OCMExpect([(CENChat *)[chatMock reject] fetchParticipants]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:2.f afterBlock:^{
        [chat wake];
    }];
}

- (void)testWake_ShouldNotWake_WhenAsleepAndHandshakeError {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    
    OCMStub([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]).andDo(nil);

    id recorded = OCMExpect([[chatMock reject] emitEventLocally:@"$.connected" withParameters:@[]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:2.f afterBlock:^{
        XCTAssertNoThrow([chat wake]);
    }];
}

- (void)testWake_ShouldNotWake_WhenNotAsleep {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(NO);
    
    id recorded = OCMExpect([[(id)self.client reject] handshakeChatAccess:chat withCompletion:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:2.f afterBlock:^{
        XCTAssertNoThrow([chatMock wake]);
    }];
}

- (void)testWake_ShouldNotHandshake_WhenCalledOnSystemChat {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateChat:YES withName:[NSUUID UUID].UUIDString group:CENChatGroup.system meta:nil];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock asleep]).andReturn(YES);
    OCMStub([(CENChat *)chatMock hasConnected]).andReturn(YES);
    
    id recorded = OCMExpect([[(id)self.client reject] handshakeChatAccess:chat withCompletion:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded withinInterval:2.f afterBlock:^{
        XCTAssertNoThrow([chatMock wake]);
    }];
}


#pragma mark - Tests :: setState

- (void)testSetState_ShouldUpdateChatState_WhenNSDictionaryStatePassed {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *expectedState = @{ @"some": @"value" };
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    id recorded = OCMExpect([self.client updateChatState:chat withData:expectedState completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.setState(expectedState);
    }];
}

- (void)testSetState_ShouldNotUpdateChatState_WhenEmptyNSDictionaryStatePassed {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    id falseExpect = [(id)self.client reject];
    id recorded = OCMExpect([falseExpect updateChatState:[OCMArg any] withData:[OCMArg any] completion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        chat.setState(@{});
    }];
}

- (void)testSetState_ShouldThrow_WhenChatNotConnected {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *expectedState = @{ @"some": @"value" };
    
    
    XCTAssertThrowsSpecificNamed(chat.setState(expectedState), NSException, kCENErrorDomain);
}

- (void)testSetState_ShouldThrow_WhenFunctionReportedError {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *expectedState = @{ @"some": @"value" };
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    OCMStub([self.client updateChatState:chat withData:expectedState completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(NSError *) = [self objectForInvocation:invocation argumentAtIndex:3];
            handlerBlock([NSError errorWithDomain:@"TestError" code:1000 userInfo:nil]);
        });
    
    XCTAssertThrowsSpecificNamed(chat.setState(expectedState), NSException, @"TestError");
}


#pragma mark - Tests :: restoreState / restoreStateForChat

- (void)testRestoreState_ShouldRegisterUserStateResolverPlugin_WhenStateRestoreCalled {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    
    
    chat.restoreState(nil);
    
    XCTAssertTrue(chat.plugin([CENStateRestoreAugmentationPlugin class]).exists());
}

- (void)testRestoreState_ShouldUseSearchChatForStateRestore_WhenStateRestoreCalledWithNil {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    
    
    id chatMock = [self mockForObject:chat];
    OCMExpect([chatMock restoreStateForChat:nil]).andForwardToRealObject();
    OCMExpect([chatMock defaultStateChat]).andForwardToRealObject();
    XCTAssertEqualObjects([chat defaultStateChat], chat);
    
    chat.restoreState(nil);
    
    OCMVerifyAll(chatMock);
}

- (void)testRestoreState_ShouldUseCustomChatForStateRestore_WhenStateRestoreCalledWithChat {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    CENChat *targetChat = self.client.Chat().autoConnect(NO).create();
    
    
    id chatMock = [self mockForObject:chat];
    OCMExpect([chatMock restoreStateForChat:targetChat]).andForwardToRealObject();
    OCMExpect([[chatMock reject] defaultStateChat]).andForwardToRealObject();
    
    chat.restoreState(targetChat);
    
    OCMVerifyAll(chatMock);
}

- (void)testRestoreState_ShouldTryRestoreState_WhenStateRestoreCalledWithNil {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *event = @{
        CENEventData.sender: @"tester",
        CENEventData.chat: chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"message",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    
    
    id recorded = OCMExpect([self.client fetchUserState:[OCMArg any] forChat:chat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.restoreState(nil);
        [self.client triggerEventLocallyFrom:chat event:@"message", event, nil];
    }];
}

- (void)testRestoreState_ShouldTryRestoreState_WhenStateRestoreCalledCalledWithChat {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *event = @{
        CENEventData.sender: @"tester",
        CENEventData.chat: chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"message",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    CENChat *targetChat = self.client.Chat().autoConnect(NO).create();
    
    
    id recorded = OCMExpect([self.client fetchUserState:[OCMArg any] forChat:targetChat withCompletion:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.restoreState(targetChat);
        [self.client triggerEventLocallyFrom:chat event:@"message", event, nil];
    }];
}


#pragma mark - Tests :: handlePreseneEvent

- (void)testHandlePreseneEvent_ShouldEmitOnlineHere_WhenUsersListRefreshed {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    NSDictionary *expectedState = @{ @"test": @"value" };
    
    
    [user assignState:expectedState forChat:chat];
    [self object:chat shouldHandleEvent:@"$.online.here" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *userWithUpdate = emittedEvent.data;
            
            XCTAssertEqualObjects(userWithUpdate.uuid, expectedUserUUID);
            XCTAssertEqualObjects(userWithUpdate.state(chat), expectedState);
            
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersRefresh:@[user] withStates:@{ user.uuid: expectedState }];
    }];
}

- (void)testHandlePreseneEvent_ShouldNotEmitOnlineHereButEmitState_WhenRefreshedUsersListContainExisting {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    NSDictionary *expectedState = @{ @"test": @"value" };
    
    
    [self object:chat shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *userWithUpdate = emittedEvent.data;
            
            XCTAssertEqualObjects(userWithUpdate.state(chat), expectedState);
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsersRefresh:@[user] withStates:@{ user.uuid: expectedState }];
    }];
}

- (void)testHandlePreseneEvent_ShouldEmitOnlineJoin_WhenUserJoinToChat {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldHandleEvent:@"$.online.join" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *joinedUser = emittedEvent.data;
            
            XCTAssertEqualObjects(joinedUser.uuid, expectedUserUUID);
            
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
    }];
}

- (void)testHandlePreseneEvent_ShouldEmitOnlineHere_WhenUserJoinAfterTimeout {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldHandleEvent:@"$.online.here" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *joinedUser = emittedEvent.data;
            
            XCTAssertEqualObjects(joinedUser.uuid, expectedUserUUID);
            
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsersDisconnect:@[user]];
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
    }];
}

- (void)testHandlePreseneEvent_ShouldEmitOfflineDisconnect_WhenUserTimeoutAfterJoin {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldHandleEvent:@"$.offline.disconnect" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *disconnectedUser = emittedEvent.data;
            
            XCTAssertEqualObjects(disconnectedUser.uuid, expectedUserUUID);
            
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsersDisconnect:@[user]];
    }];
}

- (void)testHandlePreseneEvent_ShouldNotEmitOfflineDisconnect_WhenUnknownUserTimeout {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user1 = [CENUser userWithUUID:@"PubNub" state:@{} chatEngine:self.client];
    CENUser *user2 = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldNotHandleEvent:@"$.offline.disconnect" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user1] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsersDisconnect:@[user2]];
    }];
}

- (void)testHandlePreseneEvent_ShouldEmitOfflineLeave_WhenUserLeaveAfterJoin {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldHandleEvent:@"$.offline.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *leavedUser = emittedEvent.data;
            
            XCTAssertEqualObjects(leavedUser.uuid, expectedUserUUID);
            
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsersLeave:@[user]];
    }];
}

- (void)testHandlePreseneEvent_ShouldNotEmitOfflineLeave_WhenUnknownUserLeave {
    
    NSString *expectedUserUUID = @"test-user";
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user1 = [CENUser userWithUUID:expectedUserUUID state:@{} chatEngine:self.client];
    CENUser *user2 = [CENUser userWithUUID:@"PubNub" state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldNotHandleEvent:@"$.offline.leave" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user1] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsersLeave:@[user2]];
    }];
}

- (void)testHandlePreseneEvent_ShouldEmitState_WhenUsersStateDidChange {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            CENUser *userWithUpdate = emittedEvent.data;
            
            XCTAssertEqualObjects(userWithUpdate.uuid, user.uuid);
            
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{} onStateChange:NO];
        [chat handleRemoteUsers:@[user] stateChange:@{ user.uuid: @{ @"test": @"value" }}];
    }];
}

- (void)testHandlePreseneEvent_ShouldNotEmitState_WhenUsersStateNotChanged {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    
    
    [self object:chat shouldNotHandleEvent:@"$.state" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        [chat handleRemoteUsersJoin:@[user] withStates:@{ user.uuid: @{ @"test": @"value" }} onStateChange:NO];
        [chat handleRemoteUsers:@[user] stateChange:@{ user.uuid: @{ @"test": @"value" }}];
    }];
}

- (void)testHandlePreseneEvent_ShouldEmitDisconnectedAndLeft_WhenLocalUserLeaveChat {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    
    
    [self object:chat shouldHandleEvents:@[@"$.disconnected", @"$.left"] withinInterval:self.testCompletionDelay
    withHandlers:@[
        ^(dispatch_block_t handler) {
            return ^{
                handler();
            };
        },
        ^(dispatch_block_t handler) {
            return ^{
                handler();
            };
        }
    ] afterBlock:^{
        [chat handleLeave];
    }];
}

- (void)testHandlePreseneEvent_ShouldHandleRemoteDeviceLeave {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    NSDictionary *event = @{
        CENEventData.sender: user,
        CENEventData.chat: chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"$.system.leave",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock handleRemoteUsersLeave:@[user]]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [chat emitEventLocally:@"$.system.leave" withParameters:@[event]];
    }];
}


#pragma mark - Tests :: connect / connectChat

- (void)testConnect_ShouldEmitConnected_WhenHandshakeSuccessful {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateSystemChat:NO withName:self.chatName meta:@{}];
    
    
    OCMStub([self.client isReady]).andReturn(YES);
    OCMStub([self.client connectToChat:chat withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            void(^handlerBlock)(BOOL, id) = [self objectForInvocation:invocation argumentAtIndex:2];
            handlerBlock(NO, nil);
        });
    
    [self object:chat shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        chat.connect();
    }];
}

- (void)testConnect_ShouldThrow_WhenChatAlreadyConnected {
    
    CENChat *chat = [self privateSystemChat:NO withName:self.chatName meta:@{}];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([(CENChat *)chatMock connected]).andReturn(YES);
    
    [self object:chat shouldNotHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        XCTAssertThrowsSpecificNamed(chat.connect(), NSException, kCENErrorDomain);
    }];
}

- (void)testConnect_ShouldRefreshParticipantsList_WhenHandshakeSuccessful {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    
    
    OCMStub([self.client isReady]).andReturn(YES);
    OCMStub([self.client handshakeChatAccess:chat withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
        block();
    });
    
    id recorded = OCMExpect([self.client fetchParticipantsForChat:chat]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.connect();
    }];
}

#pragma mark - Tests :: update / updateMeta

- (void)testUpdate_ShouldPushUpdatedState {
    
    self.usesMockedObjects = YES;
    NSDictionary *metaForUpdate = @{ @"PubNub": @"Awesome!!!" };
    NSMutableDictionary *expectedMeta = [NSMutableDictionary dictionaryWithDictionary:self.publicChatMeta];
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    [expectedMeta addEntriesFromDictionary:metaForUpdate];
    
    
    id recorded = OCMStub([self.client pushUpdatedChatMeta:chat withRepresentation:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.update(expectedMeta);
    }];
    
    XCTAssertEqualObjects(chat.meta, expectedMeta);
}

- (void)testUpdate_ShouldNotPushUpdatedState_WhenStateUpdateIsEmpty {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    NSDictionary *metaForUpdate = @{};
    
    
    id recorded = OCMStub([self.client pushUpdatedChatMeta:chat withRepresentation:[OCMArg any]]);
    [self waitForObject:self.client recordedInvocationNotCall:recorded withinInterval:self.falseTestCompletionDelay afterBlock:^{
        chat.update(metaForUpdate);
    }];
}


#pragma mark - Tests :: updateMetaWithFetchedData

- (void)testUpdateMetaWithFetchedData_ShouldUseFetchedState {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    NSDictionary *metaForUpdate = @{ @"PubNub": @"Awesome!!!" };
    NSDictionary *fetchedData = @{
        @"found": @YES,
        CENEventData.chat: @{ @"meta": metaForUpdate }
    };
    
    
    [chat updateMetaWithFetchedData:fetchedData];
    
    XCTAssertEqualObjects(chat.meta, metaForUpdate);
}

- (void)testUpdateMetaWithFetchedData_ShouldPushLocalMeta_WhenStateNotFound {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    NSDictionary *representation = [chat dictionaryRepresentation];
    NSDictionary *fetchedData = @{ @"found": @NO };

    
    id recorded = OCMExpect([self.client pushUpdatedChatMeta:chat withRepresentation:representation]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [chat updateMetaWithFetchedData:fetchedData];
    }];
}

- (void)testUpdateMetaWithFetchedData_ShouldPushLocalMeta_WhenNilStatePassed {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    NSDictionary *representation = [chat dictionaryRepresentation];
    
    
    id recorded = OCMExpect([self.client pushUpdatedChatMeta:chat withRepresentation:representation]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [chat updateMetaWithFetchedData:nil];
    }];
}


#pragma mark - Tests :: invite / inviteUser

- (void)testInvite_ShouldInviteRemoteUser {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:@"chat-join-tester" state:@{} chatEngine:self.client];
    
    
    id recorded = OCMExpect([self.client inviteToChat:chat user:user]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.invite(user);
    }];
}


#pragma mark - Tests :: leave / leaveChat

- (void)testLeave_ShouldLeavePublicChat {

    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];

    
    OCMStub([self.client connectToChat:chat withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t handlerBlock = [self objectForInvocation:invocation argumentAtIndex:2];
            handlerBlock();
        });
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock emitEvent:@"$.system.leave" withData:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            NSDictionary *payload = [self objectForInvocation:invocation argumentAtIndex:2];
            
            NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionaryWithDictionary:payload];
            mutablePayload[CENEventData.sender] = user;
            [chat emitEventLocally:@"$.system.leave" withParameters:@[mutablePayload]];
        });
    
    [self object:chat shouldHandleEvent:@"$.connected" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            handler();
        };
    } afterBlock:^{
        chat.connect();
    }];
    
    id recorded = OCMExpect([self.client leaveChat:chat]);
    [self waitForObject:chatMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.leave();
    }];
}


#pragma mark - Tests :: search / searchEvent

- (void)testSearch_ShouldCreateSearchInstance {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *expectedSender = self.client.me;
    NSString *expectedEvent = @"test-event";
    NSInteger expectedLimit = 123;
    NSInteger expectedPages = 45;
    NSInteger expectedCount = 67;
    NSNumber *expectedStart = @1;
    NSNumber *expectedEnd = @2;
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock hasConnected]).andReturn(YES);
    
    CENSearch *search = chat.search().event(expectedEvent).sender(expectedSender).limit(expectedLimit).pages(expectedPages)
        .count(expectedCount).start(expectedStart).end(expectedEnd).create();
    
    XCTAssertNotNil(search);
    XCTAssertEqualObjects(search.event, expectedEvent);
    XCTAssertEqual(search.sender, expectedSender);
    XCTAssertEqual(search.limit, expectedLimit);
    XCTAssertEqual(search.pages, expectedPages);
    XCTAssertEqual(search.count, expectedCount);
    XCTAssertEqual([search.start compare:expectedStart], NSOrderedSame);
    XCTAssertEqual([search.end compare:expectedEnd], NSOrderedSame);
}

- (void)testSearch_ShouldThrow_WhenNotConnected {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    
    XCTAssertThrowsSpecificNamed(chat.search().event(@"test-event").create(), NSException, kCENErrorDomain);
}


#pragma mark - Tests :: emit / emitEvent

- (void)testEmit_ShouldPushEvent {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    NSDictionary *expectedPayload = @{ @"test": @"data" };
    NSString *expectedEventName = @"test-event";
    
    
    OCMStub([self.client me]).andReturn(user);
    OCMStub([self.client publishStorable:YES event:[OCMArg any] toChannel:[OCMArg any] withData:[OCMArg any]
                              completion:[OCMArg any]]).andDo(nil);
    
    id recorded = OCMExpect([self.client publishToChat:chat eventWithName:expectedEventName data:expectedPayload]);
    [self waitForObject:self.client recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        chat.emit(expectedEventName).data(expectedPayload).perform();
    }];
}


#pragma mark - Tests :: augmentation

- (void)testAugmentation_ShouldReplaceChatNameWithCENChatInstance {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    NSDictionary *event = @{
        CENEventData.sender: @"tester",
        CENEventData.chat: chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"message",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    
    [self object:chat shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.chat]);
            XCTAssertTrue([payload[CENEventData.chat] isKindOfClass:[CENChat class]]);
            XCTAssertEqualObjects(((CENChat *)payload[CENEventData.chat]).channel, chat.channel);
            
            handler();
        };
    } afterBlock:^{
        [self.client triggerEventLocallyFrom:chat event:@"message", event, nil];
    }];
}

- (void)testAugmentation_ShouldReplaceSenderUUIDWithCENUserInstance {
    
    self.usesMockedObjects = YES;
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    CENUser *user = [CENUser userWithUUID:@"test-user" state:@{} chatEngine:self.client];
    NSDictionary *event = @{
        CENEventData.sender: user.uuid,
        CENEventData.chat: chat.name,
        CENEventData.data: @{ @"message": @"Hello" },
        CENEventData.event: @"message",
        CENEventData.timetoken: @1234567890,
        CENEventData.eventID: [NSUUID UUID].UUIDString
    };
    
    [self object:chat shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.sender]);
            XCTAssertTrue([payload[CENEventData.sender] isKindOfClass:[CENUser class]]);
            XCTAssertEqualObjects(((CENUser *)payload[CENEventData.sender]).uuid, user.uuid);
            
            handler();
        };
    } afterBlock:^{
        [self.client triggerEventLocallyFrom:chat event:@"message", event, nil];
    }];
}


#pragma mark - Tests :: description

- (void)testDescription_ShouldProvidePublicChatInstanceDescription {
    
    CENChat *chat = [self privateCustomChat:NO withName:self.chatName meta:self.publicChatMeta];
    
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock asleep]).andReturn(YES);
    
    NSString *description = [chat description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"private: NO"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"asleep: YES"].location, NSNotFound);
}

- (void)testDescription_ShouldProvidePrivateChatInstanceDescription {
    
    CENChat *chat = [self privateCustomChat:YES withName:self.chatName meta:self.privateChatMeta];
    
    
    NSString *description = [chat description];
    
    XCTAssertNotNil(description);
    XCTAssertGreaterThan(description.length, 0);
    XCTAssertNotEqual([description rangeOfString:@"private: YES"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"asleep: NO"].location, NSNotFound);
}


#pragma mark - Misc

- (CENChat *)privateCustomChat:(BOOL)isPrivate withName:(NSString *)name meta:(NSDictionary *)meta {
    
    return [self privateChat:isPrivate withName:name group:CENChatGroup.custom meta:meta];
}

- (CENChat *)privateSystemChat:(BOOL)isPrivate withName:(NSString *)name meta:(NSDictionary *)meta {
    
    return [self privateChat:isPrivate withName:name group:CENChatGroup.system meta:meta];
}

- (CENChat *)privateChat:(BOOL)isPrivate withName:(NSString *)name group:(NSString *)group
                    meta:(NSDictionary *)meta {
    
    return [CENChat chatWithName:name namespace:self.chatNamespace group:group private:isPrivate
                        metaData:meta chatEngine:self.client];
}

#pragma mark -


@end
