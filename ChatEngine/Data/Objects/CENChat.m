/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChat+Private.h"
#import "CENChat+Interface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENChatSearchBuilderInterface.h"
    #import "CENChatEmitBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
    #import "CENChat+BuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+AuthorizationPrivate.h"
#import "CENChatEngine+PluginsPrivate.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENSenderAugmentationPlugin.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatAugmentationPlugin.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Publish.h"
#import "CENChatEngine+Private.h"
#import "CENPrivateStructures.h"
#import "CENChatEngine+Search.h"
#import "CENChatEngine+User.h"
#import "CENObject+Private.h"
#import "CENSearch+Private.h"
#import "CENObject+Plugins.h"
#import "CENEvent+Private.h"
#import "CENUser+Private.h"
#import "CENEmittedEvent.h"
#import "CENErrorCodes.h"
#import "CENConstants.h"
#import "CENLogMacro.h"
#import "CENDefines.h"
#import "CENSession.h"
#import "CENError.h"
#import "CENUser.h"
#import "CENMe.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENChatDataKeys CENChatData = {
    .channel = @"channel",
    .group = @"group",
    .private = @"private",
    .meta = @"meta"
};


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENChat ()


#pragma mark - Information

/**
 * @brief Block which used for delayed participants refresh on chat.
 *
 * @discussion Reference used by memory clean up code to ensure, what destroyed chat won't try to
 * fetch participants after small delay.
 */
@property (nonatomic, nullable, copy) dispatch_block_t participantsDelayedRefreshBlock;

/**
 * @brief List of users in this chat.
 *
 * @discussion Automatically kept in sync as users join and leave the chat. Use \b {$.online.join}
 * and related events to get notified when this changes.
 */
@property (nonatomic, strong) NSMapTable<NSString *, CENUser *> *usersMap;

/**
 * @brief List of offline users in this chat.
 *
 * @discussion Automatically kept in sync as users disconnect from chat.
 */
@property (nonatomic, strong) NSHashTable<NSString *> *offlineUsersMap;

/**
 * @brief \a NSDictionary which holds recent state change for \b {local user CENMe}.
 *
 * @discussion This property used to track when \b PubNub network will confirm what
 * \b {local user CENMe} state has been changed.
 */
@property (nonatomic, nullable, strong) NSDictionary *pendingStateChanges;

@property (nonatomic, assign, getter=isPrivate) BOOL private;
@property (nonatomic, assign) BOOL hasConnected;
@property (nonatomic, copy) NSDictionary *meta;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL asleep;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure new chat instance.
 *
 * @param name Unique alphanumeric chat identifier with maximum 50 characters. Usually something
 *     like \c {The Watercooler}, \c {Support}, or \c {Off Topic}. See \b {PubNub Channels https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-}.
 *     PubNub \c channel names are limited to \c 92 characters. If a user exceeds this limit while
 *     creating chat, an \c error will be thrown. The limit includes the prefixes and suffixes added
 *     by the chat engine as listed \b {here pubnub-channel-topology}.
 * @param nspace Namespace inside of which chat will be created.
 * @param group Chat list group identifier.
 * @param isPrivate Whether \b {chat CENChat} access should be restricted only to invited users or
 *     not.
 * @param meta Chat metadata that will be persisted on the server and populated on creation.
 *     To use this parameter \b {CENConfiguration.enableMeta} should be set to \c YES during
 *     \b {CENChatEngine} client configuration.
 * @param chatEngine \b {CENChatEngine} client which will manage this chat instance.
 *
 * @return Ready to use chat instance.
 */
- (instancetype)initWithName:(NSString *)name
                   namespace:(NSString *)nspace
                       group:(NSString *)group
                     private:(BOOL)isPrivate
                    metaData:(NSDictionary *)meta
                  chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Handlers

/**
 * @brief Handle initial chat connection event.
 */
- (void)handleReadyForConnection;

