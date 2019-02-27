#import "CEDummyOnMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>


#pragma mark Statics

static NSArray<NSString *> *handledEvents = nil;


#pragma mark - Protected interface declaration

@interface CEDummyOnMiddleware ()


#pragma mark - Information

@property (nonatomic, strong) NSTimer *testTimer;


#pragma mark - Handlers

- (void)handleTimer:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEDummyOnMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    if (!handledEvents) {
        handledEvents = @[@"*"];
    }
    
    return handledEvents;
}


#pragma mark - Configuration

+ (void)resetEventNames:(NSArray<NSString *> *)events {
    
    handledEvents = [events copy];
}


#pragma mark - Call

- (void)runForEvent:(NSString *)event withData:(NSMutableDictionary *)data completion:(void (^)(BOOL rejected))block {
    
    data[@"broadcast"] = @YES;
    
    block(NO);
}


#pragma mark - Handlers

- (void)onCreate {
    
    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:1000.f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (void)handleTimer:(NSTimer *)timer {
    
}

#pragma mark -


@end
