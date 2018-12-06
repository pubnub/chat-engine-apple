/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChatsManager.h"
#import "CENChatEngine+PluginsPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENObject+Private.h"
#import "CENChat+Interface.h"
#import "CENUser+Private.h"
#import "CENChat+Private.h"
#import "CENStructures.h"
#import "CENLogMacro.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENChatsManager ()


#pragma mark - Information

/**
 * @brief Map of channel names to \b {chat CENChat} instance which they represent.
 */
@property (nonatomic, nullable, strong) NSMapTable<NSString *, CENChat *> *chatsMap;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief \b {ChatEngine CENChatEngine} which instantiated this manager.
 */
@property (nonatomic, nullable, weak) CENChatEngine *chatEngine;

/**
 * @brief Global communication \b {chat CENChat} if \b {CENConfiguration.enableGlobal} is set to
 * \c YES.
 */
@property (nonatomic, nullable, strong) CENChat *global;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENChatsManager


#pragma mark - Information

- (NSDictionary<NSString *,CENChat *> *)chats {
    
    __block NSDictionary<NSString *,CENChat *> *chats = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        chats = [self.chatsMap dictionaryRepresentation];
    });
    
    return chats.count ? chats : nil;
}

- (CENChat *)global {
    
    __block CENChat *global = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        global = self->_global;
    });
    
    return global;
}


#pragma mark - Initialization and Configuration

+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine {
    
    return [[self alloc] initWithChatEngine:chatEngine];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException
                format:@"-init not implemented, please use: +managerForChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        NSString *queue = [NSString stringWithFormat:@"com.chatengine.manager.chats.%p", self];
        _resourceAccessQueue = dispatch_queue_create([queue UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _chatsMap = [NSMapTable strongToStrongObjectsMapTable];
        _chatEngine = chatEngine;
        
        CELogResourceAllocation(self.chatEngine.logger,
            @"<ChatEngine::Manager::Chats> %p instance allocation", self);
    }
    
    return self;
}


#pragma mark - Connection

- (void)connectChats {
    
    dispatch_async(self.resourceAccessQueue, ^{
        [[self.chatsMap objectEnumerator].allObjects makeObjectsPerformSelector:@selector(wake)];
        [self->_global wake];
    });
}

- (void)resetChatsConnection {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSArray<CENChat *> *chats = [self.chatsMap objectEnumerator].allObjects;
        
        [chats makeObjectsPerformSelector:@selector(resetConnection)];
        [self->_global resetConnection];
    });
}

- (void)disconnectChats {
    
    dispatch_async(self.resourceAccessQueue, ^{
        [[self.chatsMap objectEnumerator].allObjects makeObjectsPerformSelector:@selector(sleep)];
        [self->_global sleep];
    });
}


#pragma mark - Creation

- (CENChat *)createGlobalChat:(BOOL)isGlobal
                     withName:(NSString *)name
                        group:(NSString *)group
                      private:(BOOL)isPrivate
                  autoConnect:(BOOL)autoConnect
                     metaData:(NSDictionary *)meta {
    
    __block CENChat *chat = nil;
    __block BOOL chatCreated = NO;
    NSString *namespace = self.chatEngine.configuration.namespace;
    name = name ?: @((NSUInteger)[[NSDate date] timeIntervalSince1970]).stringValue;
    NSString *internalName = [CENChat internalNameFor:name inNamespace:namespace private:isPrivate];
    group = group ?: CENChatGroup.custom;
    meta = meta ?: @{};
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Create '%@' %@chat in '%@' group%@.%@",
        name, isPrivate ? @"private " : @"public ", group, autoConnect ? @" and connect" : @"",
        meta.count ? [@[@" Meta: ", meta] componentsJoinedByString:@""] : @"");
    
    dispatch_barrier_sync(self.resourceAccessQueue, ^{
        chat = isGlobal ? self->_global : [self.chatsMap objectForKey:internalName];
        
        if (!chat) {
            chatCreated = YES;
            chat = [CENChat chatWithName:name
                               namespace:namespace
                                   group:group
                                 private:isPrivate
                                metaData:meta
                              chatEngine:self.chatEngine];
            
            if (isGlobal) {
                self.global = chat;
            } else {
                [self.chatsMap setObject:chat forKey:internalName];
            }
        }
    });
    
    if (chat && chatCreated) {
        [self.chatEngine setupProtoPluginsForObject:chat withCompletion:^{
            [chat onCreate];
            
            if (autoConnect) {
                [chat connectChat];
            }
        }];
    }
    
    return chat;
}


