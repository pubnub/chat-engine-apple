/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <objc/runtime.h>
#import <CENChatEngine/CENChatEngine+AuthorizationPrivate.h>
#import <CENChatEngine/CENChatEngine+PubNubPrivate.h>
#import <CENChatEngine/CENChatEngine+ChatInterface.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CENPrivateStructures.h>
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <CENChatEngine/CENSession.h>
#import <YAHTTPVCR/YAHTTPVCR.h>
#import <OCMock/OCMock.h>


#define WRITTING_CASSETTES 0
#define CEN_LOGGER_ENABLED NO
#define CEN_PUBNUB_LOGGER_ENABLED NO


#pragma mark Protected interface declaration

@interface CENTestCase ()


#pragma mark - Information

/**
 * @brief Reference on currently used ChatEngine instance.
 *
 * @discussion Instance created lazily and take into account whether mocking enabled at this moment
 * or not.
 */
@property (nonatomic, nullable, weak) CENChatEngine *client;

/**
 * @brief      Stores number of seconds which test should wait till async operation completion.
 * @discussion Used for tests which contain handlers with nested semaphores.
 */
@property (nonatomic, assign) NSTimeInterval testCompletionDelayWithNestedSemaphores;

/**
 * @brief  Stores number of seconds which should be waited before performing next action.
 */
@property (nonatomic, assign) NSTimeInterval delayBetweenActions;

/**
 * @brief  Stores number of seconds which should be waited before performing in-test verifications.
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
 * @brief Stores reference on list of generated and used namespaces.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedNamespaces;

/**
 * @brief Stores reference on list of generated and used globals.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedGlobals;

/**
 * @brief  Stores reference on list of configured for test case \b ChatEngine instances.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CENChatEngine *> *clients;

/**
 * @brief  Stores reference on list of configured for test case \b ChatEngine clone instances.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CENChatEngine *> *clientClones;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedUUIDs;

/**
 * @brief Stores reference on previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *classMocks;

/**
 * @brief Stores reference on previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *instanceMocks;

/**
 * @brief  Stores reference on \b PubNub publish key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *publishKey;

/**
 * @brief  Stores reference on \b PubNub subscribe key which should be used for client configuration.
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
 * @brief  Create and configure \c chat instance with random parameters, which can be used for real
 *         chats mocking.
 *
 * @param isPrivate  Reference on flag which specify whether chat should be private or public.
 * @param group One of \b CENChatGroup enum fields which describe scope to which chat belongs.
 *     \b Default: \c CENChatGroup.custom
 * @param meta Dictionary with information which shold be bound to chat instance.
 *     \b Default: @{}
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChat:(BOOL)isPrivate fromGroup:(nullable NSString *)group
                withMeta:(nullable NSDictionary *)meta chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Handlers

/**
 * @brief Test recorded (OCMExpect) stub call within specified interval.
 *
 * @param object Mock from objecr on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param shouldCall Whether tested \c invocation call or reject.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initalBlock GCD block which contain initalization of code required to invoce tested code.
 */
- (void)waitForObject:(id)object recordedInvocation:(id)invocation call:(BOOL)shouldCall
       withinInterval:(NSTimeInterval)interval afterBlock:(void(^)(void))initalBlock;


#pragma mark - Misc

- (NSString *)randomNameWithUUID:(NSString *)uuid;

/**
 * @brief  Load content of bundled 'test-keysset.plist' file and get publish/subscribe keys from it.
 */
- (void)loadTestKeys;

#pragma mark -


@end


#pragma mark Interface implementation

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


#pragma mark - Configuration

