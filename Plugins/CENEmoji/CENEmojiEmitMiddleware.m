/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENEmojiMiddleware+Private.h"
#import "CENEmojiEmitMiddleware.h"
#import "CENEmojiPlugin.h"


#pragma mark Interface implementation

@implementation CENEmojiEmitMiddleware


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
    
    NSString *messageKey = self.configuration[CENEmojiConfiguration.messageKey];
    id message = [(NSDictionary *)data[CENEventData.data] valueForKeyPath:messageKey];
    NSDictionary *emojiMap = [[self class] emojiToTextMap];
    NSMutableString *mutableMessage = nil;
    NSUInteger numberOfReplacements = 0;
    
    if ((![message isKindOfClass:[NSString class]] &&
         ![message isKindOfClass:[NSAttributedString class]]) || !((NSString *)message).length) {
        
        block(NO);
        return;
    }
    
    if ([message isKindOfClass:[NSAttributedString class]]) {
        mutableMessage = [[(NSAttributedString *)message string] mutableCopy];
    } else {
        mutableMessage = [message mutableCopy];
    }
    
    for (NSString *emoji in emojiMap) {
        if ([mutableMessage rangeOfString:emoji].location != NSNotFound) {
            NSRange searchRange = NSMakeRange(0, mutableMessage.length);
            NSString *textRepresentation = emojiMap[emoji];
            
            NSUInteger replaced = [mutableMessage replaceOccurrencesOfString:emoji
                                                                  withString:textRepresentation
                                                                     options:NSCaseInsensitiveSearch
                                                                       range:searchRange];
            numberOfReplacements += replaced;
        }
    }
    
    if (numberOfReplacements > 0) {
        NSMutableDictionary *payloadData = [self dictionaryDeepMutableFrom:data[CENEventData.data]];
        
        [self setValue:[mutableMessage copy] forKeyPath:messageKey inDictionary:payloadData];
        data[CENEventData.data] = payloadData;
    }
    
    block(NO);
}

#pragma mark -


@end
