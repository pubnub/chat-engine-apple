/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMarkdownMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENStructures.h>
#import <CENChatEngine/CEPStructures.h>
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

- (void)runForEvent:(NSString *)event withData:(NSMutableDictionary *)data completion:(void (^)(BOOL rejected))block {
    
    id markdownString = data[CENEventData.data][self.configuration[CENMarkdownConfiguration.messageKey]];
    
    if (![(NSArray *)self.configuration[CENMarkdownConfiguration.events] containsObject:event] ||
        ![markdownString isKindOfClass:[NSString class]]) {
        
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
    
    self.parser = [CENMarkdownParser parserWithConfiguration:(self.configuration[CENMarkdownConfiguration.parserConfiguration] ?: @{})];
}

#pragma mark -


@end
