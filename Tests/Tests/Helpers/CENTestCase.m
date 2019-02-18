/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <objc/runtime.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENChatEngine+Private.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <CENChatEngine/CENDefines.h>
#import <OCMock/OCMock.h>


#pragma mark - Defines

#define WRITING_CASSETTES 0
#define CEN_LOGGER_ENABLED NO
#define CEN_PUBNUB_LOGGER_ENABLED NO
#define CENT_DEBUG_CONNECTION_FLOW 0

#pragma mark - Static

/**
 * @brief Key which is used to store block which should be called to reset dispatch groups used to
 * postpone test execution till user will became online on required chats.
 */
static char kCENTPendingGroupsResetBlockKey;

/**
 * @brief Key which is used to store test status information associated with particular ChatEngine
 * instance.
 */
static char kCENTChatEngineTestStateInformationKey;


#pragma mark - Protected interface declaration

@interface CENTestCase () <PNObjectEventListener>


#pragma mark - Information

/**
 * @brief Reference on currently used ChatEngine instance.
 *
 * @discussion Instance created lazily and take into account whether mocking enabled at this moment
 * or not.
 */
@property (nonatomic, nullable, strong) CENChatEngine *client;

/**
 * @brief Currently used global chat / channel name.
 *
 * @discussion Channel name generated randomly and persist during same test case.
 */
@property (nonatomic, strong) NSString *globalChannel;

/**
 * @brief Currently used chat namespace.
 *
 * @discussion Namespace generated randomly and persist during same test case.
 */
@property (nonatomic, strong) NSString *namespace;

/**
 * @brief Stores number of seconds which should be waited before performing in-test verifications.
 */
@property (nonatomic, assign) NSTimeInterval delayedCheck;

/**
 * @brief Stores number of seconds which positive test should wait till async operation completion.
 */
@property (nonatomic, assign) NSTimeInterval testCompletionDelay;

/**
 * @brief Stores number of seconds which negative test should wait till async operation completion.
 */
@property (nonatomic, assign) NSTimeInterval falseTestCompletionDelay;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, nullable, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief Stores reference on list of generated and used globals.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedGlobals;

/**
 * @brief Stores reference on list of configured for test case \b ChatEngine instances.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CENChatEngine *> *clients;

/**
 * @brief Stores reference on list of configured for test case \b ChatEngine clone instances.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CENChatEngine *> *clientClones;

/**
 * @brief \a NSDictionary where original user identifiers mapped to their randomized values used by
 * \b ChatEngine.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedUUIDs;

/**
 * @brief Some tests based on creation of two instanced for same user. In this case, only first one
 * will receive updates about user presence in chats (PubNub presence service already see one user
 * with same \c uuid and won't trigger another \c join).
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *userPresenceInChat;

/**
 * @brief Block which should be called right after PubNub client has been configured.
 */
@property (nonatomic, nullable, copy) dispatch_block_t pubNubClientSetHandlerBlock;

/**
 * @brief Stores reference on previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *classMocks;

/**
 * @brief Stores reference on previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *instanceMocks;

/**
 * @brief Stores reference on \b PubNub publish key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *publishKey;

/**
 * @brief Stores reference on \b PubNub subscribe key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *subscribeKey;

/**
 * @brief List of objects which has been pulled out from method invocation arguments.
 *
 * @return List of stored invocation objects.
 */
+ (NSMutableArray *)invocationObjects;


#pragma mark - Chat mocking

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param isPrivate Reference on flag which specify whether chat should be private or public.
 * @param group One of \b CENChatGroup enum fields which describe scope to which chat belongs.
 *     \b Default: \c CENChatGroup.custom
 * @param meta Dictionary with information which should be bound to chat instance.
 *     \b Default: @{}
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChat:(BOOL)isPrivate
               fromGroup:(nullable NSString *)group
                withMeta:(nullable NSDictionary *)meta
              chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Handlers

/**
 * @brief Handle connection from one of underlying \b PubNub instances.
 *
 * @param client \b PubNub client for which local user (own client instance) reported \c join to
 *     \c chat.
 * @param chatName Name of chat to which join event has been reported.
 */
- (void)handleClientsUser:(PubNub *)client joinToChatWithName:(NSString *)chatName;

/**
 * @brief Handle disconnection from one of underlying \b PubNub instances.
 *
 * @param client \b PubNub client for which local user (own client instance) reported \c leave from
 *     \c chat.
 * @param chatName Name of chat from which leave event has been reported.
 */
- (void)handleClientsUser:(PubNub *)client leaveFromChatWithName:(NSString *)chatName;

/**
 * @brief Handle user's state change from one of underlying \b PubNub instances.
 *
 * @param client \b PubNub client for which local user (own client instance) reported
 *     \c state-change in \c chat.
 * @param chatName Name of chat for which \c state-change event has been reported.
 */
- (void)handleClientsUser:(PubNub *)client stateChangeInChatWithName:(NSString *)chatName;

/**
 * @brief Test recorded (OCMExpect) stub call within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param shouldCall Whether tested \c invocation call or reject.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocation:(id)invocation
                  call:(BOOL)shouldCall
        withinInterval:(NSTimeInterval)interval
            afterBlock:(void(^)(void))initialBlock;


#pragma mark - Helpers

/**
 * @brief Instruct test case to wait till \c client will complete connection.
 *
 * @discussion In context of this method \c connection mean receiving presence events on all system
 * and global chats (if configured).
 *
 * @param user Actual user unique identifier which has been passed from test case subclass.
 * @param userUUID Randomized user identifier which actually used with \b ChatEngine and \b PubNub.
 * @param client \b ChatEngine client for which test case is waiting for \c connection.
 * @param group Dispatch group which is used by test case to observe when requirements will be met.
 */
- (void)waitForUser:(NSString *)user
                 withRandomUUID:(NSString *)userUUID
    connectionToChatsWithClient:(CENChatEngine *)client
                       andGroup:(dispatch_group_t)group;

/**
 * @brief Instruct test case to wait till \c client will be ready and a bit more to give a chance to
 * non-system chats fetch presence information.
 *
 * @param client \b ChatEngine client for which test case if waiting to be ready.
 * @param group Dispatch group which is used by test case to observe when requirements will be met.
 */
- (void)waitForClientReady:(CENChatEngine *)client withGroup:(dispatch_group_t)group;

/**
 * @brief Instruct test case to wait till \c client will update \c user's state.
 *
 * @param user Actual user unique identifier which has been passed from test case subclass.
 * @param userUUID Randomized user identifier which actually used with \b ChatEngine and \b PubNub.
 * @param state \a NSDictionary with data which should be assigned to \c user at test defined chat.
 * @param client \b ChatEngine client for which test case if waiting local user state update.
 * @param group Dispatch group which is used by test case to observe when requirements will be met.
 */
- (void)waitForUser:(NSString *)user
     withRandomUUID:(NSString *)userUUID
      changeStateTo:(NSDictionary *)state
         withClient:(CENChatEngine *)client
           andGroup:(dispatch_group_t)group;

/**
 * @brief Instruct test case to wait a bit till chats presence refresh will be completed.
 *
 * @param user Randomized user identifier which actually used with \b ChatEngine and \b PubNub.
 */
- (void)waitForUsersChatsPresenceRefresh:(NSString *)user;


#pragma mark - Misc