/**
 * @brief Handle chat connection / awake completion event.
 */
- (void)handleConnection;

/**
 * @brief Handle chat connection / awake completion event.
 *
 * @param shouldUseQueue Whether handle code should be executed on serialization queue or not.
 */
- (void)handleConnectionOnQueue:(BOOL)shouldUseQueue;

/**
 * @brief Handle chat disconnection / sleep completion event.
 */
- (void)handleDisconnection;


#pragma mark - Misc

/**
 * @brief Retrieve information about user's presence in this chat.
 *
 * @discussion Along with check, user record will be added to users map and removed from offline.
 *
 * @param exists Pointer to which user's existence flag value will be stored.
 * @param offline Pointer to which user's offline presence flag value will be stored.
 */
- (void)getUserPresenceInChat:(CENUser *)user exists:(BOOL *)exists offline:(BOOL *)offline;

/**
 * @brief Chat serialization helper.
 *
 * @param shouldUseQueue Whether serialization should be done on serialization queue or not.
 *
 * @return Chat's dictionary representation.
 */
- (NSDictionary *)dictionaryRepresentationOnQueue:(BOOL)shouldUseQueue;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENChat


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.chat;
}

- (CENChat *)defaultStateChat {
    
    return self;
}

- (NSString *)identifier {
    
    return self.channel;
}

- (NSDictionary *)meta {
    
    __block NSDictionary *meta = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        meta = [self->_meta copy];
    });
    
    return meta;
}

- (NSDictionary<NSString *,CENUser *> *)users {
    
    __block NSDictionary<NSString *,CENUser *> *users = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        users = [self.usersMap dictionaryRepresentation];
    });
    
    return users;
}


#pragma mark - Initialization and Configuration

+ (instancetype)chatWithName:(NSString *)name
                   namespace:(NSString *)nspace
                       group:(NSString *)group
                     private:(BOOL)isPrivate
                    metaData:(NSDictionary *)meta
                  chatEngine:(CENChatEngine *)chatEngine {
    
    static NSArray<NSString *> *groups;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        groups = @[CENChatGroup.system, CENChatGroup.custom];
    });
    
    if (![name isKindOfClass:[NSString class]] || !name.length ||
        ![nspace isKindOfClass:[NSString class]] || !nspace.length ||
        ![group isKindOfClass:[NSString class]] || !group.length ||
        ![groups containsObject:group.lowercaseString] ||
        ![chatEngine isKindOfClass:[CENChatEngine class]]) {
        
        return nil;
    }
    
    return [[self alloc] initWithName:name
                            namespace:nspace
                                group:group
                              private:isPrivate
                             metaData:meta
                           chatEngine:chatEngine];
}

- (instancetype)initWithName:(NSString *)name
                   namespace:(NSString *)nspace
                       group:(NSString *)group
                     private:(BOOL)isPrivate
                    metaData:(NSDictionary *)meta
                  chatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super initWithChatEngine:chatEngine])) {
        _group = [group copy];
        _private = isPrivate;
        _meta = [(meta ?: @{}) copy];
        _channel = [[self class] internalNameFor:name inNamespace:nspace private:isPrivate];
        
        if ([name isEqualToString:_channel]) {
            name = [_channel componentsSeparatedByString:@"#"].lastObject;
        }
        
        _name = [name copy];
        _usersMap = [NSMapTable strongToWeakObjectsMapTable];
        _offlineUsersMap = [NSHashTable new];
        
        [self registerPlugin:[CENChatAugmentationPlugin class] withConfiguration:@{ }];
        [self registerPlugin:[CENSenderAugmentationPlugin class] withConfiguration:@{ }];
        
        CENWeakify(self)
        [self handleEvent:@"$.system.leave" withHandlerBlock:^(CENEmittedEvent *event) {
            CENStrongify(self)
            NSDictionary *channelData = event.data;
            
            [self handleRemoteUsersLeave:@[channelData[CENEventData.sender]]];
        }];
    }
    
    return self;
}


