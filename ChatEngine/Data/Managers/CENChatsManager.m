/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
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

@property (nonatomic, nullable, strong) NSMapTable<NSString *, CENChat *> *chatsMap;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, nullable, weak) CENChatEngine *chatEngine;
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
    
    [NSException raise:NSDestinationInvalidException format:@"-init not implemented, please use: +managerForChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        NSString *resourceQueueIdentifier = [NSString stringWithFormat:@"com.chatengine.manager.chats.%p", self];
        _resourceAccessQueue = dispatch_queue_create([resourceQueueIdentifier UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _chatsMap = [NSMapTable strongToStrongObjectsMapTable];
        _chatEngine = chatEngine;
        
        CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::Manager::Chats> %p instance allocation", self);
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

- (void)disconnectChats {
    
    dispatch_async(self.resourceAccessQueue, ^{
        [[self.chatsMap objectEnumerator].allObjects makeObjectsPerformSelector:@selector(sleep)];
        [self->_global sleep];
    });
}


#pragma mark - Creation

- (CENChat *)createChatWithName:(NSString *)name
                         group:(NSString *)group
                       private:(BOOL)isPrivate
                   autoConnect:(BOOL)shouldAutoConnect
                      metaData:(NSDictionary *)meta {
    
    __block CENChat *chat = nil;
    __block BOOL chatCreated = NO;
    NSString *namespace = self.chatEngine.configuration.globalChannel;
    BOOL isGlobal = [name isEqualToString:namespace];
    name = name ?: @((NSUInteger)[[NSDate date] timeIntervalSince1970]).stringValue;
    NSString *internalName = [CENChat internalNameFor:name inNamespace:namespace private:isPrivate];
    group = [(group ?: CENChatGroup.custom) componentsSeparatedByString:@"#"].lastObject;
    meta = meta ?: @{};
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Create '%@' %@ chat in '%@' group%@.%@", name, isPrivate ? @"private" : @"public",
                 group, shouldAutoConnect ? @" and connect" : @"", meta.count ? [@[@" Meta: ", meta] componentsJoinedByString:@""] : @"");
    
    dispatch_barrier_sync(self.resourceAccessQueue, ^{
        chat = isGlobal ? self->_global : [self.chatsMap objectForKey:internalName];
        
        if (!chat) {
            chatCreated = YES;
            chat = [CENChat chatWithName:name namespace:namespace group:group private:isPrivate metaData:meta chatEngine:self.chatEngine];
            
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
            
            if (shouldAutoConnect) {
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
        NSString *namespace = self.chatEngine.configuration.globalChannel;
        BOOL isGlobal = [name isEqualToString:namespace];
        NSString *internalName = [CENChat internalNameFor:name inNamespace:namespace private:isPrivate];
        
        dispatch_sync(self.resourceAccessQueue, ^{
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
    
    if (([eventType isEqualToString:@"join"] && !join)) {
        join = @[presenceData.uuid];
    } else if ([eventType isEqualToString:@"leave"]) {
        leave = @[presenceData.uuid];
    } else if ([eventType isEqualToString:@"timeout"]) {
        timeout = @[presenceData.uuid];
    } else if ([eventType isEqualToString:@"state-change"]) {
        stateChange = @[presenceData.uuid];
        CENUser *user = [self.chatEngine.usersManager createUserWithUUID:presenceData.uuid state:presenceData.state];
        
        [user assignState:presenceData.state];
    }
    
    [chat handleRemoteUsersJoin:[self.chatEngine.usersManager createUsersWithUUID:join]];
    [chat handleRemoteUsersLeave:[self.chatEngine.usersManager createUsersWithUUID:leave]];
    [chat handleRemoteUsersDisconnect:[self.chatEngine.usersManager createUsersWithUUID:timeout]];
    [chat handleRemoteUsersStateChange:[self.chatEngine.usersManager createUsersWithUUID:stateChange]];
}


#pragma mark - Clean up

- (void)destroy {
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        [[self.chatsMap objectEnumerator].allObjects makeObjectsPerformSelector:@selector(destruct)];
        [self.chatsMap removeAllObjects];
        [self->_global destruct];
        self->_global = nil;
    });
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::Manager::Chats> %p instance deallocation", self);
}

#pragma mark -

@end