#pragma mark - Audition

- (CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate {
    
    __block CENChat *chat = nil;
    
    if ([name isKindOfClass:[NSString class]] && name.length) {
        NSString *internalName = [CENChat internalNameFor:name
                                              inNamespace:self.chatEngine.configuration.namespace
                                                  private:isPrivate];
        
        dispatch_sync(self.resourceAccessQueue, ^{
            BOOL isGlobal = ([self->_global.name isEqualToString:name] ||
                             [self->_global.channel isEqualToString:name]);
            chat = isGlobal ? self->_global : [self.chatsMap objectForKey:internalName];
        });
    }
    
    return chat;
}


#pragma mark - Removal

- (void)removeChat:(CENChat *)chat {
    
    [chat destruct];
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        [self.chatsMap removeObjectForKey:chat.channel];
    });
}


#pragma mark - Handlers

- (void)handleChat:(CENChat *)chat message:(NSDictionary *)payload {
    
    if (!chat) {
        return;
    }
    
    [self.chatEngine triggerEventLocallyFrom:chat event:payload[CENEventData.event], payload, nil];
}

- (void)handleChat:(CENChat *)chat presenceEvent:(PNPresenceEventData *)information {
    
    if (!chat) {
        return;
    }
    
    PNPresenceDetailsData *presenceData = information.presence;
    NSString *eventType = information.presenceEvent;
    NSArray<NSString *> *join = presenceData.join.count ? presenceData.join : nil;
    NSArray<NSString *> *leave = presenceData.leave.count ? presenceData.leave : nil;
    NSArray<NSString *> *timeout = presenceData.timeout.count ? presenceData.timeout : nil;
    NSArray<NSString *> *stateChange = nil;
    NSMutableDictionary *usersState = [NSMutableDictionary new];
    BOOL onStateChange = NO;
    
    if (([eventType isEqualToString:@"join"] && !join)) {
        join = @[presenceData.uuid];
        usersState[presenceData.uuid] = presenceData.state;
    } else if ([eventType isEqualToString:@"leave"]) {
        leave = @[presenceData.uuid];
    } else if ([eventType isEqualToString:@"timeout"]) {
        timeout = @[presenceData.uuid];
    } else if ([eventType isEqualToString:@"state-change"]) {
        usersState[presenceData.uuid] = presenceData.state;
        stateChange = @[presenceData.uuid];
        join = @[presenceData.uuid];
        onStateChange = YES;
    }
    
    [chat handleRemoteUsersJoin:[self.chatEngine.usersManager createUsersWithUUID:join]
                     withStates:usersState onStateChange:onStateChange];
    [chat handleRemoteUsersLeave:[self.chatEngine.usersManager createUsersWithUUID:leave]];
    [chat handleRemoteUsersDisconnect:[self.chatEngine.usersManager createUsersWithUUID:timeout]];
    [chat handleRemoteUsers:[self.chatEngine.usersManager createUsersWithUUID:stateChange]
                stateChange:usersState];
}


#pragma mark - Clean up

- (void)destroy {
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        NSArray<CENChat *> *chats = [self.chatsMap objectEnumerator].allObjects;
        [chats makeObjectsPerformSelector:@selector(destruct)];
        [self.chatsMap removeAllObjects];
        [self->_global destruct];
        self->_global = nil;
    });
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger,
        @"<ChatEngine::Manager::Chats> %p instance deallocation", self);
}

#pragma mark -

@end
