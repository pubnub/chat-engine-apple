/**
 *@author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
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
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Interface.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+Publish.h"
#import "CENChatEngine+Private.h"
#import "CENPrivateStructures.h"
#import "CENChatEngine+Search.h"
#import "CENChatEngine+User.h"
#import "CENObject+Private.h"
#import "CENSearch+Private.h"
#import "CENEvent+Private.h"
#import "CENUser+Private.h"
#import "CENErrorCodes.h"
#import "CENConstants.h"
#import "CENLogMacro.h"
#import "CENSession.h"
#import "CENUser.h"


#pragma mark Externs

CENChatDataKeys CENChatData = { .channel = @"channel", .group = @"group", .private = @"private", .meta = @"meta" };


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENChat ()

#pragma mark - Information

@property (nonatomic, strong) NSMapTable<NSString *, CENUser *> *usersMap;
@property (nonatomic, strong) NSHashTable<NSString *> *offlineUsersMap;
@property (nonatomic, assign, getter=isPrivate) BOOL private;
@property (nonatomic, assign) BOOL hasConnected;
@property (nonatomic, copy) NSDictionary *meta;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL asleep;


#pragma mark - Initialization and Configuration

- (instancetype)initWithName:(NSString *)name
                   namespace:(NSString *)nspace
                       group:(NSString *)group
                     private:(BOOL)isPrivate
                    metaData:(NSDictionary *)meta
                  chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Handlers

- (void)handleReadyForConnection;
- (void)handleConnection;
- (void)handleDisconnection;
- (void)handleRemoteUsersJoin:(NSArray<CENUser *> *)users onQueue:(BOOL)shouldUseQueue;


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentationOnQueue:(BOOL)onQueue;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENChat


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.chat;
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
    
    if (![name isKindOfClass:[NSString class]] || !name.length || ![nspace isKindOfClass:[NSString class]] || !nspace.length ||
        ![group isKindOfClass:[NSString class]] || !group.length || ![groups containsObject:group.lowercaseString] ||
        ![chatEngine isKindOfClass:[CENChatEngine class]]) {
        
        return nil;
    }
    return [[self alloc] initWithName:name namespace:nspace group:group private:isPrivate metaData:meta chatEngine:chatEngine];
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
    }
    
    return self;
}

- (void)setState:(NSDictionary *)state withCompletion:(nullable dispatch_block_t)block {
    
    [self.chatEngine updateChatState:self withData:state completion:block];
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
    
    [self.chatEngine connectToChat:self withCompletion:^(__unused NSDictionary *meta) {
        [self handleReadyForConnection];
    }];
}


#pragma mark - Meta

- (CENChat * (^)(NSDictionary *meta))update {
    
    return ^CENChat * (NSDictionary *meta) {
        [self updateMeta:meta];
        
        return self;
    };
}

- (void)updateMeta:(NSDictionary *)meta {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Update '%@' chat meta with: %@", self.name, meta);
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *updatedState = [NSMutableDictionary dictionaryWithDictionary:self->_meta];
        [updatedState addEntriesFromDictionary:meta];
        self.meta = updatedState;
        
        [self.chatEngine pushUpdatedChatMeta:self withRepresentation:[self dictionaryRepresentationOnQueue:NO]];
    });
}

- (void)updateMetaWithFetchedData:(NSDictionary *)meta {
    
    if (meta) {
        self.meta = meta;
    } else {
        [self updateMeta:self.meta];
    }
}


#pragma mark - Participants

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENChat * (^)(CENUser *user))invite {
    
    return ^CENChat * (CENUser *user) {
        [self inviteUser:user];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)inviteUser:(CENUser *)user {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Invite '%@' to '%@' chat.", user.uuid, self.name);
    
    [self.chatEngine inviteToChat:self user:user];
}

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENChat * (^)(void))leave {
    
    return ^CENChat * {
        [self leaveChat];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)leaveChat {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Leave '%@' chat.", self.name);
    
    [self.chatEngine leaveChat:self];
}

- (CENChat * (^)(void))fetchUserUpdates {
    
    return ^CENChat * {
        [self fetchParticipants];
        
        return self;
    };
}

- (void)fetchParticipants {
    
    [self.chatEngine fetchParticipantsForChat:self];
}


#pragma mark - Events search

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENChatSearchBuilderInterface * (^)(void))search {
    
    CENChatSearchBuilderInterface *builder = nil;
    builder = [CENChatSearchBuilderInterface builderWithExecutionBlock:^id(__unused NSArray<NSString *> *flags, NSDictionary *arguments) {
        NSString *event = arguments[NSStringFromSelector(@selector(event))];
        CENUser *sender = arguments[NSStringFromSelector(@selector(sender))];
        NSInteger limit = ((NSNumber *)arguments[NSStringFromSelector(@selector(limit))]).integerValue;
        NSInteger pages = ((NSNumber *)arguments[NSStringFromSelector(@selector(pages))]).integerValue;
        NSInteger count = ((NSNumber *)arguments[NSStringFromSelector(@selector(count))]).integerValue;
        NSNumber *start = arguments[NSStringFromSelector(@selector(start))];
        NSNumber *end = arguments[NSStringFromSelector(@selector(end))];
        
        return [self searchEvent:event fromUser:sender withLimit:limit pages:pages count:count start:start end:end];
    }];
    
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
        NSString *description = @"You must call -[chatEngine connect] and wait for the $.ready event before calling "
                                 "-[chat search].";
        NSDictionary *errorInformation = @{ NSLocalizedDescriptionKey: description };
        NSError *error = [NSError errorWithDomain:kCENErrorDomain code:kCENClientNotConnectedError userInfo:errorInformation];
        
        [self.chatEngine throwError:error forScope:@"search" from:self propagateFlow:CEExceptionPropagationFlow.middleware];
    }
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Search for%@%@ events%@ in '%@' chat%@%@.%@%@",
                 limit > 0 ? [@[@" ", @(limit)] componentsJoinedByString:@""] : @"",
                 event.length ? [@[@" '", event, @"'"] componentsJoinedByString:@""] : @"",
                 sender ? [@[@" from '", sender.uuid, @"'"] componentsJoinedByString:@""] : @"", self.name,
                 start ? [@[@" starting from ", start] componentsJoinedByString:@""] : @"",
                 end ? [@[@" till ", end] componentsJoinedByString:@""] : @"",
                 pages > 0 ? [@[@" Maximum ", @(pages), @" requests."] componentsJoinedByString:@""] : @"",
                 count > 0 ? [@[@" Batch ", @(count), @" per page."] componentsJoinedByString:@""]: @"");
    
    return [self.chatEngine searchEventsInChat:self sentBy:sender withName:event limit:limit pages:pages count:count start:start end:end];
}


#pragma mark - Activity

- (void)sleep {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (self.connected && !self.asleep) {
            self.asleep = YES;
            
            [self handleDisconnection];
        }
    });
}

- (void)wake {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (self.asleep) {
            void(^handshakeCompletionBlock)(BOOL, NSDictionary *) = ^(BOOL isError, __unused NSDictionary *meta) {
                if (!isError) {
                    dispatch_async(self.resourceAccessQueue, ^{
                        self.asleep = NO;
                        [self handleConnection];
                    });
                }
            };
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.chatEngine handshakeChatAccess:self withCompletion:handshakeCompletionBlock];
            });
        }
    });
}


#pragma mark - Handlers

- (void)handleReadyForConnection {
    
    [self handleConnection];
    
    [self handleEvent:@"$.system.leave" withHandlerBlock:^(NSDictionary *channelData) {
        [self handleRemoteUsersLeave:@[channelData[CENEventData.sender]]];
    }];
}

- (void)handleConnection {
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.connected = YES;
        self.hasConnected = YES;
        [self.chatEngine triggerEventLocallyFrom:self event:@"$.connected", nil];
    });
}

- (void)handleDisconnection {
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.connected = NO;
        [self.chatEngine triggerEventLocallyFrom:self event:@"$.disconnected", nil];
    });
}

- (void)handleLeave {
    
    [self.chatEngine triggerEventLocallyFrom:self event:@"$.left", nil];
    [self handleDisconnection];
}

- (void)handleRemoteUsersJoin:(NSArray<CENUser *> *)users {
    
    [self handleRemoteUsersJoin:users onQueue:YES];
}

- (void)handleRemoteUsersJoin:(NSArray<CENUser *> *)users onQueue:(BOOL)shouldUseQueue {
    
    dispatch_block_t handlerBlock = ^{
        for (CENUser *user in users) {
            BOOL userAlreadyHere = [self.usersMap objectForKey:user.uuid] != nil;
            BOOL userWasHere = [self.offlineUsersMap containsObject:user.uuid];
            
            [self.usersMap setObject:user forKey:user.uuid];
            [self.offlineUsersMap removeObject:user.uuid];
            
            if (userWasHere) {
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.online.here", user, nil];
            } else if (!userAlreadyHere) {
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.online.join", user, nil];
            }
        }
    };
    
    if (shouldUseQueue) {
        dispatch_async(self.resourceAccessQueue, handlerBlock);
    } else {
        handlerBlock();
    }
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
                [self.chatEngine triggerEventLocallyFrom:self event:@"$.offline.disconnect", user, nil];
            }
            
            [self.usersMap removeObjectForKey:user.uuid];
        }
    });
}

- (void)handleRemoteUsersStateChange:(NSArray<CENUser *> *)users {

    dispatch_async(self.resourceAccessQueue, ^{
        for (CENUser *user in users) {
            if (![self.usersMap objectForKey:user.uuid]) {
                [self handleRemoteUsersJoin:@[user] onQueue:NO];
            }
        };
    });
}


#pragma mark - Events emitting

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENChatEmitBuilderInterface * (^)(NSString *event))emit {
    
    CENChatEmitBuilderInterface *builder = nil;
    builder = [CENChatEmitBuilderInterface builderWithExecutionBlock:^id(__unused NSArray<NSString *> *flags, NSDictionary *arguments) {
        return [self emitEvent:arguments[@"event"] withData:arguments[NSStringFromSelector(@selector(data))]];
    }];
    
    return ^CENChatEmitBuilderInterface * (NSString *event) {
        [builder setArgument:event forParameter:@"event"];
        
        return builder;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (CENEvent *)emitEvent:(NSString *)event withData:(NSDictionary *)data {
    
    CELogAPICall(self.chatEngine.logger, @"<ChatEngine::API> Emit '%@' event to '%@' chat%@", event, self.name,
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

+ (NSString *)internalNameFor:(NSString *)channelName inNamespace:(NSString *)nspace private:(BOOL)isPrivate {
    
    NSString *internalName = channelName;
    
    if ([channelName rangeOfString:nspace].location == NSNotFound) {
        internalName = [@[ nspace, @"chat", (isPrivate ? @"private." : @"public."), channelName ] componentsJoinedByString:@"#"];
    }
    
    return internalName;
}

- (NSDictionary * (^)(void))objectify {
    
    return ^NSDictionary * {
        return [self dictionaryRepresentation];
    };
}

- (NSDictionary *)dictionaryRepresentation {
    
    return [self dictionaryRepresentationOnQueue:YES];
}

- (NSDictionary *)dictionaryRepresentationOnQueue:(BOOL)onQueue {
    
    __block NSDictionary *representation = nil;
    NSDictionary *(^representationBlock)(void) = ^NSDictionary * {
        return @{
            CENChatData.channel: self->_channel,
            CENChatData.group: self->_group,
            CENChatData.private: @(self.isPrivate),
            CENChatData.meta: self->_meta
        };
    };
    
    if (onQueue) {
        dispatch_sync(self.resourceAccessQueue, ^{
            representation = representationBlock();
        });
    } else {
        representation = representationBlock();
    }
    
    return representation;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<CENChat:%p name: '%@'; group: '%@'; channel: '%@'; private: %@; asleep: %@; participants: %@>",
            self, self.name, self.group, self.channel, self.isPrivate ? @"YES" : @"NO", self.asleep ? @"YES" : @"NO", @(self.usersMap.count)];
}

#pragma mark -


@end
