/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+UserInterface.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENObject+Private.h"
#import "CENUser+Private.h"
#import "CENStructures.h"
#import "CENLogMacro.h"


#pragma mark Interface implementation

@implementation CENChatEngine (EventEmitter)


- (void)triggerEventLocallyFrom:(CENEventEmitter *)object event:(NSString *)event, ... {
    
    va_list args;
    va_start(args, event);
    NSMutableArray *parameters = [NSMutableArray array];
    id parameter;
    
    while ((parameter = va_arg(args, id)) != nil) {
        [parameters addObject:parameter];
    }
    va_end(args);
    
    [self triggerEventLocallyFrom:object event:event withParameters:parameters completion:nil];
}

- (void)triggerEventLocallyFrom:(CENEventEmitter *)object
                          event:(NSString *)event
                 withParameters:(NSArray *)parameters
                     completion:(void (^)(NSString *, id, BOOL))block {

    void(^completion)(NSMutableDictionary *) = ^(NSMutableDictionary *data) {
        [self.pluginsManager runMiddlewaresAtLocation:@"on"
                                             forEvent:event
                                               object:(CENObject *)object
                                          withPayload:data
                                           completion:^(BOOL rejected, id processedData) {
                         
            if (rejected) {
                if (block) {
                    block(event, nil, YES);
                }
            } else {
                id updatedParams = [NSMutableArray arrayWithArray:parameters];
                
                if (data) {
                    [updatedParams replaceObjectAtIndex:0 withObject:processedData];
                }
                
                [object emitEventLocally:event withParameters:updatedParams];
                
                if (block) {
                    block(event, updatedParams, NO);
                }
            }
        }];
    };

    if ([parameters.firstObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *data = [parameters.firstObject mutableCopy];
        
        if (!data[CENEventData.chat] && [[[object class] objectType] isEqualToString:CENObjectType.chat]) {
            data[CENEventData.chat] = object;
        }
        
        if (data[CENEventData.sender] && [data[CENEventData.sender] isKindOfClass:[NSString class]]) {
            CENUser *sender = [self createUserWithUUID:data[CENEventData.sender] state:nil];
            data[CENEventData.sender] = sender;
            
            [sender fetchStoredStateWithCompletion:^(__unused NSDictionary *state) {
                completion(data);
            }];
        } else {
            completion(data);
        }
    } else {
        [object emitEventLocally:event withParameters:parameters];
        
        if (block) {
            block(event, parameters.firstObject, NO);
        }
    }
}

- (void)throwError:(NSError *)error forScope:(NSString *)scope from:(CENEventEmitter *)emitter propagateFlow:(NSString *)flow {
    
    if (self.configuration.shouldThrowExceptions) {
        CELogClientExceptions(self.logger, @"<ChatEngine> Thrown error: (%@)", error);

        @throw [NSException exceptionWithName:error.domain reason:error.localizedDescription userInfo:@{ NSUnderlyingErrorKey: error }];
    }
    
    NSString *eventName = [@[@"$", @"error", scope] componentsJoinedByString:@"."];
    emitter = emitter ?: self;
    
    if ([emitter isKindOfClass:[self class]] || [flow isEqualToString:CEExceptionPropagationFlow.direct]) {
        [emitter emitEventLocally:eventName, error, nil];
    } else if ([flow isEqualToString:CEExceptionPropagationFlow.middleware]) {
        [self triggerEventLocallyFrom:emitter event:eventName withParameters:@[error] completion:nil];
    }
}

#pragma mark -


@end
