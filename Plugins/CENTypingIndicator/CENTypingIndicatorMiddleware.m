/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENTypingIndicatorMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENTypingIndicatorExtension.h"
#import <CENChatEngine/CENChat.h>


#pragma mark Interface implementation

@implementation CENTypingIndicatorMiddleware


#pragma mark - Information

+ (NSArray<NSString *> *)events {

    return @[@"*"];
}

+ (NSString *)location {

    return CEPMiddlewareLocation.emit;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    CENChat *chat = data[CENEventData.chat];
    
    CENTypingIndicatorExtension *extension = [chat extensionWithIdentifier:[self identifier]];
    [extension stopTyping];
    
    block(NO);
}

#pragma mark -


@end
