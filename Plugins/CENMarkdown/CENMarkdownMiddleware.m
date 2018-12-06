/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMarkdownMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENMarkdownParser+Private.h"
#import "CENMarkdownPlugin.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENMarkdownMiddleware ()


#pragma mark - Information

@property (nonatomic, strong) CENMarkdownParser *parser;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENMarkdownMiddleware


#pragma mark - Information

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    NSString *messageKey = self.configuration[CENMarkdownConfiguration.messageKey];
    id markdownString = data[CENEventData.data][messageKey];
    
    if (![markdownString isKindOfClass:[NSString class]]) {
        block(NO);
        return;
    }
    
    [self.parser parseMarkdownString:markdownString withCompletion:^(id processedString) {
        NSMutableDictionary *mutableData = [data[CENEventData.data] mutableCopy];
        mutableData[self.configuration[CENMarkdownConfiguration.messageKey]] = processedString;
        data[CENEventData.data] = mutableData;
        
        block(NO);
    }];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSDictionary *configuration = self.configuration[CENMarkdownConfiguration.parserConfiguration];
    self.parser = [CENMarkdownParser parserWithConfiguration:(configuration ?: @{})];
}

#pragma mark -


@end
