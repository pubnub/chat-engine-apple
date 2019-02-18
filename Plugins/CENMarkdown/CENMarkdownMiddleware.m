/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENMarkdownMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENMarkdownParser+Private.h"
#import "CENMarkdownPlugin.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENMarkdownMiddleware ()


#pragma mark - Information

/**
 * @brief Bundled simple Markdown markup processor.
 */
@property (nonatomic, strong) CENMarkdownParser *parser;


#pragma mark - Misc

/**
 * @brief Update value in \c dictionary.
 *
 * @param value Object which should be stored at specified location.
 * @param keyPath Key or path to location where \c value should be stored.
 * @param dictionary \a NSMutableDictionary with mutable content which should be modified.
 */
- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary;

/**
 * @brief Create mutable copy from \a NSDictionary by replacing other \a NSDictionary values in it
 * with \a NSMutableDictionary.
 *
 * @param dictionary \a NSDictionary from which deep mutable copy should be created.
 *
 * @return Mutable dictionary with mutable content.
 */
- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary;

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
    
    NSString *parsedMessageKey = self.configuration[CENMarkdownConfiguration.parsedMessageKey];
    CENMarkdownParserCallback parser = self.configuration[CENMarkdownConfiguration.parser];
    NSString *messageKey = self.configuration[CENMarkdownConfiguration.messageKey];
    id markdownString = [data[CENEventData.data] valueForKeyPath:messageKey];
    
    if (![markdownString isKindOfClass:[NSString class]]) {
        block(NO);
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    void(^parseCompletion)(id) = ^(id processedString) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        NSMutableDictionary *payloadData = nil;
        payloadData = [strongSelf dictionaryDeepMutableFrom:data[CENEventData.data]];
        
        [strongSelf setValue:processedString forKeyPath:parsedMessageKey inDictionary:payloadData];
        data[CENEventData.data] = [payloadData copy];
        
        block(NO);
    };
    
    if (parser) {
        parser(markdownString, parseCompletion);
    } else {
        [self.parser parseMarkdownString:markdownString withCompletion:parseCompletion];
    }
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSDictionary *configuration = self.configuration[CENMarkdownConfiguration.parserConfiguration];
    void(^parser)(NSString *, void(^)(id)) = self.configuration[CENMarkdownConfiguration.parser];
    
    if (!parser) {
        self.parser = [CENMarkdownParser parserWithConfiguration:(configuration ?: @{})];
    }
}


#pragma mark - Misc

- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary {
    
    NSArray<NSString *> *pathComponents = [keyPath componentsSeparatedByString:@"."];
    
    if (pathComponents.count > 1) {
        NSRange pathSubRange = NSMakeRange(0, pathComponents.count - 1);
        NSArray *pathSubComponents = [pathComponents subarrayWithRange:pathSubRange];
        NSMutableDictionary *currentRoot = dictionary;
        
        for (NSString *key in pathSubComponents) {
            if (!currentRoot[key]) {
                currentRoot[key] = [NSMutableDictionary new];
            }
            
            currentRoot = currentRoot[key];
        }
        
        [currentRoot setValue:value forKeyPath:pathComponents.lastObject];
    } else {
        [dictionary setValue:value forKeyPath:keyPath];
    }
}

- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary {
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    for (NSString *key in dictionary) {
        if ([dictionary[key] isKindOfClass:[NSDictionary class]]) {
            mutable[key] = [self dictionaryDeepMutableFrom:dictionary[key]];
        }
    }
    
    return mutable;
}

#pragma mark -


@end