#pragma mark - Connection

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChat * (^)(void))connect {
    
    return ^CENChat * {
        [self connectChat];
        return self;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)connectChat {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Connect to '%@' chat.", self.name);
    
    if (self.connected) {
        NSString *description = @"Connect called but chat is already connected.";
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatAlreadyConnectedError
                                         userInfo:errorInformation];
        
        [self.chatEngine throwError:error
                           forScope:@"connection.duplicate"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
        
        return;
    }
    
    [self.chatEngine connectToChat:self withCompletion:^{
        [self handleReadyForConnection];
    }];
}


#pragma mark - Meta

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChat * (^)(NSDictionary *meta))update {
    
    return ^CENChat * (NSDictionary *meta) {
        [self updateMeta:meta];
        return self;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)updateMeta:(NSDictionary *)meta {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Update '%@' chat meta with: %@",
        self.name, meta);
    
    if (!meta.count) {
        return;
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *updatedMeta = [NSMutableDictionary dictionaryWithDictionary:self->_meta];
        [updatedMeta addEntriesFromDictionary:meta];
        self.meta = updatedMeta;
        
        [self.chatEngine pushUpdatedChatMeta:self
                          withRepresentation:[self dictionaryRepresentationOnQueue:NO]];
    });
}

- (void)updateMetaWithFetchedData:(NSDictionary *)meta {
    
    if (((NSNumber *)meta[@"found"]).boolValue) {
        self.meta = meta[CENEventData.chat][@"meta"];
    } else {
        [self updateMeta:self.meta];
    }
}


#pragma mark - State

- (void)restoreStateForChat:(CENChat *)chat {
    
    [super restoreStateForChat:chat];
}

- (void)setState:(NSDictionary *)state {
    
    if (!self.connected) {
        NSString *description = @"Trying to set state in chat you are not connected to. You must "
                                 "wait for the $.connected event before setting state in this "
                                 "chat.";
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatNotConnectedError
                                         userInfo:errorInformation];
        
        [self.chatEngine throwError:error
                           forScope:@"state"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
        
        return;
    }
    
    if (!state.count) {
        return;
    }
    
    self.pendingStateChanges = state;
    [self.chatEngine updateChatState:self withData:state completion:^(NSError *error) {
        if (error) {
            [self.chatEngine throwError:error
                               forScope:@"state"
                                   from:self
                          propagateFlow:CEExceptionPropagationFlow.direct];
        }
    }];
}


#pragma mark - Participants

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChat * (^)(CENUser *user))invite {
    
    return ^CENChat * (CENUser *user) {
        [self inviteUser:user];
        return self;
    };
}

- (CENChat * (^)(void))leave {
    
    return ^CENChat * {
        [self leaveChat];
        return self;
    };
}

- (CENChat * (^)(void))fetchUserUpdates {
    
    return ^CENChat * {
        [self fetchParticipants];
        
        return self;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)inviteUser:(CENUser *)user {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Invite '%@' to '%@' chat.",
        user.uuid, self.name);
    
    [self.chatEngine inviteToChat:self user:user];
}

- (void)leaveChat {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Leave '%@' chat.", self.name);
    
    [self.chatEngine leaveChat:self];
}

- (void)fetchParticipants {
    
    [self.chatEngine fetchParticipantsForChat:self];
}


