/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENStateRestoreAugmentationMiddleware.h"
#import "CENStateRestoreAugmentationPlugin.h"
#import "CEPMiddleware+Developer.h"
#import "CENUser+Private.h"


#pragma mark Interface implementation

@implementation CENStateRestoreAugmentationMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    static NSArray<NSString *> *_stateRestoreAugmentationMiddlewareEvents;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _stateRestoreAugmentationMiddlewareEvents = @[@"*"];
    });
    
    return _stateRestoreAugmentationMiddlewareEvents;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL))block {
    
    if ([event isEqualToString:@"$.state"]) {
        block(NO);
        return;
    }
    
    if (data[CENEventData.sender] && [data[CENEventData.sender] isKindOfClass:[CENUser class]]) {
        CENUser *sender = (CENUser *)data[CENEventData.sender];
        CENChat *chat = self.configuration[CENStateRestoreAugmentationConfiguration.chat];
        
        [sender restoreStateForChat:chat withCompletion:^(NSDictionary *__unused state) {
            block(NO);
        }];
    } else {
        block(NO);
    }
}

#pragma mark -


@end