/**
 * @brief Retrieve map of chat names for dispatch group which hold test till chats will be
 * connected.
 *
 * @param client ChatEngine client for which map should be retrieved.
 * @param block Block which allow to synchronously access test states for client:
 *     \c waitingStateChange - map of PubNub client identifiers to dispatch groups which allow to
 *     wait for user's own state update; \c waitingOnline - map of chat names for which test case is
 *     waiting user get online.
 */
- (void)testStatesForClient:(CENChatEngine *)client
            withManageBlock:(void(^)(NSMutableDictionary<NSString *, dispatch_group_t> *waitingStateChange,
                                     NSMutableDictionary<NSString *, dispatch_group_t> *waitingOnline))block;

/**
 * @brief Find ChatEngine which works with specified PubNub instance.
 *
 * @param pubnub PubNub instance for which ChatEngine should be found.
 *
 * @return ChatEngine which users provided PubNub client.
 */
- (CENChatEngine *)clientWithUnderlyingPubNubClient:(PubNub *)pubnub;

/**
 * @brief Schedule block which will be responsible for 'leaving' groups, which has been created to
 * track user's presence.
 *
 * @param chatEngine ChatEngine to which reset block should be bound.
 */
- (void)scheduleLeavePendingGroupForChatConnection:(CENChatEngine *)chatEngine;

- (NSString *)randomNameWithUUID:(NSString *)uuid;

/**
 * @brief  Load content of bundled 'test-keysset.plist' file and get publish/subscribe keys from it.
 */
- (void)loadTestKeys;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENTestCase


#pragma mark - Information

+ (NSMutableArray *)invocationObjects {
    
    static NSMutableArray *_invocationObjects;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _invocationObjects = [NSMutableArray new];
    });
    
    return _invocationObjects;
}

- (NSString *)fixturesLocation {
    
    return @"/Volumes/Develop/Projects/Xcode/PubNub/chat-engine-apple/Tests/Tests/Fixtures";
}


#pragma mark - Configuration

- (void)setUp {
    
    [super setUp];
    
    [self loadTestKeys];

    self.resourceAccessQueue = dispatch_queue_create("test-case", DISPATCH_QUEUE_SERIAL);
    self.usesMockedObjects = [self hasMockedObjectsInTestCaseWithName:self.name];
    self.testCompletionDelay = 15.f;
    self.delayedCheck = 0.25f;
    self.falseTestCompletionDelay = (YHVVCR.cassette.isNewCassette ? self.testCompletionDelay : 0.25f);
    self.userPresenceInChat = [NSMutableDictionary new];
    self.randomizedGlobals = [NSMutableDictionary new];
    self.randomizedUUIDs = [NSMutableDictionary new];
    self.clientClones = [NSMutableDictionary new];
    self.instanceMocks = [NSMutableArray new];
    self.clients = [NSMutableDictionary new];
    self.classMocks = [NSMutableArray new];
}

- (void)tearDown {
    
    BOOL shouldPostponeTearDown = self.clients.count || self.clientClones.count;
    BOOL shouldWaitToRecordResponses = [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette;
    if (shouldPostponeTearDown && shouldWaitToRecordResponses) {
        NSLog(@"\nTest completed. Record final requests from clients.\n");
    } else if (!shouldWaitToRecordResponses) {
        NSLog(@"\nTest completed.\n");
    }
    
    if ([self shouldSetupVCR] && shouldPostponeTearDown) {
        NSTimeInterval waitDelay = shouldWaitToRecordResponses ? 4.f : 0.1f;
        
        [self waitTask:@"clientsTaskCompletion" completionFor:waitDelay];
        
        for (CENChatEngine *client in self.clientClones.allValues) {
            dispatch_block_t resetBlock = objc_getAssociatedObject(client, &kCENTPendingGroupsResetBlockKey);
            
            if ([client.pubnub isKindOfClass:[PubNub class]]) {
                [client.pubnub removeListener:(id<PNObjectEventListener>)client];
                [client.pubnub unsubscribeFromAll];
            }

            if (!client.pubnub || [client.pubnub isKindOfClass:[PubNub class]]) {
                [client destroy];
            }
            
            if (resetBlock) {
                dispatch_block_cancel(resetBlock);
                objc_setAssociatedObject(client, &kCENTPendingGroupsResetBlockKey, nil, OBJC_ASSOCIATION_RETAIN);
            }
            
            [self waitTask:@"clientsDestroyCompletion1" completionFor:waitDelay];
        }
        
        for (CENChatEngine *client in self.clients.allValues) {
            dispatch_block_t resetBlock = objc_getAssociatedObject(client, &kCENTPendingGroupsResetBlockKey);
            
            if ([client.pubnub isKindOfClass:[PubNub class]]) {
                [client.pubnub removeListener:(id<PNObjectEventListener>)client];
                [client.pubnub unsubscribeFromAll];
            }
            
            if (!client.pubnub || [client.pubnub isKindOfClass:[PubNub class]]) {
                [client destroy];
            }
            
            if (resetBlock) {
                dispatch_block_cancel(resetBlock);
                objc_setAssociatedObject(client, &kCENTPendingGroupsResetBlockKey, nil, OBJC_ASSOCIATION_RETAIN);
            }

            [self waitTask:@"clientsDestroyCompletion2" completionFor:waitDelay];
        }
    }
    
    [self.clientClones removeAllObjects];
    [self.clients removeAllObjects];
    self.client = nil;
    
    if (self.instanceMocks.count || self.classMocks.count) {
        [self.clientClones.allValues makeObjectsPerformSelector:@selector(destroy)];
        [self.clients.allValues makeObjectsPerformSelector:@selector(destroy)];
        [self waitTask:@"clientsDestroyCompletion" completionFor:0.2f];
        
        [self.instanceMocks makeObjectsPerformSelector:@selector(stopMocking)];
        [self.classMocks makeObjectsPerformSelector:@selector(stopMocking)];
    }
    
    [self.instanceMocks removeAllObjects];
    [self.classMocks removeAllObjects];
    
    [self.randomizedGlobals removeAllObjects];
    [self.randomizedUUIDs removeAllObjects];
    
    if (shouldPostponeTearDown) {
        NSTimeInterval waitDelay = shouldWaitToRecordResponses ? 4.f : 0.1f;

        if (![self shouldSetupVCR]) {
            waitDelay = 0.1f;
        }
        
        [self waitTask:@"clientsDestroyCompletion" completionFor:waitDelay];
    }
    
    self.pubNubClientSetHandlerBlock = nil;
    
    [super tearDown];
}


#pragma mark - Test configuration

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)__unused name {
    
    return NO;
}

- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)shouldEnableMetaForTestCaseWithName:(NSString *)__unused name {
    
    return NO;
}

- (BOOL)shouldSynchronizeSessionForTestCaseWithName:(NSString *)__unused name {
    
    return NO;
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)__unused name {

    return NO;
}

- (BOOL)shouldWaitOwnOnlineStatusForTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return NO;
}

- (NSString *)globalChatChannelForTestCaseWithName:(NSString *)__unused name {

    NSString *uuid = [[NSUUID UUID].UUIDString substringToIndex:13];
    NSString *channel = [@[@"test", uuid] componentsJoinedByString:@"-"];
    
    if (!self.globalChannel) {
        self.globalChannel = channel ?: @"global";
        
        if (YHVVCR.cassette) {
            self.globalChannel = YHVVCR.cassette.isNewCassette ? self.globalChannel : @"chat-engine";
        }
    }
    
    return self.globalChannel;
}

