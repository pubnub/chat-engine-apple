/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENObject+Private.h"
#import "CENStateRestoreAugmentationPlugin.h"
#import "CENChatEngine+UserInterface.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Private.h"
#import "CEPMiddleware+Private.h"
#import "CENChatEngine+Private.h"
#import "CENLogMacro.h"


#pragma mark Externs

/**
 * @brief Typedef structure fields assignment.
 */
CENObjectTypes CENObjectType = {
    .user = @"user",
    .me = @"me",
    .chat = @"chat",
    .search = @"search",
    .event = @"event",
    .session = @"session"
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENObject ()


#pragma mark - Information

@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, readonly, weak) CENChat *defaultStateChat;
@property (nonatomic, getter = isValid, assign) BOOL valid;
@property (nonatomic, weak) CENChatEngine *chatEngine;
@property (nonatomic, copy) NSString *identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENObject


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    [NSException raise:NSInternalInconsistencyException
                format:@"-init not implemented, please use: -initWithChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        NSString *type = [[self class] objectType];
        NSString *identifier = [NSString stringWithFormat:@"com.chatengine.%@.%p", type, self];
        _resourceAccessQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _identifier = [[NSUUID UUID] UUIDString];
        _chatEngine = chatEngine;
        _valid = YES;
        
        CELogResourceAllocation(_chatEngine.logger, @"<ChatEngine::%@> Allocate instance: %@",
            NSStringFromClass([self class]), self);
    }
    
    return self;
}


#pragma mark - Presence state

- (void)restoreStateForChat:(CENChat *)chat {
    
    chat = chat ?: ([self defaultStateChat] ?: self.chatEngine.global);
    if ([[[self class] objectType] isEqualToString:CENObjectType.chat]) {
        chat = self.chatEngine.global;
    }
    
    if ([self hasPlugin:[CENStateRestoreAugmentationPlugin class]] || !chat) {
        return;
    }
    
    [self registerPlugin:[CENStateRestoreAugmentationPlugin class]
       withConfiguration:@{ CENStateRestoreAugmentationConfiguration.chat: chat }];
}


#pragma mark - Event emitting

- (void)emitEventLocally:(NSString *)event withParameters:(NSArray *)parameters {
    
    [self.chatEngine emitEventLocally:event
                       withParameters:[@[self] arrayByAddingObjectsFromArray:parameters]];
    [super emitEventLocally:event withParameters:parameters];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSString *type = [[self class] objectType];
    NSString *event = [@[@"$.created", type] componentsJoinedByString:@"."];
    
    [self.chatEngine triggerEventLocallyFrom:self event:event, nil];
}


#pragma mark - Clean up

- (void)destruct {
    
    self.valid = NO;
    
    [self.chatEngine unregisterAllFromObjects:self];
    [super destruct];
}


#pragma mark - Misc

+ (NSString *)objectType {
    
    NSAssert(0, @"%s should be implemented by subclass", __PRETTY_FUNCTION__);
    
    return nil;
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::%@> Deallocate instance: %@",
        NSStringFromClass([self class]), self);
}

#pragma mark -


@end
