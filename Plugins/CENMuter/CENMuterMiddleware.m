/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENChat.h>
#import "CENMuterMiddleware.h"
#import "CENMuterExtension.h"
#import "CENMuterPlugin.h"


#pragma mark Interface implementation

@implementation CENMuterMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    CENUser *user = data[CENEventData.sender];
    CENChat *chat = (id)self.object;
    
    if ([data[CENEventData.event] rangeOfString:@"$muter"].location != NSNotFound) {
        block(NO);
        return;
    }
    
    CENMuterExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    BOOL muted = [extension isMutedUser:user];
    
    if (muted) {
        [chat.chatEngine triggerEventLocallyFrom:chat event:@"$muter.eventRejected", data, nil];
    }
        
    block(muted);
}

#pragma mark -


@end
