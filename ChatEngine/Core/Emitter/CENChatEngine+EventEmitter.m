/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+EventEmitter.h"
#import "CENEventEmitter+Private.h"
#import "CENChatEngine+Private.h"
#import "CENObject+Private.h"
#import "CENStructures.h"
#import "CENLogMacro.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENChatEngine (EventEmitterProtected)


#pragma mark - Misc

/**
 * @brief Check whether emitted event parameters should be wrapped into \a NSDictionary or not.
 *
 * @discussion Some events emit raw objects, which should be wrapped into \a NSDictionary to be able
 * to run plugins against them.
 *
 * @param parameters List of parameters which should be checked.
 *
 * @return Whether parameters should be placed into \a NSDictionary before sending to plugins or
 * not.
 */
- (BOOL)shouldWrapParametersToDictionary:(NSArray *)parameters;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation CENChatEngine (EventEmitter)


#pragma mark - Events emitting

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

    BOOL shouldWrap = [self shouldWrapParametersToDictionary:parameters];
    
    if (shouldWrap) {
        parameters = @[@{ CENEventData.sender: parameters[0] }];
    }
    
    if ([parameters.firstObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *data = [parameters.firstObject mutableCopy];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
                        if (shouldWrap) {
                            processedData = ((NSDictionary *)processedData)[CENEventData.sender];
                        }
                        
                        [updatedParams replaceObjectAtIndex:0 withObject:processedData];
                    }

                    [object emitEventLocally:event withParameters:updatedParams];

                    if (block) {
                        block(event, updatedParams, NO);
                    }
                }
            }];
        });
    } else {
        [object emitEventLocally:event withParameters:parameters];
        
        if (block) {
            block(event, parameters.firstObject, NO);
        }
    }
}


#pragma mark - Exception throwing

- (void)throwError:(NSError *)error
          forScope:(NSString *)scope
              from:(CENEventEmitter *)emitter
     propagateFlow:(NSString *)flow {
    
    if (self.configuration.shouldThrowExceptions) {
        CELogClientExceptions(self.logger, @"<ChatEngine> Thrown error: (%@)", error);

        @throw [NSException exceptionWithName:error.domain
                                       reason:error.localizedDescription
                                     userInfo:@{ NSUnderlyingErrorKey: error }];
    }
    
    NSString *eventName = [@[@"$", @"error", scope] componentsJoinedByString:@"."];
    emitter = emitter ?: (id)self;
    
    if ([emitter isKindOfClass:[self class]] ||
        [flow isEqualToString:CEExceptionPropagationFlow.direct]) {

        [emitter emitEventLocally:eventName, error, nil];
    } else if ([flow isEqualToString:CEExceptionPropagationFlow.middleware]) {
        [self triggerEventLocallyFrom:emitter
                                event:eventName
                       withParameters:@[error]
                           completion:nil];
    }
}


#pragma mark - Misc

- (BOOL)shouldWrapParametersToDictionary:(NSArray *)parameters {
    
    BOOL shouldWrap = NO;
    
    if (parameters.count == 1 && [parameters[0] isKindOfClass:[CENObject class]]) {
        NSString *type = [[(CENObject *)parameters[0] class] objectType];
        shouldWrap = ([type isEqualToString:CENObjectType.user] ||
                      [type isEqualToString:CENObjectType.me]);
    }
    
    return shouldWrap;
}

#pragma mark -


@end
