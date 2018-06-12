/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase+Private.h"
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import <CENChatEngine/CENSession.h>
#import <OCMock/OCMock.h>


#pragma mark Protected interface declaration

@interface CENTestCase ()


#pragma mark - Information

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
    
    self.randomizedUUIDs = [NSMutableDictionary new];
    self.clientClones = [NSMutableDictionary new];
    self.clients = [NSMutableDictionary new];
    self.mocks = [NSMutableArray new];
}

- (void)tearDown {
    
    BOOL shouldPostponeTearDown = self.clients.count || self.clientClones.count;
    
    [self.clients.allValues makeObjectsPerformSelector:@selector(destroy)];
    [self.clientClones.allValues makeObjectsPerformSelector:@selector(destroy)];
    
    [self.clientClones removeAllObjects];
    [self.clients removeAllObjects];
    
    if (shouldPostponeTearDown) {
        [self waitTask:@"testTearDown" completionFor:0.1f];
    }
    
    [self.mocks makeObjectsPerformSelector:@selector(stopMocking)];
    [self.mocks removeAllObjects];
    
    [super tearDown];
}


#pragma mark - Classes

- (Class)chatEngineClass {
    
    return [CENChatEngine class];
}

- (Class)sessionClass {
    
    return [CENSession class];
}

- (Class)userClass {
    
    return [CENUser class];
}

- (Class)meClass {
    
    return [CENMe class];
}


#pragma mark - Client configuration

- (CENChatEngine *)chatEngineWithConfiguration:(CENConfiguration *)configuration {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    self.clients[uuid] = [[self chatEngineClass] clientWithConfiguration:configuration];
    
    return self.clients[uuid];
}

- (void)setupChatEngineForUser:(NSString *)user withSynchronization:(BOOL)synchronizeSession meta:(BOOL)synchronizeMeta state:(NSDictionary *)state {
    
    NSNumber *timestamp = @((NSUInteger)[NSDate date].timeIntervalSince1970);
    NSString *globalChannel = [@[@"test", CENChatEngine.sdkVersion, timestamp] componentsJoinedByString:@"-"];
    
    [self setupChatEngineWithGlobal:globalChannel forUser:user synchronization:synchronizeSession meta:synchronizeMeta state:state];
}

- (void)setupChatEngineWithGlobal:(nullable NSString *)globalChannel
                          forUser:(NSString *)user
                  synchronization:(BOOL)synchronizeSession
                             meta:(BOOL)synchronizeMeta
                            state:(NSDictionary *)state {
    
    globalChannel = [globalChannel stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    NSString *userUUID = [self randomNameWithUUID:user];
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:self.publishKey subscribeKey:self.subscribeKey];
    configuration.synchronizeSession = synchronizeSession;
    configuration.throwExceptions = YES;
    configuration.globalChannel = globalChannel;
    
    CENChatEngine *client = [[self chatEngineClass] clientWithConfiguration:configuration];
    
    if (!self.clients[user]) {
        self.clients[user] = client;
    } else if (!self.clientClones[user]) {
        self.clientClones[user] = client;
    } else {
        @throw [NSException exceptionWithName:@"CENChatEngine setup"
                                       reason:[@"Attempt to create more than 2 instances for: " stringByAppendingString:user]
                                     userInfo:nil];
    }
    
    dispatch_semaphore_t connectionSemaphore = dispatch_semaphore_create(0);
    client.connect(userUUID).state(state).authKey(userUUID).perform();
    client.on(@"$.ready", ^(CENMe *me) {
        dispatch_semaphore_signal(connectionSemaphore);
    });
    dispatch_semaphore_wait(connectionSemaphore, DISPATCH_TIME_FOREVER);
}

- (CENChatEngine *)chatEngineForUser:(NSString *)user {
    
    return self.clients[user];
}

- (CENChatEngine *)chatEngineCloneForUser:(NSString *)user {
    
    return self.clientClones[user];
}


#pragma mark - Mocking

- (id)mockForClass:(Class)cls {
    
    id classMock = OCMClassMock(cls);
    
    [self.mocks addObject:classMock];
    
    return classMock;
}

- (id)partialMockForObject:(id)object {

    id partialMock = OCMPartialMock(object);
    
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

- (void)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds {
    
    XCTestExpectation *waitExpectation = [self expectationWithDescription:taskName];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ [waitExpectation fulfill]; });
    [self waitForExpectations:@[waitExpectation] timeout:(seconds + 0.3f)];
}


#pragma mark - Misc

- (NSString *)randomNameWithUUID:(NSString *)uuid {
    
    if (self.randomizedUUIDs[uuid]) {
        return self.randomizedUUIDs[uuid];
    }
    
    NSNumber *timestamp = @((NSUInteger)[NSDate date].timeIntervalSince1970);
    NSString *userUUID = [@[uuid, CENChatEngine.sdkVersion, timestamp] componentsJoinedByString:@"-"];
    userUUID = [userUUID stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    
    self.randomizedUUIDs[uuid] = userUUID;
    
    return userUUID;
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
