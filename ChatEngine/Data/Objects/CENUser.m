/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENUser.h"
#import "CENChatEngine+ChatInterface.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+UserPrivate.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENObject+Private.h"
#import "CENLogMacro.h"
#import "CENChat.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENUser ()


#pragma mark - Information

@property (nonatomic, copy) NSDictionary *userState;
@property (nonatomic, assign) BOOL stateIsSet;
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

- (NSString *)identifier {
    
    return self.uuid;
}

- (NSDictionary *)state {
    
    __block NSDictionary *state = @{};

    dispatch_sync(self.resourceAccessQueue, ^{
        state = [(self->_userState ?: @{}) copy];
    });
    
    return state;
}


#pragma mark - Initialization and Configuration

+ (instancetype)userWithUUID:(NSString *)uuid state:(NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine {
    
    CENUser *user = nil;
    
    if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
        user = [[self alloc] initWithUUID:uuid state:state chatEngine:chatEngine];
    }
    
    return user;
}

- (instancetype)initWithUUID:(NSString *)uuid state:(NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super initWithChatEngine:chatEngine])) {
        _uuid = [uuid copy];
        _direct = [self.chatEngine createDirectChatForUser:self];
        _feed = [self.chatEngine createFeedChatForUser:self];
        
        _userState = [state copy];
        if (state.count) {
            [self assignState:state];
        }
        
        CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::%@> Allocate instance: %@", NSStringFromClass([self class]), self);
    }
    
    return self;
}


#pragma mark - State

- (void)assignState:(nullable NSDictionary *)state {
    
    [self updateState:state];
}

- (void)updateState:(NSDictionary *)state {
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSDictionary *currentState = [self.userState copy];
        NSMutableDictionary *updatedState = [NSMutableDictionary dictionaryWithDictionary:self.userState];
        [updatedState addEntriesFromDictionary:state];
        
        self.stateIsSet = YES;
        self.userState = updatedState;
        if (![updatedState isEqualToDictionary:currentState]) {
            [self.chatEngine emitEventLocally:@"$.state", self, nil];
        }
    });
}

- (void)fetchStoredStateWithCompletion:(void(^)(NSDictionary *state))block {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (!self.stateIsSet) {
            [self.chatEngine fetchUserState:self withCompletion:^(NSDictionary *state) {
                dispatch_async(self.resourceAccessQueue, ^{
                    [self assignState:state];
                    
                    block(state);
                });
            }];
        } else {
            block(self.userState);
        }
    });
}


#pragma mark - Misc

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<CENUser:%p uuid: '%@'; state set: %@>", self, self.uuid, self.stateIsSet ? @"YES" : @"NO"];
}

#pragma mark -


@end
