/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENEvent+Private.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENChatEngine+Publish.h"
#import "CENChat+Private.h"
#import "CENStructures.h"
#import "CENLogMacro.h"


#pragma mark Extern

CENEventDataKeys CENEventData = {
    .data = @"data",
    .sender = @"sender",
    .chat = @"chat",
    .event = @"event",
    .eventID = @"eid",
    .timetoken = @"timetoken",
    .sdk = @"chatengineSDK"
};


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENEvent ()


#pragma mark - Information

@property (nonatomic, weak) CENChatEngine *chatEngine;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, strong) CENChat *chat;


#pragma mark - Initialization and Configuration

- (instancetype)initWithName:(NSString *)event chat:(CENChat *)chat chatEngine:(CENChatEngine *)chatEngine;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENEvent


#pragma mark - Initialization and Configuration

+ (instancetype)eventWithName:(NSString *)event chat:(CENChat *)chat chatEngine:(CENChatEngine *)chatEngine {

    return [[self alloc] initWithName:event chat:chat chatEngine:chatEngine];
}

- (instancetype)initWithName:(NSString *)event chat:(CENChat *)chat chatEngine:(CENChatEngine *)chatEngine {
    
    if ((self = [super init])) {
        _channel = [chat.channel copy];
        _chatEngine = chatEngine;
        _event = [event copy];
        _chat = chat;
        
        CELogResourceAllocation(chatEngine.logger, @"<ChatEngine::%@> Allocate instance: %@", NSStringFromClass([self class]), self);
    }
    
    return self;
}


#pragma mark - Publishing

- (void)publish:(NSMutableDictionary *)data {
    
    data[CENEventData.event] = self.event;
    BOOL storeInHistory = [self.event rangeOfString:@"$.system"].location == NSNotFound;
    
    CELogEventEmit(self.chatEngine.logger, @"<ChatEngine::Event> Emit '%@' event to '%@' chat with data: %@",
                   self.event, self.chat.channel, data);
    
    [self.chatEngine publishStorable:storeInHistory event:self toChannel:self.channel withData:data completion:^(NSNumber *timetoken) {
        data[CENEventData.timetoken] = timetoken;
        
        [self emitEventLocally:@"$.emitted", data, nil];
    }];
}


#pragma mark - Misc

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<CENEvent:%p event: '%@'; chat: '%@'>", self, self.event, self.channel];
}

- (void)dealloc {
    
    CELogResourceAllocation(self.chatEngine.logger, @"<ChatEngine::%@> Deallocate instance: %@", NSStringFromClass([self class]), self);
}

#pragma mark -

@end
