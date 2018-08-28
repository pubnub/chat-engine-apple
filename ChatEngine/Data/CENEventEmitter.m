/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENEventEmitter+Private.h"
#import "CENEventEmitter+Interface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENEventEmitter+BuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE


#pragma mark Static

/**
 * @brief  Constant stores name of key under which stored whether \c handler added for wildcard event or not.
 */
static NSString * const kCENEventIsWildcardKey = @"iw";

/**
 * @brief  Constant stores name of key under which stored whether \c handler should handle any event or not.
 */
static NSString * const kCENEventIsAnyKey = @"ae";

/**
 * @brief  Constant stores name of key under which actual event handling GCD block is stored.
 */
static NSString * const kCENEventHandlerKey = @"h";

/**
 * @brief  Constant stores name of key under which stored flag with information on whether \c handler block should be
 *         executed only once or not.
 */
static NSString * const kCENEventIsOneTimeHandlerKey = @"oth";


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CENEventEmitter ()


#pragma mark - Information

/**
 * @brief  Stores reference on list of events handlers for any fired event.
 */
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *allEvents;

/**
 * @brief  Stores reference on list of events with linkage to their handlers.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary *> *> *events;

/**
 * @brief  Stores reference on queue which is used to serialize access to shared object information.
 */
@property (nonatomic, readonly, strong) dispatch_queue_t eventsAccessQueue;


#pragma mark - Handlers addition

/**
 * @brief      Add handler \c block for specified \c event which may fire only once (depending from passed argument to
 *             \c shouldNotifyOnce).
 * @discussion It is possible to specify specific event to be handler or use wildcard specified (*) to route all events
 *             emitted by \b ChatEngine and it's comonents.
 *
 * @param event            Reference on event name which should be handled by \c block.
 * @param shouldNotifyOnce Reference on flag which specify whether passed \c block should be called only once for specified
 *                         \c event or not.
 * @param block            Reference on GCD block which will handle specified \c event.
 */
- (void)handleEvent:(NSString *)event once:(BOOL)shouldNotifyOnce withHandlerBlock:(id)block;


#pragma mark - Events emitting

/**
 * @brief      Call passed \c handler with list of \c parameters.
 * @discussion It is expected what block will have same number of expected arguments as stored in \c parameters list.
 *
 * @param event      Reference on name of event about which handler should be notified.
 * @param data       Reference on listeners' data object.
 * @param parameters Reference on list of parameters which should be passed to \c handler. Each value will be assigned to
 *                   corresponding place in \c handler's block argument.
 */
- (void)notifyAbout:(NSString *)event usingHandlerData:(NSDictionary *)data withParameters:(NSArray *)parameters;


#pragma mark - Misc

/**
 * @brief  Extract proper value for handler from list of passed \c parameters.
 *
 * @param index      Index of expected value in passed \c parameters list.
 * @param parameters Reference on list which hold values to be passed into handler block.
 *
 * @return Value or \c nil in case if index bigger than \c parameters can provide or fetched value is \a NSNull.
 *
 * @since 0.9.2
 */
- (nullable id)valueAtIndex:(NSUInteger)index fromParametersList:(NSArray *)parameters;

/**
 * @brief      Search for event handler subscribed to specific \c event.
 * @discussion Search also will find list of handlers which has been subscribed on wildcard \c event.
 *
 * @param event Reference on name of event for which list of handlers should be found.
 *
 * @return Reference on list of \c event handlers' data which can be used to notify handlers or for clean up.
 */
- (NSArray<NSDictionary *> *)eventHandlersForEvent:(NSString *)event;

/**
 * @brief  Retrieve list of registered events which is equal to passed \c event or partly equal (wildcard).
 *
 * @param event Reference on \c event name which should be searched in registered events.
 *
 * @return List of registered events based on \c event name.
 */
- (NSArray<NSString *> *)eventNamesForEvent:(NSString *)event;

/**
 * @brief      Calculate next level of \c event name.
 * @discussion This method used by \c -eventNamesForEvent: to perform partial event name match.
 * @discussion \b Important: this method modify passed \c eventComponents argument.
 *
 * @param eventComponents Reference on mutable array which contain event name components (\c event name separated by '.').
 *
 * @return Reference on part of original event name, which is created from concatination of rest of elements from
 *         \c eventComponents.
 */
