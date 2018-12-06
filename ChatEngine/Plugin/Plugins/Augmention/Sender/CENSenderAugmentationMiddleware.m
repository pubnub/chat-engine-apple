/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENSenderAugmentationMiddleware.h"
#import "CENChatEngine+UserInterface.h"
#import "CEPMiddleware+Developer.h"


#pragma mark Interface implementation

@implementation CENSenderAugmentationMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    static NSArray<NSString *> *_senderAugmentationMiddlewareEvents;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _senderAugmentationMiddlewareEvents = @[@"*"];
    });
    
    return _senderAugmentationMiddlewareEvents;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL))block {
    
    if ([data[CENEventData.sender] isKindOfClass:[NSString class]]) {
        NSString *uuid = data[CENEventData.sender];
        data[CENEventData.sender] = [self.object.chatEngine createUserWithUUID:uuid state:@{ }];
    }
    
    block(NO);
}

#pragma mark -


@end
