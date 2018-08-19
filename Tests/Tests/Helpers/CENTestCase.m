/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENObject+Private.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <CENChatEngine/CENSession.h>
#import <YAHTTPVCR/YAHTTPVCR.h>
#import <OCMock/OCMock.h>


#define WRITTING_CASSETTES 1


#pragma mark Protected interface declaration

@interface CENTestCase ()


#pragma mark - Information

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
 * @brief Stores reference on list of generated and used global chat names.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedGlobalChatNames;

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
@property (nonatomic, strong) NSMutableArray *mocks;


/**
 * @brief  Stores reference on \b PubNub publish key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *publishKey;

/**
 * @brief  Stores reference on \b PubNub subscribe key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *subscribeKey;


#pragma mark - Chat mocking

/**
 * @brief  Create and configure \c chat instance with random parameters, which can be used for real
 *         chats mocking.
 *
 * @param isPrivate  Reference on flag which specify whether chat should be private or public.
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)chatForMocking:(BOOL)isPrivate chatEngine:(CENChatEngine *)chatEngine;


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


#pragma mark - Configuration

- (void)setUp {
    
    [super setUp];
    
    [self loadTestKeys];

    self.testCompletionDelay = 15.f;
    self.delayedCheck = 0.25f;
    self.falseTestCompletionDelay = (YHVVCR.cassette.isNewCassette ? self.testCompletionDelay : 0.25f);
    self.delayBetweenActions = YHVVCR.cassette.isNewCassette ? 5.f : 0.f;
    self.testCompletionDelayWithNestedSemaphores = (YHVVCR.cassette.isNewCassette ? 60.f : 15.f);
    self.randomizedGlobalChatNames = [NSMutableDictionary new];
    self.randomizedUUIDs = [NSMutableDictionary new];
    self.clientClones = [NSMutableDictionary new];
    self.clients = [NSMutableDictionary new];
    self.mocks = [NSMutableArray new];
}

- (void)tearDown {
    
    BOOL shouldPostponeTearDown = self.clients.count || self.clientClones.count;
    if (shouldPostponeTearDown && [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette) {
        NSLog(@"Test completed. Record final requests from clients.");
    }
    
    if (shouldPostponeTearDown || self.mocks.count) {
        [self waitTask:@"clientsTaskCompletion" completionFor:0.2f];
    }
    
    if (shouldPostponeTearDown && [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette) {
        NSLog(@"Destroy mock objects.");
    }
    
    [self.mocks makeObjectsPerformSelector:@selector(stopMocking)];
    [self.mocks removeAllObjects];
    
    if (shouldPostponeTearDown && [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette) {
        [self waitTask:@"mocksRemovalCompletion" completionFor:0.2f];
    }
    
    if (shouldPostponeTearDown && [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette) {
        NSLog(@"Destroy created ChatEngine instances.");
    }
    
    [self.clients.allValues makeObjectsPerformSelector:@selector(destroy)];
    [self.clientClones.allValues makeObjectsPerformSelector:@selector(destroy)];
    
    if (shouldPostponeTearDown && [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette) {
        [self waitTask:@"clientsRemovalCompletion" completionFor:4.0f];
    }
    
    [self.clientClones removeAllObjects];
    [self.clients removeAllObjects];
    
    if (shouldPostponeTearDown && [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette) {
        NSLog(@"Record cassette's content.");
    }
    
    [super tearDown];
}

- (CENConfiguration *)defaultConfiguration {
    
    return [CENConfiguration configurationWithPublishKey:self.publishKey subscribeKey:self.subscribeKey];
}


#pragma mark - VCR configuration

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
#if WRITTING_CASSETTES
    NSString *cassette = [NSStringFromClass([self class]) stringByAppendingPathExtension:@"bundle"];
    configuration.cassettesPath = [@"/Volumes/Develop/Projects/Xcode/PubNub/chat-engine-apple/Tests/Tests/Fixtures" stringByAppendingPathComponent:cassette];
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

        [self.clients enumerateKeysAndObjectsUsingBlock:^(NSString * __unused identifider, CENChatEngine *client, BOOL * __unused stop) {
            NSString *globalChannel = client.currentConfiguration.globalChannel;
            for (NSString *component in [pathComponents copy]) {
                if ([component rangeOfString:globalChannel].location == NSNotFound) {
                    continue;
                }
                
                NSString *replacement = [[component componentsSeparatedByString:globalChannel] componentsJoinedByString:@"chatEngine"];
                [pathComponents replaceObjectAtIndex:[pathComponents indexOfObject:component] withObject:replacement];
            }
        }];
        
        for (NSString *component in [pathComponents copy]) {
            NSUInteger componentIdx = [pathComponents indexOfObject:component];
            id replacement = component;
            
            if (component.length > 10 && ([component isEqualToString:self.publishKey] || [component isEqualToString:self.subscribeKey])) {
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
            
            for (NSString *globalChat in self.randomizedGlobalChatNames.allValues) {
                if ([component rangeOfString:globalChat].location != NSNotFound) {
                    replacement = [[component componentsSeparatedByString:globalChat] componentsJoinedByString:@"chatEngine"];
                    break;
                }
            }
            
            [pathComponents replaceObjectAtIndex:componentIdx withObject:replacement];
        }
        
        return [pathComponents componentsJoinedByString:@"/"];
    };
    
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        for (NSString *parameter in queryParameters.allKeys) {
            __block id value = queryParameters[parameter];
            
            if ([parameter hasPrefix:@"l_"] || [parameter isEqualToString:@"deviceid"] || [parameter isEqualToString:@"instanceid"] || [parameter isEqualToString:@"requestid"]) {
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
                value = @"chatEngine";
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
            
            for (NSString *globalChat in self.randomizedGlobalChatNames.allValues) {
                if (![value isKindOfClass:[NSString class]] || [globalChat isEqualToString:@"global"]) {
                    continue;
                }
                
                value = [[value componentsSeparatedByString:globalChat] componentsJoinedByString:@"chatEngine"];
            }
            
            for (NSString *uuid in self.randomizedUUIDs) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }

                value = [[value componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
            }
            
            [self.clients enumerateKeysAndObjectsUsingBlock:^(NSString * __unused identifider, CENChatEngine *client, BOOL * __unused stop) {
                NSString *globalChannel = client.currentConfiguration.globalChannel;
                
                if ([value isKindOfClass:[NSString class]]) {
                    value = [[value componentsSeparatedByString:globalChannel] componentsJoinedByString:@"chatEngine"];
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
        
        for (NSString *globalChat in self.randomizedGlobalChatNames.allValues) {
            if ([globalChat isEqualToString:@"global"]) {
                continue;
            }
            
            httpBodyString = [[httpBodyString componentsSeparatedByString:globalChat] componentsJoinedByString:@"chatEngine"];
        }
        
        NSData *bodyData = [httpBodyString dataUsingEncoding:NSUTF8StringEncoding];
        NSJSONReadingOptions readOptions = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments;
        id bodyContent = bodyData;
        
        if (![request.URL.absoluteString hasSuffix:@".png"] && ![request.URL.absoluteString hasSuffix:@".jpg"]) {
            bodyContent = [NSJSONSerialization JSONObjectWithData:bodyData options:readOptions error:nil];
        }
        
        if (![bodyContent isKindOfClass:[NSDictionary class]]) {
            return body;
        }
        
        if (bodyContent[@"global"]) {
            bodyContent[@"global"] = @"chatEngine";
            if ([bodyContent[@"chat"][@"channel"] rangeOfString:@"global"].location != NSNotFound) {
                bodyContent[@"chat"][@"channel"] = [[bodyContent[@"chat"][@"channel"] componentsSeparatedByString:@"global"] componentsJoinedByString:@"chatEngine"];
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
        
        return postBodyFilter(request, data);
    };
}


#pragma mark - VCR filter

- (NSString *)filteredPublishMessageFrom:(NSString *)message {
    
    for (NSString *uuid in self.randomizedUUIDs) {
        message = [[message componentsSeparatedByString:self.randomizedUUIDs[uuid]] componentsJoinedByString:uuid];
    }
    
    for (NSString *globalChat in self.randomizedGlobalChatNames.allValues) {
        message = [[message componentsSeparatedByString:globalChat] componentsJoinedByString:@"chatEngine"];
    }
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *payload = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] mutableCopy];
    
    payload[CENEventData.sdk] = @"objc";
    payload[CENEventData.eventID] = @"unique-event-id";
    
    data = [NSJSONSerialization dataWithJSONObject:payload options:(NSJSONWritingOptions)0 error:nil];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


#pragma mark - Client configuration

- (CENChatEngine *)chatEngineWithConfiguration:(CENConfiguration *)configuration {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    self.clients[uuid] = [CENChatEngine clientWithConfiguration:configuration];
    self.clients[uuid].logger.enabled = NO;
    
    return self.clients[uuid];
}

- (void)setupChatEngineForUser:(NSString *)user withSynchronization:(BOOL)synchronizeSession meta:(BOOL)synchronizeMeta state:(NSDictionary *)state {
    
    NSNumber *timestamp = @((NSUInteger)[NSDate date].timeIntervalSince1970);
    NSString *globalChannel = [@[@"test", CENChatEngine.sdkVersion, timestamp] componentsJoinedByString:@"-"];
    
    [self setupChatEngineWithGlobal:globalChannel forUser:user synchronization:synchronizeSession meta:synchronizeMeta state:state];
}

- (void)setupChatEngineWithConfiguration:(CENConfiguration *)configuration forUser:(NSString *)user withState:(NSDictionary *)state {
    
    NSString *userUUID = [self randomNameWithUUID:user];
    
    configuration.globalChannel = self.randomizedGlobalChatNames[user] ?: configuration.globalChannel;
    CENChatEngine *client = [CENChatEngine clientWithConfiguration:configuration];
    client.logger.enabled = NO;
    
    if (!self.clients[user]) {
        self.clients[user] = client;
    } else if (!self.clientClones[user]) {
        self.clientClones[user] = client;
    } else {
        @throw [NSException exceptionWithName:@"CENChatEngine setup"
                                       reason:[@"Attempt to create more than 2 instances for: " stringByAppendingString:user]
                                     userInfo:nil];
    }
    
    self.randomizedGlobalChatNames[user] = self.randomizedGlobalChatNames[user] ?: configuration.globalChannel;
    [self connectUser:userUUID withAuthKey:userUUID state:state usingClient:client];
}

- (void)setupChatEngineWithGlobal:(nullable NSString *)globalChannel
                          forUser:(NSString *)user
                  synchronization:(BOOL)synchronizeSession
                             meta:(BOOL)synchronizeMeta
                            state:(NSDictionary *)state {
    
    globalChannel = [globalChannel stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    CENConfiguration *configuration = [self defaultConfiguration];
    NSString *userUUID = [self randomNameWithUUID:user];
    configuration.synchronizeSession = synchronizeSession;
    configuration.throwExceptions = YES;
    configuration.globalChannel = YHVVCR.cassette.isNewCassette ? globalChannel : @"chatEngine";
    
    CENChatEngine *client = [CENChatEngine clientWithConfiguration:configuration];
    client.logger.enabled = NO;
    
    if (!self.clients[user]) {
        self.clients[user] = client;
    } else if (!self.clientClones[user]) {
        self.clientClones[user] = client;
    } else {
        @throw [NSException exceptionWithName:@"CENChatEngine setup"
                                       reason:[@"Attempt to create more than 2 instances for: " stringByAppendingString:user]
                                     userInfo:nil];
    }
    
    self.randomizedGlobalChatNames[user] = self.randomizedGlobalChatNames[user] ?: configuration.globalChannel;
    [self connectUser:userUUID withAuthKey:userUUID state:state usingClient:client];
}

- (CENChatEngine *)chatEngineForUser:(NSString *)user {
    
    return self.clients[user];
}

- (CENChatEngine *)chatEngineCloneForUser:(NSString *)user {
    
    return self.clientClones[user];
}


#pragma mark - Connection

- (void)connectUser:(NSString *)uuid withAuthKey:(NSString *)authKey state:(NSDictionary *)state usingClient:(CENChatEngine *)client {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    client.connect(uuid).state(state).authKey(authKey).perform();
    client.once(@"$.ready", ^(CENMe *me) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)disconnectUserUsingClient:(CENChatEngine *)client {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    client.disconnect();
    client.once(@"$.disconnected", ^(CENMe *me) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)reconnectUserUsingClient:(CENChatEngine *)client {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    client.reconnect();
    client.once(@"$.connected", ^(CENChat *chat) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - State

- (void)updateState:(NSDictionary *)state forUser:(CENMe *)me {
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    
    me.update(state);
    me.chatEngine.once(@"$.state", ^(CENMe *me) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - Mocking

- (id)mockForClass:(Class)cls {
    
    id classMock = OCMClassMock(cls);
    
    [self.mocks addObject:classMock];
    
    return classMock;
}

- (id)partialMockForObject:(id)object {

    __strong id partialMock = OCMPartialMock(object);
    
    [self.mocks addObject:partialMock];
    
    return partialMock;
}


#pragma mark - Chat mocking

- (CENChat *)privateChatForMockingWithChatEngine:(CENChatEngine *)chatEngine {
    
    return [self chatForMocking:YES chatEngine:chatEngine];
}

- (CENChat *)publicChatForMockingWithChatEngine:(CENChatEngine *)chatEngine {
    
    return [self chatForMocking:NO chatEngine:chatEngine];
}

- (CENChat *)chatForMocking:(BOOL)isPrivate chatEngine:(CENChatEngine *)chatEngine {
    
    NSString *name = [[NSUUID UUID] UUIDString];
    NSString *namespace = [[NSUUID UUID] UUIDString];
    
    return [CENChat chatWithName:name namespace:namespace group:CENChatGroup.custom private:isPrivate metaData:@{} chatEngine:chatEngine];
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
