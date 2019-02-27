/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatAugmentationMiddleware.h"
#import "CEPMiddleware+Developer.h"
#import "CENObject+Private.h"


#pragma mark Interface implementation

@implementation CENChatAugmentationMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    static NSArray<NSString *> *_chatAugmentationMiddlewareEvents;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _chatAugmentationMiddlewareEvents = @[@"*"];
    });
    
    return _chatAugmentationMiddlewareEvents;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL))block {
    
    if (!data[CENEventData.chat] || ![data[CENEventData.chat] isKindOfClass:[CENObject class]]) {
        data[CENEventData.chat] = [self.object defaultStateChat];
    }
    
    block(NO);
}

#pragma mark -


@end