- (void)setUp {
    
    [super setUp];
    
    [self loadTestKeys];

    self.testCompletionDelay = 15.f;
    self.delayedCheck = 0.25f;
    self.falseTestCompletionDelay = (YHVVCR.cassette.isNewCassette ? self.testCompletionDelay : 0.25f);
    self.delayBetweenActions = YHVVCR.cassette.isNewCassette ? 5.f : 0.1f;
    self.testCompletionDelayWithNestedSemaphores = (YHVVCR.cassette.isNewCassette ? 60.f : 15.f);
    self.randomizedNamespaces = [NSMutableDictionary new];
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
        NSLog(@"Test completed. Record final requests from clients.");
    }
    
    if (shouldPostponeTearDown || self.instanceMocks.count || self.classMocks.count) {
        NSTimeInterval waitDelay = shouldWaitToRecordResponses ? 4.f : .01f;
        
        [self waitTask:@"clientsTaskCompletion" completionFor:waitDelay];
    }
    
    [self.clientClones removeAllObjects];
    [self.clients removeAllObjects];
    self.client = nil;
    
    [self.instanceMocks removeAllObjects];
    [self.classMocks removeAllObjects];
    
    [self.randomizedNamespaces removeAllObjects];
    [self.randomizedGlobals removeAllObjects];
    [self.randomizedUUIDs removeAllObjects];
    [self.clientClones removeAllObjects];
    [self.clients removeAllObjects];
    
    if (shouldPostponeTearDown) {
        NSTimeInterval waitDelay = shouldWaitToRecordResponses ? 4.f : .01f;
        
        [self waitTask:@"clientsDestroyCompletion" completionFor:waitDelay];
    }
    
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

- (BOOL)shouldWaitOwnPresenceEventsTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)shouldWaitOwnStateChangeEventTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (nullable NSString *)namespaceForTestCaseWithName:(NSString *)__unused name {
    
    NSString *namespace = [@[@"namespace", [[NSUUID UUID].UUIDString substringToIndex:13]] componentsJoinedByString:@"-"];
    
    return YHVVCR.cassette.isNewCassette ? namespace : @"namespace";
}

- (NSString *)globalChatChannelForTestCaseWithName:(NSString *)__unused name {
    
    NSString *channel = [@[@"test", [[NSUUID UUID].UUIDString substringToIndex:13]] componentsJoinedByString:@"-"];
    
    return YHVVCR.cassette.isNewCassette ? channel : @"global";
}

- (NSDictionary *)stateForUser:(NSString *)__unused user inTestCaseWithName:(NSString *)__unused name {
    
    return nil;
}

