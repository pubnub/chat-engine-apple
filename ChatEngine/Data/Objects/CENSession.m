/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENSession+Private.h"
#import "CENChatEngine+ChatInterface.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+Session.h"
#import "CENChatEngine+Private.h"
#import "CENChatEngine+User.h"
#import "CENObject+Private.h"
#import "CENChat+Interface.h"
#import "CENChat+Private.h"
#import "CENLogMacro.h"
#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Proteced interface declaration


@interface CENSession ()


#pragma mark - Information

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMapTable<NSString *, CENChat *> *> *groupsToChatsMap;
@property (nonatomic, strong) dispatch_queue_t sessionAccessQueue;
@property (nonatomic, strong) CENChat *sync;


#pragma mark - Handlers

- (void)handleJoinToChat:(NSDictionary *)chatData;
- (void)handleLeaveFromChat:(NSDictionary *)chatData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENSession


#pragma mark - Information

+ (NSString *)objectType {
    
    return @"session";
}

- (NSDictionary<NSString *, NSDictionary<NSString *, CENChat *> *> *)chats {
    
    NSMutableDictionary *chats = [NSMutableDictionary new];
    
    dispatch_sync(self.resourceAccessQueue, ^{
        for (NSString *group in self.groupsToChatsMap) {
            NSDictionary *groupChats = [self.groupsToChatsMap[group] dictionaryRepresentation];
            
            if (groupChats.count) {
                chats[group] = groupChats;
            }
        }
    });
    
    return chats.count ? chats : nil;
}


#pragma mark - Initialization and configuration

+ (instancetype)sessionWithChatEngine:(CENChatEngine *)chatEngine {
    
    return [[self alloc] initWithChatEngine:chatEngine];
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super initWithChatEngine:chatEngine])) {
        _sessionAccessQueue = dispatch_queue_create("com.chatengine.session", DISPATCH_QUEUE_SERIAL);
        _groupsToChatsMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}


- (void)destruct {
    
    dispatch_sync(self.sessionAccessQueue, ^{
        [self.groupsToChatsMap removeAllObjects];
        [self.sync destruct];
    });
    
    [super destruct];
}


#pragma mark - Synchronization

- (void)listenEvents {
    
    self.sync = [self.chatEngine synchronizationChat];
    
    __weak __typeof__(self) weakSelf = self;
    [self.sync handleEvent:@"$.session.notify.chat.join" withHandlerBlock:^(NSDictionary *payload) {
        [weakSelf handleJoinToChat:payload[CENEventData.data][@"subject"]];
    }];
    
    [self.sync handleEvent:@"$.session.notify.chat.leave" withHandlerBlock:^(NSDictionary *payload) {
        [weakSelf handleLeaveFromChat:payload[CENEventData.data][@"subject"]];
    }];
}

- (void)restore {
    
    [self.chatEngine synchronizeSessionChatsWithCompletion:^(NSString *group, NSArray<NSString *> *chats) {
        for (NSString *channelName in chats) {
            [self handleJoinToChat:@{
                CENChatData.channel: channelName,
                CENChatData.private: @([CENChat isPrivate:channelName]),
                CENChatData.group: group
            }];
        };
        
        [self.chatEngine triggerEventLocallyFrom:self event:@"$.group.restored", group, nil];
    }];
}


- (void)joinChat:(CENChat *)chat {
    
    dispatch_async(self.sessionAccessQueue, ^{
        if (![self.groupsToChatsMap[chat.group] objectForKey:chat.channel]) {
            [self.sync emitEvent:@"$.session.notify.chat.join" withData:@{ @"subject": [chat dictionaryRepresentation] }];
        }
    });
}

- (void)leaveChat:(CENChat *)chat {
    
    dispatch_async(self.sessionAccessQueue, ^{
        [self.sync emitEvent:@"$.session.notify.chat.leave" withData:@{ @"subject": [chat dictionaryRepresentation] }];
    });
}


#pragma mark - Handlers

- (void)handleJoinToChat:(NSDictionary *)chatData {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSString *group = chatData[CENChatData.group];
        NSString *internalName = chatData[CENChatData.channel];
        NSDictionary *meta = chatData[CENChatData.meta];
        BOOL isPrivate = ((NSNumber *)chatData[CENChatData.private]).boolValue;
        
        if (!self.groupsToChatsMap[group]) {
            self.groupsToChatsMap[group] = [NSMapTable strongToWeakObjectsMapTable];
        }
        
        CENChat *chat = [self.chatEngine chatWithName:internalName private:isPrivate];
        
        if (chat) {
            [self.groupsToChatsMap[group] setObject:chat forKey:internalName];
        } else {
            chat = [self.chatEngine createChatWithName:internalName group:group private:isPrivate autoConnect:NO metaData:meta];
            
            [self.groupsToChatsMap[group] setObject:chat forKey:internalName];
            [self.chatEngine triggerEventLocallyFrom:self event:@"$.chat.join", chat, nil];
        }
    });
}

- (void)handleLeaveFromChat:(NSDictionary *)chatData {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSString *group = chatData[CENChatData.group];
        NSString *internalName = chatData[CENChatData.channel];
        BOOL isPrivate = ((NSNumber *)chatData[CENChatData.private]).boolValue;
        CENChat *chat = [self.chatEngine chatWithName:internalName private:isPrivate];
        
        if (chat && [self.groupsToChatsMap[group] objectForKey:internalName]) {
            [self.groupsToChatsMap[group] removeObjectForKey:internalName];
            [self.chatEngine removeChat:chat];
            [self.chatEngine triggerEventLocallyFrom:self event:@"$.chat.leave", chat, nil];
        }
    });
}


#pragma mark - Misc

- (NSString *)description {
    
    NSMutableArray *groupsInformation = [NSMutableArray new];
    dispatch_sync(self.resourceAccessQueue, ^{
        for (NSString *group in self.groupsToChatsMap.allKeys) {
            NSUInteger chatsInGroup = self.groupsToChatsMap[group].count;
            
            [groupsInformation addObject:[NSString stringWithFormat:@"%@ (contains %@ chats)", group, @(chatsInGroup)]];
        }
    });
    
    groupsInformation = groupsInformation.count ? groupsInformation : nil;
    
    
    return [NSString stringWithFormat:@"<CENSession:%p user: '%@'; groups: %@>",
            self, self.chatEngine.me.uuid,
            [groupsInformation componentsJoinedByString:@", "] ?: @"none"];
}

#pragma mark -


@end
