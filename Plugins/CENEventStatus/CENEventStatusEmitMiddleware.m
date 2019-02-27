/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEventStatusEmitMiddleware.h"
#import <CENChatEngine/CENChatEngine+PluginsDeveloper.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENChat.h>
#import "CENEventStatusPlugin.h"


#pragma mark Interface implementation

@implementation CENEventStatusEmitMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.emit;
}

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    if (data[CENEventStatusData.data]) {
        block(NO);
        return;
    }
    
    CENChat *chat = (CENChat *)self.object;
    data[CENEventStatusData.data] = @{ CENEventStatusData.identifier: data[CENEventData.eventID] };
    
    NSString *createdEvent = @"$.eventStatus.created";
    NSDictionary *eventStatusData = @{ CENEventData.data: data[CENEventStatusData.data] };
    
    [chat.chatEngine triggerEventLocallyFrom:chat event:createdEvent, eventStatusData, nil];
    
    block(NO);
}

#pragma mark -


@end
