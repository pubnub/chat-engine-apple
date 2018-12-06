/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENEventEmitter+Private.h"
#import "CENEventEmitter+Interface.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENEventEmitter+BuilderInterface.h"
#import "CENEmittedEvent+Private.h"

#endif // CHATENGINE_USE_BUILDER_INTERFACE


#pragma mark Static

/**
 * @brief Key under which stored whether \c handler added for wildcard event or not.
 */
static NSString * const kCENEventIsWildcardKey = @"iw";

/**
 * @brief Key under which stored whether \c handler should handle any event or not.
 */
static NSString * const kCENEventIsAnyKey = @"ae";

/**
 * @brief Key under which actual event handling GCD block is stored.
 */
static NSString * const kCENEventHandlerKey = @"h";

/**
 * @brief Key under which stored flag with information on whether \c handler block should be called
 *     only once or not.
 */
static NSString * const kCENEventIsOneTimeHandlerKey = @"oth";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENEventEmitter ()


#pragma mark - Information

/**
 * @brief List of events handlers for wildcard (\c *) event.
 */
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *allEvents;

/**
 * @brief \a NSDictionary where event names mapped to list of handlers for those events.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary *> *> *events;

/**
 * @brief Queue which is used to serialize access to shared object information.
 */
@property (nonatomic, readonly, strong) dispatch_queue_t eventsAccessQueue;


#pragma mark - Handlers addition

/**
 * @brief Add handler \c block for specified \c event which may fire only once (depending from
 * passed argument to \c shouldNotifyOnce).
 *
 * @param event Name of event which should be handled by \c block.
 * @param shouldNotifyOnce Whether passed \c block should be called only once for specified
 *     \c event or not.
 * @param block Block / closure which will be called when specified \c event emitted.
 */
- (void)handleEvent:(NSString *)event
                once:(BOOL)shouldNotifyOnce
    withHandlerBlock:(CENEventHandlerBlock)block;


#pragma mark - Events emitting

/**
 * @brief Call passed \c handler with list of \c parameters.
 *
 * @param event Name of event about which handler should be notified.
 * @param data Listener's data object.
 * @param parameters List of parameters which should be passed to \c handler. Each value will be
 *     assigned to corresponding place in \c handler's block argument.
 */
- (void)notifyAbout:(NSString *)event
   usingHandlerData:(NSDictionary *)data
     withParameters:(NSArray *)parameters;


#pragma mark - Misc

/**
 * @brief Search for event handler subscribed to specific \c event.
 *
 * @param event Name of event for which list of handlers should be found.
 *
 * @return List of \c event handlers' data which can be used to notify handlers or for clean up.
 */
- (NSArray<NSDictionary *> *)eventHandlersForEvent:(NSString *)event;

/**
 * @brief Match passed \c event against registered events list to find those which has complete
 * or partial (in case if \c event has wildcards) match.
 *
 * @param event \c event name which should be searched in registered events.
 *
 * @return List of registered events based on \c event name.
 */
- (NSArray<NSString *> *)eventNamesForEvent:(NSString *)event;

/**
 * @brief Match passed \c event against registered events list to find those which has partial
 * match.
 *
 * @param event \c event name which should be searched in registered events.
 *
 * @return List of registered events based on \c event name.
 */
- (NSArray<NSString *> *)eventNamesForWildcardEvent:(NSString *)event;

/**
 * @brief Calculate next level of \c event name.
 *
 * @param eventComponents Mutable array which contain event name components
 *     (\c event name separated by '.').
 *
 * @return Part of original event name, which is created from concatination of rest of elements from
 *     \c eventComponents.
 */
- (nullable NSString *)nextEventNameFromComponents:(NSMutableArray<NSString *> *)eventComponents;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENEventEmitter


#pragma mark - Information

- (NSArray<NSString *> *)eventNames {
    
    __block NSMutableArray<NSString *> *eventNames = nil;
    
    dispatch_sync(self.eventsAccessQueue, ^{
        eventNames = [NSMutableArray arrayWithArray:self.events.allKeys];
        
        if (self.allEvents.count) {
            [eventNames insertObject:@"*" atIndex:0];
        }
    });
    
    return eventNames;
}


#pragma mark - Initialization and Configuration

- (instancetype)init {
    
    if ((self = [super init])) {
        NSString *identifier = [NSString stringWithFormat:@"com.chatengine.emitter.%p", self];
        _eventsAccessQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_SERIAL);
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
- (CENEventEmitter * (^)(NSString *event, CENEventHandlerBlock handlerBlock))on {
    
    return ^(NSString *event, CENEventHandlerBlock handlerBlock) {
        [self handleEvent:event withHandlerBlock:handlerBlock];
        return self;
    };
}

- (CENEventEmitter * (^)(CENEventHandlerBlock handlerBlock))onAny {
    
    return ^(CENEventHandlerBlock handlerBlock) {
        [self handleEvent:@"*" withHandlerBlock:handlerBlock];
        return self;
    };
}

- (CENEventEmitter * (^)(NSString *event, CENEventHandlerBlock handlerBlock))once {
    
    return ^(NSString *event, CENEventHandlerBlock handlerBlock) {
        [self handleEventOnce:event withHandlerBlock:handlerBlock];
        return self;
    };
}
#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (void)handleEvent:(NSString *)event withHandlerBlock:(CENEventHandlerBlock)block {
    
    [self handleEvent:event once:NO withHandlerBlock:block];
}

- (void)handleEventOnce:(NSString *)event withHandlerBlock:(CENEventHandlerBlock)block {
    
    [self handleEvent:event once:YES withHandlerBlock:block];
}