#pragma mark - Events search

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChatSearchBuilderInterface * (^)(void))search {
    
    CENChatSearchBuilderInterface *builder = nil;
    CENInterfaceCallCompletionBlock block = ^id (__unused NSArray *flags, NSDictionary *arguments) {
        NSString *event = arguments[NSStringFromSelector(@selector(event))];
        CENUser *sender = arguments[NSStringFromSelector(@selector(sender))];
        NSNumber *limit = (NSNumber *)arguments[NSStringFromSelector(@selector(limit))];
        NSNumber *pages = (NSNumber *)arguments[NSStringFromSelector(@selector(pages))];
        NSNumber *count = (NSNumber *)arguments[NSStringFromSelector(@selector(count))];
        NSNumber *start = arguments[NSStringFromSelector(@selector(start))];
        NSNumber *end = arguments[NSStringFromSelector(@selector(end))];
        
        return [self searchEvent:event
                        fromUser:sender
                       withLimit:limit.integerValue
                           pages:pages.integerValue
                           count:count.integerValue
                           start:start
                             end:end];
    };
    
    builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:block];
    
    return ^CENChatSearchBuilderInterface * {
        return builder;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (CENSearch *)searchEvent:(NSString *)event
                  fromUser:(nullable CENUser *)sender
                 withLimit:(NSInteger)limit
                     pages:(NSInteger)pages
                     count:(NSInteger)count
                     start:(NSNumber *)start
                       end:(NSNumber *)end {
    
    if (!self.hasConnected) {
        NSString *description = @"You must wait for the $.connected event before calling "
                                 "-[chat search].";
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatNotConnectedError
                                         userInfo:errorInformation];
        
        [self.chatEngine throwError:error
                           forScope:@"search"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
    }
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Search for%@%@ events%@ in '%@' "
        "chat%@%@.%@%@", limit > 0 ? [@[@" ", @(limit)] componentsJoinedByString:@""] : @"",
        event.length ? [@[@" '", event, @"'"] componentsJoinedByString:@""] : @"",
        sender ? [@[@" from '", sender.uuid, @"'"] componentsJoinedByString:@""] : @"",
        self.name,
        start ? [@[@" starting from ", start] componentsJoinedByString:@""] : @"",
        end ? [@[@" till ", end] componentsJoinedByString:@""] : @"",
        pages > 0 ? [@[@" Maximum ", @(pages), @" requests."] componentsJoinedByString:@""] : @"",
        count > 0 ? [@[@" Batch ", @(count), @" per page."] componentsJoinedByString:@""]: @"");
    
    return [self.chatEngine searchEventsInChat:self
                                        sentBy:sender
                                      withName:event
                                         limit:limit
                                         pages:pages
                                         count:count
                                         start:start
                                           end:end];
}


#pragma mark - Activity

- (void)resetConnection {
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.hasConnected = NO;
    });
}

- (void)sleep {
    
    dispatch_async(self.resourceAccessQueue, ^{
        BOOL asleep = self.asleep;
        self.asleep = YES;
        
        if (self.connected && !asleep) {
            [self handleDisconnection];
        }
    });
}

- (void)wake {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (!self.asleep) {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (([self.group isEqualToString:CENChatGroup.system] ||
                 [self isEqual:self.chatEngine.global]) && self.hasConnected) {
                
                [self handleConnection];
                return;
            }
            
            [self.chatEngine handshakeChatAccess:self withCompletion:^{
                [self handleConnection];
            }];
        });
    });
}


#pragma mark - Handlers

- (void)handleReadyForConnection {
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.hasConnected = YES;
        self.asleep = NO;
        [self handleConnectionOnQueue:NO];
    });
}

- (void)handleConnection {
    
    [self handleConnectionOnQueue:YES];
}

- (void)handleConnectionOnQueue:(BOOL)shouldUseQueue {
    
    BOOL isGlobal = [self isEqual:self.chatEngine.global];
    
    CENWeakify(self);
    dispatch_block_t handlerBlock = ^{
        CENStrongify(self);
        BOOL chatWithParticipants = isGlobal || [self.group isEqualToString:CENChatGroup.custom];
        self.connected = YES;
        self.asleep = NO;
        [self.chatEngine triggerEventLocallyFrom:self event:@"$.connected", nil];
        
        if (!chatWithParticipants || !self.isValid) {
            return;
        }

        dispatch_block_flags_t flags = DISPATCH_BLOCK_INHERIT_QOS_CLASS;
        self.participantsDelayedRefreshBlock = dispatch_block_create(flags, ^{
            dispatch_async(self.resourceAccessQueue, ^{
                self.participantsDelayedRefreshBlock = nil;
                
                if (self.connected && self.isValid) {
                    [self fetchParticipants];
                }
            });
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       self.participantsDelayedRefreshBlock);
    };
    
    if (shouldUseQueue) {
        dispatch_async(self.resourceAccessQueue, handlerBlock);
    } else {
        handlerBlock();
    }
}

- (void)handleDisconnection {
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.connected = NO;
        [self.chatEngine triggerEventLocallyFrom:self event:@"$.disconnected", nil];
    });
}

