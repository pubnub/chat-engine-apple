/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENUser+Private.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
#import "CENUser+BuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+ChatInterface.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+UserPrivate.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENObject+Private.h"
#import "CENChat+Interface.h"
#import "CENChat+Private.h"
#import "CENErrorCodes.h"
#import "CENLogMacro.h"
#import "CENError.h"
#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENUser ()


#pragma mark - Information

/**
 * @brief Map of chat channel names to \a NSNumber which represent boolean on whether state synced
 * for chat or not.
 */
@property (nonatomic, copy) NSMutableDictionary<NSString *, NSNumber *> *restoredUserStates;

/**
 * @brief Map of chat channel names to \a NSDictionary which represent user's state on that chat.
 */
@property (nonatomic, copy) NSMutableDictionary<NSString *, NSDictionary *> *states;

@property (nonatomic, strong) CENChat *direct;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) CENChat *feed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENUser


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.user;
}

- (CENChat *)defaultStateChat {
    
    return self.chatEngine.global;
}

- (NSString *)identifier {
    
    return self.uuid;
}

- (NSDictionary *)state {
    
    return [self stateForChat:nil];
}

- (NSDictionary *)stateForChat:(CENChat *)chat {

    chat = chat ?: self.chatEngine.global;
    __block NSDictionary *state = nil;

    if (chat) {
        dispatch_sync(self.resourceAccessQueue, ^{
            state = self.states[chat.channel] ?: @{};
        });
    } else {
        NSString *description = @"No chat specified for state lookup.";
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatMissingError
                                         userInfo:@{ NSLocalizedDescriptionKey: description }];
        
        [self.chatEngine throwError:error
                           forScope:@"getState"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
    }
    
    return state;
}


#pragma mark - Initialization and Configuration

+ (instancetype)userWithUUID:(NSString *)uuid
                       state:(NSDictionary *)state
                  chatEngine:(CENChatEngine *)chatEngine {
    
    CENUser *user = nil;
    
    if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
        user = [[self alloc] initWithUUID:uuid state:state chatEngine:chatEngine];
    }
    
    return user;
}

- (instancetype)initWithUUID:(NSString *)uuid
                       state:(NSDictionary *)state
                  chatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super initWithChatEngine:chatEngine])) {
        _uuid = [uuid copy];
        _direct = [self.chatEngine createDirectChatForUser:self];
        _feed = [self.chatEngine createFeedChatForUser:self];
        
        _restoredUserStates = [NSMutableDictionary new];
        _states = [NSMutableDictionary new];

        if (state.count && ![self isKindOfClass:[CENMe class]]) {
            [self updateState:state forChat:nil];
        }
        
        CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::%@> Allocate instance: %@",
            NSStringFromClass([self class]), self);
    }
    
    return self;
}


#pragma mark - State

- (void)assignState:(NSDictionary *)state forChat:(CENChat *)chat {
    
    [self assignState:state forChat:chat onQueue:YES];
}

- (void)assignState:(NSDictionary *)state forChat:(CENChat *)chat onQueue:(BOOL)useAccessQueue {
    
    chat = chat ?: self.chatEngine.global;
    
    if (!chat) {
        NSString *description = @"No chat specified for state assign.";
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatMissingError
                                         userInfo:@{ NSLocalizedDescriptionKey: description }];
        
        [self.chatEngine throwError:error
                           forScope:@"state.param"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
        
        return;
    }
    
    dispatch_block_t assignBlock = ^{
        NSDictionary *chatState = self.states[chat.channel];
        NSMutableDictionary *updatedState = [NSMutableDictionary dictionaryWithDictionary:chatState];
        [updatedState addEntriesFromDictionary:state];
        
        self.states[chat.channel] = updatedState;
        
        if (state && ![self isKindOfClass:[CENMe class]]) {
            self.restoredUserStates[chat.channel] = @YES;
        }
    };
    
    if (useAccessQueue) {
        dispatch_async(self.resourceAccessQueue, assignBlock);
    } else {
        assignBlock();
    }
}

- (void)updateState:(NSDictionary *)state forChat:(CENChat *)chat {

    chat = chat ?: self.chatEngine.global;

    if (!chat) {
        NSString *description = @"No chat specified for state update.";
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatMissingError
                                         userInfo:@{ NSLocalizedDescriptionKey: description }];
        
        [self.chatEngine throwError:error
                           forScope:@"state.param"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
        
        return;
    }
    
    [self assignState:state forChat:chat];
}

- (void)restoreStateForChat:(CENChat *)chat {
    
    [self restoreStateForChat:(chat ?: self.chatEngine.global) withCompletion:nil];
}

- (void)restoreStateForChat:(CENChat *)chat withCompletion:(void(^)(NSDictionary *state))block {
    
    if (!chat) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"No chat supplied." };
        NSError *error = [NSError errorWithDomain:kCENErrorDomain
                                             code:kCENChatMissingError
                                         userInfo:userInfo];
        
        [self.chatEngine throwError:error
                           forScope:@"state.param"
                               from:self
                      propagateFlow:CEExceptionPropagationFlow.direct];
        
        return;
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (self.restoredUserStates[chat.channel]) {
            if (block) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block(self.states[chat.channel]);
                });
            }
            
            return;
        }
        
        [self.chatEngine fetchUserState:self
                                forChat:chat
                         withCompletion:^(NSDictionary *restoredState) {

            dispatch_async(self.resourceAccessQueue, ^{
                NSDictionary *currentUserState = self.states[chat.channel];
                self.restoredUserStates[chat.channel] = @YES;
                
                [self assignState:(restoredState ?: @{}) forChat:chat onQueue:NO];
                NSDictionary *updatedState = self.states[chat.channel];
                
                if (block) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        block(self.states[chat.channel]);
                    });
                }
                
                if (![currentUserState isEqualToDictionary:updatedState]) {
                    [self.chatEngine triggerEventLocallyFrom:chat event:@"$.state", self, nil];
                }
            });
        }];
    });
}


#pragma mark - Misc

- (NSString *)description {
    
    __block NSString *description = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        description = [NSString stringWithFormat:@"<CENUser:%p uuid: '%@'; state set: %@ chats>",
                       self, self.uuid, @(self.restoredUserStates.allKeys.count)];
    });
    
    return description;
}

#pragma mark -


@end
