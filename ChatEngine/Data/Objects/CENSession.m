/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
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
#import "CENEmittedEvent.h"
#import "CENDefines.h"
#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Proteced interface declaration


@interface CENSession ()


#pragma mark - Information

/**
 * @brief Map of group names to map of channel names and \b {chats CENChat} which has been
 * synchronized between \b {local user CENMe} devices.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMapTable<NSString *, CENChat *> *> *groupsToChatsMap;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, strong) dispatch_queue_t sessionAccessQueue;

/**
 * @brief Special \b { chat CENChat} which is used by user's devices to sync up changes in chats
 * list.
 */
@property (nonatomic, strong) CENChat *sync;


#pragma mark - Handlers

/**
 * @brief Handle chat join event from one of user's devices.
 *
 * @param data \a NSDictionary which contain serialized \b {chat CENChat} information.
 */
- (void)handleJoinToChat:(NSDictionary *)data;

/**
 * @brief Handle chat leave event from one of user's devices.
 *
 * @param data \a NSDictionary which contain serialized \b {chat CENChat} information.
 */
- (void)handleLeaveFromChat:(NSDictionary *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENSession


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.session;
}

- (NSDictionary<NSString *, CENChat *> *)chats {
    
    __block NSDictionary *chats = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        chats = [self.groupsToChatsMap[CENChatGroup.custom] dictionaryRepresentation];
    });
    
    return chats.count ? chats : nil;
}


#pragma mark - Initialization and configuration

+ (instancetype)sessionWithChatEngine:(CENChatEngine *)chatEngine {
    
    return [[self alloc] initWithChatEngine:chatEngine];
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super initWithChatEngine:chatEngine])) {
        const char *identifier = "com.chatengine.session";
        _sessionAccessQueue = dispatch_queue_create(identifier, DISPATCH_QUEUE_SERIAL);
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
    
    CENWeakify(self)
    [self.sync handleEvent:@"$.session.notify.chat.join"
          withHandlerBlock:^(CENEmittedEvent *event) {
        CENStrongify(self)
              
        NSDictionary *payload = event.data;
        
        [self handleJoinToChat:payload[CENEventData.data][@"subject"]];
    }];
    
    [self.sync handleEvent:@"$.session.notify.chat.leave"
          withHandlerBlock:^(CENEmittedEvent *event) {
        CENStrongify(self)
              
        NSDictionary *payload = event.data;
              
        [self handleLeaveFromChat:payload[CENEventData.data][@"subject"]];
    }];
}

- (void)restore {
    
    [self.chatEngine synchronizeSessionWithCompletion:^(NSString *group, NSArray *chats) {
        [self.groupsToChatsMap removeObjectForKey:group];
        
        for (NSString *channelName in chats) {
            [self handleJoinToChat:@{
                CENChatData.channel: channelName,
                CENChatData.private: @([CENChat isPrivate:channelName]),
                CENChatData.group: group
            }];
        };

        dispatch_async(self.resourceAccessQueue, ^{
            [self.chatEngine triggerEventLocallyFrom:self event:@"$.group.restored", group, nil];
        });
    }];
}


- (void)joinChat:(CENChat *)chat {
    
    __block BOOL alreadySynchronized = NO;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        alreadySynchronized = [self.groupsToChatsMap[chat.group] objectForKey:chat.channel] != nil;
    });

    if (alreadySynchronized) {
        return;
    }
    
    dispatch_async(self.sessionAccessQueue, ^{
        [self.sync emitEvent:@"$.session.notify.chat.join"
                    withData:@{ @"subject": [chat dictionaryRepresentation] }];
    });
}

- (void)leaveChat:(CENChat *)chat {
    
    dispatch_async(self.sessionAccessQueue, ^{
        [self.sync emitEvent:@"$.session.notify.chat.leave"
                    withData:@{ @"subject": [chat dictionaryRepresentation] }];
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
            chat = [self.chatEngine createChatWithName:internalName
                                                 group:group
                                               private:isPrivate
                                           autoConnect:NO
                                              metaData:meta];
            
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
    
    NSMutableArray *groups = [NSMutableArray new];
    dispatch_sync(self.resourceAccessQueue, ^{
        for (NSString *group in self.groupsToChatsMap.allKeys) {
            NSUInteger chatsInGroup = self.groupsToChatsMap[group].count;
            
            NSString *groupInformation = [NSString stringWithFormat:@"%@ (contains %@ chats)",
                                          group, @(chatsInGroup)];
            [groups addObject:groupInformation];
        }
    });
    
    groups = groups.count ? groups : nil;
    
    
    return [NSString stringWithFormat:@"<CENSession:%p user: '%@'; groups: %@>",
            self, self.chatEngine.me.uuid, [groups componentsJoinedByString:@", "] ?: @"none"];
}

#pragma mark -


@end