- (CENConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    
    CENConfiguration *configuration = [self defaultConfiguration];
    configuration.throwExceptions = [self shouldThrowExceptionForTestCaseWithName:name];
    configuration.enableGlobal = [self shouldEnableGlobalChatForTestCaseWithName:name];
    configuration.enableMeta = [self shouldEnableMetaForTestCaseWithName:name];
    configuration.synchronizeSession = [self shouldSynchronizeSessionForTestCaseWithName:name];
    configuration.namespace = [self namespaceForTestCaseWithName:name];
    
    if (!configuration.namespace) {
        NSString *timestamp = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
        NSString *namespace = [@[@"test", CENChatEngine.sdkVersion, timestamp] componentsJoinedByString:@"-"];
        configuration.namespace = [namespace stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    }
    
    if (!YHVVCR.cassette.isNewCassette) {
        configuration.namespace = @"namespace";
    }
    
    return configuration;
}


#pragma mark - VCR configuration

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
#if WRITTING_CASSETTES
    NSString *fixturesPath = @"/Volumes/Develop/Projects/Xcode/PubNub/chat-engine-apple/Tests/Tests/Fixtures";
    NSString *cassette = [NSStringFromClass([self class]) stringByAppendingPathExtension:@"bundle"];
    configuration.cassettesPath = [fixturesPath stringByAppendingPathComponent:cassette];
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

            NSString *namespace = client.currentConfiguration.namespace;
            for (NSString *component in [pathComponents copy]) {
                if ([component rangeOfString:namespace].location == NSNotFound || [component isEqualToString:@"chat-engine-server"]) {
                    continue;
                }
                
                NSString *replacement = [[component componentsSeparatedByString:namespace] componentsJoinedByString:@"namespace"];
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
            
            for (NSString *uuid in self.randomizedUUIDs) {
                if ([component rangeOfString:self.randomizedUUIDs[uuid]].location != NSNotFound) {
                    if ([request.URL.path hasPrefix:@"/publish/"] && componentIdx == pathComponents.count - 1) {
                        continue;
                    }
                    
                    replacement = [[component componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
                    break;
                }
            }
            
            for (NSString *randomNamespace in self.randomizedNamespaces.allValues) {
                if ([component rangeOfString:randomNamespace].location != NSNotFound) {
                    replacement = [[component componentsSeparatedByString:randomNamespace] componentsJoinedByString:@"namespace"];
                    break;
                }
            }
            
            for (NSString *randomGlobal in self.randomizedGlobals.allValues) {
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
        for (NSString *parameter in queryParameters.allKeys) {
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
            
            if ([parameter isEqualToString:@"namespace"]) {
                value = @"namespace";
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
            
            for (NSString *randomNamespace in self.randomizedNamespaces.allValues) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                value = [[value componentsSeparatedByString:randomNamespace] componentsJoinedByString:@"namespace"];
            }
            
            for (NSString *randomGlobal in self.randomizedGlobals.allValues) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                value = [[value componentsSeparatedByString:randomGlobal] componentsJoinedByString:@"chat-engine"];
            }
            
            for (NSString *uuid in self.randomizedUUIDs) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }

                value = [[value componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
            }
            
            [self.clients enumerateKeysAndObjectsUsingBlock:^(NSString * __unused identifier, CENChatEngine *client,
                                                              BOOL * __unused stop) {

                NSString *namespace = client.currentConfiguration.namespace;
                
                if ([value isKindOfClass:[NSString class]]) {
                    value = [[value componentsSeparatedByString:namespace] componentsJoinedByString:@"namespace"];
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
        
        for (NSString *uuid in self.randomizedUUIDs) {
            httpBodyString = [[httpBodyString componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
        }
        
        for (NSString *randomNamespace in self.randomizedNamespaces.allValues) {
            httpBodyString = [[httpBodyString componentsSeparatedByString:randomNamespace] componentsJoinedByString:@"namespace"];
        }
        
        for (NSString *randomGlobal in self.randomizedGlobals.allValues) {
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
        
        if (bodyContent[@"namespace"]) {
            bodyContent[@"namespace"] = @"namespace";
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
    
    for (NSString *uuid in self.randomizedUUIDs) {
        message = [[message componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
    }
    
    for (NSString *randomNamespace in self.randomizedNamespaces.allValues) {
        message = [[message componentsSeparatedByString:randomNamespace] componentsJoinedByString:@"namespace"];
    }
    
    for (NSString *randomGlobal in self.randomizedGlobals.allValues) {
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

    return [self createChatEngineForUser:user withConfiguration:[self configurationForTestCaseWithName:self.name]];
}

- (CENChatEngine *)createChatEngineWithConfiguration:(CENConfiguration *)configuration {

    return [self createChatEngineForUser:[[NSUUID UUID] UUIDString] withConfiguration:configuration];
}

- (CENChatEngine *)createChatEngineForUser:(NSString *)user withConfiguration:(CENConfiguration *)configuration {

    CENChatEngine *client = [CENChatEngine clientWithConfiguration:configuration];
    client.logger.enabled = CEN_LOGGER_ENABLED;
    client.logger.logLevel = CEN_LOGGER_ENABLED ? CENVerboseLogLevel : CENSilentLogLevel;

    if (!self.clients[user]) {
        self.clients[user] = client;
    } else if (!self.clientClones[user]) {
        self.clientClones[user] = client;
    } else {
        NSString *reason = [@"Attempt to create more than 2 instances for: " stringByAppendingString:user];

        @throw [NSException exceptionWithName:@"CENChatEngine setup" reason:reason userInfo:nil];
    }
    
    if (![configuration.namespace isEqualToString:@"namespace"]) {
        self.randomizedNamespaces[user] = self.randomizedNamespaces[user] ?: configuration.namespace;
    }
    
    return client;
}

- (void)setupChatEngineForUser:(NSString *)user {

    CENChatEngine *client = [self createChatEngineForUser:user];

    if ([self shouldConnectChatEngineForTestCaseWithName:self.name]) {
        [self connectUser:user usingClient:client];
    }
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
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    NSString *userUUID = [self randomNameWithUUID:user];
    CENUserConnectBuilderInterface *connection = client.connect(userUUID).authKey(userUUID);
    
    if (client.currentConfiguration.enableGlobal) {
        NSString *globalChannel = [self globalChatChannelForTestCaseWithName:self.name] ?: @"global";
        globalChannel = YHVVCR.cassette.isNewCassette ? globalChannel : @"chat-engine";
        
        self.randomizedGlobals[user] = self.randomizedGlobals[user] ?: globalChannel;
        connection = connection.globalChannel(globalChannel);
    }
    
    connection.perform().once(@"$.ready", ^(CENEmittedEvent *event) {
        client.pubnub.logger.enabled = CEN_PUBNUB_LOGGER_ENABLED;
        client.pubnub.logger.logLevel = CEN_PUBNUB_LOGGER_ENABLED ? PNVerboseLogLevel : PNSilentLogLevel;
        
        if ([self shouldWaitOwnPresenceEventsTestCaseWithName:self.name]) {
            dispatch_semaphore_t presenceSemaphore = dispatch_semaphore_create(0);
            
            if (client.global) {
                [self object:client shouldHandleEvent:@"$.online.*" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
                    return ^(CENEmittedEvent *emittedEvent) {
                        CENChat *chat = emittedEvent.emitter;
                        CENUser *user = emittedEvent.data;
                        
                        if ([user.uuid isEqualToString:user.uuid] && [chat.name isEqualToString:client.global.name]) {
                            handler();
                        }
                    };
                } afterBlock:^{ }];
            }
            
            dispatch_semaphore_wait(presenceSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * NSEC_PER_SEC)));
        }
        
        if (client.global && state.count) {
            if ([self shouldWaitOwnStateChangeEventTestCaseWithName:self.name]) {
                dispatch_semaphore_t stateSemaphore = dispatch_semaphore_create(0);
                
                client.me.update(state, nil);
                dispatch_semaphore_wait(stateSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayedCheck * 2.f * NSEC_PER_SEC)));
            } else {
                client.me.update(state, nil);
            }
        }

        dispatch_semaphore_signal(connectionSemaphore);
    }).once(@"$.error.*", ^(CENEmittedEvent *event) {
        dispatch_semaphore_signal(connectionSemaphore);
    }).once(@"$.error.**", ^(CENEmittedEvent *event) {
        dispatch_semaphore_signal(connectionSemaphore);
    });

    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
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
    
    me.update(state, me.chatEngine.global);
    me.chatEngine.once(@"$.state", ^(CENEmittedEvent *event) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - Mocking

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
    
    OCMStub([self.client handshakeChatAccess:[OCMArg any] withCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
        block();
    });
}

- (void)stubPubNubSubscribe {
    
    OCMStub([self.client connectToPubNubWithCompletion:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:1];
        block();
    });
}

- (CENChat *)feedChatForUser:(NSString *)uuid connectable:(BOOL)ableToConnect
              withChatEngine:(CENChatEngine *)chatEngine {
    
    NSString *namespace = [self namespaceForTestCaseWithName:self.name] ?: @"namespace";
    NSString *name = [@[namespace, @"user", uuid, @"read.#feed"] componentsJoinedByString:@"#"];
    CENChat *chat = chatEngine.Chat().name(name).autoConnect(NO).create();
    
    if (!ableToConnect) {
        OCMStub([chatEngine connectToChat:chat withCompletion:[OCMArg any]])
            .andDo(^(NSInvocation *invocation) {
                dispatch_block_t block = [self objectForInvocation:invocation argumentAtIndex:2];
                block();
            });
    }
    
    return chat;
}

- (CENChat *)directChatForUser:(NSString *)uuid connectable:(BOOL)ableToConnect
                withChatEngine:(CENChatEngine *)chatEngine {
    
    NSString *namespace = [self namespaceForTestCaseWithName:self.name] ?: @"namespace";
    NSString *name = [@[namespace, @"user", uuid, @"write.#direct"] componentsJoinedByString:@"#"];
    CENChat *chat = chatEngine.Chat().name(name).autoConnect(NO).create();
    
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

- (CENChat *)privateChatFromGroup:(NSString *)group withMeta:(NSDictionary *)meta
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
    
    return [chatEngine createChatWithName:name group:(group ?: CENChatGroup.custom) private:isPrivate
                              autoConnect:NO metaData:(meta ?: @{})];
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

- (void)waitForObject:(id)object recordedInvocation:(id)invocation call:(BOOL)shouldCall
       withinInterval:(NSTimeInterval)interval afterBlock:(void(^)(void))initalBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    ((OCMStubRecorder *)invocation).andDo(^(NSInvocation *expectedInvocation) {
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initalBlock) {
        initalBlock();
    }
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));
    if (shouldCall) {
        XCTAssertTrue(handlerCalled);
    } else {
        XCTAssertFalse(handlerCalled);
    }
    OCMVerifyAll(object);
}

- (void)waitForObject:(id)object recordedInvocationCall:(id)invocation withinInterval:(NSTimeInterval)interval
           afterBlock:(void(^)(void))initalBlock {
    
    [self waitForObject:object recordedInvocation:invocation call:YES withinInterval:interval
             afterBlock:initalBlock];
}

- (void)waitToCompleteIn:(NSTimeInterval)delay codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToCompleteIn:delay codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToCompleteIn:(NSTimeInterval)delay codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(void(^)(void))initalBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initalBlock) {
        initalBlock();
    }
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)object:(CENEventEmitter *)object
  shouldHandle:(BOOL)shouldHandle
        events:(NSArray<NSString *> *)events
withinInterval:(NSTimeInterval)interval
  withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
    afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_t handleGroup = dispatch_group_create();
    __block BOOL handlerCalled = NO;
    
    __weak __typeof__(object) weakObject = object;
    [events enumerateObjectsUsingBlock:^(NSString *event, NSUInteger eventIdx, BOOL *stop) {
        CENEventHandlerBlock(^handler)(dispatch_block_t) = handlers[eventIdx];
        __block BOOL handlerCalled = NO;
        
        dispatch_group_enter(handleGroup);
        [object handleEvent:event withHandlerBlock:handler(^{
            if (!handlerCalled) {
                handlerCalled = YES;
                [weakObject removeAllHandlersForEvent:event];
                dispatch_group_leave(handleGroup);
            }
        })];
    }];
    
    
    if (initialBlock) {
        initialBlock();
    }
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_notify(handleGroup, queue, ^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)));
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
    
    [self object:object shouldHandleEvent:event withinInterval:self.testCompletionDelay
     withHandler:handler afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
  shouldHandleEvent:(NSString *)event
     withinInterval:(NSTimeInterval)interval
        withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
         afterBlock:(void(^)(void))initialBlock {
    
    [self object:object shouldHandleEvents:@[event] withinInterval:interval withHandlers:@[handler]
      afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
  shouldHandleEvents:(NSArray<NSString *> *)events
      withinInterval:(NSTimeInterval)interval
        withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
          afterBlock:(void(^)(void))initialBlock {
    
    [self object:object shouldHandle:YES events:events withinInterval:interval withHandlers:handlers
      afterBlock:initialBlock];
}

- (void)waitForObject:(id)object recordedInvocationNotCall:(id)invocation
       withinInterval:(NSTimeInterval)interval afterBlock:(nullable void(^)(void))initialBlock {
    
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
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)));
    XCTAssertFalse(handlerCalled);
}

- (void)object:(CENEventEmitter *)object
    shouldNotHandleEvent:(NSString *)event
             withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
              afterBlock:(void(^)(void))initialBlock {
    
    [self object:object shouldNotHandleEvent:event withinInterval:self.falseTestCompletionDelay
     withHandler:handler afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
  shouldNotHandleEvent:(NSString *)event
        withinInterval:(NSTimeInterval)interval
           withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
            afterBlock:(void(^)(void))initialBlock {
    
    [self object:object shouldNotHandleEvents:@[event] withinInterval:interval
    withHandlers:@[handler] afterBlock:initialBlock];
}

- (void)object:(CENEventEmitter *)object
  shouldNotHandleEvents:(NSArray<NSString *> *)events
         withinInterval:(NSTimeInterval)interval
           withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
             afterBlock:(void(^)(void))initialBlock {
    
    [self object:object shouldHandle:NO events:events withinInterval:interval withHandlers:handlers
      afterBlock:initialBlock];
}

- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds {
    
    if (seconds <= 0.f) {
        return nil;
    }
    
    XCTestExpectation *waitExpectation = [self expectationWithDescription:taskName];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ [waitExpectation fulfill]; });
    [self waitForExpectations:@[waitExpectation] timeout:(seconds + 0.3f)];
    
    return waitExpectation;
}


#pragma mark - Helpers

- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index {
    
    __strong id object = [invocation objectForArgumentAtIndex:(index + 1)];
    
    [[CENTestCase invocationObjects] addObject:object];
    
    return object;
}


#pragma mark - Misc

- (NSString *)randomNameWithUUID:(NSString *)uuid {
    
    if (self.randomizedUUIDs[uuid]) {
        return self.randomizedUUIDs[uuid];
    }
    
    NSNumber *timestamp = @((NSUInteger)[NSDate date].timeIntervalSince1970);
    NSString *userUUID = [@[uuid, CENChatEngine.sdkVersion, timestamp] componentsJoinedByString:@"-"];
    userUUID = [userUUID stringByReplacingOccurrencesOfString:@"." withString:@"-"];

    self.randomizedUUIDs[uuid] = YHVVCR.cassette.isNewCassette ? userUUID : uuid;
    
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