- (void)handleLeave {
    
    [self handleDisconnection];
    [self.chatEngine triggerEventLocallyFrom:self event:@"$.left", nil];
}

- (void)handleRemoteUsersRefresh:(NSArray<CENUser *> *)users withStates:(NSDictionary *)states {
    
    [self handleRemoteUsersHere:users];
    [self handleRemoteUsers:users stateChange:states];
}

- (void)handleRemoteUsersHere:(NSArray<CENUser *> *)users {
    
    dispatch_async(self.resourceAccessQueue, ^{
        for (CENUser *user in users) {
            BOOL exists = NO;
            BOOL offline = NO;
            
            [self getUserPresenceInChat:user exists:&exists offline:&offline];
            
            if (!exists || offline) {
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.online.here", user, nil];
            }
        }
    });
}

- (void)handleRemoteUsersJoin:(NSArray<CENUser *> *)users withStates:(NSDictionary *)states
                onStateChange:(BOOL)onStateChange {
    
    dispatch_async(self.resourceAccessQueue, ^{
        for (CENUser *user in users) {
            BOOL exists = NO;
            BOOL offline = NO;
            
            [self getUserPresenceInChat:user exists:&exists offline:&offline];
            
            if (!exists && !offline) {
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.online.join", user, nil];
            } else if (offline) {
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.online.here", user, nil];
            }
            
            if (!onStateChange) {
                [user assignState:states[user.uuid] forChat:self];
            }
        }
    });
}

- (void)handleRemoteUsersLeave:(NSArray<CENUser *> *)users {
    
    dispatch_async(self.resourceAccessQueue, ^{
        for (CENUser *user in users) {
            [self.offlineUsersMap removeObject:user.uuid];
            
            if ([self.usersMap objectForKey:user.uuid]) {
                [self.usersMap removeObjectForKey:user.uuid];
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.offline.leave", user, nil];
            }
        }
    });
}

- (void)handleRemoteUsersDisconnect:(NSArray<CENUser *> *)users {

    dispatch_async(self.resourceAccessQueue, ^{
        for (CENUser *user in users) {
            if ([self.usersMap objectForKey:user.uuid]) {
                [self.offlineUsersMap addObject:user.uuid];
                [self.chatEngine triggerEventLocallyFrom:self
                                                   event:@"$.offline.disconnect", user, nil];
            }
            
            [self.usersMap removeObjectForKey:user.uuid];
        }
    });
}

- (void)handleRemoteUsers:(NSArray<CENUser *> *)users
              stateChange:(NSDictionary<NSString *, NSDictionary *> *)states {
    
    dispatch_async(self.resourceAccessQueue, ^{
        for (CENUser *user in users) {
            NSDictionary *currentUserState = [user stateForChat:self];
            [user assignState:states[user.uuid] forChat:self];
            NSDictionary *updatedState = [user stateForChat:self];
            BOOL stateChanged = ![currentUserState isEqualToDictionary:updatedState];
            BOOL isPendingState = ([user isKindOfClass:[CENMe class]] &&
                                   [updatedState isEqualToDictionary:self.pendingStateChanges]);
            
            // Emit $.state event only in case if state really did changed with last assignment.
            if (stateChanged || isPendingState) {
                if (isPendingState) {
                    self.pendingStateChanges = nil;
                }
                
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.state", user, nil];
            }
        };
    });
}

