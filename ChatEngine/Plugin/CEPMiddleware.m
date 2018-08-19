/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPMiddleware+Private.h"
#import "CEPPlugablePropertyStorage+Private.h"
#import "CEPStructures.h"
#import <objc/runtime.h>
#import "CENObject.h"


#pragma mark Externs

CEPMiddlewareLocations CEPMiddlewareLocation = { .emit = @"emit", .on = @"on" };


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CEPMiddleware ()


#pragma mark - Information

@property (nonatomic, nullable, strong) NSDictionary *configuration;

/**
 * @brief  Stores reference on list of events which can't be handled by middleware (after verification).
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *ignoredEvents;

/**
 * @brief  Stores reference on list of events for which middleware already verified ability to handle them.
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *checkedEvents;

@property (nonatomic, assign, getter=shouldHandleAllEvents) BOOL handleAllEvents;

/**
 * @brief  Stores reference on unique identifier of plugin which instantiated this middleware.
 */
@property (nonatomic, copy) NSString *identifier;


#pragma mark -  Initialization and Configuration

/**
 * @brief  Initialize middleware instance.
 *
 * @param identifier    Reference on unique identifier of plugin which provided this middleware.
 * @param configuration Reference on dictionary which is passed during plugin registration.
 *
 * @return Initialized and ready to use plugin instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier configuration:(nullable NSDictionary *)configuration;

#pragma mark -


@end


NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CEPMiddleware


#pragma mark - Information

+ (NSArray<NSString *> *)locations {
    
    static NSArray<NSString *> *_middlewareLocations;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _middlewareLocations = @[CEPMiddlewareLocation.emit, CEPMiddlewareLocation.on];
    });
    
    return _middlewareLocations;
}

+ (NSString *)location {
    
    NSAssert(0, @"%s should be implemented by subclass", __PRETTY_FUNCTION__);
    
    return nil;
}

+ (NSArray<NSString *> *)events {
    
    NSAssert(0, @"%s should be implemented by subclass", __PRETTY_FUNCTION__);
    
    return nil;
}

+ (void)replaceEventsWith:(NSArray<NSString *> *)events {
    
    SEL eventsGetter = NSSelectorFromString(@"events");
    IMP swizzledEventsGetter = imp_implementationWithBlock(^id (Class __unused _self) {
        return events;
    });
    
    Method method = class_getClassMethod(self, eventsGetter);
    method_setImplementation(method, swizzledEventsGetter);
}


#pragma mark -  Initialization and Configuration

+ (instancetype)middlewareWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {
    
    if (!identifier || ![identifier isKindOfClass:[NSString class]] || !identifier.length) {
        return nil;
    }
    
    if (!configuration || ![configuration isKindOfClass:[NSDictionary class]]) {
        configuration = @{};
    }
    
    return [[self alloc] initWithIdentifier:identifier configuration:configuration];
}

- (instancetype)initWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration {
    
    if ((self = [super init])) {
        _ignoredEvents = [NSMutableArray new];
        _checkedEvents = [NSMutableArray new];
        _configuration = configuration;
        _identifier = identifier;
        
        _handleAllEvents = [[[self class] events] containsObject:@"*"];
    }
    
    return self;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)__unused data
         completion:(void(^)(BOOL rejected))block {
    
    block(NO);
}


#pragma mark - Events

- (BOOL)registeredForEvent:(NSString *)event {
    
    NSArray<NSString *> *events = [[self class] events];
    BOOL registeredForEvent = NO;
    
    if ([self.checkedEvents containsObject:event]) {
        registeredForEvent = ![self.ignoredEvents containsObject:event];
    } else if (self.shouldHandleAllEvents) {
        registeredForEvent = YES;
    } else {
        NSArray<NSString *> *eventComponents = [event componentsSeparatedByString:@"."];
        BOOL eventAsPath = eventComponents.count > 1;
        
        for (NSString *registeredEvent in events) {
            if (!eventAsPath) {
                registeredForEvent = [event isEqualToString:registeredEvent];
            } else {
                NSArray<NSString *> *registeredEventComponents = [registeredEvent componentsSeparatedByString:@"."];
                if (registeredEventComponents.count > eventComponents.count) {
                    registeredForEvent = NO;
                } else {
                    registeredForEvent = [self partlyMatchEvent:eventComponents toEvent:registeredEventComponents];
                }
            }
            
            if (registeredForEvent) {
                break;
            }
        }
        
        [self.checkedEvents addObject:event];
    }
    
    if (!registeredForEvent) {
        [self.ignoredEvents addObject:event];
    }
    
    return registeredForEvent;
}

- (BOOL)partlyMatchEvent:(NSArray<NSString *> *)tEvent toEvent:(NSArray<NSString *> *)rEvent {

    __block BOOL partlyMatch = YES;
    
    [tEvent enumerateObjectsUsingBlock:^(NSString *eventComponent, NSUInteger componentIdx, BOOL *stop) {
        NSString *registeredEventComponent = componentIdx < rEvent.count ? rEvent[componentIdx] : rEvent.lastObject;
        
        if (![eventComponent isEqualToString:registeredEventComponent]) {
            if ([registeredEventComponent isEqualToString:@"*"]) {
                partlyMatch = (tEvent.count - rEvent.count) == 0;
            } else {
                partlyMatch = [registeredEventComponent isEqualToString:@"**"];
            }
        }
        
        *stop = !partlyMatch;
    }];
    
    return partlyMatch;
}


#pragma mark - Handlers

- (void)onCreate {
    
    // Default implementation doesn't do anything.
}

- (void)onDestruct {
    
    // Default implementation doesn't do anything.
}


#pragma mark - Properties bind

+ (NSArray<NSString *> *)nonbindableProperties {
    
    return @[
        @"configuration",
        @"identifier",
        @"ignoredEvents",
        @"checkedEvents",
        @"handleAllEvents"
    ];
}

#pragma mark -


@end
