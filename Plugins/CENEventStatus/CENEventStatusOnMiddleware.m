/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEventStatusOnMiddleware.h"
#import <CENChatEngine/CENChatEngine+PluginsDeveloper.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <CENChatEngine/CENEvent.h>
#import <CENChatEngine/CENUser.h>
#import "CENEventStatusPlugin.h"
#import <CENChatEngine/CENMe.h>


#pragma mark Interface implementation

@implementation CENEventStatusOnMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}


#pragma mark - Call

- (void)runForEvent:(NSString *)event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    NSDictionary *eventStatusData = data[CENEventStatusData.data];
    
    if (!eventStatusData) {
        block(NO);
        return;
    }
    
    NSString *eventIdentifier = eventStatusData[CENEventStatusData.identifier];
    CENUser *sender = data[CENEventData.sender];
    
    if ([event isEqualToString:@"$.emitted"]) {
        CENChat *chat = ((CENEvent *)self.object).chat;
        NSString *emittedEvent = @"$.eventStatus.sent";
        eventStatusData = @{ CENEventData.data: eventStatusData };
        
        [chat.chatEngine triggerEventLocallyFrom:chat event:emittedEvent, eventStatusData, nil];
    } else if ([sender isKindOfClass:[CENMe class]] && ![self.object isKindOfClass:[CENEvent class]]) {
        CENChat *chat = (CENChat *)self.object;
        [chat emitEvent:@"$.eventStatus.delivered"
               withData:@{ CENEventStatusData.identifier: eventIdentifier }];
    }
    
    block(NO);
}

#pragma mark -


@end
