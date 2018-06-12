/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENObject+Private.h"
#import "CENChatEngine+UserInterface.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Private.h"
#import "CEPMiddleware+Private.h"
#import "CENChatEngine+Private.h"
#import "CENLogMacro.h"


#pragma mark Externs

CENObjectTypes CENObjectType = { .user = @"user", .me = @"me", .chat = @"chat", .search = @"search" };


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENObject ()


#pragma mark - Information

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *extensionsData;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *middlewareData;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, weak) CENChatEngine *chatEngine;
@property (nonatomic, copy) NSString *identifier;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENObject


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    [NSException raise:NSInternalInconsistencyException format:@"-init not implemented, please use: -initWithChatEngine:"];
    
    return nil;
}

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        NSString *resourceQueueIdentifier = [NSString stringWithFormat:@"com.chatengine.%@.%p", [[self class] objectType], self];
        _resourceAccessQueue = dispatch_queue_create([resourceQueueIdentifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _identifier = [[NSUUID UUID] UUIDString];
        _extensionsData = [NSMutableDictionary new];
        _middlewareData = [NSMutableDictionary new];
        _chatEngine = chatEngine;
        
        CELogResourceAllocation(_chatEngine.logger, @"<ChatEngine::%@> Allocate instance: %@", NSStringFromClass([self class]), self);
    }
    
    return self;
}


#pragma mark - Event emitting

- (void)emitEventLocally:(NSString *)event withParameters:(NSArray *)parameters {

    [self.chatEngine emitEventLocally:event withParameters:[@[self] arrayByAddingObjectsFromArray:parameters]];
    [super emitEventLocally:event withParameters:parameters];
}


#pragma mark - Handlers

- (void)onCreate {
    
    [self.chatEngine triggerEventLocallyFrom:self event:[@[@"$.created", [[self class] objectType]] componentsJoinedByString:@"."], nil];
}


#pragma mark - Clean up

- (void)destruct {
    
    [self.chatEngine unregisterAllFromObjects:self];
    [super destruct];
}


#pragma mark - Misc

+ (NSString *)objectType {
    
    NSAssert(0, @"%s should be implemented by subclass", __PRETTY_FUNCTION__);
    
    return nil;
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::%@> Deallocate instance: %@", NSStringFromClass([self class]), self);
}

#pragma mark -


@end