- (nullable NSString *)nextEventNameFromComponents:(NSMutableArray<NSString *> *)eventComponents;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENEventEmitter


#pragma mark - Information

- (NSArray<NSString *> *)eventNames {
    
    __block NSArray<NSString *> *eventNames = nil;
    
    dispatch_sync(self.eventsAccessQueue, ^{
        eventNames = self.events.allKeys;
    });
    
    return eventNames;
}


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    if ((self = [super init])) {
        NSString *resourceQueueIdentifier = [NSString stringWithFormat:@"com.chatengine.emitter.%p", self];
        _eventsAccessQueue = dispatch_queue_create([resourceQueueIdentifier UTF8String], DISPATCH_QUEUE_SERIAL);
        _events = [NSMutableDictionary dictionary];
        _allEvents = [NSMutableArray array];
    }
    
    return self;
}

- (void)destruct {
    
    dispatch_sync(self.eventsAccessQueue, ^{
        [self->_allEvents removeAllObjects];
        [self->_events removeAllObjects];
    });
}


#pragma mark - Handlers addition

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENEventEmitter * (^)(NSString *event, id handlerBlock))on {
    
    return ^(NSString *event, id handlerBlock) {
        [self handleEvent:event withHandlerBlock:handlerBlock];
        
        return self;
    };
}

- (CENEventEmitter * (^)(id handlerBlock))onAny {
    
    return ^(id handlerBlock) {
        [self handleEvent:@"*" withHandlerBlock:handlerBlock];
        
        return self;
    };
}

- (CENEventEmitter * (^)(NSString *event, id handlerBlock))once {
    
    return ^(NSString *event, id handlerBlock) {
        [self handleEventOnce:event withHandlerBlock:handlerBlock];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)handleEvent:(NSString *)event withHandlerBlock:(id)block {
    
    [self handleEvent:event once:NO withHandlerBlock:block];
}

- (void)handleEventOnce:(NSString *)event withHandlerBlock:(id)block {
    
    [self handleEvent:event once:YES withHandlerBlock:block];
}

- (void)handleEvent:(NSString *)event once:(BOOL)shouldNotifyOnce withHandlerBlock:(id)block {
    
    event = event.lowercaseString;
    BOOL isAllEvents = [event isEqualToString:@"*"];
    
    dispatch_async(self.eventsAccessQueue, ^{
        NSMutableArray<NSDictionary *> *eventHandlers = !isAllEvents ? self.events[event] : self.allEvents;
        
        if (!eventHandlers && !isAllEvents) {
            eventHandlers = [NSMutableArray array];
            self.events[event] = eventHandlers;
        }
        
        [eventHandlers addObject:@{
            kCENEventIsAnyKey: @(isAllEvents),
            kCENEventIsWildcardKey: @(!isAllEvents && [event rangeOfString:@"*"].location != NSNotFound),
            kCENEventHandlerKey: block,
            kCENEventIsOneTimeHandlerKey: @(shouldNotifyOnce)
        }];
    });
}


#pragma mark - Handlers removal

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENEventEmitter * (^)(NSString *event, id handlerBlock))off {
    
    return ^(NSString *event, id handlerBlock) {
        [self removeHandler:handlerBlock forEvent:event];
        
        return self;
    };
}

- (CENEventEmitter * (^)(id handlerBlock))offAny {
    
    return ^(id handlerBlock) {
        [self removeHandler:handlerBlock forEvent:@"*"];
        
        return self;
    };
}