- (NSDictionary *)stateForUser:(NSString *)__unused user inTestCaseWithName:(NSString *)__unused name {
    
    return nil;
}

- (CENChat *)stateChatForUser:(NSString *)__unused user inTestCaseWithName:(NSString *)__unused name {
    
    return nil;
}

- (nullable CENChat *)chatToTrackOnlineStatusForTestCaseWithName:(NSString *)__unused name {
    
    return nil;
}

- (CENConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    
    CENConfiguration *configuration = [self defaultConfiguration];
    configuration.throwExceptions = [self shouldThrowExceptionForTestCaseWithName:name];
    configuration.enableMeta = [self shouldEnableMetaForTestCaseWithName:name];
    configuration.synchronizeSession = [self shouldSynchronizeSessionForTestCaseWithName:name];
    configuration.globalChannel = [self globalChatChannelForTestCaseWithName:name];
    
    if (YHVVCR.cassette) {
        configuration.globalChannel = YHVVCR.cassette.isNewCassette ? configuration.globalChannel : @"chat-engine";
    }
    
    return configuration;
}


#pragma mark - VCR configuration

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
#if WRITING_CASSETTES
    NSString *cassette = [NSStringFromClass([self class]) stringByAppendingPathExtension:@"bundle"];
    configuration.cassettesPath = [self.fixturesLocation stringByAppendingPathComponent:cassette];
#endif
    
    NSMutableArray *matchers = [configuration.matchers mutableCopy];
    if (![matchers containsObject:YHVMatcher.body]) {
        [matchers addObject:YHVMatcher.body];
        configuration.matchers = matchers;
    }
    
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        NSMutableArray *pathComponents = [[request.URL.path componentsSeparatedByString:@"/"] mutableCopy];

        if ([request.URL.path hasPrefix:@"/publish/"]) {
            NSArray *messageParts = [pathComponents subarrayWithRange:NSMakeRange(7, pathComponents.count - 7)];
            NSString *messageString = [messageParts componentsJoinedByString:@"/"];
            NSString *filteredString = [self filteredPublishMessageFrom:messageString];
            [pathComponents removeObjectsInArray:messageParts];
            [pathComponents addObject:filteredString];
        }

        [self.clients enumerateKeysAndObjectsUsingBlock:^(NSString * __unused identifier, CENChatEngine *client,
                                                          BOOL * __unused stop) {

            NSString *namespace = client.currentConfiguration.globalChannel;
            for (NSString *component in [pathComponents copy]) {
                if ([component rangeOfString:namespace].location == NSNotFound ||
                    [component isEqualToString:@"chat-engine-server"]) {
                    
                    continue;
                }
                
                NSString *replacement = [[component componentsSeparatedByString:namespace] componentsJoinedByString:@"chat-engine"];
                pathComponents[[pathComponents indexOfObject:component]] = replacement;
            }
        }];
        
        for (NSString *component in [pathComponents copy]) {
            NSUInteger componentIdx = [pathComponents indexOfObject:component];
            id replacement = component;
            
            if (component.length > 10 && ([component isEqualToString:self.publishKey] ||
                                          [component isEqualToString:self.subscribeKey])) {

                replacement = @"demo-36";
            }
            
            for (NSString *key in @[self.publishKey, self.subscribeKey]) {
                if ([component rangeOfString:key].location != NSNotFound) {
                    replacement = @"demo-36";
                    break;
                }
            }
            
            for (NSString *uuid in [self.randomizedUUIDs copy]) {
                if ([component rangeOfString:self.randomizedUUIDs[uuid]].location != NSNotFound) {
                    if ([request.URL.path hasPrefix:@"/publish/"] && componentIdx == pathComponents.count - 1) {
                        continue;
                    }
                    
                    replacement = [[component componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
                    break;
                }
            }
            
            for (NSString *randomGlobal in [self.randomizedGlobals.allValues copy]) {
                if ([component rangeOfString:randomGlobal].location != NSNotFound) {
                    replacement = [[component componentsSeparatedByString:randomGlobal] componentsJoinedByString:@"chat-engine"];
                    break;
                }
            }

            pathComponents[componentIdx] = replacement;
        }
        
        return [pathComponents componentsJoinedByString:@"/"];
    };
    
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        for (NSString *parameter in [queryParameters.allKeys copy]) {
            __block id value = queryParameters[parameter];
            
            if ([parameter hasPrefix:@"l_"] || [parameter isEqualToString:@"deviceid"] ||
                [parameter isEqualToString:@"instanceid"] || [parameter isEqualToString:@"requestid"]) {

                [queryParameters removeObjectForKey:parameter];
                continue;
            }
            
            if ([parameter isEqualToString:@"pnsdk"]) {
                value = @"PubNub-ObjC-iOS/4.x.x";
            }
            
            if ([parameter isEqualToString:@"seqn"]) {
                value = @"1";
            }
            
            if ([parameter isEqualToString:@"global"]) {
                value = @"chat-engine";
            }
            
            if ([parameter isEqualToString:@"user"] &&
                [value componentsSeparatedByString:@"-"].count >= [self.randomizedUUIDs.allValues.firstObject componentsSeparatedByString:@"-"].count) {

                value = [value componentsSeparatedByString:@"-"].firstObject;
            }
            
            for (NSString *key in @[self.publishKey, self.subscribeKey]) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                value = [[value componentsSeparatedByString:key] componentsJoinedByString:@"demo-36"];
            }
            
            for (NSString *randomGlobal in [self.randomizedGlobals.allValues copy]) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                value = [[value componentsSeparatedByString:randomGlobal] componentsJoinedByString:@"chat-engine"];
            }
            
            for (NSString *uuid in [self.randomizedUUIDs copy]) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }

                value = [[value componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
            }
            
            [self.clients enumerateKeysAndObjectsUsingBlock:^(NSString * __unused identifier, CENChatEngine *client,
                                                              BOOL * __unused stop) {

                NSString *namespace = client.currentConfiguration.globalChannel;
                
                if ([value isKindOfClass:[NSString class]]) {
                    value = [[value componentsSeparatedByString:namespace] componentsJoinedByString:@"chat-engine"];
                }
            }];
            
            queryParameters[parameter] = value;
        }
    };
    
    
    YHVPostBodyFilterBlock postBodyFilter = ^NSData * (NSURLRequest *request, NSData *body) {
        NSString *httpBodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        
        for (NSString *key in @[self.publishKey, self.subscribeKey]) {
            httpBodyString = [[httpBodyString componentsSeparatedByString:key] componentsJoinedByString:@"demo-36"];
        }
        
        for (NSString *uuid in [self.randomizedUUIDs copy]) {
            httpBodyString = [[httpBodyString componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
        }
        
        for (NSString *randomGlobal in [self.randomizedGlobals.allValues copy]) {
            httpBodyString = [[httpBodyString componentsSeparatedByString:randomGlobal] componentsJoinedByString:@"chat-engine"];
        }
        
        NSData *bodyData = [httpBodyString dataUsingEncoding:NSUTF8StringEncoding];
        NSJSONReadingOptions readOptions = (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves |
                                            NSJSONReadingAllowFragments);
        id bodyContent = bodyData;
        
        if (![request.URL.absoluteString hasSuffix:@".png"] && ![request.URL.absoluteString hasSuffix:@".jpg"]) {
            bodyContent = [NSJSONSerialization JSONObjectWithData:bodyData options:readOptions error:nil];
        }
        
        if (![bodyContent isKindOfClass:[NSDictionary class]]) {
            return body;
        }
        
        if (bodyContent[@"global"]) {
            bodyContent[@"global"] = @"chat-engine";
            if ([bodyContent[@"chat"][@"channel"] rangeOfString:@"global"].location != NSNotFound) {
                NSArray *channelComponents = [bodyContent[@"chat"][@"channel"] componentsSeparatedByString:@"global"];
                bodyContent[@"chat"][@"channel"] = [channelComponents componentsJoinedByString:@"chat-engine"];
            }
        }

        return [NSJSONSerialization dataWithJSONObject:bodyContent options:(NSJSONWritingOptions)0 error:nil];
    };
    
    configuration.postBodyFilter = postBodyFilter;
    
    configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        NSData *filteredBody = data;
        if (!filteredBody.length) {
            return filteredBody;
        }
        
        filteredBody = postBodyFilter(request, data);
        
        return filteredBody;
    };
}


