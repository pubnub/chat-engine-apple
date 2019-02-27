/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import "CENEventStatusExtension.h"
#import "CENEventStatusPlugin.h"


#pragma mark Interface implementation

@implementation CENEventStatusExtension


#pragma mark - Seen

- (void)readEvent:(NSDictionary *)event {
    
    NSDictionary *eventStatusData = event[CENEventStatusData.data];
    
    if (eventStatusData) {
        NSString *identifier = eventStatusData[CENEventStatusData.identifier];
        CENChat *chat = (CENChat *)self.object;
        
        [chat emitEvent:@"$.eventStatus.read"
               withData:@{ CENEventStatusData.identifier: identifier }];
    }
}

#pragma mark -


@end
