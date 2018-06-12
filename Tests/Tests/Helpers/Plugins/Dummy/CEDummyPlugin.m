/**
 * @author Serhii Mamontov
 * @since 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEDummyPlugin.h"
#import <CENChatEngine/ChatEngine.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CEPStructures.h>
#import "CEDummyExtension.h"


#pragma mark Statics

static NSArray<Class> *sharedClassesWithExtensions = nil;
static NSDictionary<NSString *,NSArray<Class> *> *sharedMiddlewareLocationClasses = nil;


#pragma mark - Interface implementation

@implementation CEDummyPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"testPlugin";
}

+ (NSArray<Class> *)classesWithExtensions {
    
    return sharedClassesWithExtensions;
}

+ (void)setClassesWithExtensions:(NSArray<Class> *)classesWithExtensions {
    
    sharedClassesWithExtensions = classesWithExtensions;
}

+ (NSDictionary<NSString *,NSArray<Class> *> *)middlewareLocationClasses {
    
    return sharedMiddlewareLocationClasses;
}

+ (void)setMiddlewareLocationClasses:(NSDictionary<NSString *,NSArray<Class> *> *)middlewareLocationClasses {
    
    sharedMiddlewareLocationClasses = middlewareLocationClasses;
}

+ (NSDictionary<NSString *,NSArray<NSString *> *> *)middlewareLocationEvents {
    
    NSMutableDictionary *map = [NSMutableDictionary new];
    map[CEPMiddlewareLocation.on] = CEDummyOnMiddleware.events;
    map[CEPMiddlewareLocation.emit] = CEDummyEmitMiddleware.events;
    
    return map;
}

+ (void)setMiddlewareLocationEvents:(NSDictionary<NSString *,NSArray<NSString *> *> *)middlewareLocationEvents {
    
    [CEDummyOnMiddleware resetEventNames:middlewareLocationEvents[CEPMiddlewareLocation.on]];
    [CEDummyEmitMiddleware resetEventNames:middlewareLocationEvents[CEPMiddlewareLocation.emit]];
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    return [[[self class] classesWithExtensions] containsObject:[object class]] ? [CEDummyExtension class] : nil;
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object {
    
    Class middlewareClass = nil;
    
    if ([[[self class] middlewareLocationClasses][location] containsObject:[object class]]) {
        middlewareClass = ([location isEqualToString:CEPMiddlewareLocation.on] ? [CEDummyOnMiddleware class]
                                                                               : [CEDummyEmitMiddleware class]);
    }
    
    return middlewareClass;
}

#pragma mark -


@end