#pragma mark - VCR filter

- (NSString *)filteredPublishMessageFrom:(NSString *)message {
    
    for (NSString *uuid in [self.randomizedUUIDs copy]) {
        message = [[message componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
    }
    
    for (NSString *randomGlobal in [self.randomizedGlobals.allValues copy]) {
        message = [[message componentsSeparatedByString:randomGlobal] componentsJoinedByString:@"chat-engine"];
    }
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSJSONReadingOptions readOptions = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments;
    NSMutableDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:readOptions error:nil];
    
    payload[CENEventData.sdk] = @"objc";
    payload[CENEventData.eventID] = @"unique-event-id";
    
    data = [NSJSONSerialization dataWithJSONObject:payload options:(NSJSONWritingOptions)0 error:nil];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


#pragma mark - Client configuration

- (CENConfiguration *)defaultConfiguration {
    
    return [CENConfiguration configurationWithPublishKey:self.publishKey subscribeKey:self.subscribeKey];
}

- (CENChatEngine *)client {
    
    if (!_client) {
        CENConfiguration *configuration = [self configurationForTestCaseWithName:self.name];
        CENChatEngine *chatEngine = [self createChatEngineWithConfiguration:configuration];
        
        _client = !self.usesMockedObjects ? chatEngine : [self mockForObject:chatEngine];
    }
    
    return _client;
}

- (CENChatEngine *)createChatEngineForUser:(NSString *)user {

    return [self createChatEngineForUser:user
                       withConfiguration:[self configurationForTestCaseWithName:self.name]];
}

- (CENChatEngine *)createChatEngineWithConfiguration:(CENConfiguration *)configuration {

    return [self createChatEngineForUser:[[NSUUID UUID] UUIDString]
                       withConfiguration:configuration];
}

- (CENChatEngine *)createChatEngineForUser:(NSString *)user
                         withConfiguration:(CENConfiguration *)configuration {

    CENChatEngine *client = [CENChatEngine clientWithConfiguration:configuration];
    client.logger.enabled = CEN_LOGGER_ENABLED;
    client.logger.logLevel = CEN_LOGGER_ENABLED ? CENVerboseLogLevel : CENSilentLogLevel;
    client.logger.writeToConsole = CEN_LOGGER_ENABLED;
    client.logger.writeToFile = CEN_LOGGER_ENABLED;

    if (!self.clients[user]) {
        self.clients[user] = client;
    } else if (!self.clientClones[user]) {
        self.clientClones[user] = client;
    } else {
        NSString *reason = [@"Attempt to create more than 2 instances for: " stringByAppendingString:user];

        @throw [NSException exceptionWithName:@"CENChatEngine setup" reason:reason userInfo:nil];
    }
    
    if (![configuration.globalChannel isEqualToString:@"chat-engine"]) {
        self.randomizedGlobals[user] = self.randomizedGlobals[user] ?: configuration.globalChannel;
    }
    
    [client addObserver:self forKeyPath:@"pubnub" options:NSKeyValueObservingOptionNew context:nil];
    
    return client;
}

- (void)setupChatEngineForUser:(NSString *)user {

    CENChatEngine *client = [self createChatEngineForUser:user];

    if ([self shouldConnectChatEngineForTestCaseWithName:self.name]) {
        [self connectUser:user usingClient:client];
    }
}

- (void)completeChatEngineConfiguration:(CENChatEngine *)chatEngine {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *namespace = chatEngine.currentConfiguration.globalChannel;
#pragma clang diagnostic pop
}

- (CENChatEngine *)chatEngineForUser:(NSString *)user {
    
    return self.clients[user];
}

- (CENChatEngine *)chatEngineCloneForUser:(NSString *)user {
    
    return self.clientClones[user];
}


#pragma mark - Connection

- (void)connectUser:(NSString *)user usingClient:(CENChatEngine *)client {

    NSDictionary *state = [self stateForUser:user inTestCaseWithName:self.name];
    dispatch_group_t handleGroup = dispatch_group_create();
    NSString *userUUID = [self randomNameWithUUID:user];
    NSMutableArray *userPresentChats = self.userPresenceInChat[userUUID];
    __block BOOL handlerCalled = NO;
    
#if CENT_DEBUG_CONNECTION_FLOW
    NSString *separator = @"\n---------- CE --------------\n";
    NSLog(@"%@CONNECT USER WITH: %@ (%@)%@", separator, user, userUUID, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
    CENUserConnectBuilderInterface *connection = client.connect(userUUID).authKey(userUUID);
    
    self.randomizedGlobals[user] = self.randomizedGlobals[user] ?: client.currentConfiguration.globalChannel;
    
    if (!userPresentChats) {
        userPresentChats = [NSMutableArray new];
        self.userPresenceInChat[userUUID] = userPresentChats;
    }
    
    CENEventHandlerBlock errorHandler = ^(CENEmittedEvent *event) {
        if (self.expectedError) {
            dispatch_group_leave(handleGroup);
            return;
        }
        
        NSString *reason = [NSString stringWithFormat:@"Client setup did fail for %@ with error: %@",
                            user, event.data];
        @throw [NSException exceptionWithName:@"TestCase" reason:reason userInfo:nil];
    };
    client.once(@"$.error.*", errorHandler).once(@"$.error.**", errorHandler);
    
    [self waitForUser:user withRandomUUID:userUUID connectionToChatsWithClient:client andGroup:handleGroup];
    [self waitForClientReady:client withGroup:handleGroup];
    
    // Wait for client connection completion and ready.
    CENWeakify(connection);
    [self waitToCompleteIn:self.testCompletionDelay codeTaskLabel:@"userConnectionPerformAndWait"
                 codeBlock:^(dispatch_block_t handler) {
                     
        CENStrongify(connection);
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_notify(handleGroup, queue, handler);
        connection.perform();
    }];
    
    [self waitForUsersChatsPresenceRefresh:userUUID];
    [self waitForUser:user withRandomUUID:userUUID changeStateTo:state withClient:client andGroup:handleGroup];
    
    [self waitToCompleteIn:self.testCompletionDelay codeTaskLabel:@"waitPresenceRefreshAndStateUpdate"
                 codeBlock:^(dispatch_block_t handler) {
                     
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_notify(handleGroup, queue, ^{
#if CENT_DEBUG_CONNECTION_FLOW
            NSLog(@"%@SETUP OF CHAT ENGINE FOR '%@' COMPLETED!%@", separator, user, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
            handlerCalled = YES;
            handler();
        });
    }];
    
    if (!handlerCalled) {
        NSString *reason = [NSString stringWithFormat:@"ChatEngine setup for '%@' did fail!", user];
        
        @throw [NSException exceptionWithName:@"TestCase" reason:reason userInfo:nil];
    }
}

- (void)disconnectUserUsingClient:(CENChatEngine *)client {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    client.disconnect();
    client.once(@"$.disconnected", ^(CENEmittedEvent *event) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)reconnectUserUsingClient:(CENChatEngine *)client {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    client.reconnect();
    client.once(@"$.connected", ^(CENEmittedEvent *event) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - State

- (void)updateState:(NSDictionary *)state forUser:(CENMe *)me {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    me.update(state);
    me.chatEngine.once(@"$.state", ^(CENEmittedEvent *event) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - Mocking

- (BOOL)isObjectMocked:(id)object {

    return [self.classMocks containsObject:object] || [self.instanceMocks containsObject:object];
}

- (id)mockForObject:(id)object {
    
    BOOL isClass = object_isClass(object);
    __unsafe_unretained id mock = isClass ? OCMClassMock(object) : OCMPartialMock(object);
    
    if (isClass) {
        [self.classMocks addObject:mock];
    } else {
        [self.instanceMocks addObject:mock];
    }
    
    return mock;
}


#pragma mark - Chat mocking

- (void)stubUserAuthorization {
    
    OCMStub([self.client authorizeLocalUserWithUUID:[OCMArg any] authorizationKey:[OCMArg any] completion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t handlerBlock = [self objectForInvocation:invocation argumentAtIndex:3];
            handlerBlock();
        });
}

- (void)stubChatConnection {
    
    OCMStub([self.client connectToChat:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t handlerBlock = [self objectForInvocation:invocation argumentAtIndex:2];
            handlerBlock();
        });
}

- (void)stubChatHandshake {
    
    OCMStub([self.client handshakeChatAccess:[OCMArg any] withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
            block();
        });
}

- (void)stubPubNubSubscribe {
    
    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:1];
            block();
        });
}

- (CENChat *)feedChatForUser:(NSString *)uuid
                 connectable:(BOOL)ableToConnect
              withChatEngine:(CENChatEngine *)chatEngine {
    
    NSString *namespace = [self globalChatChannelForTestCaseWithName:self.name] ?: @"global";

    if (YHVVCR.cassette) {
        namespace = YHVVCR.cassette.isNewCassette ? namespace : @"chat-engine";
    }
    
    NSString *name = [@[namespace, @"user", uuid, @"read.#feed"] componentsJoinedByString:@"#"];
    CENChat *chat = [chatEngine createChatWithName:name group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    
    if (!ableToConnect) {
        OCMStub([chatEngine connectToChat:chat withCompletion:[OCMArg any]])
            .andDo(^(NSInvocation *invocation) {
                dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
                block();
            });
    }
    
    return chat;
}

- (CENChat *)directChatForUser:(NSString *)uuid
                   connectable:(BOOL)ableToConnect
                withChatEngine:(CENChatEngine *)chatEngine {
    
    NSString *namespace = [self globalChatChannelForTestCaseWithName:self.name] ?: @"global";
    
    if (YHVVCR.cassette) {
        namespace = YHVVCR.cassette.isNewCassette ? namespace : @"chat-engine";
    }
    
    NSString *name = [@[namespace, @"user", uuid, @"write.#direct"] componentsJoinedByString:@"#"];
    CENChat *chat = [chatEngine createChatWithName:name group:CENChatGroup.system private:NO autoConnect:NO metaData:nil];
    
    if (!ableToConnect) {
        OCMStub([chatEngine connectToChat:chat withCompletion:[OCMArg any]])
            .andDo(^(NSInvocation *invocation) {
                dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
                
                block();
            });
    }
    
    return chat;
}

- (CENChat *)privateChatWithChatEngine:(CENChatEngine *)chatEngine {
    
    return [self privateChatWithMeta:nil chatEngine:chatEngine];
}

- (CENChat *)privateChatWithMeta:(NSDictionary *)meta chatEngine:(CENChatEngine *)chatEngine {
    
    return [self privateChatFromGroup:nil withMeta:meta chatEngine:chatEngine];
}

- (CENChat *)privateChatFromGroup:(NSString *)group withChatEngine:(CENChatEngine *)chatEngine {
    
    return [self privateChatFromGroup:group withMeta:nil chatEngine:chatEngine];
}

- (CENChat *)privateChatFromGroup:(NSString *)group
                         withMeta:(NSDictionary *)meta
                       chatEngine:(CENChatEngine *)chatEngine {
    
    return [self privateChat:YES fromGroup:group withMeta:meta chatEngine:chatEngine];
}

- (CENChat *)publicChatWithChatEngine:(CENChatEngine *)chatEngine {
    
    return [self publicChatWithMeta:nil chatEngine:chatEngine];
}

- (CENChat *)publicChatWithMeta:(NSDictionary *)meta chatEngine:(CENChatEngine *)chatEngine {
    
    return [self publicChatFromGroup:nil withMeta:meta cithChatEngine:chatEngine];
}

- (CENChat *)publicChatFromGroup:(NSString *)group withChatEngine:(CENChatEngine *)chatEngine {
    
    return [self publicChatFromGroup:group withMeta:nil cithChatEngine:chatEngine];
}

- (CENChat *)publicChatFromGroup:(NSString *)group withMeta:(NSDictionary *)meta
                  cithChatEngine:(CENChatEngine *)chatEngine {
    
    return [self privateChat:NO fromGroup:group withMeta:meta chatEngine:chatEngine];
}

- (CENChat *)privateChat:(BOOL)isPrivate fromGroup:(NSString *)group withMeta:(NSDictionary *)meta
              chatEngine:(CENChatEngine *)chatEngine {
    
    NSString *name = [[NSUUID UUID] UUIDString];
    
    return [chatEngine createChatWithName:name
                                    group:(group ?: CENChatGroup.custom)
                                  private:isPrivate
                              autoConnect:NO
                                 metaData:(meta ?: @{})];
}

- (id)createPrivateChat:(BOOL)isPrivate invocationForClassMock:(id)mock {
    
    return [mock chatWithName:[OCMArg any]
                    namespace:[OCMArg any]
                        group:[OCMArg any]
                      private:isPrivate
                     metaData:[OCMArg any]
                   chatEngine:[OCMArg any]];
}


#pragma mark - Helpers

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    PubNub *pubnub = change[NSKeyValueChangeNewKey];
    pubnub.logger.enabled = CEN_PUBNUB_LOGGER_ENABLED;
    pubnub.logger.logLevel = CEN_PUBNUB_LOGGER_ENABLED ? PNVerboseLogLevel : PNSilentLogLevel;
    [pubnub addListener:self];
    
    id pubnubMock = [self mockForObject:pubnub];
    OCMStub([pubnubMock instanceID]).andReturn([NSUUID UUID].UUIDString);
    
    id configurationMock = [self mockForObject:pubnub.configuration];
    OCMStub([configurationMock shouldManagePresenceListManually]).andReturn(YES);
    
    if (self.pubNubClientSetHandlerBlock) {
        self.pubNubClientSetHandlerBlock();
        self.pubNubClientSetHandlerBlock = nil;
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
#if CENT_DEBUG_CONNECTION_FLOW
    NSString *separator = @"\n---------- PN --------------\n";
    NSLog(@"%@%@ %@'ed %@ (%@)%@", separator, event.data.presence.uuid, event.data.presenceEvent,
          event.data.channel, client.uuid, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
    if (![event.data.presence.uuid isEqualToString:client.uuid]) {
        return;
    }
    
    NSString *chatName = [event.data.channel componentsSeparatedByString:@"#"].lastObject;
    
    if ([event.data.presenceEvent isEqualToString:@"join"]) {
        [self handleClientsUser:client joinToChatWithName:chatName];
    } else if ([event.data.presenceEvent isEqualToString:@"leave"]) {
        [self handleClientsUser:client leaveFromChatWithName:chatName];
    } else if ([event.data.presenceEvent isEqualToString:@"state-change"]) {
        [self handleClientsUser:client stateChangeInChatWithName:chatName];
    }
}

- (void)handleClientsUser:(PubNub *)client joinToChatWithName:(NSString *)chatName {

    CENChatEngine *chatEngine = [self clientWithUnderlyingPubNubClient:client];
    
    [self testStatesForClient:chatEngine
              withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                  
        [self.userPresenceInChat[client.uuid] addObject:chatName];
        
        dispatch_group_t group = waitingOnline[chatName];
        [waitingOnline removeObjectForKey:chatName];
        if (group) {
            
#if CENT_DEBUG_CONNECTION_FLOW
            NSString *separator = @"\n---------- CE --------------\n";
            NSLog(@"%@'%@' ONLINE ON '%@' (%@)%@", separator, client.uuid, chatName,
                  [client valueForKey:@"instanceID"], separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
            
            dispatch_group_leave(group);
        }
    }];
}

- (void)handleClientsUser:(PubNub *)client leaveFromChatWithName:(NSString *)chatName {
    
    CENChatEngine *chatEngine = [self clientWithUnderlyingPubNubClient:client];
    
    [self testStatesForClient:chatEngine
              withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                  
#if CENT_DEBUG_CONNECTION_FLOW
        if ([self.userPresenceInChat[client.uuid] containsObject:chatName]) {
            NSString *separator = @"\n---------- CE --------------\n";
            NSLog(@"%@'%@' OFFLINE ON '%@' (%@)%@", separator, client.uuid, chatName,
                  [client valueForKey:@"instanceID"], separator);
        }
#endif // CENT_DEBUG_CONNECTION_FLOW
        
        [self.userPresenceInChat[client.uuid] addObject:chatName];
    }];
}

- (void)handleClientsUser:(PubNub *)client stateChangeInChatWithName:(NSString *)chatName {
    
    CENChatEngine *chatEngine = [self clientWithUnderlyingPubNubClient:client];
    
    [self testStatesForClient:chatEngine
              withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                  
        dispatch_group_t group = waitingStateChange[chatName];
        if (group) {
            [waitingStateChange removeObjectForKey:chatName];
#if CENT_DEBUG_CONNECTION_FLOW
            NSString *separator = @"\n---------- PN --------------\n";
            NSLog(@"%@'%@' UPDATED STATE ON '%@' (%@)%@", separator, client.uuid, chatName,
                  [client valueForKey:@"instanceID"], separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
            
            dispatch_group_leave(group);
        }
    }];
}

- (void)waitForObject:(id)object
    recordedInvocation:(id)invocation
                  call:(BOOL)shouldCall
        withinInterval:(NSTimeInterval)interval
            afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    ((OCMStubRecorder *)invocation).andDo(^(NSInvocation *expectedInvocation) {
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));

    if (shouldCall) {
        XCTAssertTrue(handlerCalled);
    } else {
        XCTAssertFalse(handlerCalled);
    }

    OCMVerifyAll(object);
}

- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
                afterBlock:(void(^)(void))initialBlock {

    [self waitForObject:object
     recordedInvocationCall:invocation
             withinInterval:self.testCompletionDelay
                 afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
            withinInterval:(NSTimeInterval)interval
                afterBlock:(void(^)(void))initialBlock {
    
    [self waitForObject:object
     recordedInvocation:invocation
                   call:YES
         withinInterval:interval
             afterBlock:initialBlock];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToCompleteIn:interval codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToCompleteIn:interval codeTaskLabel:label codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(void(^)(void))initialBlock {
    
    [self waitToCompleteIn:interval codeTaskLabel:nil codeBlock:codeBlock afterBlock:initialBlock];
}

- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));
    
    if (label) {
        XCTAssertTrue(handlerCalled, @"'%@' code block not completed in time", label);
    } else {
        XCTAssertTrue(handlerCalled);
    }
}

- (void)object:(CENEventEmitter *)object
      shouldHandle:(BOOL)shouldHandle
            events:(NSArray<NSString *> *)events
    withinInterval:(NSTimeInterval)interval
      withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
        afterBlock:(void(^)(void))initialBlock {
    
    NSMutableArray<CENEventHandlerBlock> *registeredHandlers = [NSMutableArray new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_t handleGroup = dispatch_group_create();
    NSMutableArray *calledHandlersFor = [NSMutableArray new];
    __block BOOL handlerCalled = NO;
    
    CENWeakify(object);
    [events enumerateObjectsUsingBlock:^(NSString *event, NSUInteger eventIdx, BOOL *stop) {
        CENEventHandlerBlock(^handlerGenerator)(dispatch_block_t) = handlers[eventIdx];
        NSString *handlerIdentifier = [NSUUID UUID].UUIDString;
        CENStrongify(object);
        
        dispatch_group_enter(handleGroup);
        CENEventHandlerBlock handler = handlerGenerator(^{
            if (![calledHandlersFor containsObject:handlerIdentifier]) {
                [calledHandlersFor addObject:handlerIdentifier];
                [object removeAllHandlersForEvent:event];
                dispatch_group_leave(handleGroup);
            }
        });
        
        [registeredHandlers addObject:handler];
        [object handleEvent:event withHandlerBlock:handler];
    }];
    
    
    if (initialBlock) {
        initialBlock();
    }
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_notify(handleGroup, queue, ^{
        handlerCalled = calledHandlersFor.count == events.count;
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));
    
    [events enumerateObjectsUsingBlock:^(NSString *event, NSUInteger eventIdx, BOOL *stop) {
        [object removeHandler:registeredHandlers[eventIdx] forEvent:event];
    }];
    
    if (shouldHandle) {
        XCTAssertTrue(handlerCalled, @"Not called for events: %@", events);
    } else {
        XCTAssertFalse(handlerCalled);
    }
}

- (void)object:(CENEventEmitter *)object
    shouldHandleEvent:(NSString *)event
           afterBlock:(void(^)(void))initialBlock {

    [self object:object shouldHandleEvent:event withHandler:^CENEventHandlerBlock(dispatch_block_t handler) {
        return ^(CENEmittedEvent *__unused event) {
            handler();
        };
    } afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
    shouldHandleEvent:(NSString *)event
          withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
           afterBlock:(void(^)(void))initialBlock {
    
    [self object:object
     shouldHandleEvent:event
        withinInterval:self.testCompletionDelay
           withHandler:handler
            afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
    shouldHandleEvent:(NSString *)event
       withinInterval:(NSTimeInterval)interval
          withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
           afterBlock:(void(^)(void))initialBlock {
    
    [self object:object
     shouldHandleEvents:@[event]
         withinInterval:interval
           withHandlers:@[handler]
             afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
    shouldHandleEvents:(NSArray<NSString *> *)events
        withinInterval:(NSTimeInterval)interval
          withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
            afterBlock:(void(^)(void))initialBlock {
    
    [self object:object
       shouldHandle:YES
             events:events
     withinInterval:interval
       withHandlers:handlers
         afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
                   afterBlock:(void(^)(void))initialBlock {

    [self waitForObject:object
     recordedInvocationNotCall:invocation
                withinInterval:self.falseTestCompletionDelay
                    afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
               withinInterval:(NSTimeInterval)interval
                   afterBlock:(nullable void(^)(void))initialBlock {
    
    [self waitForObject:object recordedInvocation:invocation call:NO withinInterval:interval
             afterBlock:initialBlock];
}

- (void)waitToNotCompleteIn:(NSTimeInterval)delay
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToNotCompleteIn:delay codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToNotCompleteIn:(NSTimeInterval)delay
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock
                 afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_semaphore_wait(semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (void)object:(CENEventEmitter *)object
    shouldNotHandleEvent:(NSString *)event
             withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
              afterBlock:(void(^)(void))initialBlock {
    
    [self object:object
     shouldNotHandleEvent:event
           withinInterval:self.falseTestCompletionDelay
              withHandler:handler
               afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
    shouldNotHandleEvent:(NSString *)event
          withinInterval:(NSTimeInterval)interval
             withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
              afterBlock:(void(^)(void))initialBlock {
    
    [self object:object
     shouldNotHandleEvents:@[event]
            withinInterval:interval
              withHandlers:@[handler]
                afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
    shouldNotHandleEvents:(NSArray<NSString *> *)events
           withinInterval:(NSTimeInterval)interval
             withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
               afterBlock:(void(^)(void))initialBlock {
    
    [self object:object
       shouldHandle:NO
             events:events
     withinInterval:interval
       withHandlers:handlers
         afterBlock:initialBlock];
}

- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds {
    
    if (seconds <= 0.f) {
        return nil;
    }
    
    XCTestExpectation *waitExpectation = [self expectationWithDescription:taskName];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [waitExpectation fulfill];
    });

    [self waitForExpectations:@[waitExpectation] timeout:(seconds + 0.3f)];
    
    return waitExpectation;
}

- (void)waitForUser:(NSString *)user
                 withRandomUUID:(NSString *)userUUID
    connectionToChatsWithClient:(CENChatEngine *)client
                       andGroup:(dispatch_group_t)group {
    
    if (![self shouldWaitOwnOnlineStatusForTestCaseWithName:self.name]) {
#if CENT_DEBUG_CONNECTION_FLOW
        NSString *separator = @"\n---------- CE --------------\n";
        NSLog(@"%@'%@' ONLINE TRACKING NOT REQUIRED%@", separator, userUUID, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
        return;
    }
    
    __block CENChat *chatForOnline = [self chatToTrackOnlineStatusForTestCaseWithName:self.name];
    NSString *nameOfChatForOnline = chatForOnline.name ? chatForOnline.name : self.randomizedGlobals[user];
    void(^onlineTrackingLog)(NSString *) = ^(NSString *channelName) {
#if CENT_DEBUG_CONNECTION_FLOW
        NSString *separator = @"\n---------- CE --------------\n";
        NSLog(@"%@'%@' ONLINE TRACKING REQUIRED ON '%@'%@", separator, userUUID, channelName, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
    };
    
    [self testStatesForClient:client
              withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                  
        if (![self.userPresenceInChat[userUUID] containsObject:nameOfChatForOnline]) {
            waitingOnline[nameOfChatForOnline] = group;
            dispatch_group_enter(group);
            
            onlineTrackingLog(nameOfChatForOnline);
        }
        
        if (![self.userPresenceInChat[userUUID] containsObject:@"direct"]) {
            waitingOnline[@"direct"] = group;
            dispatch_group_enter(group);
            
            onlineTrackingLog(@"direct");
        }
        
        if (![self.userPresenceInChat[userUUID] containsObject:@"feed"]) {
            waitingOnline[@"feed"] = group;
            dispatch_group_enter(group);
            
            onlineTrackingLog(@"feed");
        }
        
        if ([self shouldSynchronizeSessionForTestCaseWithName:self.name] &&
            ![self.userPresenceInChat[userUUID] containsObject:@"sync"]) {
            
            waitingOnline[@"sync"] = group;
            dispatch_group_enter(group);
            
            onlineTrackingLog(@"sync");
        }
                  
    }];
    
    dispatch_group_enter(group);
    CENEventHandlerBlock __block __weak weakFeedConnectionHandler;
    CENEventHandlerBlock feedConnectionHandler = nil;
    weakFeedConnectionHandler = feedConnectionHandler =^(CENEmittedEvent *event) {
        CENChat *chat = event.emitter;

        if (![chat.channel isEqualToString:client.me.feed.channel]) {
            return;
        }

        client.off(@"$.connected", weakFeedConnectionHandler);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)), queue, ^{
            client.pubnub.presence().connected(YES).channelGroups(client.pubnub.channelGroups)
                .performWithCompletion(^(PNStatus *status) {
                    dispatch_group_leave(group);
                });
        });
    };

    client.on(@"$.connected", feedConnectionHandler);
    
    // Clean up chats connection waiting group.
    [self scheduleLeavePendingGroupForChatConnection:client];
}

- (void)waitForClientReady:(CENChatEngine *)client withGroup:(dispatch_group_t)group {
    
    dispatch_group_enter(group);
    
    CENWeakify(client);
    client.on(@"$.ready", ^(CENEmittedEvent *emittedEvent) {
        CENStrongify(client);
        client.removeAll(@"$.ready");
        
#if CENT_DEBUG_CONNECTION_FLOW
        NSString *separator = @"\n---------- CE --------------\n";
        NSLog(@"%@'%@' IS READY%@", separator, client.pubNubUUID, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
        dispatch_group_leave(group);
    });
}

- (void)waitForUser:(NSString *)user
     withRandomUUID:(NSString *)userUUID
      changeStateTo:(NSDictionary *)state
         withClient:(CENChatEngine *)client
           andGroup:(dispatch_group_t)group {
    
    CENChat *stateChat = [self stateChatForUser:user inTestCaseWithName:self.name] ?: client.global;
    
    if (!stateChat || !state.count) {
        return;
    }
    
#if CENT_DEBUG_CONNECTION_FLOW
    NSString *separator = @"\n---------- CE --------------\n";
    NSLog(@"%@'%@' UPDATING STATE ON '%@'%@", separator, userUUID, stateChat.name, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
    [self testStatesForClient:client
              withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                  
        waitingStateChange[stateChat.name] = group;
    }];
    
    dispatch_group_enter(group);
    client.me.update(state);
}

- (void)waitForUsersChatsPresenceRefresh:(NSString *)user {
    
#if CENT_DEBUG_CONNECTION_FLOW
    NSString *separator = @"\n---------- CE --------------\n";
    NSLog(@"%@'%@' IS WAITING PRESENCE REFRESH%@", separator, user, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
    
    /**
     * Wait a bit more, to let presence timers fire and fetch presence (they need at least
     * 1 second delay.
     */
    NSTimeInterval delay = YHVVCR.cassette.isNewCassette ? 2.f : 1.2f;
    [self waitTask:@"chatsPresenceRefresh" completionFor:delay];
    
#if CENT_DEBUG_CONNECTION_FLOW
    NSLog(@"%@'%@' COMPLETED PRESENCE REFRESH WAITING%@", separator, user, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW
}

- (void)waitForOtherUsers:(NSUInteger)count withClient:(CENChatEngine *)client {
    
    if (client.global.users.count != count) {
        CENWeakify(client);
        
        [self object:client
   shouldHandleEvent:@"$.online.*"
         withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {

            CENStrongify(client);
            
            return ^(CENEmittedEvent *emittedEvent) {
                if (client.global.users.count == count) {
                    handler();
                }
            };
        } afterBlock:^{ }];
    }

    [self waitTask:@"waitForUsersListUpdate" completionFor:1.f];
}

- (void)waitForOwnOnlineOnChat:(CENChat *)chat {
    
    dispatch_group_t handleGroup = dispatch_group_create();
    CENChatEngine *client = chat.chatEngine;
    NSString *userUUID = client.me.uuid;
    
    if (chat.users[client.me.uuid]) {
        return;
    }
    
#if CENT_DEBUG_CONNECTION_FLOW
    NSString *separator = @"\n---------- CE --------------\n";
    NSLog(@"%@'%@' ONLINE TRACKING REQUIRED ON '%@'%@", separator, userUUID, chat.name, separator);
#endif // CENT_DEBUG_CONNECTION_FLOW

    [self testStatesForClient:client
              withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                  
        if (![self.userPresenceInChat[userUUID] containsObject:chat.name]) {
            waitingOnline[chat.name] = handleGroup;
            dispatch_group_enter(handleGroup);
        }
    }];
    
    dispatch_group_enter(handleGroup);
    chat.once(@"$.connected", ^(CENEmittedEvent * __unused event) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)), queue, ^{
            client.pubnub.presence().connected(YES).channelGroups(client.pubnub.channelGroups)
                .performWithCompletion(^(PNStatus *status) {
                    dispatch_group_leave(handleGroup);
                });
        });
    });
    
    // Clean up chats connection waiting group.
    [self scheduleLeavePendingGroupForChatConnection:client];
    
    // Wait for client connection to specified chat.
    NSString *codeLabel = [@"waitUserOnlineOnSpecificChat-" stringByAppendingString:chat.name];
    [self waitToCompleteIn:self.testCompletionDelay codeTaskLabel:codeLabel codeBlock:^(dispatch_block_t handler) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_notify(handleGroup, queue, ^{
            handler();
        });
    }];
    
    [self waitForUsersChatsPresenceRefresh:userUUID];
}


#pragma mark - Helpers

- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index {
    
    __strong id object = [invocation objectForArgumentAtIndex:(index + 1)];
    
    [[CENTestCase invocationObjects] addObject:object];
    
    return object;
}


#pragma mark - Misc

- (void)testStatesForClient:(CENChatEngine *)client
            withManageBlock:(void(^)(NSMutableDictionary<NSString *, dispatch_group_t> *waitingStateChange,
                                     NSMutableDictionary<NSString *, dispatch_group_t> *waitingOnline))block {
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSDictionary *states = objc_getAssociatedObject(client, &kCENTChatEngineTestStateInformationKey);
        
        if (!states) {
            states = @{
                @"waitingStateChange": [NSMutableDictionary new],
                @"waitingOnline": [NSMutableDictionary new]
            };
            objc_setAssociatedObject(client, &kCENTChatEngineTestStateInformationKey, states, OBJC_ASSOCIATION_RETAIN);
        }
        
        block(states[@"waitingStateChange"], states[@"waitingOnline"]);
    });
}

- (CENChatEngine *)clientWithUnderlyingPubNubClient:(PubNub *)pubnub {
    
    NSString *targetPubNubID = [pubnub valueForKey:@"instanceID"];
    
    for (CENChatEngine *client in self.clients.allValues) {
        if ([[client.pubnub valueForKey:@"instanceID"] isEqualToString:targetPubNubID]) {
            return client;
        }
    }
    for (CENChatEngine *client in self.clientClones.allValues) {
        if ([[client.pubnub valueForKey:@"instanceID"] isEqualToString:targetPubNubID]) {
            return client;
        }
    }
    
    return nil;
}

- (void)scheduleLeavePendingGroupForChatConnection:(CENChatEngine *)chatEngine {
    
    __block dispatch_block_t block = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
        block = objc_getAssociatedObject(chatEngine, &kCENTPendingGroupsResetBlockKey);
    });
    
    if (block) {
        return;
    }
    
    CENWeakify(chatEngine);
    CENWeakify(self);
    dispatch_block_flags_t flags = DISPATCH_BLOCK_INHERIT_QOS_CLASS;
    block = dispatch_block_create(flags, ^{
        CENStrongify(chatEngine);
        CENStrongify(self);
        __block NSArray<dispatch_group_t> *groups = nil;
        
        [self testStatesForClient:chatEngine
                  withManageBlock:^(NSMutableDictionary<NSString *,dispatch_group_t> *waitingStateChange,
                                    NSMutableDictionary<NSString *,dispatch_group_t> *waitingOnline) {
                      
            groups = waitingOnline.allValues;
            [waitingOnline removeAllObjects];
            
#if CENT_DEBUG_CONNECTION_FLOW
            if (groups.count) {
                NSString *separator = @"\n---------- CE --------------\n";
                NSLog(@"%@IGNORING MISSING 'JOIN' EVENT FOR:\n\t%@%@", separator,
                      [waitingOnline.allKeys componentsJoinedByString:@"\n\t"],
                      separator);
            }
#endif // CENT_DEBUG_CONNECTION_FLOW
        }];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            for (dispatch_group_t pendingGroup in groups) {
                dispatch_group_leave(pendingGroup);
            }
        });
    });
    
    objc_setAssociatedObject(chatEngine, &kCENTPendingGroupsResetBlockKey, block, OBJC_ASSOCIATION_COPY);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSTimeInterval resetDelay = !YHVVCR.cassette || YHVVCR.cassette.isNewCassette ? self.testCompletionDelay - 2.f : 2.f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resetDelay * NSEC_PER_SEC)), queue, block);
}

- (NSString *)randomNameWithUUID:(NSString *)uuid {
    
    if (self.randomizedUUIDs[uuid]) {
        return self.randomizedUUIDs[uuid];
    }
    
    NSNumber *timestamp = @((NSUInteger)[NSDate date].timeIntervalSince1970);
    NSString *userUUID = [@[uuid, CENChatEngine.sdkVersion, timestamp] componentsJoinedByString:@"-"];
    userUUID = [userUUID stringByReplacingOccurrencesOfString:@"." withString:@"-"];

    if (YHVVCR.cassette) {
        self.randomizedUUIDs[uuid] = YHVVCR.cassette.isNewCassette ? userUUID : uuid;
    } else {
        self.randomizedUUIDs[uuid] = userUUID;
    }
    
    return self.randomizedUUIDs[uuid];
}

- (void)loadTestKeys {
    
    static NSDictionary *_testKeysSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *keysPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test-keysset" ofType:@"plist"];
        _testKeysSet = [NSDictionary dictionaryWithContentsOfFile:keysPath];
    });
    
    self.publishKey = _testKeysSet[@"pub-key"];
    self.subscribeKey = _testKeysSet[@"sub-key"];
}


#pragma mark -


@end