- (void)handleEvent:(NSString *)event
                once:(BOOL)shouldNotifyOnce
    withHandlerBlock:(CENEventHandlerBlock)block {
    
    event = event.lowercaseString;
    BOOL hasWildcard = [event rangeOfString:@"*"].location != NSNotFound;
    BOOL isAllEvents = [event isEqualToString:@"*"];
    
    dispatch_async(self.eventsAccessQueue, ^{
        NSMutableArray<NSDictionary *> *eventHandlers = (!isAllEvents ? self.events[event]
                                                                      : self.allEvents);
        
        if (!eventHandlers && !isAllEvents) {
            eventHandlers = [NSMutableArray array];
            self.events[event] = eventHandlers;
        }
        
        [eventHandlers addObject:@{
            kCENEventIsAnyKey: @(isAllEvents),
            kCENEventIsWildcardKey: @(!isAllEvents && hasWildcard),
            kCENEventHandlerKey: block,
            kCENEventIsOneTimeHandlerKey: @(shouldNotifyOnce)
        }];
    });
}


#pragma mark - Handlers removal

#if CHATENGINE_USE_BUILDER_INTERFACE
- (CENEventEmitter * (^)(NSString *event, CENEventHandlerBlock handlerBlock))off {
    
    return ^(NSString *event, CENEventHandlerBlock handlerBlock) {
        [self removeHandler:handlerBlock forEvent:event];
        return self;
    };
}

- (CENEventEmitter * (^)(CENEventHandlerBlock handlerBlock))offAny {
    
    return ^(CENEventHandlerBlock handlerBlock) {
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

- (void)removeHandler:(CENEventHandlerBlock)block forEvent:(NSString *)event {
    
    event = event.lowercaseString;
    BOOL isAllEvents = [event isEqualToString:@"*"];
    
    dispatch_sync(self.eventsAccessQueue, ^{
        __block NSDictionary *dataForRemoval = nil;
        NSMutableArray<NSDictionary *> *eventHandlers = (!isAllEvents ? self.events[event]
                                                                      : self.allEvents);
        
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

- (void)notifyAbout:(NSString *)event
   usingHandlerData:(NSDictionary *)data
     withParameters:(NSArray *)parameters {

    CENEventHandlerBlock handler = data[kCENEventHandlerKey];
    CENEventEmitter *emitter = self;

    if ([self superclass] == [CENEventEmitter class]) {
        if ([parameters.firstObject isKindOfClass:[CENEventEmitter class]]) {
            emitter = parameters.firstObject;
            parameters = [parameters subarrayWithRange:NSMakeRange(1, parameters.count - 1)];
        }
    }

    id emittedData = parameters.count ? parameters.firstObject : nil;

    handler([CENEmittedEvent eventWithName:event data:emittedData emittedBy:emitter]);
}


#pragma mark - Misc

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
    NSMutableArray<NSString *> *components = [[event componentsSeparatedByString:@"."] mutableCopy];
    NSArray<NSString *> *registeredEvents = self.events.allKeys;
    NSUInteger componentsCount = components.count;
    BOOL isXXWildcard = [event rangeOfString:@".**"].location != NSNotFound;
    BOOL isXWildcard = !isXXWildcard && [event rangeOfString:@".*"].location != NSNotFound;

    if (isXXWildcard || isXWildcard) {
        [eventNames addObjectsFromArray:[self eventNamesForWildcardEvent:event]];
    } else {
        NSString *nextEventName = event;
        
        while (nextEventName != nil) {
            NSString *xxEventName = [nextEventName stringByAppendingString:@".**"];
            NSString *xEventName = [nextEventName stringByAppendingString:@".*"];
            
            if ([registeredEvents containsObject:nextEventName]) {
                [eventNames addObject:nextEventName];
            }
            
            if ((componentsCount - components.count) == 1 &&
                [registeredEvents containsObject:xEventName]) {
                
                [eventNames addObject:xEventName];
            }
            
            if ((componentsCount - components.count) >= 1 &&
                [registeredEvents containsObject:xxEventName]) {
                
                [eventNames addObject:xxEventName];
            }
            
            nextEventName = [self nextEventNameFromComponents:components];
        }
    }
    
    return eventNames;
}

- (NSArray<NSString *> *)eventNamesForWildcardEvent:(NSString *)event {
    
    NSMutableArray<NSString *> *eventNames = [NSMutableArray array];
    NSMutableArray<NSString *> *components = [[event componentsSeparatedByString:@"."] mutableCopy];
    BOOL isXXWildcard = [event rangeOfString:@".**"].location != NSNotFound;
    BOOL isXWildcard = !isXXWildcard && [event rangeOfString:@".*"].location != NSNotFound;
    NSArray<NSString *> *registeredEvents = self.events.allKeys;
    
    [components removeObject:components.lastObject];
    NSString *cleared = [[components componentsJoinedByString:@"."] stringByAppendingString:@"."];
    
    for (NSString *registeredEvent in registeredEvents) {
        if ([registeredEvent isEqualToString:event]) {
            [eventNames addObject:event];
        } else if ([registeredEvent rangeOfString:cleared].location == 0) {
            NSString *prefixless = [registeredEvent stringByReplacingOccurrencesOfString:cleared
                                                                             withString:@""];
            NSUInteger prefixlessCount = [prefixless componentsSeparatedByString:@"."].count;
            
            if ((isXWildcard && prefixlessCount == 1) || (isXXWildcard && prefixlessCount >= 1)) {
                [eventNames addObject:registeredEvent];
            }
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
