/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSearchFilterMiddleware.h"
#import "CEPMiddleware+Developer.h"
#import "CENUser.h"


#pragma mark Interface implementation

@implementation CENSearchFilterMiddleware


#pragma mark - Information

+ (NSString *)location {

    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {

    static NSArray<NSString *> *_searchFilterMiddlewareEvents;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _searchFilterMiddlewareEvents = @[@"*"];
    });

    return _searchFilterMiddlewareEvents;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL))block {
    
    BOOL rejected = NO;
    
    if (data) {
        NSString *senderUUID = data[CENEventData.sender];
        
        if (self.configuration[@"sender"]) {
            rejected = ![self.configuration[@"sender"] isEqualToString:senderUUID];
        }
        
        if (!rejected && self.configuration[@"event"]) {
            rejected = ![self.configuration[@"event"] isEqualToString:event];
        }
    }
    
    block(rejected);
}

#pragma mark -


@end