- (void)destruct {
    
    dispatch_sync(self.resourceAccessQueue, ^{
        if (self.participantsDelayedRefreshBlock) {
            dispatch_block_cancel(self.participantsDelayedRefreshBlock);
        }
        
        self.participantsDelayedRefreshBlock = nil;
    });
    
    [super destruct];
}


#pragma mark - Events emitting

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChatEmitBuilderInterface * (^)(NSString *event))emit {
    
    CENChatEmitBuilderInterface *builder = nil;
    CENInterfaceCallCompletionBlock block = ^id (__unused NSArray *flags, NSDictionary *arguments) {
        NSString *event = arguments[@"event"];
        return [self emitEvent:event withData:arguments[NSStringFromSelector(@selector(data))]];
    };
    
    builder = [CENChatEmitBuilderInterface builderWithExecutionBlock:block];
    
    return ^CENChatEmitBuilderInterface * (NSString *event) {
        [builder setArgument:event forParameter:@"event"];
        return builder;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (CENEvent *)emitEvent:(NSString *)event withData:(NSDictionary *)data {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Emit '%@' event to '%@' chat%@",
        event, self.name,
        data.count ? [@[@" with data: ", data] componentsJoinedByString:@""] : @".");
    
    return [self.chatEngine publishToChat:self eventWithName:event data:data];
}


#pragma mark - Misc

+ (BOOL)isPrivate:(NSString *)chatName {
    
    NSArray<NSString *> *components = [chatName componentsSeparatedByString:@"#"];
    if (components.count < 3) {
        return  NO;
    }
    
    return [components[2] isEqualToString:@"private."];
}

+ (NSString *)internalNameFor:(NSString *)channelName
                  inNamespace:(NSString *)nspace
                      private:(BOOL)isPrivate {
    
    NSString *visibility = isPrivate ? @"private." : @"public.";
    NSString *internalName = channelName;
    
    if ([channelName rangeOfString:nspace].location == NSNotFound) {
        internalName = [@[nspace, @"chat", visibility, channelName] componentsJoinedByString:@"#"];
    }
    
    return internalName;
}

- (void)getUserPresenceInChat:(CENUser *)user exists:(BOOL *)exists offline:(BOOL *)offline {
    
    if (exists != NULL) {
        *exists = [self.usersMap objectForKey:user.uuid] != nil;
    }
    
    if (offline != NULL) {
        *offline = [self.offlineUsersMap containsObject:user.uuid];
    }
    
    [self.usersMap setObject:user forKey:user.uuid];
    [self.offlineUsersMap removeObject:user.uuid];
}

- (NSDictionary * (^)(void))objectify {
    
    return ^NSDictionary * {
        return [self dictionaryRepresentation];
    };
}

- (NSDictionary *)dictionaryRepresentation {
    
    return [self dictionaryRepresentationOnQueue:YES];
}

- (NSDictionary *)dictionaryRepresentationOnQueue:(BOOL)shouldUseQueue {
    
    __block NSDictionary *representation = nil;
    NSDictionary *(^representationBlock)(void) = ^NSDictionary * {
        return @{
            CENChatData.channel: self->_channel,
            CENChatData.group: self->_group,
            CENChatData.private: @(self.isPrivate),
            CENChatData.meta: self->_meta
        };
    };
    
    if (shouldUseQueue) {
        dispatch_sync(self.resourceAccessQueue, ^{
            representation = representationBlock();
        });
    } else {
        representation = representationBlock();
    }
    
    return representation;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<CENChat:%p name: '%@'; group: '%@'; channel: '%@'; "
                                       "private: %@; asleep: %@; participants: %@>",
            self, self.name, self.group, self.channel, self.isPrivate ? @"YES" : @"NO",
            self.asleep ? @"YES" : @"NO", @(self.usersMap.count)];
}  

#pragma mark -


@end