- (CENEventEmitter * (^)(NSString *event))removeAll {
    
    return ^(NSString *event) {
        [self removeAllHandlersForEvent:event];
        
        return self;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)removeHandler:(id)block forEvent:(NSString *)event {
    
    event = event.lowercaseString;
    BOOL isAllEvents = [event isEqualToString:@"*"];
    
    dispatch_sync(self.eventsAccessQueue, ^{
        __block NSDictionary *dataForRemoval = nil;
        NSMutableArray<NSDictionary *> *eventHandlers = !isAllEvents ? self.events[event] : self.allEvents;
        
        for (NSDictionary *data in eventHandlers) {
            if ([data[kCENEventHandlerKey] isEqual:block]) {
                dataForRemoval = data;
                
                break;
            }
        }
        
        if (dataForRemoval) {
            [eventHandlers removeObject:dataForRemoval];
            
            if (!isAllEvents && !eventHandlers.count) {
                [self.events removeObjectForKey:event];
            }
        }
    });
}

- (void)removeAllHandlersForEvent:(NSString *)event {
    
    dispatch_sync(self.eventsAccessQueue, ^{
        if (![event isEqualToString:@"*"]) {
            if ([event rangeOfString:@"*"].location == NSNotFound) {
                [self.events removeObjectForKey:event.lowercaseString];
            } else {
                NSArray<NSString *> *eventsToRemoveHandlers = [self eventNamesForEvent:event];
                for (NSString *eventName in eventsToRemoveHandlers) {
                    [self.events removeObjectForKey:eventName.lowercaseString];
                }
            }
        } else {
            [self.allEvents removeAllObjects];
        }
    });
}


#pragma mark - Events emitting

- (void)emitEventLocally:(NSString *)event, ... {
    
    va_list args;
    va_start(args, event);
    NSMutableArray *parameters = [NSMutableArray array];
    id parameter;
    
    while ((parameter = va_arg(args, id)) != nil) {
        [parameters addObject:parameter];
    }
    va_end(args);
    
    [self emitEventLocally:event withParameters:parameters];
}

- (void)emitEventLocally:(NSString *)event withParameters:(NSArray *)parameters {

    event = event.lowercaseString;
    __block NSArray<NSDictionary *> *eventHandlers = nil;
    
    dispatch_sync(self.eventsAccessQueue, ^{
        eventHandlers = [[self eventHandlersForEvent:event] copy];
        
        for (NSDictionary *data in eventHandlers) {
            if (((NSNumber *)data[kCENEventIsOneTimeHandlerKey]).boolValue) {
                [self.events[event] removeObject:data];
                [self.allEvents removeObject:data];
            }
        }
        
        if (self.events[event] && !self.events[event].count) {
            [self.events removeObjectForKey:event];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSDictionary *data in eventHandlers) {
            [self notifyAbout:event usingHandlerData:data withParameters:parameters];
        }
    });
}

- (void)notifyAbout:(NSString *)event usingHandlerData:(NSDictionary *)data withParameters:(NSArray *)parameters {
        
    BOOL isAnyEventHandler = ((NSNumber *)data[kCENEventIsAnyKey]).boolValue;
    id handler = data[kCENEventHandlerKey];
    if (isAnyEventHandler || ((NSNumber *)data[kCENEventIsWildcardKey]).boolValue) {
        NSUInteger expectedCount = isAnyEventHandler ? ([self superclass] == [CENEventEmitter class] ? 3 : 2) : parameters.count;
        parameters = [@[event] arrayByAddingObjectsFromArray:parameters];
        
        while (parameters.count < expectedCount) {
            parameters = [parameters arrayByAddingObject:[NSNull null]];
        }
    }
    
    if (!parameters.count) {
        ((dispatch_block_t)handler)();
    } else if (parameters.count == 1) {
        ((void(^)(id))handler)([self valueAtIndex:0 fromParametersList:parameters]);
    } else if (parameters.count == 2) {
        ((void(^)(id, id))handler)([self valueAtIndex:0 fromParametersList:parameters], [self valueAtIndex:1 fromParametersList:parameters]);
    } else if (parameters.count == 3) {
        ((void(^)(id, id, id))handler)([self valueAtIndex:0 fromParametersList:parameters],
                                       [self valueAtIndex:1 fromParametersList:parameters],
                                       [self valueAtIndex:2 fromParametersList:parameters]);
    } else if (parameters.count == 4) {
        ((void(^)(id, id, id, id))handler)([self valueAtIndex:0 fromParametersList:parameters],
                                           [self valueAtIndex:1 fromParametersList:parameters],
                                           [self valueAtIndex:2 fromParametersList:parameters],
                                           [self valueAtIndex:3 fromParametersList:parameters]);
    } else if (parameters.count == 5) {
        ((void(^)(id, id, id, id, id))handler)([self valueAtIndex:0 fromParametersList:parameters],
                                               [self valueAtIndex:1 fromParametersList:parameters],
                                               [self valueAtIndex:2 fromParametersList:parameters],
                                               [self valueAtIndex:3 fromParametersList:parameters],
                                               [self valueAtIndex:4 fromParametersList:parameters]);
    }
}


#pragma mark - Misc

- (id)valueAtIndex:(NSUInteger)index fromParametersList:(NSArray *)parameters {
    
    if (index >= parameters.count || [parameters[index] isEqual:[NSNull null]]) {
        return nil;
    }
    
    return parameters[index];
}

- (NSArray<NSDictionary *> *)eventHandlersForEvent:(NSString *)event {
    
    NSMutableArray<NSDictionary *> *handlers = [NSMutableArray arrayWithArray:self.allEvents];
    NSArray *eventNames = [self eventNamesForEvent:event];
    
    for (NSString *eventName in eventNames) {
        [handlers addObjectsFromArray:self.events[eventName]];
    };
    
    return handlers;
}

- (NSArray<NSString *> *)eventNamesForEvent:(NSString *)event {
    
    NSMutableArray<NSString *> *eventNames = [NSMutableArray array];
    NSMutableArray<NSString *> *eventComponents = [[event componentsSeparatedByString:@"."] mutableCopy];
    NSArray<NSString *> *registeredEvents = self.events.allKeys;
    NSUInteger componentsCount = eventComponents.count;
    BOOL isXXWildcardEvent = [event rangeOfString:@".**"].location != NSNotFound;
    BOOL isXWildcardEvent = !isXXWildcardEvent && [event rangeOfString:@".*"].location != NSNotFound;

    if (isXXWildcardEvent || isXWildcardEvent) {
        [eventComponents removeObject:eventComponents.lastObject];
        NSString *eventWithOutWildcard = [[eventComponents componentsJoinedByString:@"."] stringByAppendingString:@"."];
        
        for (NSString *registeredEvent in registeredEvents) {
            if ([registeredEvent isEqualToString:event]) {
                [eventNames addObject:event];
            } else if ([registeredEvent rangeOfString:eventWithOutWildcard].location == 0) {
                NSString *pefixlessEvent = [registeredEvent stringByReplacingOccurrencesOfString:eventWithOutWildcard withString:@""];
                NSUInteger prefixlessEventComponentsCount = [pefixlessEvent componentsSeparatedByString:@"."].count;
                
                if ((isXWildcardEvent && prefixlessEventComponentsCount == 1) || (isXXWildcardEvent && prefixlessEventComponentsCount >= 1)) {
                    [eventNames addObject:registeredEvent];
                }
            }
        }
    } else {
        NSString *nextEventName = event;
        while (nextEventName != nil) {
            NSString *xxEventName = [nextEventName stringByAppendingString:@".**"];
            NSString *xEventName = [nextEventName stringByAppendingString:@".*"];
            
            if ([registeredEvents containsObject:nextEventName]) {
                [eventNames addObject:nextEventName];
            }
            
            if ((componentsCount - eventComponents.count) == 1 && [registeredEvents containsObject:xEventName]) {
                [eventNames addObject:xEventName];
            }
            
            if ((componentsCount - eventComponents.count) >= 1 && [registeredEvents containsObject:xxEventName]) {
                [eventNames addObject:xxEventName];
            }
            
            nextEventName = [self nextEventNameFromComponents:eventComponents];
        }
    }
    
    return eventNames;
}

- (NSString *)nextEventNameFromComponents:(NSMutableArray<NSString *> *)eventComponents {
    
    if (eventComponents.count) {
        [eventComponents removeObject:eventComponents.lastObject];
    }
    
    return eventComponents.count ? [eventComponents componentsJoinedByString:@"."] : nil;
}

#pragma mark -


@end
